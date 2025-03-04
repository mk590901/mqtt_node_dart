class Response {
  final bool result;
  final String message;
  Response({required this.result, required this.message});
  @override
  String toString() {
    return '[$result,$message]';
  }
}
