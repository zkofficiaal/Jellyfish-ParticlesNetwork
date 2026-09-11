//
//  ParticleNetworkView.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import SwiftUI

struct ParticleNetworkView: View {

    @State private var viewModel =
        ParticleNetworkViewModel()

    var body: some View {

        GeometryReader { geometry in

            TimelineView(
                .animation(
                    minimumInterval: 1.0 / 60.0,
                    paused: false
                )
            ) { timeline in

                let size =
                    geometry.size

                Canvas(
                    opaque: true,
                    colorMode: .linear,
                    rendersAsynchronously: true
                ) { context, canvasSize in

                    drawConnections(
                        context: &context
                    )

                    drawJellyfishGlow(
                        context: &context
                    )

                    drawParticleGlow(
                        context: &context
                    )

                    drawParticles(
                        context: &context
                    )
                }
                .onAppear {

                    viewModel.start(
                        size: size
                    )
                }
                .onChange(
                    of: timeline.date
                ) { _, newDate in

                    viewModel.update(
                        time:
                            newDate.timeIntervalSinceReferenceDate,
                        size:
                            size
                    )
                }
            }
        }
        .background(
            Color.black
        )
        .contentShape(
            Rectangle()
        )
        .gesture(
            DragGesture(
                minimumDistance: 0,
                coordinateSpace: .local
            )
            .onChanged { value in

                viewModel.setPointer(
                    value.location
                )
            }
            .onEnded { _ in

                viewModel.clearPointer()
            }
        )
        .onContinuousHover(
            coordinateSpace: .local
        ) { phase in

            switch phase {

            case .active(let location):

                viewModel.setPointer(
                    location
                )

            case .ended:

                viewModel.clearPointer()
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Connections

    private func drawConnections(
        context: inout GraphicsContext
    ) {

        let connections =
            viewModel.connections

        for connection in connections {

            var path = Path()

            path.move(
                to: connection.start
            )

            path.addLine(
                to: connection.end
            )

            context.stroke(
                path,
                with:
                    .color(
                        Color.cyan.opacity(
                            connection.opacity
                        )
                    ),
                lineWidth:
                    connection.width
            )
        }
    }

    // MARK: - Jellyfish Glow

    private func drawJellyfishGlow(
        context: inout GraphicsContext
    ) {

        let center =
            viewModel.jellyfishCenter

        context.drawLayer { layer in

            layer.addFilter(
                .blur(
                    radius: 18
                )
            )

            let size: CGFloat = 180

            let rect =
                CGRect(
                    x:
                        center.x - size / 2,
                    y:
                        center.y - size / 2,
                    width:
                        size,
                    height:
                        size
                )

            let gradient =
                Gradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.cyan.opacity(0.07),
                        Color.blue.opacity(0.025),
                        Color.clear
                    ]
                )

            let shading =
                GraphicsContext.Shading.radialGradient(
                    gradient,
                    center: center,
                    startRadius: 0,
                    endRadius: size / 2
                )

            layer.fill(
                Path(
                    ellipseIn: rect
                ),
                with: shading
            )
        }
    }

    // MARK: - Particle Glow

    private func drawParticleGlow(
        context: inout GraphicsContext
    ) {

        let particles =
            viewModel.particles

        context.drawLayer { layer in

            layer.addFilter(
                .blur(
                    radius: 4
                )
            )

            for particle in particles {

                guard particle.intensity > 0.5
                else {
                    continue
                }

                let glowSize =
                    particle.radius * 4

                let rect =
                    CGRect(
                        x:
                            particle.position.x -
                            glowSize / 2,
                        y:
                            particle.position.y -
                            glowSize / 2,
                        width:
                            glowSize,
                        height:
                            glowSize
                    )

                let color =
                    particle.isCore
                    ?
                    Color.cyan.opacity(
                        particle.opacity * 0.30
                    )
                    :
                    Color.white.opacity(
                        particle.opacity * 0.15
                    )

                layer.fill(
                    Path(
                        ellipseIn: rect
                    ),
                    with:
                        .color(color)
                )
            }
        }
    }

    // MARK: - Particles

    private func drawParticles(
        context: inout GraphicsContext
    ) {

        let particles =
            viewModel.particles

        for particle in particles {

            let diameter =
                particle.radius * 2

            let rect =
                CGRect(
                    x:
                        particle.position.x -
                        diameter / 2,
                    y:
                        particle.position.y -
                        diameter / 2,
                    width:
                        diameter,
                    height:
                        diameter
                )

            let opacity =
                (
                    particle.opacity *
                    particle.intensity
                )
                .clamped(
                    minimum: 0,
                    maximum: 1
                )

            context.fill(
                Path(
                    ellipseIn: rect
                ),
                with:
                    .color(
                        Color.white.opacity(
                            opacity
                        )
                    )
            )

            if particle.isCore &&
                particle.intensity > 0.75 {

                let highlightSize =
                    max(
                        0.8,
                        particle.radius * 0.8
                    )

                let highlightRect =
                    CGRect(
                        x:
                            particle.position.x -
                            highlightSize / 2,
                        y:
                            particle.position.y -
                            highlightSize / 2,
                        width:
                            highlightSize,
                        height:
                            highlightSize
                    )

                context.fill(
                    Path(
                        ellipseIn:
                            highlightRect
                    ),
                    with:
                        .color(
                            Color.cyan.opacity(
                                opacity * 0.65
                            )
                        )
                )
            }
        }
    }
}
