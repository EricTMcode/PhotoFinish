//
//  CGFloat-Clamped.swift
//  PhotoFinish
//
//  Created by Eric on 19/09/2025.
//

import Foundation

extension BinaryFloatingPoint {
    func clamped(in range: ClosedRange<Self>) -> Self {
        Swift.max(range.lowerBound, Swift.min(self, range.upperBound))
    }
}
