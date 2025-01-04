//
//  SongManager.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 14/10/2024.
//

import SwiftUI
import AVKit
import MediaPlayer

extension AVAudioFramePosition {
    func toTimeInterval(sampleRate: Double) -> TimeInterval {
        return TimeInterval(self) / sampleRate
    }
}

class SongManager: NSObject, ObservableObject {
    @Published var songs: [Song] = loadSongs() {
        didSet {
            saveSongs(songs)
        }
    }
    @Published var favoriteSongs: [Song] = loadFavouriteSongs() {
        didSet {
            saveFavouriteSongs(favoriteSongs)
            synchronizeFavourites()
        }
    }
    @Published var recentSongs: [Song] = loadRecentSongs() {
        didSet {
            saveRecentSongs(recentSongs)
        }
    }
    @Published var currentSong: Song? = nil
    @Published var isPlaying = false
    @Published var isRepeat = false
    @Published var isShuffle = false

    @Published var currentTime: TimeInterval = 0.0 {
        didSet {
            if currentTime < 0 { currentTime = 0 }
            if currentTime > totalTime { currentTime = totalTime }
        }
    }
    @Published var totalTime: TimeInterval = 0.0 {
        didSet {
            if totalTime < 0 { totalTime = 0 }
        }
    }
    @Published var bassBoostLevel: Float = 0.0 {
        didSet {
            audioEQ.bands[0].gain = bassBoostLevel
        }
    }
    @Published var volume: Float = 0.5 {
        didSet {
            audioPlayerNode?.volume = volume
        }
    }
    
    @Published var isBoosterViewEnabled: Bool = false
    @Published var isEqualizerViewEnabled: Bool = false
    @Published var isMaximizerViewEnabled: Bool = false

    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioEQ: AVAudioUnitEQ!
    var audioFile: AVAudioFile?
    var audioStartTime: AVAudioTime?
    private var timer: Timer?
    
    override init() {
        super.init()
        configureAudioSession()
        setupAudioEngine()
        setupRemoteCommandCenter()
    }

    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEQ = AVAudioUnitEQ(numberOfBands: 1)

        let bassBoostBand = audioEQ.bands[0]
        bassBoostBand.filterType = .lowShelf
        bassBoostBand.frequency = 80.0
        bassBoostBand.gain = bassBoostLevel

        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(audioEQ)

        audioEngine.connect(audioPlayerNode, to: audioEQ, format: nil)
        audioEngine.connect(audioEQ, to: audioEngine.mainMixerNode, format: nil)

        try? audioEngine.start()
    }
    
    func seekToTime(_ time: TimeInterval) {
        guard let audioFile = audioFile else { return }

        let sampleRate = audioFile.processingFormat.sampleRate
        let samplePosition = AVAudioFramePosition(time * sampleRate)

        guard samplePosition < audioFile.length else { return }

        let wasPlaying = isPlaying

        audioPlayerNode.stop()

        let remainingFrames = AVAudioFrameCount(audioFile.length - samplePosition)
        audioPlayerNode.scheduleSegment(audioFile, startingFrame: samplePosition, frameCount: remainingFrames, at: nil, completionHandler: nil)

        currentTime = time

        if let renderTime = audioEngine.outputNode.lastRenderTime {
            audioStartTime = AVAudioTime(sampleTime: renderTime.sampleTime - samplePosition, atRate: sampleRate)
        }

        if wasPlaying {
            audioPlayerNode.play()
        }

        updateNowPlayingInfo()
    }

    func updateNowPlayingInfo() {
        guard let currentSong = currentSong else { return }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyTitle] = currentSong.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentSong.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalTime
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let artwork = UIImage(named: "\(currentSong.image)")  {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { size in
                return artwork
            }
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            self.resumeSong()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pauseSong()
            return .success
        }

        commandCenter.stopCommand.addTarget { [unowned self] event in
            self.stopSong()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.playNextSong(selectedSong: .constant(self.currentSong))
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.playPreviousSong(selectedSong: .constant(self.currentSong))
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pauseSong()
            } else {
                self.resumeSong()
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .noActionableNowPlayingItem }

            let newTime = event.positionTime
            self.seekToTime(newTime)

            return .success
        }
    }

    func playSong(_ song: Song) {
        stopSong()
        currentSong = song
        let fileURL = song.url

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                audioFile = try AVAudioFile(forReading: fileURL)
                guard let audioFile = audioFile else {
                    print("Audio file is nil after loading, cannot play.")
                    return
                }
                audioPlayerNode.scheduleFile(audioFile, at: nil)
                audioPlayerNode.volume = volume
                audioPlayerNode.play()
                isPlaying = true

                totalTime = audioFile.length.toTimeInterval(sampleRate: audioFile.processingFormat.sampleRate)
                currentTime = 0.0
                if let renderTime = audioEngine.outputNode.lastRenderTime {
                    audioStartTime = AVAudioTime(sampleTime: renderTime.sampleTime, atRate: audioFile.processingFormat.sampleRate)
                }

                startProgressTimer()
                updateNowPlayingInfo()
            } catch {
                print("Error loading or playing song: \(error)")
            }
        } else {
            print("File does not exist at path: \(fileURL.path)")
        }
    }

    func playNextSong(selectedSong: Binding<Song?>) {
        guard !songs.isEmpty else { return }

        if isShuffle {
            let availableSongs = songs.filter { $0.id != currentSong?.id }
            guard let randomSong = availableSongs.randomElement() else { return }
            playSong(randomSong)
            selectedSong.wrappedValue = randomSong
        } else {
            guard let currentSong = currentSong,
                  let currentIndex = songs.firstIndex(where: { $0.id == currentSong.id }) else { return }
            let nextIndex = (currentIndex + 1) % songs.count
            let nextSong = songs[nextIndex]
            playSong(nextSong)
            selectedSong.wrappedValue = nextSong
        }
    }

    func playPreviousSong(selectedSong: Binding<Song?>) {
        guard let currentSong = currentSong,
              let currentIndex = songs.firstIndex(where: { $0.id == currentSong.id }) else { return }
        let previousIndex = (currentIndex - 1 + songs.count) % songs.count
        let previousSong = songs[previousIndex]
        playSong(previousSong)
        selectedSong.wrappedValue = previousSong
    }

    func stopSong() {
        currentTime = getCurrentPlaybackTime()
        audioPlayerNode.stop()
        isPlaying = false
        stopProgressTimer()
    }

    func pauseSong() {
        currentTime = getCurrentPlaybackTime()
        audioPlayerNode?.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    func resumeSong() {
        guard let audioFile = audioFile else { return }

        audioPlayerNode.stop()

        let sampleRate = audioFile.processingFormat.sampleRate
        let samplePosition = AVAudioFramePosition(currentTime * sampleRate)

        let remainingFrames = AVAudioFrameCount(audioFile.length - samplePosition)
        audioPlayerNode.scheduleSegment(audioFile, startingFrame: samplePosition, frameCount: remainingFrames, at: nil, completionHandler: nil)

        audioPlayerNode.play()
        isPlaying = true
        startProgressTimer()

        if let renderTime = audioEngine.outputNode.lastRenderTime {
            audioStartTime = AVAudioTime(sampleTime: renderTime.sampleTime - samplePosition, atRate: sampleRate)
        }
    }

    func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            self.currentTime = self.getCurrentPlaybackTime()
            self.updateNowPlayingInfo()

            if self.currentTime >= self.totalTime {
                self.stopProgressTimer()

                if self.isRepeat {
                    self.seekToTime(0)
                    self.playSong(self.currentSong!)
                } else {
                    if let currentSong = self.currentSong {
                        self.playNextSong(selectedSong: .constant(currentSong))
                    }
                }
            }
        })
    }

    func setBassBoost(_ boost: Float) {
        bassBoostLevel = boost
    }

    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }

    func synchronizeFavourites() {
       for i in 0..<songs.count {
           songs[i].isFavorite = favoriteSongs.contains { $0.id == songs[i].id }
       }
   }

    func getCurrentPlaybackTime() -> TimeInterval {
        guard let audioStartTime = audioStartTime else { return currentTime }
        guard let playerTime = audioEngine.outputNode.lastRenderTime else { return currentTime }

        let sampleRate = audioFile?.processingFormat.sampleRate ?? 44100
        let elapsedSample = playerTime.sampleTime - audioStartTime.sampleTime

        return isPlaying ? TimeInterval(elapsedSample) / sampleRate : currentTime
    }

    func toggleFavorite(song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].isFavorite.toggle()

            if songs[index].isFavorite {
                if !favoriteSongs.contains(where: { $0.id == song.id }) {
                    favoriteSongs.append(songs[index])
                }
            } else {
                favoriteSongs.removeAll { $0.id == song.id }
            }
            saveSongs(songs)
            saveFavouriteSongs(favoriteSongs)
        }
    }
    func addSong(_ song: Song) {
        let filename = song.url.lastPathComponent
        let newSong = Song(image: song.image, title: song.title, artist: song.artist, urlString: filename)

        songs.append(newSong)
        saveSongs(songs)
    }
    func deleteSong(_ song: Song) {
        if let currentSong = currentSong, currentSong.id == song.id {
            stopSong()
            self.currentSong = nil
        }
        if let index = songs.firstIndex(where: {$0.id == song.id} ) {
            songs.remove(at: index)
            favoriteSongs.removeAll(where:  {$0.id == song.id})
            recentSongs.removeAll(where: { $0.id == song.id })
            saveSongs(songs)
            saveFavouriteSongs(favoriteSongs)
            saveRecentSongs(recentSongs)
        }
    }
    func isFavorite(song: Song) -> Bool {
        return favoriteSongs.contains(where: { $0.id == song.id })
    }


    func addSongToRecent(_ song: Song) {
        if !recentSongs.contains(song) {
            recentSongs.append(song)
        }
    }

    func removeSongFromRecent(_ song: Song) {
        recentSongs.removeAll { $0.id == song.id }
    }
}

func loadSongs() -> [Song] {
    guard let data = UserDefaults.standard.data(forKey: "savedSongs") else { return [] }
    let decoder = JSONDecoder()
    do {
        return try decoder.decode([Song].self, from: data)
    } catch {
        print("Error decoding saved songs: \(error)")
        return []
    }
}

func saveSongs(_ songs: [Song]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(songs) {
        UserDefaults.standard.set(data, forKey: "savedSongs")
        UserDefaults.standard.synchronize()
    }
}

func loadFavouriteSongs() -> [Song] {
    guard let data = UserDefaults.standard.data(forKey: "favouriteSongs") else { return [] }
    let decoder = JSONDecoder()
    return (try? decoder.decode([Song].self, from: data)) ?? []
}

func saveFavouriteSongs(_ favouriteSongs: [Song]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(favouriteSongs) {
        UserDefaults.standard.set(data, forKey: "favouriteSongs")
    }
}

func loadRecentSongs() -> [Song] {
    guard let data = UserDefaults.standard.data(forKey: "recentSongs") else { return [] }
    let decoder = JSONDecoder()
    return (try? decoder.decode([Song].self, from: data)) ?? []
}

func saveRecentSongs(_ recentSongs: [Song]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(recentSongs) {
        UserDefaults.standard.set(data, forKey: "recentSongs")
    }
}

