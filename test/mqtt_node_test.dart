import 'dart:math';

import 'package:mqtt_node/mqtt_node.dart';
import 'package:mqtt_node/slicer/chunks_wrapper.dart';
import 'package:mqtt_node/slicer/scheduler.dart';
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

  });

  test('scheduler', () {

    Scheduler scheduler = Scheduler();

    Slicer slicer = Slicer('1234', 32);
    String message = randomString(100);
    List<String> bundle = slicer.chunkMessage('test.txt', message);
    expect(bundle.length, 4);

    ChunksWrapper?
    wrapper = scheduler.addChunk(bundle[0]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundle[1]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundle[2]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundle[3]);
    expect(wrapper, isNotNull);

    String out = slicer.messagesAssembly(wrapper!.chunks);
    expect(message, equals(out));


    // Slicer slicer = Slicer('1234', 64);
    // String message = randomString(300);
    //
    // List<String> bundle = slicer.chunkMessage('test.txt', message);
    // expect(bundle.length, 5);
    //
    // String out = slicer.messagesAssembly(bundle);
    // expect(message, equals(out));

  });

}
