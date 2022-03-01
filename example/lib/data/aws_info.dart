import 'dart:convert';

AwsInfo awsInfoFromJson(String str) => AwsInfo.fromJson(json.decode(str));

String awsInfoToJson(AwsInfo data) => json.encode(data.toJson());

class AwsInfo {
  AwsInfo({
    required this.joinInfo,
  });

  JoinInfo joinInfo;

  factory AwsInfo.fromJson(Map<String, dynamic> json) => AwsInfo(
        joinInfo: JoinInfo.fromJson(json["JoinInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "JoinInfo": joinInfo.toJson(),
      };
}

class JoinInfo {
  JoinInfo({
    required this.meeting,
    required this.attendee,
  });

  JoinInfoMeeting meeting;
  JoinInfoAttendee attendee;

  factory JoinInfo.fromJson(Map<String, dynamic> json) => JoinInfo(
        meeting: JoinInfoMeeting.fromJson(json["Meeting"]),
        attendee: JoinInfoAttendee.fromJson(json["Attendee"]),
      );

  Map<String, dynamic> toJson() => {
        "Meeting": meeting.toJson(),
        "Attendee": attendee.toJson(),
      };
}

class JoinInfoAttendee {
  JoinInfoAttendee({
    required this.attendee,
  });

  AttendeeAttendee attendee;

  factory JoinInfoAttendee.fromJson(Map<String, dynamic> json) =>
      JoinInfoAttendee(
        attendee: AttendeeAttendee.fromJson(json["Attendee"]),
      );

  Map<String, dynamic> toJson() => {
        "Attendee": attendee.toJson(),
      };
}

class AttendeeAttendee {
  AttendeeAttendee({
    required this.externalUserId,
    required this.attendeeId,
    required this.joinToken,
  });

  String externalUserId;
  String attendeeId;
  String joinToken;

  factory AttendeeAttendee.fromJson(Map<String, dynamic> json) =>
      AttendeeAttendee(
        externalUserId: json["ExternalUserId"],
        attendeeId: json["AttendeeId"],
        joinToken: json["JoinToken"],
      );

  Map<String, dynamic> toJson() => {
        "ExternalUserId": externalUserId,
        "AttendeeId": attendeeId,
        "JoinToken": joinToken,
      };
}

class JoinInfoMeeting {
  JoinInfoMeeting({
    required this.meeting,
  });

  MeetingMeeting meeting;

  factory JoinInfoMeeting.fromJson(Map<String, dynamic> json) =>
      JoinInfoMeeting(
        meeting: MeetingMeeting.fromJson(json["Meeting"]),
      );

  Map<String, dynamic> toJson() => {
        "Meeting": meeting.toJson(),
      };
}

class MeetingMeeting {
  MeetingMeeting({
    required this.meetingId,
    this.meetingHostId,
    required this.externalMeetingId,
    required this.mediaRegion,
    required this.mediaPlacement,
  });

  String meetingId;
  dynamic meetingHostId;
  String externalMeetingId;
  String mediaRegion;
  MediaPlacement mediaPlacement;

  factory MeetingMeeting.fromJson(Map<String, dynamic> json) => MeetingMeeting(
        meetingId: json["MeetingId"],
        meetingHostId: json["MeetingHostId"],
        externalMeetingId: json["ExternalMeetingId"],
        mediaRegion: json["MediaRegion"],
        mediaPlacement: MediaPlacement.fromJson(json["MediaPlacement"]),
      );

  Map<String, dynamic> toJson() => {
        "MeetingId": meetingId,
        "MeetingHostId": meetingHostId,
        "ExternalMeetingId": externalMeetingId,
        "MediaRegion": mediaRegion,
        "MediaPlacement": mediaPlacement.toJson(),
      };
}

class MediaPlacement {
  MediaPlacement({
    required this.audioHostUrl,
    required this.audioFallbackUrl,
    required this.signalingUrl,
    required this.turnControlUrl,
    required this.screenDataUrl,
    required this.screenViewingUrl,
    required this.screenSharingUrl,
    this.eventIngestionUrl,
  });

  String audioHostUrl;
  String audioFallbackUrl;
  String signalingUrl;
  String turnControlUrl;
  String screenDataUrl;
  String screenViewingUrl;
  String screenSharingUrl;
  dynamic eventIngestionUrl;

  factory MediaPlacement.fromJson(Map<String, dynamic> json) => MediaPlacement(
        audioHostUrl: json["AudioHostUrl"],
        audioFallbackUrl: json["AudioFallbackUrl"],
        signalingUrl: json["SignalingUrl"],
        turnControlUrl: json["TurnControlUrl"],
        screenDataUrl: json["ScreenDataUrl"],
        screenViewingUrl: json["ScreenViewingUrl"],
        screenSharingUrl: json["ScreenSharingUrl"],
        eventIngestionUrl: json["EventIngestionUrl"],
      );

  Map<String, dynamic> toJson() => {
        "AudioHostUrl": audioHostUrl,
        "AudioFallbackUrl": audioFallbackUrl,
        "SignalingUrl": signalingUrl,
        "TurnControlUrl": turnControlUrl,
        "ScreenDataUrl": screenDataUrl,
        "ScreenViewingUrl": screenViewingUrl,
        "ScreenSharingUrl": screenSharingUrl,
        "EventIngestionUrl": eventIngestionUrl,
      };
}
