package com.free.aws_chime_plugin.observers

import com.amazonaws.services.chime.sdk.meetings.audiovideo.AttendeeInfo
import com.amazonaws.services.chime.sdk.meetings.audiovideo.SignalUpdate
import com.amazonaws.services.chime.sdk.meetings.audiovideo.VolumeUpdate
import com.amazonaws.services.chime.sdk.meetings.realtime.RealtimeObserver
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

class ChimeRealtimeObserver(private val _eventSink: EventChannel.EventSink) : RealtimeObserver {
    override fun onAttendeesDropped(attendeeInfo: Array<AttendeeInfo>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("AttendeeInfos", convertAttendeeInfoToJson(attendeeInfo))
        jsonObject.put("Name", "OnAttendeesDropped")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onAttendeesJoined(attendeeInfo: Array<AttendeeInfo>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("AttendeeInfos", convertAttendeeInfoToJson(attendeeInfo))
        jsonObject.put("Name", "OnAttendeesJoined")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onAttendeesLeft(attendeeInfo: Array<AttendeeInfo>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("AttendeeInfos", convertAttendeeInfoToJson(attendeeInfo))
        jsonObject.put("Name", "OnAttendeesLeft")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onAttendeesMuted(attendeeInfo: Array<AttendeeInfo>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("AttendeeInfos", convertAttendeeInfoToJson(attendeeInfo))
        jsonObject.put("Name", "OnAttendeesMuted")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onAttendeesUnmuted(attendeeInfo: Array<AttendeeInfo>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("AttendeeInfos", convertAttendeeInfoToJson(attendeeInfo))
        jsonObject.put("Name", "OnAttendeesUnmuted")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onSignalStrengthChanged(signalUpdates: Array<SignalUpdate>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("SignalUpdates", convertSignalUpdatesToJson(signalUpdates))
        jsonObject.put("Name", "OnSignalStrengthChanged")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }

    override fun onVolumeChanged(volumeUpdates: Array<VolumeUpdate>) {
        val jsonObject = JSONObject()
        val eventArguments = JSONObject()
        eventArguments.put("VolumeUpdates", convertVolumeUpdatesToJson(volumeUpdates))
        jsonObject.put("Name", "OnVolumeChanged")
        jsonObject.put("Arguments", eventArguments)
        _eventSink.success(jsonObject.toString())
    }


    private fun convertAttendeeInfoToJson(attendeeInfos: Array<AttendeeInfo>): JSONArray {
        val list = JSONArray()

        for (attendeeInfo in attendeeInfos) {
            val item = JSONObject()
            item.put("AttendeeId", attendeeInfo.attendeeId)
            item.put("ExternalUserId", attendeeInfo.externalUserId)
            list.put(item)
        }
        return list
    }

    private fun convertSignalUpdatesToJson(signalUpdates: Array<SignalUpdate>): JSONArray {
        val list = JSONArray()

        for (signalUpdate in signalUpdates) {
            val item = JSONObject()
            item.put("AttendeeId", signalUpdate.attendeeInfo.attendeeId)
            item.put("ExternalUserId", signalUpdate.attendeeInfo.externalUserId)
            item.put("SignalStrength", signalUpdate.signalStrength)
            list.put(item)
        }
        return list
    }

    private fun convertVolumeUpdatesToJson(volumeUpdates: Array<VolumeUpdate>): JSONArray {
        val list = JSONArray()

        for (volumeUpdate in volumeUpdates) {
            val item = JSONObject()
            item.put("AttendeeId", volumeUpdate.attendeeInfo.attendeeId)
            item.put("ExternalUserId", volumeUpdate.attendeeInfo.externalUserId)
            item.put("VolumeLevel", volumeUpdate.volumeLevel)
            list.put(item)
        }
        return list
    }
}