//
//  ITMSPackageTests.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/11/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import XCTest
@testable import DistributorKit

class ITMSPackageTests: XCTestCase {

    let appID = "12345"
    let ipa = IPA(path: "/tmp/test.ipa")
    let ipaData = "Hello, world".dataUsingEncoding(NSUTF8StringEncoding)!
    let path = "/tmp/test.itmsp"

    let expectedMetadata =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
        "<package xmlns=\"http://apple.com/itunes/importer\" version=\"software5.4\">\n" +
        "    <software_assets apple_id=\"12345\" app_platform=\"ios\">\n" +
        "        <asset type=\"bundle\">\n" +
        "            <data_file>\n" +
        "                <size>12</size>\n" +
        "                <file_name>12345.ipa</file_name>\n" +
        "                <checksum type=\"md5\">bc6e6f16b8a077ef5fbc8d59d0b931b9</checksum>\n" +
        "            </data_file>\n" +
        "        </asset>\n" +
        "    </software_assets>\n" +
        "</package>"

    func testExample() throws {
        let fileManager = TestFileManager()
        fileManager.fileSystem[ipa.path] = .File(data: ipaData)

        let _ = try ITMSPackage(appID: appID, ipa: ipa, path: path, fileManager: fileManager)

        switch fileManager.fileSystem["/tmp/test.itmsp/12345.ipa"] {
        case .None:
            XCTFail("Expected IPA file to be present.")
        case .Some(.Directory):
            XCTFail("Expected IPA file to a regular file.")
        case .Some(.File(let actualIPAData)):
            XCTAssertEqual(ipaData, actualIPAData)
        }

        switch fileManager.fileSystem["/tmp/test.itmsp/metadata.xml"] {
        case .None:
            XCTFail("Expected metadata file to be present.")
        case .Some(.Directory):
            XCTFail("Expected metadata file to a regular file.")
        case .Some(.File(let actualMetadata)):
            XCTAssertEqual(expectedMetadata, String(data: actualMetadata, encoding: NSUTF8StringEncoding)!)
        }
    }
}
