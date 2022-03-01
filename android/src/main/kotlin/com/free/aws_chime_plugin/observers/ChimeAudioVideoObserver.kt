package com.free.aws_chime_plugin.observers

import com.amazonaws.services.chime.sdk.meetings.audiovideo.AudioVideoObserver
import com.amazonaws.services.chime.sdk.meetings.session.MeetingSessionStatus
import io.flutter.plugin.common.EventChannel
import org.json.JSONObject

class ChimeAudioVideoObserver(private val _eventSink: EventChannel.EventSink) : AudioVideoObserver {
    // Called when audio session cancelled reconnecting.
    override fun onAudioSessionCancelledReconnect() {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnAudioSessionCancelledReconnect")
        _eventSink.success(jsonObject.toString())
    }

    // Called when audio session got dropped due to poor network conditions.
    // There will be an automatic attempt of reconnecting it. If the reconnection is successful,
    // onAudioSessionStarted will be called with value of reconnecting as true
    override fun onAudioSessionDropped() {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnAudioSessionDropped")
        _eventSink.success(jsonObject.toString())
    }

    override fun onAudioSessionStarted(reconnecting: Boolean) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("Reconnecting", reconnecting)
        jsonObject.put("Name", "OnAudioSessionStarted")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    // Called when the audio session is connecting or reconnecting.
    override fun onAudioSessionStartedConnecting(reconnecting: Boolean) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("Reconnecting", reconnecting)
        jsonObject.put("Name", "OnAudioSessionStartedConnecting")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    // Called when the audio session has stopped with the reason provided in the status.
    // This callback implies that audio client has stopped permanently for this session
    // and there will be no attempt of reconnecting it.
    override fun onAudioSessionStopped(sessionStatus: MeetingSessionStatus) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("StatusCode", sessionStatus.statusCode)
        jsonObject.put("Name", "OnAudioSessionStopped")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onConnectionBecamePoor() {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnConnectionBecamePoor")
        _eventSink.success(jsonObject.toString())
    }

    override fun onConnectionRecovered() {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnConnectionRecovered")
        _eventSink.success(jsonObject.toString())
    }

    // Called when the video session has started. Sometimes there is a non fatal error such as
    // trying to send local video when the capacity was already reached.
    // However, user can still receive remote video in the existing video session.
    override fun onVideoSessionStarted(sessionStatus: MeetingSessionStatus) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("StatusCode", sessionStatus.statusCode)
        jsonObject.put("Name", "OnVideoSessionStarted")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onVideoSessionStartedConnecting() {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnVideoSessionStartedConnecting")
        _eventSink.success(jsonObject.toString())
    }

    // Called when the video session has stopped from a started state with the reason provided in the status.
    override fun onVideoSessionStopped(sessionStatus: MeetingSessionStatus) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("StatusCode", sessionStatus.statusCode)
        jsonObject.put("Name", "OnVideoSessionStopped")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }
}