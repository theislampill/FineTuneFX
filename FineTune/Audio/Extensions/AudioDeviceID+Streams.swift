// FineTune/Audio/Extensions/AudioDeviceID+Streams.swift
import AudioToolbox

// MARK: - Stream Queries

extension AudioDeviceID {
    func hasOutputStreams() -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        let err = AudioObjectGetPropertyDataSize(self, &address, 0, nil, &size)
        guard err == noErr else { return false }
        return size > 0
    }

    func hasInputStreams() -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        let err = AudioObjectGetPropertyDataSize(self, &address, 0, nil, &size)
        guard err == noErr else { return false }
        return size > 0
    }
}
