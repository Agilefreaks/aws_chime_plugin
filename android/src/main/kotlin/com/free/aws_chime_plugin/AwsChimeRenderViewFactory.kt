package com.free.aws_chime_plugin

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AwsChimeRenderViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val view = AwsChimeRenderView(context)
        viewIdToMapView[viewId] = view
        return view

    }

    companion object {
        private val viewIdToMapView: MutableMap<Int, AwsChimeRenderView> = HashMap()

        fun getViewById(id: Int): AwsChimeRenderView? = viewIdToMapView[id]

        fun clearViewIds() {
            viewIdToMapView.clear()
        }
    }
}