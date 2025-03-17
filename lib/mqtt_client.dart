import 'dart:math';
import 'mqtt_bridge.dart';
import 'mqtt_service.dart';
import 'typedef.dart';

class MQTTClient {

  late MqttService mqttService;

  final String subscribeTopic = 'hsm_v2/topic';

  final VoidCallbackStringBoolString callbackFunction;
  final MQTTBridge bridge;

  MQTTClient(this.callbackFunction, this.bridge) {
    mqttService = MqttService(callbackFunction, bridge);
  }

  void connect () {
    //print('******* connect *******');
    mqttService.connect();
  }

  void subscribe () {
    //print('******* subscribe *******');
    mqttService.subscribe(subscribeTopic);
  }

  void publish () {
    print('******* publish *******');
    mqttService.publish(subscribeTopic, randomString(128));
  }

  void unsubscribe () {
    //print('******* unsubscribe *******');
    mqttService.unsubscribe(subscribeTopic);
  }

  void disconnect () {
    //print('******* disconnect *******');
    mqttService.disconnect();
  }

  String randomString(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void setUnitTest() {
    mqttService.setUnitTest();
  }

}