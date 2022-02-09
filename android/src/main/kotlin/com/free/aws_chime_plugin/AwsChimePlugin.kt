package com.free.aws_chime_plugin

import android.content.ContentValues.TAG
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AwsChimePlugin */
class AwsChimePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var _methodChannel: MethodChannel? = null
    private var _applicationContext: Context? = null
    private var _eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val binaryMessenger = flutterPluginBinding.binaryMessenger

        _applicationContext = flutterPluginBinding.applicationContext

        _methodChannel = MethodChannel(binaryMessenger, "aws_chime_plugin_method")
        _methodChannel?.setMethodCallHandler(this)

        val eventChannel = EventChannel(binaryMessenger, "aws_chime_plugin_events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                _eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "EventChannel.setStreamHandler().onCancel()")
            }
        })

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "AwsChimeRenderView",
            AwsChimeRenderViewFactory()
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        _methodChannel?.setMethodCallHandler(null)
    }
}
