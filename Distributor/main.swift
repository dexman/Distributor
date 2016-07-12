//
//  main.swift
//  Distributor
//
//  Created by Arthur Dexter on 7/11/16.
//  Copyright © 2016 Arthur Dexter. All rights reserved.
//

import CommandLine
import DistributorKit

func uploadToCrashlytics(arguments arguments: [String]) throws {
    let frameworkPath = StringOption(
        shortFlag: "f", longFlag: "framework", required: true,
        helpMessage: "Path to Crashlytics.frameworks")
    let key = StringOption(
        shortFlag: "k", longFlag: "key", required: true,
        helpMessage: "Crashlytics API key")
    let secret = StringOption(
        shortFlag: "s", longFlag: "secret", required: true,
        helpMessage: "Crashlytics secret")
    let groups = StringOption(
        shortFlag: "g", longFlag: "groups", required: false,
        helpMessage: "Crashlytics distribution groups (comma separated)")
    let ipaPath = StringOption(
        shortFlag: "i", longFlag: "ipa", required: true,
        helpMessage: "Path to IPA file to upload")

    let cli = CommandLine(arguments: arguments)
    cli.addOptions(frameworkPath, key, secret, groups, ipaPath)
    do {
        try cli.parse()
    } catch {
        cli.printUsage(error)
        throw error
    }

    let crashlytics = Crashlytics(
        submit: TaskExecutable(
            path: frameworkPath.value!.byAppendingPathComponent("submit"),
            fileManager: NSFileManager.defaultManager()),
        apiKey: key.value!,
        buildSecret: secret.value!,
        groupAliases: (groups.value ?? "").componentsSeparatedByString(","),
        ipa: IPA(path: ipaPath.value!))
    try crashlytics.upload()
}

func uploadToTestFlight(arguments arguments: [String]) throws {
    let username = StringOption(
        shortFlag: "u", longFlag: "username", required: true,
        helpMessage: "iTunes Connect username")
    let password = StringOption(
        shortFlag: "p", longFlag: "password", required: true,
        helpMessage: "iTunes Connect password")
    let appID = StringOption(
        shortFlag: "a", longFlag: "appID", required: true,
        helpMessage: "iTunes Connect application ID")
    let ipaPath = StringOption(
        shortFlag: "i", longFlag: "ipa", required: true,
        helpMessage: "Path to IPA file to upload")

    let cli = CommandLine(arguments: arguments)
    cli.addOptions(username, password, appID, ipaPath)
    do {
        try cli.parse()
    } catch {
        cli.printUsage(error)
        throw error
    }

    if let xcode = SystemXcode(fileManager: NSFileManager.defaultManager()) {
        let testFlight = TestFlight(
            xcode: xcode,
            appID: appID.value!,
            username: username.value!,
            password: password.value!,
            ipa: IPA(path: ipaPath.value!),
            fileManager: NSFileManager.defaultManager())
        try testFlight.upload()
    } else {
        print("No system Xcode found")
    }
}

func parseCommandLineArguments() throws {
    // Skip over program name
    let arguments = Process.arguments.suffixFrom(1)

    let commandName = arguments.first ?? "help"
    switch commandName {
    case "crashlytics":
        try uploadToCrashlytics(arguments: Array(arguments.suffixFrom(1)))
    case "testflight":
        try uploadToTestFlight(arguments: Array(arguments.suffixFrom(1)))
    default:
        print("Usage: \(Process.arguments.first!.lastPathComponent) <crashlytics|testflight|help> [options...]")
        break
    }
}

do  {
    try parseCommandLineArguments()
} catch {
    print("\(error)")
}


// Also look in environment variables

// distribute:crashlytics -c /path/to/Crashlytics.framework -a API_TOKEN -s BUILD_SECRET -g groups

// distribute:itunesconnect -a me@email.com -p myitunesconnectpassword -i appleid --upload
