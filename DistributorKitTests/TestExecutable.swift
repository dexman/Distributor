//
//  TestExecutable.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/10/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation
@testable import DistributorKit

class TestExecutable: Executable {

    let path: String
    var onExecute: ([String], [String: String]?) throws -> ()
    private(set) var executed: Bool = false

    init(path: String, onExecute: ([String], [String: String]?) throws -> ()) {
        self.path = path
        self.onExecute = onExecute
    }

    func execute(arguments: [String], environment: [String: String]?) throws {
        executed = true
        try onExecute(arguments, environment)
    }
}