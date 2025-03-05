import 'dart:convert';

class Slicer {
  final int chunkSize;
  final String clientId;

  final Map<String, Map<int, Map<String, dynamic>>> chunks = {};

  Slicer(this.clientId, this.chunkSize);

  List<String> chunkMessage(String fileName, String message) {
    List<String> result = [];

    final String messageId = DateTime.now().millisecondsSinceEpoch.toString();
    List<int> data = utf8.encode(message);

    int totalChunks = (data.length/chunkSize).ceil();

    for (int i = 0; i < totalChunks; i++) {
      int start = i * chunkSize;
      int end = (start + chunkSize < data.length) ? start + chunkSize : data.length;
      List<int> chunk = data.sublist(start, end);
      String chunkBase64 = base64Encode(chunk);
      Map<String, dynamic> chunkMetadata = {
        'client': clientId,
        'file'  : fileName,
        'id'    : messageId,
        'total' : totalChunks,
        'index' : i,
        'size'  : chunk.length,
        'data'  : chunkBase64,
      };
      String jsonString = jsonEncode(chunkMetadata);
      result.add(jsonString);
    }
    return result;
  }

  String messagesAssembly(List<String> messages) {
    String result = '';
    chunks.clear();
    for (String payload in messages) {
      String? restoredMessage = addChunk(payload);
      if (restoredMessage != null) {
        print('Message restored: $restoredMessage');
        result = restoredMessage;
      }
    }
    return result;
  }

  String assembleMessage(String messageId) {
    List<int> fullData = [];
    int total = chunks[messageId]!.length;
    for (int i = 0; i < total; i++) {
      String chunkBase64 = chunks[messageId]![i]!['data'];
      List<int> chunkBytes = base64Decode(chunkBase64);
      fullData.addAll(chunkBytes);
    }
    chunks.remove(messageId);
    return utf8.decode(fullData);
  }

  String? addChunk(String jsonString) {
    Map<String, dynamic> chunk = jsonDecode(jsonString);
    String messageId = chunk['id'];
    int index = chunk['index'];
    int total = chunk['total'];

    if (!chunks.containsKey(messageId)) {
      chunks[messageId] = {};
    }

    chunks[messageId]![index] = chunk;
    print('Received chunk ${index + 1} from $total for ID $messageId');

    if (chunks[messageId]!.length == total) {
      return assembleMessage(messageId);
    }
    return null;
  }

}