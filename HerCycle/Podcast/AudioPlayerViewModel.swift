//
//  AudioPlayerViewModel.swift
//  HerCycle
//
//  Created by Ana on 9/8/24.
//

import AVFoundation

final class AudioPlayerViewModel {
    private var player: AVAudioPlayer?
    var tracks: [AudioTrack]
    var currentTrackIndex: Int
    
    var track: AudioTrack {
        return tracks[currentTrackIndex]
    }
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    var currentTime: TimeInterval {
        return player?.currentTime ?? 0
    }
    
    var duration: TimeInterval {
        return player?.duration ?? 0
    }
    
    var progress: Float {
        return Float(currentTime / duration)
    }
    
    init(tracks: [AudioTrack], currentTrackIndex: Int) {
        self.tracks = tracks
        self.currentTrackIndex = currentTrackIndex
        setupPlayer()
    }
    
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: track.filename, withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Error setting up player: \(error)")
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }
    
    func playPreviousTrack() {
        currentTrackIndex = (currentTrackIndex - 1 + tracks.count) % tracks.count
        setupPlayer()
        play()
    }
    
    func playNextTrack() {
        currentTrackIndex = (currentTrackIndex + 1) % tracks.count
        setupPlayer()
        play()
    }
}
