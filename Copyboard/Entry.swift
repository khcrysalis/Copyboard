//
//  Entry.swift
//  Copyboard
//
//  Created by samara on 5.07.2025.
//

import Cocoa
import ClipKit

// MARK: - Entry Point
@main struct Entry {
	static func main() {
		UserDefaults.standard.register(defaults: [
			"CK.ignoreApps": true,
			"CK.ignoreTransient": true,
			"CK.ignoreConfidential": true,
			"CB.automaticUpdates": true,
		])
		let appDelegate = AppDelegate()
		NSApplication.shared.delegate = appDelegate
		// before fully starting the application we should
		// initilize our coredata database, to avoid any
		// troubles when it comes to doing it later on
		_ = StorageManager.shared
		_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
	}
}
