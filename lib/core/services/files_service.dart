/// 
/// Files Service  Flutter  Backend Integration
///
/// Maps to FilesController endpoints:
///   POST   /files/upload
///   DELETE /files/{fileKey}
/// 
library;

import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';

class FilesService {
  final ApiClient _api;

  FilesService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  //  File Operations 

  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    String filePath,
    String folder,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'folder': folder,
    });
    return _api.post<Map<String, dynamic>>(
      '/files/upload',
      data: formData,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteFile(String fileKey) {
    return _api.delete<void>('/files/$fileKey');
  }
}
