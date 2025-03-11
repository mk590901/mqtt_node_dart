

import 'i_reaction.dart';
import 'i_response.dart';
import 'mqtt_bridge.dart';
import 'typedef.dart';

class Task {

  //final IReaction reaction;
  late  MQTTBridge mqttBridge;

  //final Random random = Random();

  void response(bool rc, String text, bool next) {
    print ('response $rc, $text, $next');
  }

  void connect (VoidBridgeCallback cb) {
    print ('******* connect [${mqttBridge.state()}] *******');
    mqttBridge.postComposite('Connect', cb);
  }

  void disconnect (VoidBridgeCallback cb) {
    print ('******* connect [${mqttBridge.state()}] *******');
    mqttBridge.postComposite('Unsubscribe', cb);
  }

  void disconnectOnExit (VoidBridgeCallback cb) {
    print ('******* connect [${mqttBridge.state()}] *******');
    mqttBridge.postComposite('Disconnect', cb);
  }

  Task (/*this.reaction*/) {
    mqttBridge = MQTTBridge(response);
  }

  void openConnection() {
    bool rc = false;
    String message = 'result';

    connect ((bool rc_, String parameter_) {
      rc = rc_;
      message = parameter_;
      //@print('******* execute $rc, $message');
      //reaction.result(Response(result: rc, message: message));
    });
  }

  void closeConnection(Null Function() fun) {
    bool rc = false;
    String message = 'result';

    disconnect ((bool rc_, String parameter_) {
      rc = rc_;
      message = parameter_;
      //@print('******* execute $rc, $message');
      fun.call();
      //reaction.result(Response(result: rc, message: message));
    });
  }

  void breakConnection(Null Function() fun) {
    bool rc = false;
    String message = 'result';

    disconnectOnExit ((bool rc_, String parameter_) {
      rc = rc_;
      message = parameter_;
      //@print('******* execute $rc, $message');
      fun.call();
      //reaction.result(Response(result: rc, message: message));
    });
  }



}
