//
//  SystemXcode.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/12/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

public struct SystemXcode: Xcode {

    public let path: String
    public let itms: Executable
    public let itmsPath: String

    public init?(fileManager: FileManager) {
        guard let path = SystemXcode.XcodePath(fileManager) else {
            return nil
        }
        self.path = path
        self.itmsPath = path
            .byDeletingLastPathComponent
            .byAppendingPathComponent("/Applications/Application Loader.app/Contents/itms")
        self.itms = TaskExecutable(
            path: self.itmsPath.byAppendingPathComponent("java/bin/java"),
            fileManager: fileManager)
    }

    public static func XcodePath(fileManager: FileManager) -> String? {
        if !fileManager.isExecutableFileAtPath("/usr/bin/xcode-select") {
            return nil
        }

        let output = NSPipe()

        let task = NSTask()
        task.launchPath = "/usr/bin/xcode-select"
        task.arguments = ["-p"]
        task.standardOutput = output
        task.standardError = output

        task.launch()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            return nil
        }

        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        guard let path = String(data: outputData, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        
        return path.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
    }
}