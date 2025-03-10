import 'dart:math';
import 'package:mqtt_node/slicer/chunks_wrapper.dart';
import 'package:mqtt_node/slicer/scheduler.dart';
import 'package:mqtt_node/slicer/slicer.dart';
import 'package:test/test.dart';

import 'dart:io' show Directory, File, Platform;
import 'package:platform/platform.dart' show LocalPlatform;

String randomString(int length) {
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String? getUserHomeDirectory() {
  String? result = '';
  try {
    // Path to platform
    final platform = LocalPlatform();
    // Path to home user folder
    result = platform.environment['HOME'];
  } catch (e) {
    print('Error: $e');
  }
  return result;
}

void createFileWithDirectories(String filePath) {
  try {
    // Extract folder
    final directory = Directory(filePath.substring(0, filePath.lastIndexOf('/')));

    // Create intermediately folders
    directory.createSync(recursive: true);

    // Create file
    final file = File(filePath);
    file.createSync();

    // Write content
    file.writeAsStringSync('// ******* Code *******');

    print('File was created: $filePath');
  } catch (e) {
    print('File creation error: $e');
  }
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

  test('scheduler one', () {

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

  });

  test('scheduler two', () {

    Scheduler scheduler = Scheduler();

    Slicer slicer = Slicer('1234', 1024);
    String message = randomString(7000);
    List<String> bundle = slicer.chunkMessage('test.txt', message);
    expect(bundle.length, 7);

    ChunksWrapper? wrapper;
    int i = 0;
    do {
      wrapper = scheduler.addChunk(bundle[i++]);
    }
    while (wrapper == null) ;

    String out = slicer.messagesAssembly(wrapper!.chunks);
    expect(message, equals(out));

  });

  test('scheduler two files 1', () {

    Scheduler scheduler = Scheduler();

    Slicer slicer = Slicer('1234', 32);

    String messageOne = randomString(100);
    List<String> bundleOne = slicer.chunkMessage('test1.txt', messageOne);
    expect(bundleOne.length, 4);

    String messageTwo = randomString(150);
    List<String> bundleTwo = slicer.chunkMessage('test2.txt', messageTwo);
    expect(bundleTwo.length, 5);

    ChunksWrapper? wrapper;
    wrapper = scheduler.addChunk(bundleOne[0]); //1
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[0]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[1]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[1]); //2
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[2]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[2]); //3
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[3]); //4
    expect(wrapper, isNotNull);

    String outOne = slicer.messagesAssembly(wrapper!.chunks);
    expect(messageOne, equals(outOne));
    scheduler.removeFileEntry(wrapper.clientId, wrapper.fileName);
    expect(scheduler.existFlleChunks(wrapper.clientId, wrapper.fileName),false);
    expect(scheduler.isEmpty(),false);

    wrapper = scheduler.addChunk(bundleTwo[3]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[4]);
    expect(wrapper, isNotNull);

    String outTwo = slicer.messagesAssembly(wrapper!.chunks);
    expect(messageTwo, equals(outTwo));
    scheduler.removeFileEntry(wrapper.clientId, wrapper.fileName);
    expect(scheduler.existFlleChunks(wrapper.clientId, wrapper.fileName),false);
    expect(scheduler.isEmpty(),true);

  });

  test('scheduler two files 2', () {

    Scheduler scheduler = Scheduler();

    Slicer slicer = Slicer('1234', 32);

    String messageOne = randomString(100);
    List<String> bundleOne = slicer.chunkMessage('test1.txt', messageOne);
    expect(bundleOne.length, 4);

    String messageTwo = randomString(150);
    List<String> bundleTwo = slicer.chunkMessage('test2.txt', messageTwo);
    expect(bundleTwo.length, 5);

    ChunksWrapper? wrapper;
    wrapper = scheduler.addChunk(bundleOne[3]); //1
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[0]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[1]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[1]); //2
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[2]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[2]); //3
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[0]); //4
    expect(wrapper, isNotNull);

    String outOne = slicer.messagesAssembly(wrapper!.chunks);
    expect(messageOne, equals(outOne));
    scheduler.removeFileEntry(wrapper.clientId, wrapper.fileName);
    expect(scheduler.existFlleChunks(wrapper.clientId, wrapper.fileName),false);
    expect(scheduler.isEmpty(),false);

    wrapper = scheduler.addChunk(bundleTwo[3]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[4]);
    expect(wrapper, isNotNull);

    String outTwo = slicer.messagesAssembly(wrapper!.chunks);
    expect(messageTwo, equals(outTwo));
    scheduler.removeFileEntry(wrapper.clientId, wrapper.fileName);
    expect(scheduler.existFlleChunks(wrapper.clientId, wrapper.fileName),false);
    expect(scheduler.isEmpty(),true);

  });

  test('scheduler two files 3', () {

    Scheduler scheduler = Scheduler();

    Slicer slicerOne = Slicer('1234', 32);

    String messageOne = randomString(100);
    List<String> bundleOne = slicerOne.chunkMessage('test1.txt', messageOne);
    expect(bundleOne.length, 4);

    Slicer slicerTwo = Slicer('4321', 32);

    String messageTwo = randomString(150);
    List<String> bundleTwo = slicerTwo.chunkMessage('test2.txt', messageTwo);
    expect(bundleTwo.length, 5);

    ChunksWrapper? wrapper;
    wrapper = scheduler.addChunk(bundleOne[3]); //1
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[0]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[1]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[1]); //2
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[2]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[2]); //3
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleOne[0]); //4
    expect(wrapper, isNotNull);

    String outOne = slicerOne.messagesAssembly(wrapper!.chunks);
    expect(messageOne, equals(outOne));
    scheduler.removeFileEntry(wrapper.clientId, wrapper.fileName);
    expect(scheduler.existFlleChunks(wrapper.clientId, wrapper.fileName),false);
    expect(scheduler.isEmpty(),false);

    wrapper = scheduler.addChunk(bundleTwo[3]);
    expect(wrapper, isNull);
    wrapper = scheduler.addChunk(bundleTwo[4]);
    expect(wrapper, isNotNull);

    String outTwo = slicerTwo.messagesAssembly(wrapper!.chunks);
    expect(messageTwo, equals(outTwo));
    scheduler.removeFileEntry(wrapper.clientId, wrapper.fileName);
    expect(scheduler.existFlleChunks(wrapper.clientId, wrapper.fileName),false);
    expect(scheduler.isEmpty(),true);

  });

  test('File creation', () {
    String  fileName = 'HsmProjects/mqtt_cs_9.hsm/generic_code/dart/mqtt_cs_9_helper.dart';
    String? homeFolder = getUserHomeDirectory();
    String  docsFolder = 'Documents';
    String  repository = 'Repository';
    print ('$homeFolder');
    if (homeFolder == null) {
      print('Failed to get home folder');
    }
    else {
      //Directory target = Directory('$homeFolder/$docsFolder/$repository/$fileName');
      final filePath = '$homeFolder/$docsFolder/$repository/$fileName';
      print ('file -> $filePath');
      createFileWithDirectories(filePath);
    }
  });



}
