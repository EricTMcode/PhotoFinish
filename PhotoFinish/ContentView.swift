//
//  ContentView.swift
//  PhotoFinish
//
//  Created by Eric on 19/09/2025.
//

import SwiftUI

struct ContentView: View {
    enum MoveDirection {
        case up, down, left, right
    }

    var gridSize: Int
    var tileSize: Double
    var columns: [GridItem]

    @State private var images: [Image?]
    @State private var dragOffset = CGSize.zero
    @State private var dragTileIndex: Int? = nil

    @State private var moves = 0
    var correctLayout: [Image?]

    var isGameWon: Bool {
        correctLayout == images
    }

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<gridSize * gridSize, id: \.self) { index in
                    TileView(
                        tileSize: tileSize,
                        offset: dragTileIndex == index ? dragOffset : .zero,
                        image: images[index]
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{ value in
                                dragOffset = getConstrainedOffset(for: index, translation: value.translation)
                                dragTileIndex = index
                            }
                            .onEnded { value in
                                handleDragEnded(tileIndex: index, translation: getConstrainedOffset(for: index, translation: value.translation))
                                dragOffset = .zero
                            }
                    )
                }
            }

            if isGameWon {
                Text("You Won!")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                    .bold()
            }
        }
        .onAppear(perform: shuffleTiles)
        .navigationTitle("Moves: \(moves)")
        .navigationBarTitleDisplayMode(.inline)
    }

    init(gridSize: Int, images: [Image?]) {
        self.gridSize = gridSize

        tileSize = 350 / Double(gridSize)

        columns = Array(repeating: GridItem(.fixed(tileSize), spacing: 2), count: gridSize)

        _images = State(initialValue: images)

        correctLayout = images
    }

    func getAdjacentIndices(for index: Int) -> [Int] {
        let row = index / gridSize
        let col = index % gridSize

        var adjacent = [Int]()

        if row > 0 { adjacent.append(index - gridSize) }
        if row < gridSize - 1 { adjacent.append(index + gridSize) }
        if col > 0 { adjacent.append(index - 1) }
        if col < gridSize - 1 { adjacent.append(index + 1) }

        return adjacent
    }

    func shuffleTiles() {
        for _ in 0..<1000 {
            let emptyIndex = images.firstIndex(of: nil)!
            let possibleMoves = getAdjacentIndices(for: emptyIndex)

            if let randomMove = possibleMoves.randomElement() {
                images.swapAt(emptyIndex, randomMove)
            }
        }
    }

    func getValidMoveDirection(for tileIndex: Int) -> MoveDirection? {
        let emptyIndex = images.firstIndex(of: nil)!
        let adjacentToEmpty = getAdjacentIndices(for: emptyIndex)

        guard adjacentToEmpty.contains(tileIndex) else { return nil }

        let tileRow = tileIndex / gridSize
        let tileCol = tileIndex % gridSize
        let emptyRow = emptyIndex / gridSize
        let emptyCol = emptyIndex % gridSize

        if tileRow == emptyRow {
            return tileCol < emptyCol ? .right : .left
        } else {
            return tileRow < emptyRow ? .down : .up
        }
    }

    func getConstrainedOffset(for tileIndex: Int, translation: CGSize) -> CGSize {
        guard let direction = getValidMoveDirection(for: tileIndex) else { return .zero }

        let sizePlusSpacing = tileSize + 2

        switch direction {
        case .up:
            return CGSize(width: 0, height: translation.height.clamped(in: -sizePlusSpacing...0))
        case .down:
            return CGSize(width: 0, height: translation.height.clamped(in: 0...sizePlusSpacing))
        case .left:
            return CGSize(width: translation.width.clamped(in: -sizePlusSpacing...0), height: 0)
        case .right:
            return CGSize(width: translation.width.clamped(in: 0...sizePlusSpacing), height: 0)
        }
    }

    func handleDragEnded(tileIndex: Int, translation: CGSize) {
        guard let direction = getValidMoveDirection(for: tileIndex) else { return }

        let dragDistance = switch direction {
        case .up, .down: abs(translation.height)
        case .left, .right: abs(translation.width)
        }

        if dragDistance > tileSize * 0.5 {
            let emptyIndex = images.firstIndex(of: nil)!
            images.swapAt(tileIndex, emptyIndex)

            moves += 1
        }
    }
}

#Preview {
    let gridSize = 3
    let startImages = (0..<gridSize*gridSize).dropLast().map { Image(systemName: "\($0).circle") } + [nil]


    ContentView(gridSize: 3, images: startImages)
}


