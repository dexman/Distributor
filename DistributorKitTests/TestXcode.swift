//
//  TestXcode.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/12/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation
@testable import DistributorKit

struct TestXcode: Xcode {

    let path = "/Applications/Xcode-Test.app"

    let itms: Executable = TestExecutable(
        path: "/Applications/Xcode-Test.app/itms",
        onExecute: { _, _ in })

    let itmsPath = "/Applications/Xcode-Test.app/itms"

}