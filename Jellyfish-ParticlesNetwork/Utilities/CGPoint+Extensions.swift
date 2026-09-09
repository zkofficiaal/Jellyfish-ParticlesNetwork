//
//  CGPoint+Extensions.swift
//  Jellyfish-ParticlesNetwork
//
//  Created by Z.K   on 09/09/2026.
//

import CoreGraphics

extension CGPoint {

    // MARK: - Distance

    func distance(
        to point: CGPoint
    ) -> CGFloat {

        let dx = x - point.x
        let dy = y - point.y

        return sqrt(
            (dx * dx) +
            (dy * dy)
        )
    }

    // MARK: - Vector

    func vector(
        to point: CGPoint
    ) -> CGVector {

        return CGVector(
            dx: point.x - x,
            dy: point.y - y
        )
    }

    // MARK: - Add Vector

    func adding(
        _ vector: CGVector
    ) -> CGPoint {

        return CGPoint(
            x: x + vector.dx,
            y: y + vector.dy
        )
    }
}


// MARK: - CGVector Operations

extension CGVector {

    var length: CGFloat {

        sqrt(
            (dx * dx) +
            (dy * dy)
        )
    }

    var normalized: CGVector {

        let magnitude = length

        guard magnitude > 0.0001 else {

            return CGVector(
                dx: 0,
                dy: 0
            )
        }

        return CGVector(
            dx: dx / magnitude,
            dy: dy / magnitude
        )
    }

    func scaled(
        by value: CGFloat
    ) -> CGVector {

        return CGVector(
            dx: dx * value,
            dy: dy * value
        )
    }

    func limited(
        to maximum: CGFloat
    ) -> CGVector {

        let magnitude = length

        guard magnitude > maximum else {
            return self
        }

        return normalized.scaled(
            by: maximum
        )
    }

    static func + (
        lhs: CGVector,
        rhs: CGVector
    ) -> CGVector {

        return CGVector(
            dx: lhs.dx + rhs.dx,
            dy: lhs.dy + rhs.dy
        )
    }

    static func - (
        lhs: CGVector,
        rhs: CGVector
    ) -> CGVector {

        return CGVector(
            dx: lhs.dx - rhs.dx,
            dy: lhs.dy - rhs.dy
        )
    }

    static func * (
        lhs: CGVector,
        rhs: CGFloat
    ) -> CGVector {

        return CGVector(
            dx: lhs.dx * rhs,
            dy: lhs.dy * rhs
        )
    }

    static func * (
        lhs: CGFloat,
        rhs: CGVector
    ) -> CGVector {

        return CGVector(
            dx: rhs.dx * lhs,
            dy: rhs.dy * lhs
        )
    }
}


// MARK: - CGPoint Operators

extension CGPoint {

    static func + (
        lhs: CGPoint,
        rhs: CGVector
    ) -> CGPoint {

        return CGPoint(
            x: lhs.x + rhs.dx,
            y: lhs.y + rhs.dy
        )
    }

    static func - (
        lhs: CGPoint,
        rhs: CGVector
    ) -> CGPoint {

        return CGPoint(
            x: lhs.x - rhs.dx,
            y: lhs.y - rhs.dy
        )
    }
}


// MARK: - CGFloat Helpers

extension CGFloat {

    func clamped(
        minimum: CGFloat,
        maximum: CGFloat
    ) -> CGFloat {

        Swift.min(
            Swift.max(
                self,
                minimum
            ),
            maximum
        )
    }
}
