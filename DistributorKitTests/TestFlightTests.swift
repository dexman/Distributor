//
//  TestFlightTests.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/10/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import XCTest
import OCMock
@testable import DistributorKit

class TestFlightTests: XCTestCase {

    let xcode: TestXcode = TestXcode()
    let username = "hello"
    let password = "world"
    let appID = "12345"
    let ipa = IPA(path: "/tmp/mock.ipa")

    func testUpload() throws {
        let fileManager = TestFileManager()
        fileManager.fileSystem[ipa.path] = .File(data: "Hello, world".dataUsingEncoding(NSUTF8StringEncoding)!)
        fileManager.fileSystem["/Applications/Xcode-Test.app/itms"] = .Directory

        (xcode.itms as! TestExecutable).onExecute = { arguments, _ in
            let expectedArguments = [
                "-Djava.ext.dirs=/Applications/Xcode-Test.app/itms/java/lib/ext",
                "-XX:NewSize=2m", "-Xms32m", "-Xmx1024m", "-Xms1024m",
                "-Djava.awt.headless=true", "-Dsun.net.http.retryPost=false",
                "-classpath", "/Applications/Xcode-Test.app/itms/lib/itmstransporter-launcher.jar",
                "com.apple.transporter.Application", "-m", "upload",
                "-u", self.username, "-p", self.password,
                "-f", "/tmp/0/12345.itmsp",
                "-t", "Signiant", "-k", "100000"
            ]

            XCTAssertEqual(expectedArguments, arguments)
            XCTAssertEqual("/Applications/Xcode-Test.app/itms", fileManager.currentDirectory)
        }

        let testFlight = TestFlight(
            xcode: xcode,
            appID: appID,
            username: username,
            password: password,
            ipa: ipa,
            fileManager: fileManager)

        try testFlight.upload()

        XCTAssert((xcode.itms as! TestExecutable).executed)
    }
}