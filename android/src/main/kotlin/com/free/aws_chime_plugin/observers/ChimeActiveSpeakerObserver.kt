import android.os.Handler
import android.os.Looper.getMainLooper
import com.amazonaws.services.chime.sdk.meetings.audiovideo.AttendeeInfo
import com.amazonaws.services.chime.sdk.meetings.audiovideo.audio.activespeakerdetector.ActiveSpeakerObserver
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

class ChimeActiveSpeakerObserver(
    private val _eventSink: EventChannel.EventSink
) : ActiveSpeakerObserver {
    /** Specifies period (in milliseconds) of updates for onActiveSpeakerScoreChange.
     * If this is null, the observer will not get active speaker score updates.
     *  Should be a value greater than 0. **/
    override val scoreCallbackIntervalMs: Int?
        get() = null

    override fun onActiveSpeakerDetected(attendeeInfo: Array<AttendeeInfo>) {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnActiveSpeakerDetected")
        jsonObject.put("Arguments", attendeeInfoToJson(attendeeInfo))

        Handler(getMainLooper()).post {
            _eventSink.success(jsonObject.toString())
        }
    }

    override fun onActiveSpeakerScoreChanged(scores: Map<AttendeeInfo, Double>) {
        val jsonObject = JSONObject()
        jsonObject.put("Name", "OnActiveSpeakerDetected")
        _eventSink.success(jsonObject.toString())
    }

    private fun attendeeInfoToJson(attendeesInfo: Array<AttendeeInfo>): JSONArray {
        val list = JSONArray()

        for (attendeeInfo in attendeesInfo) {
            val item = JSONObject()
            item.put("AttendeeId", attendeeInfo.attendeeId)
            item.put("ExternalUserId", attendeeInfo.externalUserId)
            list.put(item)
        }
        return list
    }
}