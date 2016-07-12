//
//  Crashlytics.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/9/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation

public struct Crashlytics {

    let submit: Executable
    let apiKey: String
    let buildSecret: String
    let groupAliases: [String]
    let ipa: IPA

    public init(submit: Executable, apiKey: String, buildSecret: String, groupAliases: [String], ipa: IPA) {
        self.submit = submit
        self.apiKey = apiKey
        self.buildSecret = buildSecret
        self.groupAliases = groupAliases
        self.ipa = ipa
    }

    public func upload() throws {
        try submit.execute(
            [apiKey, buildSecret, "-ipaPath", ipa.path] + groupAliasesArguments,
            environment: nil)
    }

    private var groupAliasesArguments: [String] {
        return groupAliases.isEmpty ? [] : ["-groupAliases", groupAliases.joinWithSeparator(",")]
    }
}