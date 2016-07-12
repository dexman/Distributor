//
//  Executable.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/8/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

public protocol Executable {

    var path: String { get }

    func execute(arguments: [String], environment: [String: String]?) throws
}

public struct TaskExecutable: Executable {

    public let path: String
    public let fileManager: FileManager

    public init(path: String, fileManager: FileManager) {
        self.path = path
        self.fileManager = fileManager
    }

    public func execute(arguments: [String], environment: [String: String]?) throws {
        if !fileManager.isExecutableFileAtPath(path) {
            throw NSError(domain: "NSTask", code: 0, userInfo: nil)
        }

        let task = NSTask()
        task.launchPath = path
        task.arguments = arguments
        if environment != nil {
            task.environment = environment
        }

        task.launch()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            throw NSError(
                domain: task.launchPath ?? "NSTask",
                code: Int(task.terminationStatus),
                userInfo: nil)
        }
    }
}