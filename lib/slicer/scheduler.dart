import 'dart:convert';

import 'chunks_wrapper.dart';
import 'file_chunks.dart';

class Scheduler {
  final Map<String,FileChunks> _container = {}; // key -> client Id

  ChunksWrapper? addChunk(final String jsonString) {
    ChunksWrapper? result;
  // Extract client Id and file Name
    Map<String, dynamic> chunk = jsonDecode(jsonString);
    String client = chunk['client'];
    String file = chunk['file'];

    FileChunks? fileChunk;
    if (!_container.containsKey(client)) {
      fileChunk = FileChunks(file);
      _container[client] = fileChunk;
    }
    fileChunk = _container[client];
    result = fileChunk?.addChunk(jsonString);
    return result;
  }

  void removeEntry(final String client) {
    _container.remove(client);
  }

}