package com.free.aws_chime_plugin

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.amazonaws.services.chime.sdk.meetings.audiovideo.AudioVideoFacade
import com.amazonaws.services.chime.sdk.meetings.audiovideo.audio.activespeakerpolicy.DefaultActiveSpeakerPolicy
import com.amazonaws.services.chime.sdk.meetings.session.*
import com.amazonaws.services.chime.sdk.meetings.utils.logger.ConsoleLogger
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
    private var _audioVideoFacade: AudioVideoFacade? = null
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

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        _methodChannel?.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "CreateMeeting" -> handleCreateMeeting(call, result)
            "AudioVideoStart" -> handleAudioVideoStart(result)
            "AudioVideoStop" -> handleAudioVideoStop(result)
            "AudioVideoStartRemoteVideo" -> handleAudioVideoStartRemoteVideo(result)
            "AudioVideoStopRemoteVideo" -> handleAudioVideoStopRemoteVideo(result)
            else -> result.notImplemented()
        }
    }

    private fun handleCreateMeeting(call: MethodCall, result: Result) {
        val safeApplicationContext: Context? = _applicationContext
        if (safeApplicationContext == null) {
            result.error(UNEXPECTED_ERROR_CODE, UNEXPECTED_ERROR_MESSAGE, null)
            return
        }

        val meetingId = call.argument<String>(MEETING_ID)
        if (meetingId == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + MEETING_ID,
                null
            )
            return
        }

        val externalMeetingId = call.argument<String>(EXTERNAL_MEETING_ID)
        if (externalMeetingId == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + EXTERNAL_MEETING_ID,
                null
            )
            return
        }

        val mediaRegion = call.argument<String>(MEDIA_REGION)
        if (mediaRegion == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + MEDIA_REGION,
                null
            )
            return
        }

        val mediaPlacementAudioHostUrl = call.argument<String>(MEDIA_PLACEMENT_AUDIO_HOST_URL)
        if (mediaPlacementAudioHostUrl == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + MEDIA_PLACEMENT_AUDIO_HOST_URL,
                null
            )
            return
        }

        val mediaPlacementAudioFallbackUrl =
            call.argument<String>(MEDIA_PLACEMENT_AUDIO_FALLBACK_URL)
        if (mediaPlacementAudioFallbackUrl == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + MEDIA_PLACEMENT_AUDIO_FALLBACK_URL,
                null
            )
            return
        }


        val mediaPlacementSignalingUrl = call.argument<String>(MEDIA_PLACEMENT_SIGNALING_URL)
        if (mediaPlacementSignalingUrl == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + MEDIA_PLACEMENT_SIGNALING_URL,
                null
            )
            return
        }

        val mediaPlacementTurnControlUrl = call.argument<String>(MEDIA_PLACEMENT_TURN_CONTROL_URL)
        if (mediaPlacementTurnControlUrl == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + MEDIA_PLACEMENT_TURN_CONTROL_URL,
                null
            )
            return
        }

        val externalUserId = call.argument<String>(EXTERNAL_USER_ID)
        if (externalUserId == null) {
            result.error(
                UNEXPECTED_NULL_PARAMETER_ERROR_CODE,
                UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE + EXTERNAL_USER_ID,
                null
            )
        }

        val mediaPlacement = MediaPlacement(
            mediaPlacementAudioFallbackUrl,
            mediaPlacementAudioHostUrl,
            mediaPlacementSignalingUrl,
            mediaPlacementTurnControlUrl
        )
        val meeting = Meeting(externalMeetingId, mediaPlacement, mediaRegion, meetingId)
        val meetingResponse = CreateMeetingResponse(meeting)
        val attendee = Attendee("attendeeId", externalUserId!!, "joinToken")
        val attendeeResponse = CreateAttendeeResponse(attendee)
        val configuration =
            MeetingSessionConfiguration(meetingResponse, attendeeResponse) { s: String? -> s!! }

        val meetingSession: MeetingSession =
            DefaultMeetingSession(configuration, ConsoleLogger(), safeApplicationContext)
        val safeAudioVideoFacade: AudioVideoFacade = meetingSession.audioVideo
        _audioVideoFacade = safeAudioVideoFacade

        val safeEventSink: EventChannel.EventSink? = _eventSink
        if (safeEventSink == null) {
            result.error(UNEXPECTED_ERROR_CODE, UNEXPECTED_ERROR_MESSAGE, null)
            return
        }

        safeAudioVideoFacade.addActiveSpeakerObserver(
            DefaultActiveSpeakerPolicy(),
            ChimeActiveSpeakerDetectedObserver(safeEventSink)
        )
        safeAudioVideoFacade.addAudioVideoObserver(ChimeAudioVideoObserver(safeEventSink))
        safeAudioVideoFacade.addDeviceChangeObserver(ChimeDeviceChangeObserver(safeEventSink))
        safeAudioVideoFacade.addMetricsObserver(ChimeMetricsObserver(safeEventSink))
        safeAudioVideoFacade.addRealtimeObserver(ChimeRealtimeObserver(safeEventSink))
        safeAudioVideoFacade.addVideoTileObserver(ChimeVideoTileObserver(safeEventSink))

        result.success(null)
    }

    companion object {
        private const val MEETING_ID = "MeetingId"
        private const val EXTERNAL_MEETING_ID = "ExternalMeetingId"
        private const val MEDIA_REGION = "MediaRegion"
        private const val MEDIA_PLACEMENT_AUDIO_HOST_URL = "MediaPlacementAudioHostUrl"
        private const val MEDIA_PLACEMENT_AUDIO_FALLBACK_URL = "MediaPlacementAudioFallbackUrl"
        private const val MEDIA_PLACEMENT_SIGNALING_URL = "MediaPlacementSignalingUrl"
        private const val MEDIA_PLACEMENT_TURN_CONTROL_URL = "MediaPlacementTurnControlUrl"
        private const val EXTERNAL_USER_ID = "ExternalUserId"
        private const val TAG = "AwsChimePlugin"
        private const val UNEXPECTED_NULL_PARAMETER_ERROR_CODE = "4"
        private const val UNEXPECTED_NULL_PARAMETER_ERROR_MESSAGE = "Unexpected null parameter: "
        private const val UNEXPECTED_ERROR_CODE = "99"
        private const val UNEXPECTED_ERROR_MESSAGE = "Unexpected error."
    }
}
