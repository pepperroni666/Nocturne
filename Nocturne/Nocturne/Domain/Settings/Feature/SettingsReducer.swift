import Foundation

extension Settings {
    enum Reducer: ReducerProtocol {
        typealias State = Settings.State
        typealias Action = Settings.Action
        typealias Dependencies = Settings.Effects

        private static let previewEffectID = EffectID("settings.preview")

        static func reduce(state: inout State, action: Action, dependencies: Effects) -> Effect<Action> {
            switch action {

            case let .soundSelected(sound):
                state.beatSound = sound
                state.isPreviewPlaying = true
                let notify = dependencies.onSoundChanged
                let save = dependencies.saveBeatSound
                let play = dependencies.playPreview
                return .merge([
                    .fireAndForget { await notify(sound); save(sound) },
                    .run(id: previewEffectID) {
                        try? await play(sound)
                        return Task.isCancelled ? nil : .previewFinished
                    }
                ])

            case .previewFinished:
                state.isPreviewPlaying = false
                return .none

            case .loadSettings:
                let load = dependencies.loadBeatSound
                return .run { .settingsLoaded(beatSound: load()) }

            case let .settingsLoaded(beatSound: sound):
                state.beatSound = sound
                return .none
            }
        }
    }
}
