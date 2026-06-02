import Testing
import SwiftUI
@testable import Hearth

private let box = CGRect(x: 0, y: 0, width: 14, height: 14)
private func near(_ a: CGFloat, _ b: CGFloat, _ tol: CGFloat = 0.5) -> Bool { abs(a - b) <= tol }

@Suite struct SVGPathTests {
    @Test func lineHasZeroHeight() {
        let r = SVGPath(["M0 0 L7 0"]).path(in: box).boundingRect
        #expect(near(r.minX, 0) && near(r.width, 7) && near(r.height, 0))
    }

    @Test func relativeCommands() {
        let r = SVGPath(["M2 2 l4 0 l0 4"]).path(in: box).boundingRect
        #expect(near(r.minX, 2) && near(r.maxX, 6) && near(r.maxY, 6))
    }

    @Test func closedRectBounds() {
        let r = SVGPath(["M1 1 H13 V13 H1 Z"]).path(in: box).boundingRect
        #expect(near(r.minX, 1) && near(r.maxX, 13) && near(r.maxY, 13))
    }

    @Test func arcProducesCircleBounds() {
        let r = SVGPath(["M2 7 A5 5 0 1 0 12 7 A5 5 0 1 0 2 7"]).path(in: box).boundingRect
        #expect(near(r.minX, 2, 1.0) && near(r.maxX, 12, 1.0) && r.height > 8)
    }

    @Test func scalingMapsViewBoxToRect() {
        let r = SVGPath(["M0 0 L14 0"]).path(in: CGRect(x: 0, y: 0, width: 28, height: 28)).boundingRect
        #expect(near(r.width, 28, 1.0))
    }

    @Test func emptyPathIsEmpty() {
        #expect(SVGPath([""]).path(in: box).isEmpty)
    }
}
