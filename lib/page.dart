import 'dart:async';
import 'package:balsas/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter_view_controller/flutter_view_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalsasController extends Controller {
  Timer? _timer;
  Timer? _countdownTimer;
  Notifier<int> secondsRemaining = Notifier(60);
  Notifier<bool> load = Notifier(true);
  Notifier<int> timeSantos = Notifier(0);
  Notifier<String> timeSantosSpan = Notifier<String>('');
  Notifier<String> weatherSantos = Notifier<String>('');
  Notifier<int> timeGuaruja = Notifier(0);
  Notifier<String> timeGuarujaSpan = Notifier<String>('');
  Notifier<String> weatherGuaruja = Notifier<String>('');
  Notifier<String> notice = Notifier<String>('');
  int timeToReset = 0;
  final Map<String, String> iconMap = const {
    'Claro': 'assets/image/sol.png',
    'parcialmente-nublado': 'assets/image/encoberto.png',
    'Encoberto': 'assets/image/encoberto.png',
    'Garoa': 'assets/image/chuva.png',
  };

  @override
  void onInit() {
    reset();
  }

  reset() async {
    final prefs = await SharedPreferences.getInstance();
    timeToReset = prefs.getInt('updateInterval') ?? 60;
    fetchData();
    secondsRemaining.value = timeToReset;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        fetchData();
        secondsRemaining.value = timeToReset;
      }
    });
  }

  Future<void> fetchData() async {
    load.value = true;
    final response = await http.get(Uri.parse(
        'https://semil.sp.gov.br/travessias/travessias-automoveis/santos-guaruja/'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var timeSantosText =
          document.getElementById('espera1')?.text.trim() ?? '0';
      var timeGuarujaText =
          document.getElementById('espera2')?.text.trim() ?? '0';
      timeSantos.value =
          int.tryParse(timeSantosText.replaceAll(RegExp(r'\D'), '')) ?? 0;
      timeGuaruja.value =
          int.tryParse(timeGuarujaText.replaceAll(RegExp(r'\D'), '')) ?? 0;
      timeSantosSpan.value =
          document.querySelector('span.time')?.text.trim() ?? '';
      timeGuarujaSpan.value =
          document.querySelector('span.time')?.text.trim() ?? '';
      var clima1ElementSantos = document.getElementById('clima1');
      weatherSantos.value =
          clima1ElementSantos?.attributes['title'] ?? 'Não encontrado';
      var climaElementGuaruja = document.getElementById('clima2');
      weatherGuaruja.value =
          climaElementGuaruja?.attributes['title'] ?? 'Não encontrado';
      var noticeBox = document.getElementById('avisoBox');
      notice.value = noticeBox?.text.trim() ?? 'Não encontrado';
      load.value = false;
    } else {
      throw Exception('Falha ao carregar a página');
    }
  }

  Future<void> _goPage(BuildContext context) async {
    // ignore: unused_local_variable
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    reset();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
  }
}

class BalsasView extends ViewOf<BalsasController> {
  BalsasView({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travessia das Balsas'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 10),
            child: Transform.scale(
              scale: 0.9,
              child: IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).hintColor),
                onPressed: () => controller._goPage(context),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: controller.load.show(
          (value) => value
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height(12)),
                    Container(
                      width: size.width(90),
                      height: size.height(6),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Santos',
                              style: TextStyle(
                                  fontSize: 26,
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(width: size.width(4)),
                          Image.asset(
                            controller
                                    .iconMap[controller.weatherSantos.value] ??
                                'assets/icons/error.png',
                            width: size.width(7),
                            height: size.height(7),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: size.width(90),
                      height: size.height(6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Theme.of(context).cardColor, width: 1),
                      ),
                      child: Text(
                        '${controller.timeSantos.value} ${controller.timeSantosSpan.value}',
                        style: controller.timeSantos.value < 29
                            ? TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).highlightColor,
                              )
                            : TextStyle(
                                fontSize: 24,
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ),
                    SizedBox(height: size.height(7)),
                    Container(
                      width: size.width(90),
                      height: size.height(6),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Guarujá',
                              style: TextStyle(
                                  fontSize: 26,
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(width: size.width(4)),
                          Image.asset(
                            controller
                                    .iconMap[controller.weatherGuaruja.value] ??
                                'assets/icons/error.png',
                            width: size.width(7),
                            height: size.height(7),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: size.width(90),
                      height: size.height(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Theme.of(context).cardColor, width: 1),
                      ),
                      child: Text(
                        '${controller.timeGuaruja.value} ${controller.timeGuarujaSpan.value}',
                        style: controller.timeSantos.value < 29
                            ? TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).highlightColor,
                              )
                            : TextStyle(
                                fontSize: 24,
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Text('Avisos',
                        style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).primaryColor)),
                    const SizedBox(height: 1),
                    Container(
                      width: size.width(90),
                      height: size.height(24),
                      padding: EdgeInsets.all(size.width(3)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(controller.notice.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    controller.secondsRemaining.show(
                      (value) => SizedBox(
                        width: size.width(100),
                        height: size.height(8),
                        child: Center(
                          child: Text(
                            value < 10
                                ? 'Atualiza em: 0$value'
                                : 'Atualiza em: $value',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
