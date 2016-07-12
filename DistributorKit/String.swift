//
//  String.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/10/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

public extension String {

    public var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }

    public func byAppendingPathComponent(str: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(str)
    }

    public var byDeletingLastPathComponent: String {
        return (self as NSString).stringByDeletingLastPathComponent
    }
}