//
//  TileView.swift
//  PhotoFinish
//
//  Created by Eric on 19/09/2025.
//

import SwiftUI

struct TileView: View {
    var tileSize: Double
    var offset: CGSize
    var image: Image?
    var body: some View {
        if let image {
            image
                .resizable()
                .frame(width: tileSize, height: tileSize)
                .offset(offset)
        } else {
            Color.clear
        }
    }
}

#Preview {
    TileView(tileSize: 60, offset: .zero, image: Image(systemName: "1.circle"))
}
