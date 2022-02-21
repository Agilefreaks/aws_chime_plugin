import 'package:aws_chime_plugin/aws_chime.dart';

class Attendee {
  final int tileId;
  final bool isLocalTile;

  int? _viewId;
  AwsChimeRenderView? _videoView;

  int? height;
  int? width;

  int? get viewId => _viewId;

  AwsChimeRenderView? get videoView => _videoView;

  get aspectRatio =>
      height == null || height == 0 || width == null || width == 0
          ? 1.0
          : width! / height!;

  Attendee(this.tileId, this.isLocalTile);

  void setViewId(int viewId) {
    if (_viewId != null) throw Exception('ViewId already set!');

    _viewId = viewId;
  }

  void setVideoView(AwsChimeRenderView videoView) {
    if (_videoView != null) throw Exception('VideoView already set!');

    _videoView = videoView;
  }
}
