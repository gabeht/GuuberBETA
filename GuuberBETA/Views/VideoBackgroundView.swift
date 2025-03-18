import SwiftUI
import AVKit

struct VideoBackgroundView: View {
    let darkModeVideoName: String
    let lightModeVideoName: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VideoPlayer(player: createPlayer())
                .edgesIgnoringSafeArea(.all)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .disabled(true) // Disable interaction with the video
                .onAppear {
                    createPlayer().play()
                }
        }
    }
    
    private func createPlayer() -> AVPlayer {
        let videoName = colorScheme == .dark ? darkModeVideoName : lightModeVideoName
        guard let path = Bundle.main.path(forResource: videoName, of: "mp4") else {
            fatalError("Could not find video file: \(videoName)")
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        return player
    }
}

#Preview {
    VideoBackgroundView(darkModeVideoName: "dark_background", lightModeVideoName: "light_background")
} 