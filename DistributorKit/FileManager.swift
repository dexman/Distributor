//
//  FileManager.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/11/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

public protocol FileManager {

    func fileExistsAtPath(path: String) -> Bool

    func isExecutableFileAtPath(path: String) -> Bool

    func contentsOfFileAtPath(path: String) throws -> NSData

    func writeData(data: NSData, toPath: String) throws

    func copyItemAtPath(srcPath: String, toPath: String) throws

    func createDirectoryAtPath(path: String,
                               withIntermediateDirectories: Bool,
                               attributes: [String : AnyObject]?) throws

    func removeItemAtPath(path: String) throws

    func withCurrentDirectoryPath<A>(path: String, block: () throws -> A) throws -> A

    func createManagedTemporaryDirectory() throws -> ManagedFile
}

public class ManagedFile {

    let path: String

    init(path: String, fileManager: FileManager) {
        self.path = path
        self.fileManager = fileManager
    }

    deinit {
        do { try fileManager.removeItemAtPath(path) } catch {}
    }

    private let fileManager: FileManager
}