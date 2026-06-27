/// 
/// Multi-Channel Service  Flutter  Backend Integration
///
/// Maps to MultiChannelController endpoints:
///   POST   /multi-channel/channels
///   GET    /multi-channel/channels/{entityId}
///   PUT    /multi-channel/channels/{channelId}/sync
///   PATCH  /multi-channel/channels/{channelId}/status
///   DELETE /multi-channel/channels/{channelId}
/// 
library;

import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_routes.dart';

class MultiChannelService {
  final ApiClient _api;

  MultiChannelService([ApiClient? api]) : _api = api ?? ApiClient.instance;

  //  Channels 

  Future<ApiResponse<Map<String, dynamic>>> registerChannel(
    Map<String, dynamic> data,
  ) {
    return _api.post<Map<String, dynamic>>(
      ApiRoutes.multiChannel.channels,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> listChannels(String entityId) {
    return _api.get<List<dynamic>>(
      ApiRoutes.multiChannel.listChannels(entityId),
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> syncChannel(String channelId) {
    return _api.put<Map<String, dynamic>>(
      ApiRoutes.multiChannel.syncChannel(channelId),
      data: {},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateChannelStatus(
    String channelId,
    String status,
  ) {
    return _api.patch<Map<String, dynamic>>(
      '${ApiRoutes.multiChannel.channels}/$channelId/status',
      data: {'status': status},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> deleteChannel(String channelId) {
    return _api.delete<void>(
      ApiRoutes.multiChannel.deactivate(channelId),
    );
  }
}
