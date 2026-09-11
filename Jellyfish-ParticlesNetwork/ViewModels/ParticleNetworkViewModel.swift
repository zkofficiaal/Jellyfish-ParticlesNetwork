//
//  ParticleNetworkViewModel.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics
import Foundation

@MainActor
final class ParticleNetworkViewModel {

    private let simulation =
        ParticleSimulationService()

    var particles: [Particle] {
        simulation.particles
    }

    var jellyfishCenter: CGPoint {
        simulation.jellyfishCenter
    }

    var connections: [ParticleConnection] {
        simulation.connections()
    }

    func start(
        size: CGSize
    ) {
        simulation.reset(
            size: size
        )
    }

    func update(
        time: TimeInterval,
        size: CGSize
    ) {
        simulation.update(
            time: time,
            size: size
        )
    }

    func setPointer(
        _ location: CGPoint
    ) {
        simulation.setPointer(
            location
        )
    }

    func clearPointer() {
        simulation.clearPointer()
    }
}
