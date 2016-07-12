//
//  NSData.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/11/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

extension NSData {

    var hexString: String {
        var result = ""

        var current = UnsafePointer<UInt8>(bytes)
        let end = UnsafePointer<UInt8>(bytes.advancedBy(length))
        while current < end {
            result.appendContentsOf(String(format: "%02x", current.memory))
            current = current.successor()
        }

        return result
    }
}

