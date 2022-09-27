//
//  DrawgramBuilder.swift
//  CurvesDrawer
//
//  Created by serhii.lomov on 13.09.2022.
//

import Foundation

protocol DrawgramBuilderProtocol {}

extension DrawgramBuilderProtocol {

    static func buildBlock() -> [DrawableCurve] { [] }

    static func buildBlock(_ commands: DrawgramBuildingCommand...) -> DrawgramBuildingCommand {
        DB.Group(subcommands: commands)
    }

    static func buildEither(first: DrawgramBuildingCommand) -> DrawgramBuildingCommand {
        return first
    }

    static func buildEither(second: DrawgramBuildingCommand) -> DrawgramBuildingCommand {
        return second
    }
}

@resultBuilder struct DrawgramBuilder: DrawgramBuilderProtocol {

    static func buildFinalResult(_ commands: DrawgramBuildingCommand...) -> [DrawableCurve] {
        var context = DrawgramBuildingContext()
        commands.forEach { $0.execute(in: &context) }

        var threadCurves = context.threads.flatMap { $0.curves }
        threadCurves.sort { $0.crossing.layer < $1.crossing.layer }
        return threadCurves.map {
            DrawableCurve(curve: $0.curve, startAt: $0.startAt, finishAt: $0.finishAt)
        }
    }
}

@resultBuilder struct DrawgramIntermediateBuilder: DrawgramBuilderProtocol {}
