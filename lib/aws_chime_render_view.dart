import 'dart:io';

import 'package:flutter/cupertino.dart';

/// View for rendering video
class AwsChimeRenderView extends StatefulWidget {
  final ValueChanged<int>? onPlatformViewCreated;

  const AwsChimeRenderView({Key? key, this.onPlatformViewCreated})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AwsChimeRenderViewState();
}

class AwsChimeRenderViewState extends State<AwsChimeRenderView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
          viewType: 'AwsChimeRenderView',
          onPlatformViewCreated: (int viewId) =>
              widget.onPlatformViewCreated?.call(viewId));
    } else {
      throw Exception('Not implemented yet');
    }
  }
}
