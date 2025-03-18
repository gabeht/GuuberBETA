import SwiftUI
import AVKit

struct VideoBackgroundView: View {
    let darkModeVideoName: String
    let lightModeVideoName: String
    @Environment(\.colorScheme) var colorScheme
    @State private var player: AVPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fallback gradient background
                if player == nil {
                    backgroundGradient
                        .edgesIgnoringSafeArea(.all)
                } else {
                    VideoPlayer(player: player!)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .disabled(true)
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onChange(of: colorScheme) { _ in
            setupPlayer()
        }
    }
    
    private var backgroundGradient: some View {
        let colors: [Color] = colorScheme == .dark ?
            [Color.black, Color(red: 0.1, green: 0.1, blue: 0.3)] :
            [Color.white, Color(red: 0.9, green: 0.9, blue: 1.0)]
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func setupPlayer() {
        let videoName = colorScheme == .dark ? darkModeVideoName : lightModeVideoName
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("Could not find video file: \(videoName).mp4")
            player = nil
            return
        }
        
        let newPlayer = AVPlayer(url: URL(fileURLWithPath: path))
        newPlayer.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
        
        player = newPlayer
        player?.play()
    }
}

#Preview {
    VideoBackgroundView(darkModeVideoName: "dark_background", lightModeVideoName: "light_background")
} 
