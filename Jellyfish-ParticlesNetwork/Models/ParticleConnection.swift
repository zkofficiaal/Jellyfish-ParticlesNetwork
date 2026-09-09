//
//  ParticleConnection.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

// MARK: - ParticleConnection
// Represents a connection (line/strand) between two particles in the Jellyfish-ParticlesNetwork.
// Each connection has start/end points and rendering properties.

struct ParticleConnection {

    // MARK: - Endpoints
    let start: CGPoint   // Starting point of the connection
    let end: CGPoint     // Ending point of the connection

    // MARK: - Rendering Properties
    let opacity: CGFloat // Transparency of the connection line
    let width: CGFloat   // Thickness of the connection line

    // MARK: - Initializer
    init(
        start: CGPoint,
        end: CGPoint,
        opacity: CGFloat,
        width: CGFloat
    ) {
        self.start = start
        self.end = end
        self.opacity = opacity
        self.width = width
    }
}
