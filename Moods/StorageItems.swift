//
//  StorageItems.swift
//  Moods
//
//  Created by Milind Contractor on 26/12/24.
//

import Foundation
import SwiftUI

struct CustomText: View {
    @State var text: String
    @State var size: CGFloat
    @State var font: String
    var body: some View {
        Text(text)
            .font(.custom(font, size: size))
    }
}

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

struct StorageData: Codable {
    var url: String = ""
    var key: String = ""
}
