//
//  CrashlyticsTests.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/10/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import XCTest
@testable import DistributorKit

class CrashlyticsTests: XCTestCase {

    let mockAPIKey = "mockAPIKey"
    let mockSecret = "mockSecret"
    let mockAliases = ["mockAlias0", "mock alias 1"]
    let mockIPA = IPA(path: "/tmp/mock.ipa")

    func testUploadWithAliases() throws {
        let submit = TestExecutable(path: "/tmp/submit") { arguments, _ in
            let expectedArguments = [
                self.mockAPIKey, self.mockSecret, "-ipaPath", self.mockIPA.path, "-groupAliases", "mockAlias0,mock alias 1"]
            XCTAssertEqual(expectedArguments, arguments)
        }

        let crashlytics = Crashlytics(
            submit: submit,
            apiKey: mockAPIKey,
            buildSecret: mockSecret,
            groupAliases: mockAliases,
            ipa: mockIPA)

        try crashlytics.upload()

        XCTAssert(submit.executed)
    }

    func testUploadWithoutAliases() throws {
        let submit = TestExecutable(path: "/tmp/submit") { arguments, _ in
            let expectedArguments = [
                self.mockAPIKey, self.mockSecret, "-ipaPath", self.mockIPA.path]
            XCTAssertEqual(expectedArguments, arguments)
        }

        let crashlytics = Crashlytics(
            submit: submit,
            apiKey: mockAPIKey,
            buildSecret: mockSecret,
            groupAliases: [],
            ipa: mockIPA)

        try crashlytics.upload()

        XCTAssert(submit.executed)
    }
}
