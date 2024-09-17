import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter_view_controller/flutter_view_controller.dart';

class BalsasController extends Controller {
  // late Future<Map<String, dynamic>> data;

  Notifier<bool> load = Notifier(true);
  Notifier<String> timeSantos = Notifier<String>('');
  Notifier<String> timeSantosSpan = Notifier<String>('');
  Notifier<String> weatherSantos = Notifier<String>('');
  //
  Notifier<String> timeGuaruja = Notifier<String>('');
  Notifier<String> timeGuarujaSpan = Notifier<String>('');
  Notifier<String> weatherGuaruja = Notifier<String>('');
  //
  Notifier<String> notice = Notifier<String>('');

  @override
  void onInit() {
    fetchData();
  }

  Future<void> fetchData() async {
    load.value = true;
    final response = await http.get(Uri.parse(
        'https://semil.sp.gov.br/travessias/travessias-automoveis/santos-guaruja/'));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      timeSantos.value =
          document.getElementById('espera1')?.text.trim() ?? 'Não encontrado';
      timeSantosSpan.value =
          document.querySelector('span.time')?.text.trim() ?? '';
      timeGuaruja.value =
          document.getElementById('espera2')?.text.trim() ?? 'Não encontrado';
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
  void onClose() {}
}

class BalsasView extends ViewOf<BalsasController> {
  BalsasView({super.key, required super.controller, super.size});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travessia das Balsas'),
        centerTitle: true,
        backgroundColor: Colors.orange,
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
                      style: TextStyle(fontSize: 26, color: Colors.blue[800])),
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
                          style:
                              TextStyle(fontSize: 24, color: Colors.blue[800]),
                        ),
                        Text(
                          controller.weatherSantos.value,
                          style:
                              TextStyle(fontSize: 24, color: Colors.blue[800]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text('Guarujá',
                      style: TextStyle(fontSize: 26, color: Colors.blue[800])),
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
                            style: TextStyle(
                                fontSize: 24, color: Colors.blue[800]),
                          ),
                          Text(
                            controller.weatherGuaruja.value,
                            style: TextStyle(
                                fontSize: 24, color: Colors.blue[800]),
                          ),
                        ],
                      )),
                  const SizedBox(height: 30),
                  const Text('Aviso:',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  Text(controller.notice.value,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                ],
              ),
      )),
    );
  }
}
