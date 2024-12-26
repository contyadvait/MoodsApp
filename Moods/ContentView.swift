import SwiftUI

struct MoodsView: View {
    @State private var playlists: [String: [String]] = [:]
    @State private var currentSong: String? = nil
    @State private var availableSongs: [String] = []
    @State private var searchText: String = ""
    @State private var errorMessage: IdentifiableError? = nil
    @Environment(\.dismiss) var dismiss
    @Binding var apiBaseURL: String
    @Binding var apiKey: String
    
    var body: some View {
        TabView {
            VStack {
                NavigationView {
                    VStack {
                        HStack {
                            Text("Moods")
                                .font(.custom("Crimson Pro", size: 36))
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "gearshape.2")
                            }
                        }
                        .padding()
                        List {
                            Section(header: CustomText(text: "All songs", size: 14, font: "Space Grotesk")) {
                                ForEach(filteredSongs, id: \..self) { song in
                                    Button(action: {
                                        playSong(song: song)
                                    }) {
                                        Text(song)
                                            .font(.custom("Space Grotesk", size: 16))
                                    }
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        
                        VStack {
                            HStack {
                                if let currentSong = currentSong {
                                    Button {
                                        sendPlaybackCommand(endpoint: "/pause")
                                    } label: {
                                        Image(systemName: "pause")
                                    }
                                    .padding()
                                    
                                    Button {
                                        sendPlaybackCommand(endpoint: "/resume")
                                    } label: {
                                        Image(systemName: "play")
                                    }
                                    .padding()
                                    
                                    Button {
                                        sendPlaybackCommand(endpoint: "/stop")
                                    } label: {
                                        Image(systemName: "stop")
                                    }
                                    .padding()
                                }
                            }
                            if let currentSong = currentSong {
                                Text("Now Playing: \(currentSong)")
                                    .font(.custom("Space Grotesk", size: 16))
                                    .font(.headline)
                                    .padding()
                            } else {
                                Text("No song is currently playing")
                                    .font(.custom("Space Grotesk", size: 16))
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                    .onAppear {
                        loadPlaylists()
                        loadAvailableSongs()
                    }
                    .alert(item: $errorMessage) { error in
                        Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .ignoresSafeArea()
            .tabItem {
                CustomText(text: "Songs", size: 18, font: "Space Grotesk")
            }
            
            List {
                Section(header: CustomText(text: "Playlists", size: 14, font: "Space Grotesk")) {
                    ForEach(playlists.keys.sorted(), id: \..self) { playlist in
                        Button {
                            playPlaylist(playlist: playlist)
                        } label: {
                            Text(playlist)
                                .font(.custom("Space Grotesk", size: 16))
                        }
                    }
                }
            }
            .tabItem {
                CustomText(text: "Songs", size: 18, font: "Space Grotesk")
            }
        }
    }

    private var filteredSongs: [String] {
        if searchText.isEmpty {
            return availableSongs
        } else {
            return availableSongs.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func loadPlaylists() {
        guard let url = URL(string: "\(apiBaseURL)/playlists") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode([String: [String]].self, from: data)
                DispatchQueue.main.async {
                    playlists = decoded
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: "Failed to decode playlists")
                }
            }
        }.resume()
    }

    private func loadAvailableSongs() {
        guard let url = URL(string: "\(apiBaseURL)/available") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode([String].self, from: data)
                DispatchQueue.main.async {
                    availableSongs = decoded
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: "Failed to decode available songs")
                }
            }
        }.resume()
    }

    private func playSong(song: String) {
        guard let url = URL(string: "\(apiBaseURL)/play") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["key": apiKey, "song": song]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = IdentifiableError(message: "Failed to encode song data")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
                return
            }

            loadCurrentSong()
        }.resume()
    }
    
    private func playPlaylist(playlist: String) {
        guard let url = URL(string: "\(apiBaseURL)/play") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["key": apiKey, "song": playlist]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = IdentifiableError(message: "Failed to encode song data")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
                return
            }

            loadCurrentSong()
        }.resume()
    }

    private func loadCurrentSong() {
        guard let url = URL(string: "\(apiBaseURL)/current") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode([String: String].self, from: data)
                DispatchQueue.main.async {
                    currentSong = decoded["song_playing"]
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: "Failed to decode current song")
                }
            }
        }.resume()
    }

    private func sendPlaybackCommand(endpoint: String) {
        guard let url = URL(string: "\(apiBaseURL)\(endpoint)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
                return
            }

            loadCurrentSong()
        }.resume()
    }
}
