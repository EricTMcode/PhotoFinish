//
//  MenuView.swift
//  PhotoFinish
//
//  Created by Eric on 19/09/2025.
//

import PhotosUI
import SwiftUI

struct MenuView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var gridImages = [Image]()
    @State private var selectedImage: UIImage?
    @State private var gridSize = 3

    var body: some View {
        NavigationStack {
            Form {
                Picker("Size", selection: $gridSize) {
                    Text("Small").tag(3)
                    Text("Medium").tag(4)
                    Text("Large").tag(5)
                    Text("Epic").tag(6)
                    Text("Evil").tag(7)
                }

                PhotosPicker("Select Image", selection: $selectedItem, matching: .images)

                Section {
                    NavigationLink("Start", value: true)
                        .disabled(gridImages.isEmpty)
                }
            }
            .navigationTitle("PhotoFinish")
            .onChange(of: selectedItem) {
                Task {
                    guard let data = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                    selectedImage = UIImage(data: data)
                    splitImageIntoGrid(gridSize: gridSize)
                }
            }
            .onChange(of: gridSize) {
                splitImageIntoGrid(gridSize: gridSize)
            }
        }
    }

    func cropToSquare(_ image: UIImage) -> UIImage {
        let sideLength = min(image.size.width, image.size.height)

        let x = (image.size.width - sideLength) / 2
        let y = (image.size.height - sideLength) / 2
        let cropRect = CGRect(x: x, y: y, width: sideLength, height: sideLength)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage)
    }

    func splitImageIntoGrid(gridSize: Int) {
        guard let selectedImage else { return }

        let squareImage = cropToSquare(selectedImage)
        let pieceSize = squareImage.size.width / Double(gridSize)

        var pieces = [Image]()

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let x = Double(col) * pieceSize
                let y = Double(row) * pieceSize
                let rect = CGRect(x: x, y: y, width: pieceSize, height: pieceSize)

                if let cgImage = squareImage.cgImage?.cropping(to: rect) {
                    let pieceImage = UIImage(cgImage: cgImage)
                    pieces.append(Image(uiImage: pieceImage))
                }
            }
        }

        gridImages = pieces
    }
}

#Preview {
    MenuView()
}
