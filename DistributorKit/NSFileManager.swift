//
//  NSFileManager.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/10/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

extension NSFileManager: FileManager {

    public func contentsOfFileAtPath(path: String) throws -> NSData {
        return try NSData(contentsOfFile: path, options: [])
    }

    public func writeData(data: NSData, toPath: String) throws {
        try data.writeToFile(toPath, options: .AtomicWrite)
    }

    public func withCurrentDirectoryPath<A>(path: String, block: () throws -> A) throws -> A {
        let fileManager = NSFileManager.defaultManager()
        let originalPath = fileManager.currentDirectoryPath

        if !fileManager.changeCurrentDirectoryPath(path) {
            throw NSError(domain: NSCocoaErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil)
        }

        defer { fileManager.changeCurrentDirectoryPath(originalPath) }
        return try block()
    }

    public func createManagedTemporaryDirectory() throws -> ManagedFile {
        let processInfo = NSProcessInfo.processInfo()

        let sharedTemporaryDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let uniqueTemporaryDirectory = sharedTemporaryDirectory.URLByAppendingPathComponent(processInfo.globallyUniqueString, isDirectory: true)

        try createDirectoryAtURL(uniqueTemporaryDirectory, withIntermediateDirectories: true, attributes: nil)

        return ManagedFile(path: uniqueTemporaryDirectory.path!, fileManager: self)
    }
}
