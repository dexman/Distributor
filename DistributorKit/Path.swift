//
//  Path.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/9/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

struct Path {

    init(string: String) {
        self.path = string
    }

    var absolutePath: String {
        return ""
    }

    var relativePath: String {
        return ""
    }

    func join(path: Path) -> Path {
        return self
    }

    private let path: String
}


class CurrentDirectory {

    init(fileManager: NSFileManager, path: String) {
        self.originalPath = fileManager.currentDirectoryPath
        self.fileManager = fileManager
        fileManager.changeCurrentDirectoryPath(path)
    }

    deinit {
        fileManager.changeCurrentDirectoryPath(originalPath)
    }

    private let originalPath: String
    private let fileManager: NSFileManager
}

class TemporaryDirectory {

    init(fileManager: NSFileManager) throws {
        self.fileManager = fileManager

        let processInfo = NSProcessInfo.processInfo()

        let sharedTemporaryDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory())
        url = sharedTemporaryDirectory.URLByAppendingPathComponent(processInfo.globallyUniqueString, isDirectory: true)

        try fileManager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
    }

    deinit {
        do { try fileManager.removeItemAtURL(url) } catch {}
    }

    var path: Path {
        return Path(string: url.path!)
    }

    private let url: NSURL
    private let fileManager: NSFileManager
}