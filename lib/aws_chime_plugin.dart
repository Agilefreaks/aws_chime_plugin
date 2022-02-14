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
      required String audioFallbackUrl,
      required String audioHostUrl,
      required String signalingUrl,
      required String turnControlUrl,
      required String meetingId,
      required String mediaRegion, 
      required String externalUserId}) async {
    var params = {
      "MeetingId": meetingId,
      "ExternalMeetingId": externalMeetingId,
      "MediaRegion": mediaRegion,
      "MediaPlacementAudioHostUrl": audioHostUrl,
      "MediaPlacementAudioFallbackUrl": audioFallbackUrl,
      "MediaPlacementSignalingUrl": signalingUrl,
      "MediaPlacementTurnControlUrl": turnControlUrl, 
      "ExternalUserId": externalUserId
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
}
