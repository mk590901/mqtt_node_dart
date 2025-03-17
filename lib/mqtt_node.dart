import 'dart:io';
import 'client_helper.dart';
import 'task.dart';

bool isRunning = false;
Task task = Task();

bool run() {

  ClientHelper.initInstance();

  print('Enter command (s[tart]/f[inal]/e|x[xit]):');

  doneCommand('s');

  stdin.listen((List<int> data) {
    String command = String.fromCharCodes(data).trim();
    doneCommand(command);
  });
  return true;
}

void doneCommand(String command) {
  if (command == 's') {
    if (!isRunning) {
      isRunning = true;
      print('Task is started');

      task.openConnection();

    }
    else {
      print('Task already in progress...');
    }
  }
  else
  if (command == 'f') {
    if (isRunning) {
      isRunning = false;
      print('Task stopped');
      task.closeConnection((){});
    } else {
      print("Task isn't active");
    }
  }
  else if (command == 'e' || command == 'x') {
    print("App exit");
    task.breakConnection((){
      exit(0);
    });
  }
  else {
    print('Invalid command "$command", use start или stop.');
  }
}

