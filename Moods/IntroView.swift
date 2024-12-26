//
//  IntroView.swift
//  Moods
//
//  Created by Milind Contractor on 26/12/24.
//

import SwiftUI
import Forever

struct IntroView: View {
    @Forever("userData") var userData = StorageData()
    @AppStorage("firstLaunch") var firstLaunch = true
    @State var showIt = false
    @State var justLaunched = true
    
    var body: some View {
        VStack {
            List {
                if firstLaunch {
                    VStack {
                        HStack {
                            Text("Moods")
                                .font(.custom("Crimson Pro", size: 36))
                            Spacer()
                        }
                        HStack {
                            Text("Please start by configuring your Moods server URL and key")
                                .font(.custom("Space Grotesk", size: 18))
                            Spacer()
                        }
                    }
                } else {
                    HStack {
                        Text("Settings")
                            .font(.custom("Crimson Pro", size: 36))
                        Spacer()
                            .onAppear {
                                if justLaunched {
                                    showIt = true
                                }
                            }
                    }
                }
                HStack {
                    Text("URL:")
                        .font(.custom("Space Grotesk", size: 18))
                    Divider()
                    TextField("http://moods.advaitconty.com", text: $userData.url)
                        .font(.custom("Space Grotesk", size: 18))
                        .keyboardType(.URL)
                }
                HStack {
                    Text("Key:")
                        .font(.custom("Space Grotesk", size: 18))
                    Divider()
                    SecureField("some password", text: $userData.key)
                        .font(.custom("Space Grotesk", size: 18))
                }
                Button {
                    showIt = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        if firstLaunch {
                            Text("Finish setup!")
                                .font(.custom("Space Grotesk", size: 18))
                        } else {
                            Text("Apply changes")
                                .font(.custom("Space Grotesk", size: 18))
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showIt) {
            MoodsView(apiBaseURL: $userData.url, apiKey: $userData.key)
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
