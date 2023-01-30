//
//  ExpansionModel.swift
//  Differentiator
//
//  Created by strayRed on 2023/1/27.
//

import Foundation

public protocol ExpansionModel {
    var expansionState: ExpansionState { get set }
    mutating func updateExpansionState(_ state: ExpansionState)
}

extension ExpansionModel {
    public mutating func updateExpansionState(_ state: ExpansionState) {
        guard expansionState != state && expansionState != .invalid else { return }
        expansionState = state
    }
}

