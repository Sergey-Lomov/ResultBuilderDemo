//
//  ContentView.swift
//  CurvesDrawer
//
//  Created by serhii.lomov on 11.09.2022.
//

import SwiftUI

enum Symbol {
    case flower, celtic
}

struct ContentView: View {

    private let strokeStyle = StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
    private let backColor = Color(red: 0.75, green: 0.67, blue: 0.88)
    private let strokeColor = Color(red: 0.6, green: 0.25, blue: 0.6)

    private let cornerRadius = 0.25
    private let centerRadius = 0.4
    private let cornerOffset = 0.5 - 0.25 / 2
    private let leafsCount = 10
    private let stepByStep = true
    private let sharps = true
    private var symbol = Symbol.celtic

    private var duration: TimeInterval {
        switch symbol {
        case .celtic:
            return stepByStep ? 5.0 : 2.5
        case .flower:
            return 6.0
        }
    }

    @State private var progress: DrawingProgress = .zero

    var body: some View {
        let opacity: CGFloat = progress == .zero ? 0 : 1
        CenteredGeometryReader {
            backColor
                .ignoresSafeArea(.all)
            VStack {
                TupleView((
                    Text("1"),
                    Text("2"),
                    Text("3"),
                    Text("4"),
                    Text("5"),
                    Text("6"),
                    Text("7"),
                    Text("8"),
                    Text("9"),
                    Text("10"),
                    Text("11")
                ))
            }
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
        switch symbol {
        case .flower:
            flower()
        case .celtic:
            celtic()
        }
    }

    @DrawgramIntermediateBuilder func flower() -> DrawgramBuildingCommand {
        DB.AddThread {
            let leafLeft = BezierCurve(x0: 0, y0: 0, x1: -0.15, y1: -0.1, x2: -0.25, y2: -0.3, x3: 0, y3: -0.5)

            TB.Thread.Start(curve: leafLeft)
            TB.Repeat.SelfMirrored(reversion: true)
            for _ in 1..<leafsCount {
                TB.Repeat.Rotated(last: 2, angle: -.dpi / CGFloat(leafsCount))
            }
        }
    }

    @DrawgramIntermediateBuilder func celtic() -> DrawgramBuildingCommand {
        DB.AddThread {
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
            if stepByStep { TB.Timestamp(0.5) }
        }

        DB.RotatedThread(source: "Diagonal1", name: "Diagonal2", angle: .hpi)
        DB.InverseThreadCrossing(name: "Diagonal2")

        DB.AddThread {
            let topCorner = BezierCurve
                .arc(from: .pi * 0.75, to: .pi * 0.25, radius: 0.5)
                .scaled(x: centerRadius, y: centerRadius)
                .translated(x: 0, y: -1 * (0.5 - centerRadius / 2))

            TB.Thread.Name("OutLoop")
            if stepByStep { TB.Timestamp(0.5) }
            TB.Thread.Start(curve: topCorner)

            if sharps {
                TB.Continue.Line(to: topCorner.p0.rotated(angle: .hpi))
                TB.Repeat.Rotated(angle: .hpi)
            } else {
                TB.Continue.Line(to: topCorner.p0.rotated(angle: -.hpi))
                TB.Repeat.Rotated(angle: -.hpi)
            }

            TB.Repeat.Mirrored()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
