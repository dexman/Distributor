//
//  TestFlight.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/8/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import Foundation
import Crypto

public protocol Xcode {

    var path: String { get }

    var itms: Executable { get }

    var itmsPath: String { get }
}

public struct TestFlight {

    public let xcode: Xcode
    public let appID: String
    public let username: String
    public let password: String
    public let ipa: IPA
    public let fileManager: FileManager

    public init(xcode: Xcode, appID: String, username: String, password: String, ipa: IPA, fileManager: FileManager) {
        self.xcode = xcode
        self.appID = appID
        self.username = username
        self.password = password
        self.ipa = ipa
        self.fileManager = fileManager
    }

    public func upload() throws {
        let temporaryDirectory = try fileManager.createManagedTemporaryDirectory()
        let packagePath = temporaryDirectory.path.byAppendingPathComponent("\(self.appID).itmsp")
        let package = try ITMSPackage(appID: self.appID, ipa: self.ipa, path: packagePath, fileManager: self.fileManager)
        try self.fileManager.withCurrentDirectoryPath(self.xcode.itmsPath) {
            let arguments = self.javaArguments + [
                "-m", "upload",
                "-u", self.username, "-p", self.password,
                "-f", package.path,
                "-t", "Signiant", "-k", "100000"]
            try self.xcode.itms.execute(arguments, environment: nil)
        }
    }

    private var javaArguments: [String] {
        let javaExt = xcode.itmsPath.byAppendingPathComponent("java/lib/ext")
        let classpath = xcode.itmsPath.byAppendingPathComponent("lib/itmstransporter-launcher.jar")
        return [
            "-Djava.ext.dirs=\(javaExt)",
            "-XX:NewSize=2m", "-Xms32m", "-Xmx1024m", "-Xms1024m",
            "-Djava.awt.headless=true",
            "-Dsun.net.http.retryPost=false",
            "-classpath", classpath,
            "com.apple.transporter.Application",
        ]
    }
}

class ITMSPackage {

    let appID: String
    let ipa: IPA
    let path: String
    let fileManager: FileManager

    init(appID: String, ipa: IPA, path: String, fileManager: FileManager) throws {
        self.appID = appID
        self.ipa = ipa
        self.path = path
        self.fileManager = fileManager
        self.packageIPAPath = "\(appID).ipa"

        try write()
    }

    private let packageIPAPath: String

    private func write() throws {
        try createEmptyPackage()
        try writeIPA()
        try writeMetadata()
    }

    private func createEmptyPackage() throws {
        if fileManager.fileExistsAtPath(path) {
            try fileManager.removeItemAtPath(path)
        }
        try fileManager.createDirectoryAtPath(
            path,
            withIntermediateDirectories: true,
            attributes: nil)
    }

    private func writeIPA() throws {
        let ipaDestination = path.byAppendingPathComponent(packageIPAPath)
        try fileManager.copyItemAtPath(ipa.path, toPath: ipaDestination)
    }

    private func writeMetadata() throws {
        let fileData = try fileManager.contentsOfFileAtPath(ipa.path)
        let metadataData = try metadata(
            appleID: appID,
            fileSize: UInt64(fileData.length),
            filePath: packageIPAPath,
            fileMD5: fileData.MD5.hexString)
        let packageMetadataPath = path.byAppendingPathComponent("metadata.xml")
        try fileManager.writeData(metadataData, toPath: packageMetadataPath)
    }

    private func metadata(appleID appleID: String, fileSize: UInt64, filePath: String, fileMD5: String) throws -> NSData {
        let package = NSXMLElement(name: "package")
        package.namespaces = [NSXMLNode.namespaceWithName("", stringValue: "http://apple.com/itunes/importer") as! NSXMLNode]
        package.attributes = [NSXMLNode.attributeWithName("version", stringValue: "software5.4") as! NSXMLNode]

        let softwareAssets = NSXMLElement(name: "software_assets")
        softwareAssets.attributes = [
            NSXMLNode.attributeWithName("apple_id", stringValue: appleID) as! NSXMLNode,
            NSXMLNode.attributeWithName("app_platform", stringValue: "ios") as! NSXMLNode
        ]
        package.addChild(softwareAssets)

        let asset = NSXMLElement(name: "asset")
        asset.attributes = [NSXMLNode.attributeWithName("type", stringValue: "bundle") as! NSXMLNode]
        softwareAssets.addChild(asset)

        let dataFile = NSXMLElement(name: "data_file")
        asset.addChild(dataFile)

        let size = NSXMLElement(name: "size")
        size.stringValue = "\(fileSize)"
        dataFile.addChild(size)

        let fileNameElement = NSXMLElement(name: "file_name")
        fileNameElement.stringValue = filePath
        dataFile.addChild(fileNameElement)

        let checksum = NSXMLElement(name: "checksum")
        checksum.attributes = [NSXMLNode.attributeWithName("type", stringValue: "md5") as! NSXMLNode]
        checksum.stringValue = fileMD5
        dataFile.addChild(checksum)

        let document = NSXMLDocument(rootElement: package)
        document.characterEncoding = "UTF-8"
        return document.XMLDataWithOptions(NSXMLNodePrettyPrint)
    }
}