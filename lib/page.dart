import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter_view_controller/flutter_view_controller.dart';

class BalsasController extends Controller {
  Timer? _timer;
  Timer? _countdownTimer;
  Notifier<int> secondsRemaining = Notifier(60); // Mostrador de tempo

  Notifier<bool> load = Notifier(true);
  Notifier<int> timeSantos = Notifier(0);
  Notifier<String> timeSantosSpan = Notifier<String>('');
  Notifier<String> weatherSantos = Notifier<String>('');
  Notifier<int> timeGuaruja = Notifier(0);
  Notifier<String> timeGuarujaSpan = Notifier<String>('');
  Notifier<String> weatherGuaruja = Notifier<String>('');
  Notifier<String> notice = Notifier<String>('');

  @override
  void onInit() {
    fetchData();
    // Iniciar o contador de atualização a cada 60 segundos
    _timer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      fetchData();
      secondsRemaining.value = 60; // Reseta o contador
    });
    // Iniciar o timer de contagem regressiva
    _startCountdown();
  }

  // Método para iniciar o contador de segundos restantes
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        secondsRemaining.value = 60; // Reseta quando chega a zero
      }
    });
  }

  Future<void> fetchData() async {
    load.value = true;
    final response = await http.get(Uri.parse(
        'https://semil.sp.gov.br/travessias/travessias-automoveis/santos-guaruja/'));

    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);

      // Convertendo timeSantos e timeGuaruja de String para int
      var timeSantosText =
          document.getElementById('espera1')?.text.trim() ?? '0';
      var timeGuarujaText =
          document.getElementById('espera2')?.text.trim() ?? '0';

      // Parseando os textos para int, garantindo que sejam números válidos
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

  @override
  void onClose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
  }
}

class BalsasView extends ViewOf<BalsasController> {
  BalsasView({super.key, required super.controller, super.size});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travessia das Balsas',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange[700],
      ),
      body: Center(
        child: controller.load.show(
          (value) => value
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70),
                    Text('Santos',
                        style:
                            TextStyle(fontSize: 26, color: Colors.blue[800])),
                    const SizedBox(height: 3.5),
                    Container(
                      width: size.width(90),
                      height: size.height(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${controller.timeSantos.value} ${controller.timeSantosSpan.value}',
                            style: controller.timeSantos.value < 29
                                ? TextStyle(
                                    fontSize: 24, color: Colors.blue[800])
                                : TextStyle(
                                    fontSize: 24,
                                    color: Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                          ),
                          Text(
                            controller.weatherSantos.value,
                            style: TextStyle(
                                fontSize: 24, color: Colors.blue[800]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text('Guarujá',
                        style:
                            TextStyle(fontSize: 26, color: Colors.blue[800])),
                    const SizedBox(height: 3.5),
                    Container(
                        width: size.width(90),
                        height: size.height(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${controller.timeGuaruja.value} ${controller.timeGuarujaSpan.value}',
                              style: controller.timeSantos.value < 29
                                  ? TextStyle(
                                      fontSize: 24, color: Colors.blue[800])
                                  : TextStyle(
                                      fontSize: 24,
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                            ),
                            Text(
                              controller.weatherGuaruja.value,
                              style: TextStyle(
                                  fontSize: 24, color: Colors.blue[800]),
                            ),
                          ],
                        )),
                    const SizedBox(height: 45),
                    Text('Aviso',
                        style:
                            TextStyle(fontSize: 24, color: Colors.blue[900])),
                    const SizedBox(height: 1),
                    Container(
                      width: size.width(90),
                      height: size.height(14),
                      padding: EdgeInsets.all(size.width(3)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(controller.notice.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    controller.secondsRemaining.show(
                      (value) => Container(
                        width: size.width(100),
                        height: size.height(8),
                        color: Colors.orange,
                        // margin: EdgeInsets.only(bottom: size.height(1)),
                        child: Center(
                          child: Text(
                            value < 10
                                ? 'Atualiza em: 0$value'
                                : 'Atualiza em: $value', // Mostrando o tempo restante
                            style: const TextStyle(fontSize: 18),
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
