import 'dart:io' show Directory, File;
import 'package:platform/platform.dart' show LocalPlatform;

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

void createFileWithDirectories(String filePath, String content) {
  try {
    // Extract folder
    final directory = Directory(filePath.substring(0, filePath.lastIndexOf('/')));

    // Create intermediately folders
    directory.createSync(recursive: true);

    // Create file
    final file = File(filePath);
    file.createSync();

    // Write content
    file.writeAsStringSync(content);

    print('File was created: $filePath');
  } catch (e) {
    print('File creation error: $e');
  }
}

void saveFile(String fileName, String content) {
  String? homeFolder = getUserHomeDirectory();
  String docsFolder = 'Documents';
  String repository = 'Repository';
  //@print('$homeFolder');
  if (homeFolder == null) {
    print('Failed to get home folder');
  }
  else {
    final filePath = '$homeFolder/$docsFolder/$repository/$fileName';
    //@print('file -> $filePath');
    createFileWithDirectories(filePath, content);
  }
}