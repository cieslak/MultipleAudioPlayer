import Foundation
import AVFoundation

@available(iOS 2.2, macOS 10.7, macCatalyst 13.0, tvOS 9.0, watchOS 3.0, *)
public class MultipleAudioPlayer {
    
    private let audioPlayers: [AVAudioPlayer]
    private var currentPlayer = 0
    private let playerDelegate = MultipleAudioPlayerObjCShim()
    
    public convenience init(filenames: [String]) throws {
        let fileURLs: [URL] = filenames.map { filename in
            let nsFilename = filename as NSString
            let fileExtension = nsFilename.pathExtension
            let filePrefix = nsFilename.deletingPathExtension
            guard let fileURL = Bundle.main.url(forResource: filePrefix, withExtension: fileExtension) else {
                fatalError("Main bundle does not contain file")
            }
            return fileURL
        }
        try self.init(fileURLs: fileURLs)
    }
    
    public init(fileURLs: [URL]) throws {
        var players = [AVAudioPlayer]()
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
        if #available(iOS 3.0, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *) {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        #endif
        for url in fileURLs {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self.playerDelegate
            players.append(player)
        }
        self.audioPlayers = players
        self.playerDelegate.delegate = self
    }
    
    // MARK: Public functions
    
    public func playRandom() {
        play(index: Int.random(in: 0..<audioPlayers.count))
    }
    
    public func play(index: Int = 0) {
        guard index < audioPlayers.count else {
            fatalError("index of audio file outside range of files")
        }
        stop()
        currentPlayer = index
        audioPlayers[currentPlayer].play()
    }
    
    public func stop() {
        for player in audioPlayers {
            player.stop()
        }
    }
}

extension MultipleAudioPlayer: MultipleAudioPlayerObjCDelegate {
    func avPlayerDidFinishPlaying() {
        currentPlayer += 1
        if currentPlayer >= audioPlayers.count {
            currentPlayer = 0
        }
        audioPlayers[currentPlayer].play()
    }
}

private protocol MultipleAudioPlayerObjCDelegate: AnyObject {
    func avPlayerDidFinishPlaying()
}

private class MultipleAudioPlayerObjCShim: NSObject, AVAudioPlayerDelegate {
    weak var delegate: MultipleAudioPlayerObjCDelegate?
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.avPlayerDidFinishPlaying()
    }
}
