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

    if (!existClient(client)) {
      createClientAndFileChunksHeader(file, client);
    }
    result = addChunkToClient(client, jsonString);
    return result;
  }

  ChunksWrapper? addChunkToClient(String client, String jsonString) {
    FileChunks? fileChunk;
    fileChunk = _container[client];
    ChunksWrapper? result = fileChunk?.addChunk(jsonString);
    return result;
  }

  void createClientAndFileChunksHeader(String file, String client) {
    FileChunks? fileChunk = FileChunks(file);
    _container[client] = fileChunk;
  }

  bool existClient(String client) {
    return _container.containsKey(client);
  }

  void removeEntry(final String client) {
    _container.remove(client);
  }

}