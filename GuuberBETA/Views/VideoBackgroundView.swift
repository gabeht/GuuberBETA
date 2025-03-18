import SwiftUI
import AVKit

struct VideoBackgroundView: View {
    let darkModeVideoName: String
    let lightModeVideoName: String
    @Environment(\.colorScheme) var colorScheme
    @State private var player: AVPlayer?
    @State private var debugMessage: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fallback gradient background
                if player == nil {
                    backgroundGradient
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            VStack {
                                Text(debugMessage)
                                    .foregroundColor(.red)
                                    .padding()
                                if let url = Bundle.main.url(forResource: "dark_background", withExtension: "mp4") {
                                    Text("Video URL exists: \(url.path)")
                                        .foregroundColor(.green)
                                        .padding()
                                } else {
                                    Text("Video URL not found in bundle")
                                        .foregroundColor(.red)
                                        .padding()
                                }
                            }
                        )
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
        // Use only dark_background for now
        guard let url = Bundle.main.url(forResource: "dark_background", withExtension: "mp4") else {
            debugMessage = "Could not find video file in bundle"
            
            // Print bundle contents for debugging
            if let bundlePath = Bundle.main.resourcePath {
                print("Bundle path: \(bundlePath)")
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                    print("Bundle contents: \(contents)")
                } catch {
                    print("Error reading bundle: \(error)")
                }
            }
            
            player = nil
            return
        }
        
        debugMessage = "Found video at: \(url.path)"
        let newPlayer = AVPlayer(url: url)
        newPlayer.actionAtItemEnd = .none
        
        // Remove any existing observers
        NotificationCenter.default.removeObserver(self)
        
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
        .frame(height: 400)
} 
