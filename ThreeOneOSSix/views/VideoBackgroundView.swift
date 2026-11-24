import SwiftUI
import AVFoundation

/// Full-screen looping video background — aspect fill, no letterbox.
/// Uses AVPlayerLayer directly so videoGravity = .resizeAspectFill covers
/// every screen size without black bars.
struct VideoBackgroundView: View {
    let videoName: String
    let videoExtension: String

    @StateObject private var player = LoopingPlayer()

    var body: some View {
        VideoLayerView(player: player.avPlayer)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                player.configure(videoName: videoName, videoExtension: videoExtension)
                player.play()
            }
            .onDisappear { player.pause() }
    }

    init(videoName: String, videoExtension: String = "mp4") {
        self.videoName = videoName
        self.videoExtension = videoExtension
    }
}

// MARK: - UIViewRepresentable — AVPlayerLayer con resizeAspectFill

private struct VideoLayerView: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.setPlayer(player)
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

private final class PlayerUIView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
        backgroundColor = .black
    }

    required init?(coder: NSCoder) { fatalError() }

    func setPlayer(_ player: AVQueuePlayer) {
        playerLayer.player = player
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - LoopingPlayer

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
