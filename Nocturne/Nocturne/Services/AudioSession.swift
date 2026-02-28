import AVFoundation

enum Audio {}

extension Audio {
    enum Session {
        static func activate() throws {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        }
    }
}
