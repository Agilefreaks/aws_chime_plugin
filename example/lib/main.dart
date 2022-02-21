import 'dart:convert';
import 'dart:io';
import 'package:aws_chime_plugin/aws_chime.dart';
import 'package:aws_chime_plugin/aws_chime_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'data/attendee.dart';
import 'data/attendees.dart';

void main() {
  runApp(const AwsChimeApp());
}

class AwsChimeApp extends StatefulWidget {
  const AwsChimeApp({Key? key}) : super(key: key);

  @override
  State<AwsChimeApp> createState() => _AwsChimeAppState();
}

class _AwsChimeAppState extends State<AwsChimeApp> {
  String _platformVersion = 'Unknown';
  String _createMeetingSessionResult = 'CreateMeetingSession';
  String _audioVideoStartResult = 'AudioVideo';
  String _audioVideoStartLocalVideoResult = 'AudioVideoLocalVideo';
  String _audioVideoStartRemoteVideoResult = 'AudioVideoRemoteVideo';

  Attendees _attendees = Attendees();

  @override
  void initState() {
    super.initState();
    _startChime();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  void _startChime() async {
    if (Platform.isAndroid) {
      _addListener();
      await _createMeetingSession();
    } else if (Platform.isIOS) {
      // Nothing for now
    } else {
      _addListener();
      await _createMeetingSession();
    }
  }

  void _addListener() {
    AwsChimePlugin.eventChannel.receiveBroadcastStream().listen((data) async {
      dynamic event = const JsonDecoder().convert(data);
      String eventName = event['Name'];
      dynamic eventArguments = event['Arguments'];
      switch (eventName) {
        case 'OnVideoTileAdded':
          _handleOnVideoTileAdded(eventArguments);
          break;
        case 'OnVideoTileRemoved':
          _handleOnVideoTileRemoved(eventArguments);
          break;
        default:
          print(
              'Chime.eventChannel.receiveBroadcastStream().listen()/onData()');
          print('Warning: Unhandled event: $eventName');
          print('Data: $data');
          break;
      }
    }, onDone: () {
      print('Chime.eventChannel.receiveBroadcastStream().listen().onDone()');
    }, onError: (e) {
      print('Chime.eventChannel.receiveBroadcastStream().listen().onError()');
    });
  }

  void _handleOnVideoTileAdded(dynamic arguments) async {
    bool isLocalTile = arguments['IsLocalTile'];
    int tileId = arguments['TileId'];
    int videoStreamContentHeight = arguments['VideoStreamContentHeight'];
    int videoStreamContentWidth = arguments['VideoStreamContentWidth'];

    Attendee? attendee = _attendees.getByTileId(tileId);
    if (attendee != null) {
      print(
          '_handleOnVideoTileAdded called but already mapped. TileId=${attendee.tileId}, ViewId=${attendee.viewId}, VideoView=${attendee.videoView}');
      return;
    }

    print(
        '_handleOnVideoTileAdded: New attendee: TileId=$tileId => creating ChimeDefaultVideoRenderView');
    attendee = Attendee(tileId, isLocalTile);
    attendee.height = videoStreamContentHeight;
    attendee.width = videoStreamContentWidth;
    _attendees.add(attendee);

    Attendee nonNullAttendee = attendee;
    setState(() {
      nonNullAttendee.setVideoView(
          AwsChimeRenderView(onPlatformViewCreated: (int viewId) async {
        nonNullAttendee.setViewId(viewId);
        print(
            'ChimeDefaultVideoRenderView created. TileId=${nonNullAttendee.tileId}, ViewId=${nonNullAttendee.viewId}, VideoView=${nonNullAttendee.videoView} => binding');
        await AwsChimePlugin.bindVideoView(
            nonNullAttendee.viewId!, nonNullAttendee.tileId);
        print(
            'ChimeDefaultVideoRenderView created. TileId=${nonNullAttendee.tileId}, ViewId=${nonNullAttendee.viewId}, VideoView=${nonNullAttendee.videoView} => bound');
      }));
    });
  }

  void _handleOnVideoTileRemoved(dynamic arguments) async {
    int tileId = arguments['TileId'];

    Attendee? attendee = _attendees.getByTileId(tileId);
    if (attendee == null) {
      print(
          'Error: _handleOnVideoTileRemoved: Could not find attendee for TileId=$tileId');
      return;
    }

    print(
        '_handleOnVideoTileRemoved: Found attendee: TileId=${attendee.tileId}, ViewId=${attendee.viewId} => unbinding');
    _attendees.remove(attendee);
    await AwsChimePlugin.unbindVideoView(tileId);
    print(
        '_handleOnVideoTileRemoved: Found attendee: TileId=${attendee.tileId}, ViewId=${attendee.viewId} => unbound');

    setState(() {
      // refresh
    });
  }

  Future<void> _createMeetingSession() async {
    if (await Permission.microphone.request().isGranted == false) {
      _createMeetingSessionResult = 'Need microphone permission.';
      return;
    }

    if (await Permission.camera.request().isGranted == false) {
      _createMeetingSessionResult = 'Need camera permission.';
      return;
    }

    String meetingSessionState;

    try {
      meetingSessionState = (await createMeeting("", "", "", "", ""))!;
    } on PlatformException catch (e) {
      meetingSessionState =
          'Failed to create MeetingSession. PlatformException: $e';
    } catch (e) {
      meetingSessionState = 'Failed to create MeetingSession. Error: $e';
    }

    if (mounted) {
      setState(() {
        _createMeetingSessionResult = meetingSessionState;
      });
    }
  }

  Future<String?> createMeeting(String meetingId, String externalMeetingId,
      String audioHostUrl, String externalUserId, String joinToken) {
    return AwsChimePlugin.createMeeting(
        externalMeetingId: externalMeetingId,
        mediaPlacementAudioFallbackUrl:
            'wss://haxrp.m2.ue1.app.chime.aws:443/calls/$meetingId',
        mediaPlacementAudioHostUrl: audioHostUrl,
        mediaPlacementSignalingUrl:
            'wss://signal.m2.ue1.app.chime.aws/control/$meetingId',
        mediaPlacementTurnControlUrl:
            'https://2713.cell.us-east-1.meetings.chime.aws/v2/turn_sessions',
        meetingId: meetingId,
        mediaRegion: 'us-east-1',
        externalUserId: externalUserId,
        joinToken: joinToken);
  }
}
