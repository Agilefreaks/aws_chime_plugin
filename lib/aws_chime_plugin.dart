import 'dart:async';

import 'package:flutter/services.dart';

class AwsChimePlugin {
  static const MethodChannel _methodChannel =
      MethodChannel('aws_chime_plugin_method');
  static const EventChannel _eventChannel =
      EventChannel('aws_chime_plugin_events');

  /// Subscribe to the event channel using:
  /// AwsChimePlugin ???
  static EventChannel get eventChannel => _eventChannel;

  /// Get the AWS Chime SDK version
  static Future<String?> get version async {
    return _methodChannel.invokeMethod('GetVersion');
  }

  /// Create a metting session
  static Future<String?> createMeeting(
      {required String externalMeetingId,
      required String mediaPlacementAudioFallbackUrl,
      required String mediaPlacementAudioHostUrl,
      required String mediaPlacementSignalingUrl,
      required String mediaPlacementTurnControlUrl,
      required String meetingId,
      required String mediaRegion,
      required String externalUserId,
      required String joinToken}) async {
    var params = {
      "MeetingId": meetingId,
      "ExternalMeetingId": externalMeetingId,
      "MediaRegion": mediaRegion,
      "MediaPlacementAudioHostUrl": mediaPlacementAudioHostUrl,
      "MediaPlacementAudioFallbackUrl": mediaPlacementAudioFallbackUrl,
      "MediaPlacementSignalingUrl": mediaPlacementSignalingUrl,
      "MediaPlacementTurnControlUrl": mediaPlacementTurnControlUrl,
      "ExternalUserId": externalUserId,
      "JoinToken": joinToken
    };

    return _methodChannel.invokeMethod('CreateMeeting', params);
  }

  /// Starts audio and video
  static Future<String?> audioVideoStart() async {
    return _methodChannel.invokeMethod('AudioVideoStart');
  }

  ///Stops audio and video
  static Future<String?> audioVideoStop() async {
    return _methodChannel.invokeMethod('AudioVideoStop');
  }

  /// Starts all remote video
  static Future<String?> audioVideoStartRemoteVideo() async {
    return _methodChannel.invokeMethod('AudioVideoStartRemoteVideo');
  }

  /// Stops all remote video
  static Future<String?> audioVideoStopRemoteVideo() async {
    return _methodChannel.invokeMethod('AudioVideoStopRemoteVideo');
  }

  /// Binds a view to a video tile.
  //  @Todo: Check if this methods are in android project!
  static Future<String?> bindVideoView(int viewId, int tileId) async {
    var params = {"ViewId": viewId, "TileId": tileId};
    return _methodChannel.invokeMethod('BindVideoView', params);
  }

  /// Unbinds a video tile.
  static Future<String?> unbindVideoView(int tileId) async {
    var params = {"TileId": tileId};
    return _methodChannel.invokeMethod('UnbindVideoView', params);
  }
}
