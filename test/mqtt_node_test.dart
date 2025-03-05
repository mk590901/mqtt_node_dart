import 'dart:math';

import 'package:mqtt_node/mqtt_node.dart';
import 'package:mqtt_node/slicer/slicer.dart';
import 'package:test/test.dart';


String randomString(int length) {
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

void main() {
  test('slicer', () {
    Slicer slicer = Slicer('1234', 64);
    String message = randomString(300);

    List<String> bundle = slicer.chunkMessage('test.txt', message);
    expect(bundle.length, 5);

    String out = slicer.messagesAssembly(bundle);
    expect(message, equals(out));

    //expect(run(), 42);
  });
}
