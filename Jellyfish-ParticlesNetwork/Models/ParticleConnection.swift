//
//  ParticleConnection.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

struct ParticleConnection {

    let start: CGPoint

    let end: CGPoint

    let opacity: CGFloat

    let width: CGFloat

    let isCoreConnection: Bool

    init(
        start: CGPoint,
        end: CGPoint,
        opacity: CGFloat,
        width: CGFloat,
        isCoreConnection: Bool = false
    ) {
        self.start = start
        self.end = end
        self.opacity = opacity
        self.width = width
        self.isCoreConnection = isCoreConnection
    }
}
