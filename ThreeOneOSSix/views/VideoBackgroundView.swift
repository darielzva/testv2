import SwiftUI
import AVKit
import AVFoundation

/// Full-screen looping video background layer.
/// Add the video file to the app bundle and reference it by name + extension.
struct VideoBackgroundView: View {
    let videoName: String
    let videoExtension: String

    @StateObject private var player = LoopingPlayer()

    var body: some View {
        GeometryReader { geo in
            VideoPlayer(player: player.avPlayer)
                .disabled(true)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .allowsHitTesting(false)
                .onAppear {
                    player.configure(videoName: videoName, videoExtension: videoExtension)
                    player.play()
                }
                .onDisappear { player.pause() }
        }
        .ignoresSafeArea()
    }

    init(videoName: String, videoExtension: String = "mp4") {
        self.videoName = videoName
        self.videoExtension = videoExtension
    }
}

@MainActor
private final class LoopingPlayer: ObservableObject {
    let avPlayer: AVQueuePlayer
    private var looper: AVPlayerLooper?

    init() {
        avPlayer = AVQueuePlayer()
        avPlayer.isMuted = true
        avPlayer.allowsExternalPlayback = false
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
    }

    func configure(videoName: String, videoExtension: String) {
        guard looper == nil,
              let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else { return }
        let item = AVPlayerItem(url: url)
        looper = AVPlayerLooper(player: avPlayer, templateItem: item)
    }

    func play()  { avPlayer.play() }
    func pause() { avPlayer.pause() }
}
