//
//  ContentView.swift
//  CurvesDrawer
//
//  Created by serhii.lomov on 11.09.2022.
//

import SwiftUI

struct ContentView: View {

    private let strokeStyle = StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
    private let backColor = Color(red: 0.75, green: 0.67, blue: 0.88)
    private let strokeColor = Color(red: 0.6, green: 0.25, blue: 0.6)

    private let cornerRadius = 0.25
    private let centerRadius = 0.4
    private let cornerOffset = 0.5 - 0.25 / 2
    private let leafsCount = 10
    private let stepByStep = false
    private var duration: TimeInterval { stepByStep ? 5.0 : 2.5 }

    @State private var progress: DrawingProgress = .zero

    var body: some View {
        let opacity: CGFloat = progress == .zero ? 0 : 1
        CenteredGeometryReader {
            backColor
                .ignoresSafeArea(.all)
            DrawableCurvesView(elements: curves, undercolor: backColor)
                .opacity(opacity)
                .animation(nil, value: opacity)
                .drawingProgress(progress)
                .environment(\.drawingWidth, 20)
                .animation(.linear(duration: duration), value: progress)
                .foregroundColor(strokeColor)
                .aspectRatio(1, contentMode: .fit)
                .padding(50)
        }
        .onTapGesture {
            progress = .full
        }
    }

    @DrawgramBuilder var curves: [DrawableCurve] {
        CB.AddThread {
            let topRightCorner = BezierCurve
                .arc(from: .pi * 0.75, to: .pi * -0.25, radius: 0.5)
                .scaled(x: cornerRadius, y: cornerRadius)
                .translated(x: cornerOffset, y: -1 * cornerOffset)
                .smoothed(mult1: 1.5, mult2: 1.5)

            TB.Thread.Name("Diagonal1")
            TB.Thread.Start(curve: topRightCorner)
            TB.Continue.Line(to: topRightCorner.p0.mirrored())
            TB.Crossing(.bottom, .top, .bottom, .top)
            TB.Repeat.Mirrored()
            centerFinish
        }

        CB.RotatedThread(source: "Diagonal1", name: "Diagonal2", angle: .hpi)
        CB.InverseThreadCrossing(name: "Diagonal2")

        CB.AddThread {
            let topCorner = BezierCurve
                .arc(from: .pi * 0.75, to: .pi * 0.25, radius: 0.5)
                .scaled(x: centerRadius, y: centerRadius)
                .translated(x: 0, y: -1 * (0.5 - centerRadius / 2))

            TB.Thread.Name("OutLoop")
            outerStart
            TB.Thread.Start(curve: topCorner)
            TB.Continue.Line(to: topCorner.p0.rotated(angle: -.hpi))
            TB.Repeat.Rotated(angle: -.hpi)
            TB.Repeat.Mirrored()
        }
    }

    var centerFinish: TB.Timestamp {
        stepByStep ? .init(0.5) : .init(1)
    }

    var outerStart: TB.Timestamp {
        stepByStep ? .init(0.5) : .init(0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
