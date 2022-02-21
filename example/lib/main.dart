import 'dart:convert';
import 'dart:io';
import 'package:aws_chime_plugin/aws_chime.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'data/attendee.dart';
import 'data/attendees.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

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
  String _audioVideoStartRemoteVideoResult = 'AudioVideoRemoteVideo';

  Attendees _attendees = Attendees();

  @override
  void initState() {
    super.initState();
    _startChime();
  }

  @override
  Widget build(BuildContext context) {
    var chimeViewChildren = List<Widget>.empty(growable: true);

    if (_attendees.length == 0) {
      chimeViewChildren
          .add(const Expanded(child: Center(child: Text('No attendees yet.'))));
    } else {
      for (int attendeeIndex = 0;
          attendeeIndex < _attendees.length;
          attendeeIndex++) {
        Attendee attendee = _attendees[attendeeIndex];
        if (attendee.videoView != null) {
          chimeViewChildren.add(Expanded(
              child: Center(
                  child: AspectRatio(
                      aspectRatio: attendee.aspectRatio,
                      child: attendee.videoView))));
        }
      }
    }

    var chimeViewColumn = Column(children: chimeViewChildren);

    Widget content;
    final TextEditingController _meetingIdController = TextEditingController();
    final TextEditingController _attendeNameController =
        TextEditingController();

    content = Column(children: [
      const Text('Meeting id:'),
      Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3.0),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: EditableText(
          cursorColor: Colors.black,
          textDirection: TextDirection.ltr,
          focusNode: FocusNode(),
          style: const TextStyle(color: Colors.black),
          controller: _meetingIdController,
          backgroundCursorColor: Colors.black,
        ),
      ),
      const Text('Attende name:'),
      Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3.0),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: EditableText(
          cursorColor: Colors.black,
          textDirection: TextDirection.ltr,
          focusNode: FocusNode(),
          style: const TextStyle(color: Colors.black),
          controller: _attendeNameController,
          backgroundCursorColor: Colors.black,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Create meeting:'),
          ElevatedButton(
            child: const Text('Start'),
            onPressed: () => _createMeeting(
                _meetingIdController.text, _attendeNameController.text),
          )
        ],
      ),
      Text(_createMeetingSessionResult),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        const Text('Audio/Video:'),
        ElevatedButton(
            child: const Text('Start'), onPressed: () => _audioVideoStart()),
        ElevatedButton(
            child: const Text('Stop'), onPressed: () => _audioVideoStop())
      ]),
      Text(_audioVideoStartResult),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        const Text('Remote Video:'),
        ElevatedButton(
            child: const Text('Start'),
            onPressed: () => _audioVideoStartRemoteVideo()),
        ElevatedButton(
            child: const Text('Stop'),
            onPressed: () => _audioVideoStopRemoteVideo())
      ]),
      Text(_audioVideoStartRemoteVideoResult),
      const SizedBox(height: 8),
      Expanded(child: chimeViewColumn)
    ]);

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('AwsChimePlugin')),
            resizeToAvoidBottomInset: false,
            body: Column(children: [
              const SizedBox(height: 8),
              Text(_platformVersion),
              const SizedBox(height: 8),
              Expanded(child: content)
            ])));
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

  Future<String?> _createMeeting(String meetingId, String attendeeName) async {
    String awsServerUrl =
        "https://wbe7o32i1j.execute-api.us-east-1.amazonaws.com/Prod";

    var url = Uri.parse(
        '$awsServerUrl/join?title=$meetingId&name=$attendeeName&region=us-east-1');

    var client = http.Client();

    var response = await http.post(url, encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;

      print('Success!');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return "";
  }

  Future<void> _audioVideoStart() async {
    String result;

    try {
      result = (await AwsChimePlugin.audioVideoStart())!;
    } on PlatformException catch (e) {
      result = 'AudioVideoStart failed: PlatformException: $e';
    } catch (e) {
      result = 'AudioVideoStart failed: Error: $e';
    }

    if (mounted) {
      setState(() {
        _audioVideoStartResult = result;
      });
    }
  }

  Future<void> _audioVideoStop() async {
    String result;

    try {
      result = (await AwsChimePlugin.audioVideoStop())!;
    } on PlatformException catch (e) {
      result = 'AudioVideoStop failed: PlatformException: $e';
    } catch (e) {
      result = 'AudioVideoStop failed: Error: $e';
    }

    if (mounted) {
      setState(() {
        _audioVideoStartResult = result;
      });
    }
  }

  Future<void> _audioVideoStartRemoteVideo() async {
    String result;

    try {
      result = (await AwsChimePlugin.audioVideoStartRemoteVideo())!;
    } on PlatformException catch (e) {
      result = 'AudioVideoStartRemoteVideo failed: PlatformException: $e';
    } catch (e) {
      result = 'AudioVideoStartRemoteVideo failed: Error: $e';
    }

    if (mounted) {
      setState(() {
        _audioVideoStartRemoteVideoResult = result;
      });
    }
  }

  Future<void> _audioVideoStopRemoteVideo() async {
    String result;

    try {
      result = (await AwsChimePlugin.audioVideoStopRemoteVideo())!;
    } on PlatformException catch (e) {
      result = 'AudioVideoStopRemoteVideo failed: PlatformException: $e';
    } catch (e) {
      result = 'AudioVideoStopRemoteVideo failed: Error: $e';
    }

    if (mounted) {
      setState(() {
        _audioVideoStartRemoteVideoResult = result;
      });
    }
  }
}
