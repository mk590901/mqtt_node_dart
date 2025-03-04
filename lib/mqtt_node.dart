import 'dart:async';
import 'dart:io';

import 'client_helper.dart';

Timer? backgroundTask;
bool isRunning = false;

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
      backgroundTask = Timer.periodic(Duration(seconds: 2), (timer) {
        if (!isRunning) {
          timer.cancel();
          return;
        }
        //print('Task in progress...');
      });
    } else {
      print('Task already in progress...');
    }
  } else if (command == 'f') {
    if (isRunning) {
      isRunning = false;
      print('Task stopped');
    } else {
      print("Task isn't active");
    }
  }
  else if (command == 'e' || command == 'x') {
    print("App exit");
    exit(0);
  }
  else {
    print('Invalid command "$command", use start или stop.');
  }
}

