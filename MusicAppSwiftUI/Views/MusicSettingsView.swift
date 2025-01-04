//
//  MusicSettingsView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 24/09/2024.
//

import SwiftUI
import AVFAudio

enum SelectedOption {
    case booster, equalizer, maximizer, none
}

struct MusicSettingsView: View {
    @Binding var showMusicSettingView: Bool
    @Binding var isPlay: Bool
    @Binding var selectedSong: Song?
    @ObservedObject var songManager: SongManager
    @State private var selectedOption: SelectedOption = .none
    @State private var selectedCardTitle: String? = nil
    @State private var isDragging: Bool = false
    @State private var timer: Timer?
    
    let musicSettingCardTitles = ["Default setting", "Flat", "Bass Boost", "Acoustic", "Piano", "Electronics", "Hip-Hop", "Pop", "Rock", "Latino"]
    
    var body: some View {
        ZStack {
            Color("ExtraLight")
                .ignoresSafeArea(.all)
            GeometryReader { geometry in
                ScrollView {
                    headerView()
                    Divider()
                        .padding(.bottom, 10)
                    if selectedOption == .booster {
                        VStack {
                            MaximizerView(value: $songManager.bassBoostLevel, range: -10...10) { newValue in
                                songManager.setBassBoost(newValue)
                            }
                            .transition(.slide)
                            .opacity(songManager.isBoosterViewEnabled ? 1.0 : 0.5)
                            .allowsHitTesting(songManager.isBoosterViewEnabled )
                            Toggle("", isOn: $songManager.isBoosterViewEnabled )
                                .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
                                .frame(width: 60)
                                .padding(.top, 16)
                        }
                    } else if selectedOption == .equalizer {
                        VStack {
                            EqualizerView()
                                .transition(.slide)
                                .opacity(songManager.isEqualizerViewEnabled ? 1.0 : 0.5)
                                .allowsHitTesting(songManager.isEqualizerViewEnabled)
                                .padding(.top, 10)
                                .padding(.trailing, -18)
                            
                            HStack {
                                Toggle("", isOn: $songManager.isEqualizerViewEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
                                    .frame(width: 60)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(musicSettingCardTitles, id: \.self) { title in
                                            MusicSettingCard(isSelected: selectedCardTitle == title, title: title)
                                                .padding(1)
                                                .onTapGesture {
                                                    toggleSelection(for: title)
                                                }
                                        }
                                    }
                                }
                                .padding(.trailing, 16)
                            }
                            .padding(.top, 25)
                        }
                    } else if selectedOption == .maximizer {
                        VStack {
                            MaximizerView(value: $songManager.volume, range: 0...1) { newValue in
                            }
                            .transition(.slide)
                            .opacity(songManager.isMaximizerViewEnabled ? 1.0 : 0.5)
                            .allowsHitTesting(songManager.isMaximizerViewEnabled)
                            Toggle("", isOn: $songManager.isMaximizerViewEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
                                .frame(width: 60)
                                .padding(.top, 16)
                        }
                    } else {
                        if let imageName = selectedSong?.image, let img = UIImage(named: imageName)  {
                            Image(uiImage: img)
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 16)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("Gray"))
                                    .frame(width: geometry.size.width - 32, height: geometry.size.width - 32)
                                    .padding(.horizontal, 16)
                                Image("noImage")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width - 70, height: geometry.size.width - 70)
                            }
                        }
                    }
                    songInfoSection()
                    progressBar()
                    playControls()
                    settingsToggles()
                    Spacer()
                }
            }
        }
        .onAppear {
            songManager.currentTime = songManager.getCurrentPlaybackTime()
            if songManager.isPlaying {
                startTimer()
            } else {
                stopTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Image("arrowDown")
                .frame(width: 32, height: 32)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.2)) {
                        showMusicSettingView = false
                    }
                }
            Spacer()
            Text(selectedSong?.title ?? "Unknown Song")
                .lineLimit(1)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("PrimaryExtraLight"))
            Spacer()
            Image(songManager.isFavorite(song: selectedSong ?? Song(id: UUID(), image: "", title: "", artist: "", urlString: "")) ? "heartTrue" : "heartFalse")
                .frame(width: 32, height: 32)
                .onTapGesture {
                    toggleFavouriteStatus()
                }
        }
        .padding(.horizontal, 16)
    }
    
    private func toggleFavouriteStatus() {
        guard let song = selectedSong else { return }
        songManager.toggleFavorite(song: song)
    }
    
    private func viewToggleSection<V: View>(view: V, isOn: Binding<Bool>, additionalContent: (() -> AnyView)? = nil) -> some View {
        VStack {
            view
                .transition(.slide)
                .opacity(isOn.wrappedValue ? 1.0 : 0.5)
                .allowsHitTesting(isOn.wrappedValue)
            
            HStack {
                Toggle("", isOn: $songManager.isMaximizerViewEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
                    .frame(width: 60)
                
                if let additionalContent = additionalContent {
                    additionalContent()
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if songManager.isPlaying {
                updateProgress()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func cardScrollView() -> AnyView {
        AnyView(
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(musicSettingCardTitles, id: \.self) { title in
                        MusicSettingCard(isSelected: selectedCardTitle == title, title: title)
                            .padding(1)
                            .onTapGesture {
                                toggleSelection(for: title)
                            }
                    }
                }
            }
        )
    }
    
    private func songInfoSection() -> some View {
        VStack(alignment: .leading) {
            MarqueeText(text: selectedSong?.title ?? "Unknown Song", font: .system(size: 24, weight: .semibold), animationDuration: 20)
            
            Text(selectedSong?.artist ?? "Unknown Artist")
                .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
                .font(.system(size: 17, weight: .medium))
            
        }
        .lineLimit(1)
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func progressBar() -> some View {
        VStack {
            Slider(value: Binding(
                get: { songManager.currentTime },
                set: { newValue in
                    songManager.currentTime = newValue
                }),
                   in: 0...songManager.totalTime, onEditingChanged: { isDragging in
                if !isDragging {
                    print("Seeking to time: \(songManager.currentTime)")
                    songManager.seekToTime(songManager.currentTime)
                    
                    if songManager.isPlaying {
                        songManager.resumeSong()
                    }
                }
            }
            )
            
            .tint(Color("PrimaryExtraLight"))
            HStack {
                Text(timeString(time: songManager.currentTime))
                Spacer()
                Text(timeString(time: songManager.totalTime))
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
        }
        .padding(.horizontal, 16)
    }
    
    private func playControls() -> some View {
        HStack {
            Image("shuffle")
                .renderingMode(.template)
                .foregroundColor(songManager.isShuffle ? Color("Primary") : Color("PrimaryExtraLight"))
                .onTapGesture {
                    songManager.isShuffle.toggle()
                }
            Spacer()
            Button {
                songManager.playPreviousSong(selectedSong: $selectedSong)
            } label: {
                Image("skip previous")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            Image(songManager.isPlaying ? "pause" : "play")
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.horizontal, 20)
                .onTapGesture {
                    if songManager.isPlaying {
                        songManager.pauseSong()
                        stopTimer()
                    } else if let song = selectedSong {
                        if let currentSong = songManager.currentSong, currentSong == song {
                            songManager.resumeSong()
                            startTimer()
                        } else {
                            songManager.playSong(song)
                            startTimer()
                        }
                    }
                }
            Button {
                songManager.playNextSong(selectedSong: $selectedSong)
            } label: {
                Image("skip next")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            Image("repeat")
                .renderingMode(.template)
                .foregroundColor(songManager.isRepeat ? Color("Primary") : Color("PrimaryExtraLight"))
                .onTapGesture {
                    songManager.isRepeat.toggle()
                    print("Repeat toggled: \(songManager.isRepeat)")
                }
        }
        .padding(.horizontal, 16)
    }
    
    private func settingsToggles() -> some View {
        HStack {
            Spacer()
            settingsToggleButton(imageName: "booster", title: "Bass Booster", isSelected: selectedOption == .booster) {
                selectedOption = selectedOption == .booster ? .none : .booster
            }
            Spacer()
            settingsToggleButton(imageName: "equalizer", title: "Equalizer", isSelected: selectedOption == .equalizer) {
                selectedOption = selectedOption == .equalizer ? .none : .equalizer
            }
            Spacer()
            settingsToggleButton(imageName: "maximizer", title: "Maximizer", isSelected: selectedOption == .maximizer) {
                selectedOption = selectedOption == .maximizer ? .none : .maximizer
            }
            Spacer()
        }
        .padding(.vertical, 30)
    }
    
    private func settingsToggleButton(imageName: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        VStack {
            Image(imageName)
                .renderingMode(.template)
                .foregroundColor(isSelected ? Color("Primary") : Color("PrimaryExtraLight"))
                .onTapGesture(perform: action)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
        }
        .frame(width: 77, height: 77)
    }
    
    private func toggleSelection(for title: String) {
        selectedCardTitle = selectedCardTitle == title ? nil : title
    }
    
    private func setupAudio() {
        songManager.totalTime = songManager.audioFile?.length.toTimeInterval(sampleRate: songManager.audioFile?.processingFormat.sampleRate ?? 44100) ?? 0.0
        songManager.currentTime = 0.0
    }
    
    private func seekAudio(to time: TimeInterval) {
        guard let audioFile = songManager.audioFile else { return }
        let sampleRate = audioFile.processingFormat.sampleRate
        let samplePosition = AVAudioFramePosition(time * sampleRate)
        songManager.audioPlayerNode.stop()
        songManager.audioPlayerNode.scheduleSegment(audioFile, startingFrame: samplePosition, frameCount: AVAudioFrameCount(audioFile.length - samplePosition), at: nil) {
            self.songManager.audioPlayerNode.stop()
        }
        songManager.audioPlayerNode.play()
        if let renderTime = songManager.audioEngine.outputNode.lastRenderTime {
            songManager.audioStartTime = AVAudioTime(sampleTime: renderTime.sampleTime - samplePosition, atRate: sampleRate)
        }
        songManager.currentTime = time
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        return String(format: "%02d:%02d", minute, second)
    }
    
    private func updateProgress() {
        if songManager.isPlaying {
            songManager.currentTime = songManager.getCurrentPlaybackTime()
        }
    }
}

struct MarqueeText: View {
    let text: String
    let font: Font
    let animationDuration: Double
    @State private var offsetX: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width - 60
            ZStack(alignment: .leading) {
                Text(text)
                    .font(font)
                    .background(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                textWidth = geo.size.width
                                self.containerWidth = containerWidth
                                if textWidth > containerWidth {
                                    startScrolling()
                                }
                            }
                    })
                    .offset(x: offsetX, y: 0)
                    .foregroundColor(Color("PrimaryExtraLight"))
                    .lineLimit(1)
            }
        }
        .frame(height: 30)
        .clipped()
    }
    
    private func startScrolling() {
        let totalScrollDistance = textWidth + containerWidth
        let animation = Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)
        
        withAnimation(animation) {
            offsetX = -totalScrollDistance
        }
    }
}

//
//struct MusicSettingsView: View {
//    @Binding var showMusicSettingView: Bool
//    @Binding var isPlay: Bool
//    @Binding var selectedSong: Song?
//    @ObservedObject var songManager: SongManager
//    @State private var selectedOption: SelectedOption = .none
//    @State private var isBoosterView: Bool = false
//    @State private var isEqualizerView: Bool = false
//    @State private var isMaximizerView: Bool = false
//    @State private var selectedCardTitle: String? = nil
//    @State private var isDragging: Bool = false
//    @State private var timer: Timer?
//
//    let musicSettingCardTitles = ["Default setting", "Flat", "Bass Boost", "Acoustic", "Piano", "Electronics", "Hip-Hop", "Pop", "Rock", "Latino"]
//
//    var body: some View {
//        ZStack {
//            Color("ExtraLight")
//                .ignoresSafeArea(.all)
//            GeometryReader { geometry in
//                ScrollView {
//                    headerView()
//                    Divider()
//                        .padding(.bottom, 10)
//                    if selectedOption == .booster {
//                        VStack {
//                            MaximizerView(value: $songManager.bassBoostLevel, range: -10...10) { newValue in
//                                songManager.setBassBoost(newValue)
//                            }
//                            .transition(.slide)
//                            .opacity(isBoosterView ? 1.0 : 0.5)
//                            .allowsHitTesting(isBoosterView)
//                            Toggle("", isOn: $isBoosterView)
//                                .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
//                                .frame(width: 60)
//                                .padding(.top, 16)
//                        }
//                    } else if selectedOption == .equalizer {
//                        VStack {
//                            EqualizerView()
//                                .transition(.slide)
//                                .opacity(isEqualizerView ? 1.0 : 0.5)
//                                .allowsHitTesting(isEqualizerView)
//                                .padding(.top, 10)
//                                .padding(.trailing, -18)
//
//                            HStack {
//                                Toggle("", isOn: $isEqualizerView)
//                                    .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
//                                    .frame(width: 60)
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: 8) {
//                                        ForEach(musicSettingCardTitles, id: \.self) { title in
//                                            MusicSettingCard(isSelected: selectedCardTitle == title, title: title)
//                                                .padding(1)
//                                                .onTapGesture {
//                                                    toggleSelection(for: title)
//                                                }
//                                        }
//                                    }
//                                }
//                                .padding(.trailing, 16)
//                            }
//                            .padding(.top, 25)
//                        }
//                    } else if selectedOption == .maximizer {
//                        VStack {
//                            MaximizerView(value: $songManager.volume, range: 0...1) { newValue in
//                            }
//                            .transition(.slide)
//                            .opacity(isMaximizerView ? 1.0 : 0.5)
//                            .allowsHitTesting(isMaximizerView)
//                            Toggle("", isOn: $isMaximizerView)
//                                .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
//                                .frame(width: 60)
//                                .padding(.top, 16)
//                        }
//                    } else {
//                        if let imageName = selectedSong?.image, let img = UIImage(named: imageName)  {
//                            Image(uiImage: img)
//                                .scaledToFit()
//                                .frame(maxWidth: .infinity)
//                                .padding(.horizontal, 16)
//                        } else {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .fill(Color("Gray"))
//                                    .frame(width: geometry.size.width - 32, height: geometry.size.width - 32)
//                                    .padding(.horizontal, 16)
//                                Image("noImage")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: geometry.size.width - 70, height: geometry.size.width - 70)
//                            }
//                        }
//                    }
//                    songInfoSection()
//                    progressBar()
//                    playControls()
//                    settingsToggles()
//                    Spacer()
//                }
//            }
//        }
//        .onAppear {
//            songManager.currentTime = songManager.getCurrentPlaybackTime()
//            if songManager.isPlaying {
//                startTimer()
//            } else {
//                stopTimer()
//            }
//        }
//        .onDisappear {
//            stopTimer()
//        }
//        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
//            updateProgress()
//        }
//    }
//
//    private func headerView() -> some View {
//        HStack {
//            Image("arrowDown")
//                .frame(width: 32, height: 32)
//                .onTapGesture {
//                    withAnimation(.easeIn(duration: 0.2)) {
//                        showMusicSettingView = false
//                    }
//                }
//            Spacer()
//            Text(selectedSong?.title ?? "Unknown Song")
//                .lineLimit(1)
//                .font(.system(size: 17, weight: .medium))
//                .foregroundColor(Color("PrimaryExtraLight"))
//            Spacer()
//            Image(songManager.isFavorite(song: selectedSong ?? Song(id: UUID(), image: "", title: "", artist: "", urlString: "")) ? "heartTrue" : "heartFalse")
//                .frame(width: 32, height: 32)
//                .onTapGesture {
//                    toggleFavouriteStatus()
//                }
//        }
//        .padding(.horizontal, 16)
//    }
//
//    private func toggleFavouriteStatus() {
//        guard let song = selectedSong else { return }
//        songManager.toggleFavorite(song: song)
//    }
//
//    private func viewToggleSection<V: View>(view: V, isOn: Binding<Bool>, additionalContent: (() -> AnyView)? = nil) -> some View {
//        VStack {
//            view
//                .transition(.slide)
//                .opacity(isOn.wrappedValue ? 1.0 : 0.5)
//                .allowsHitTesting(isOn.wrappedValue)
//
//            HStack {
//                Toggle("", isOn: $isMaximizerView)
//                    .toggleStyle(SwitchToggleStyle(tint: Color("Primary")))
//                    .frame(width: 60)
//
//                if let additionalContent = additionalContent {
//                    additionalContent()
//                }
//            }
//            .padding(.vertical, 8)
//        }
//    }
//
//    private func startTimer() {
//        stopTimer()
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            if songManager.isPlaying {
//                updateProgress()
//            }
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    private func cardScrollView() -> AnyView {
//        AnyView(
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 8) {
//                    ForEach(musicSettingCardTitles, id: \.self) { title in
//                        MusicSettingCard(isSelected: selectedCardTitle == title, title: title)
//                            .padding(1)
//                            .onTapGesture {
//                                toggleSelection(for: title)
//                            }
//                    }
//                }
//            }
//        )
//    }
//
//    private func songInfoSection() -> some View {
//        VStack(alignment: .leading) {
//            MarqueeText(text: selectedSong?.title ?? "Unknown Song", font: .system(size: 24, weight: .semibold), animationDuration: 20)
//
//            Text(selectedSong?.artist ?? "Unknown Artist")
//                .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
//                .font(.system(size: 17, weight: .medium))
//
//        }
//        .lineLimit(1)
//        .padding(.horizontal, 16)
//        .padding(.top, 20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//
//    private func progressBar() -> some View {
//        VStack {
//            Slider(value: Binding(
//                get: { songManager.currentTime },
//                set: { newValue in
//                    songManager.currentTime = newValue
//                }),
//                   in: 0...songManager.totalTime, onEditingChanged: { isDragging in
//                if !isDragging {
//                    print("Seeking to time: \(songManager.currentTime)")
//                    songManager.seekToTime(songManager.currentTime)
//
//                    if songManager.isPlaying {
//                        songManager.resumeSong()
//                    }
//                }
//            }
//            )
//
//            .tint(Color("PrimaryExtraLight"))
//            HStack {
//                Text(timeString(time: songManager.currentTime))
//                Spacer()
//                Text(timeString(time: songManager.totalTime))
//            }
//            .font(.system(size: 12, weight: .medium))
//            .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
//        }
//        .padding(.horizontal, 16)
//    }
//
//    private func playControls() -> some View {
//        HStack {
//            Image("shuffle")
//                .renderingMode(.template)
//                .foregroundColor(songManager.isShuffle ? Color("Primary") : Color("PrimaryExtraLight"))
//                .onTapGesture {
//                    songManager.isShuffle.toggle()
//                }
//            Spacer()
//            Button {
//                songManager.playPreviousSong(selectedSong: $selectedSong)
//            } label: {
//                Image("skip previous")
//                    .resizable()
//                    .frame(width: 32, height: 32)
//            }
//
//            Image(songManager.isPlaying ? "pause" : "play")
//                .resizable()
//                .frame(width: 64, height: 64)
//                .padding(.horizontal, 20)
//                .onTapGesture {
//                    if songManager.isPlaying {
//                        songManager.pauseSong()
//                        stopTimer()
//                    } else if let song = selectedSong {
//                        if let currentSong = songManager.currentSong, currentSong == song {
//                            songManager.resumeSong()
//                            startTimer()
//                        } else {
//                            songManager.playSong(song)
//                            startTimer()
//                        }
//                    }
//                }
//            Button {
//                songManager.playNextSong(selectedSong: $selectedSong)
//            } label: {
//                Image("skip next")
//                    .resizable()
//                    .frame(width: 32, height: 32)
//            }
//
//            Spacer()
//            Image("repeat")
//                .renderingMode(.template)
//                .foregroundColor(songManager.isRepeat ? Color("Primary") : Color("PrimaryExtraLight"))
//                .onTapGesture {
//                    songManager.isRepeat.toggle()
//                    print("Repeat toggled: \(songManager.isRepeat)")
//                }
//        }
//        .padding(.horizontal, 16)
//    }
//
//    private func settingsToggles() -> some View {
//        HStack {
//            Spacer()
//            settingsToggleButton(imageName: "booster", title: "Bass Booster", isSelected: selectedOption == .booster) {
//                selectedOption = selectedOption == .booster ? .none : .booster
//            }
//            Spacer()
//            settingsToggleButton(imageName: "equalizer", title: "Equalizer", isSelected: selectedOption == .equalizer) {
//                selectedOption = selectedOption == .equalizer ? .none : .equalizer
//            }
//            Spacer()
//            settingsToggleButton(imageName: "maximizer", title: "Maximizer", isSelected: selectedOption == .maximizer) {
//                selectedOption = selectedOption == .maximizer ? .none : .maximizer
//            }
//            Spacer()
//        }
//        .padding(.vertical, 30)
//    }
//
//    private func settingsToggleButton(imageName: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
//        VStack {
//            Image(imageName)
//                .renderingMode(.template)
//                .foregroundColor(isSelected ? Color("Primary") : Color("PrimaryExtraLight"))
//                .onTapGesture(perform: action)
//            Text(title)
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
//        }
//        .frame(width: 77, height: 77)
//    }
//
//    private func toggleSelection(for title: String) {
//        selectedCardTitle = selectedCardTitle == title ? nil : title
//    }
//
//    private func setupAudio() {
//        songManager.totalTime = songManager.audioFile?.length.toTimeInterval(sampleRate: songManager.audioFile?.processingFormat.sampleRate ?? 44100) ?? 0.0
//        songManager.currentTime = 0.0
//    }
//
//    private func seekAudio(to time: TimeInterval) {
//        guard let audioFile = songManager.audioFile else { return }
//        let sampleRate = audioFile.processingFormat.sampleRate
//        let samplePosition = AVAudioFramePosition(time * sampleRate)
//        songManager.audioPlayerNode.stop()
//        songManager.audioPlayerNode.scheduleSegment(audioFile, startingFrame: samplePosition, frameCount: AVAudioFrameCount(audioFile.length - samplePosition), at: nil) {
//            self.songManager.audioPlayerNode.stop()
//        }
//        songManager.audioPlayerNode.play()
//        if let renderTime = songManager.audioEngine.outputNode.lastRenderTime {
//            songManager.audioStartTime = AVAudioTime(sampleTime: renderTime.sampleTime - samplePosition, atRate: sampleRate)
//        }
//        songManager.currentTime = time
//    }
//
//    private func timeString(time: TimeInterval) -> String {
//        let minute = Int(time) / 60
//        let second = Int(time) % 60
//        return String(format: "%02d:%02d", minute, second)
//    }
//
//    private func updateProgress() {
//        if songManager.isPlaying {
//            songManager.currentTime = songManager.getCurrentPlaybackTime()
//        }
//    }
//}
//
//struct MarqueeText: View {
//    let text: String
//    let font: Font
//    let animationDuration: Double
//    @State private var offsetX: CGFloat = 0
//    @State private var textWidth: CGFloat = 0
//    @State private var containerWidth: CGFloat = 0
//
//    var body: some View {
//        GeometryReader { geometry in
//            let containerWidth = geometry.size.width - 60
//            ZStack(alignment: .leading) {
//                Text(text)
//                    .font(font)
//                    .background(GeometryReader { geo in
//                        Color.clear
//                            .onAppear {
//                                textWidth = geo.size.width
//                                self.containerWidth = containerWidth
//                                if textWidth > containerWidth {
//                                    startScrolling()
//                                }
//                            }
//                    })
//                    .offset(x: offsetX, y: 0)
//                    .foregroundColor(Color("PrimaryExtraLight"))
//                    .lineLimit(1)
//            }
//        }
//        .frame(height: 30)
//        .clipped()
//    }
//
//    private func startScrolling() {
//        let totalScrollDistance = textWidth + containerWidth
//        let animation = Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)
//
//        withAnimation(animation) {
//            offsetX = -totalScrollDistance
//        }
//    }
//}

