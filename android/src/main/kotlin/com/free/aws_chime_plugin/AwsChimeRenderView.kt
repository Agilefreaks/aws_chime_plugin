package com.free.aws_chime_plugin

import android.content.Context
import android.view.View
import com.amazonaws.services.chime.sdk.meetings.audiovideo.video.DefaultVideoRenderView
import com.amazonaws.services.chime.sdk.meetings.audiovideo.video.VideoRenderView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class AwsChimeRenderView internal constructor(context: Context?) : PlatformView,
    MethodChannel.MethodCallHandler {

    private val defaultVideoView: DefaultVideoRenderView = DefaultVideoRenderView(context!!)
    val videoRenderView: VideoRenderView get() = defaultVideoView

    override fun getView(): View = defaultVideoView

    override fun dispose() = Unit

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) =
        result.notImplemented()
}