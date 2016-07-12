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

    enum Error: ErrorType {
        case fileNotFound(path: String)
        case fileNotReadable(path: String)
        case fileNotDirectory(path: String)
        case operationNotSupported
    }

    enum File {
        case File(data: NSData)
        case Directory
    }

    var fileSystem: [String: File] = ["/": .Directory]

    func fileExistsAtPath(path: String) -> Bool {
        return fileSystem[path] != nil
    }

    func isExecutableFileAtPath(path: String) -> Bool {
        return false
    }

    func contentsOfFileAtPath(path: String) throws -> NSData {
        switch fileSystem[path] {
        case .None:
            throw Error.fileNotFound(path: path)
        case .Some(.Directory):
            throw Error.fileNotReadable(path: path)
        case .Some(.File(let data)):
            return data
        }
    }

    func writeData(data: NSData, toPath: String) throws {
        fileSystem[toPath] = .File(data: data)
    }

    func copyItemAtPath(srcPath: String, toPath: String) throws {
        guard let item = fileSystem[srcPath] else {
            throw Error.fileNotFound(path: srcPath)
        }
        fileSystem[toPath] = item
    }

    func createDirectoryAtPath(path: String,
                               withIntermediateDirectories: Bool,
                               attributes: [String : AnyObject]?) throws {
        if !withIntermediateDirectories {
            throw Error.operationNotSupported
        }
        fileSystem[path] = .Directory
    }

    func removeItemAtPath(path: String) throws {
        if fileSystem[path] == nil {
            throw Error.fileNotFound(path: path)
        }
        fileSystem.removeValueForKey(path)
    }

    var currentDirectory = "/"

    func withCurrentDirectoryPath<A>(path: String, block: () throws -> A) throws -> A {
        switch fileSystem[path] {
        case .None:
            throw Error.fileNotFound(path: path)
        case .Some(.File):
            throw Error.fileNotDirectory(path: path)
        case .Some(.Directory):
            let old = currentDirectory
            currentDirectory = path
            defer { currentDirectory = old }
            return try block()
        }
    }

    func createManagedTemporaryDirectory() throws -> ManagedFile {
        defer { temporaryFileCounter += 1 }
        return ManagedFile(path: "/tmp/\(temporaryFileCounter)", fileManager: self)
    }

    private var temporaryFileCounter = 0
}
