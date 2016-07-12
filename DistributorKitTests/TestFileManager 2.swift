//
//  TestFileManager.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/11/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation
@testable import DistributorKit

class TestFileManager: FileManager {

    var lastCurrentDirectoryPath: String?
    var temporaryDirectory: String = "/tmp"

    func fileExistsAtPath(path: String) -> Bool {
        return false
    }

    func copyItemAtPath(srcPath: String, toPath: String) throws {

    }

    func createDirectoryAtPath(path: String,
                               withIntermediateDirectories: Bool,
                               attributes: [String : AnyObject]?) throws {

    }

    func removeItemAtPath(path: String) throws {

    }
    
    func withCurrentDirectoryPath<A>(path: String, block: () throws -> A) rethrows -> A {
        lastCurrentDirectoryPath = path
        return try block()
    }

    func withTemporaryDirectory<A>(block: (String) throws -> A) throws -> A {
        return try block(temporaryDirectory)
    }
}