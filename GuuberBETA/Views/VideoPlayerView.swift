import SwiftUI
import AVKit

struct VideoPlayerView: UIViewRepresentable {
    let videoName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("Could not find video file: \(videoName)")
            return view
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        
        view.layer.addSublayer(playerLayer)
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        
        player.play()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
}

#Preview {
    ZStack {
        VideoPlayerView(videoName: "dark_background")
            .ignoresSafeArea()
        Text("Content")
            .foregroundColor(.white)
            .font(.largeTitle)
    }
    .frame(height: 400)
} 