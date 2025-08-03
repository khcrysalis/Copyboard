//
//  AppDelegate.swift
//  Copyboard
//
//  Created by samara on 29.03.2025.
//

import Cocoa
import SwiftUI
import ClipKit
import UserNotifications
import MenuBarKit
import KeyboardShortcuts

// MARK: - AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
	/// We store this for later so we can access
	/// our existing functions in the extension
	static var main: AppDelegate!
	
	var menuBar: MBMenuBar?
	private var _settingsWindowController: NSWindowController?
	
	// MARK: Load
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Self.main = self
//		UNUserNotificationCenter.current().delegate = self
		_ = ClipboardMonitorManager.shared
		_ = CBNotificationManager.shared
		_setupStatusItem()
		_setupKeybinds()
	}
	
	func applicationWillTerminate(_ notification: Notification) {
		let shouldClearHistory = UserDefaults.standard.bool(forKey: "CB.clearHistoryOnQuit")
		let erasureTargetIndex = UserDefaults.standard.integer(forKey: "CB.erasureTargetIndex")

		if shouldClearHistory {
			StorageManager.shared.eraseHistory()
		} else if erasureTargetIndex != 0 {
			StorageManager.shared.deleteAllHistoryBeforeDate(for: erasureTargetIndex)
		}
	}
	
	// MARK: Setup
	
	@MainActor
	private func _setupStatusItem() {
		let content = CBContentView(frame: NSRect(x: 0, y: 0, width: 340, height: 520))
		
		menuBar = .init(
			Bundle.main.name,
			systemImage: "paperclip",
			menu: makeGeneralAppMenu(),
			content: content,
			onClick: nil
		)
	}
	
	@MainActor
	private func _setupKeybinds() {
		KeyboardShortcuts.onKeyUp(for: .togglePanel) {
			self.menuBar?.statusItem.toggleWindow()
		}
	}
}

// MARK: - AppDelegate (Extension): Utility functions
extension AppDelegate {
	/// Shows settings window
	@objc func showSettingsWindow() {
		if _settingsWindowController == nil {
			let window = NSWindow()
			window.styleMask = [.closable, .titled, .fullSizeContentView]
			window.toolbarStyle = .unified
			window.center()
			
			window.contentView = NSHostingView(
				rootView: CBSettingsView()
					.frame(minHeight: 500).frame(width: 580)
					.environment(\.managedObjectContext, StorageManager.shared.context)
			)
			
			_settingsWindowController = NSWindowController(window: window)
		}
		
		NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: .init())
		_settingsWindowController?.showWindow(nil)
	}
	/// Shows about window
	@objc func showAboutWindow() {
		NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: .init())
		NSApp.orderFrontStandardAboutPanel()
	}
	
	@objc func pause() {
		ClipboardMonitorManager.shared.stop()
	}
	
	@objc func unpause() {
		ClipboardMonitorManager.shared.unpauseMonitoring()
	}
}

// MARK: - AppDelegate (Extension): Menu
extension AppDelegate {
	
	// MARK: Menu
	
	/// Easier access to the MenuBarItem menu
	@objc func makeGeneralAppMenu() -> NSMenu {
		let menu = NSMenu()
		menu.addItem(NSMenuItem(title: "About \(Bundle.main.name)", action: #selector(showAboutWindow), keyEquivalent: ""))
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: "Settings…", action: #selector(showSettingsWindow), keyEquivalent: ","))
		menu.addItem(NSMenuItem.separator())
		
		let isPaused = ClipboardMonitorManager.shared.isPaused
		let pauseDuration = ClipboardMonitorManager.shared.pauseDiration
		
		var pauseText = "Pause \(Bundle.main.name)"
		
		if ClipboardMonitorManager.shared.isPaused {
			if pauseDuration == 0 {
				pauseText = "Resume \(Bundle.main.name)"
			} else {
				let resumeDate = Date.now + pauseDuration
				
				let formatter = DateFormatter()
				formatter.timeStyle = .short
				formatter.dateStyle = .none
				
				let formatted = formatter.string(from: resumeDate)
				pauseText = "Until \(formatted)"
			}
		}
		
		let pauseItem = NSMenuItem(title: pauseText, action: nil, keyEquivalent: "")
		let pauseSubmenu = NSMenu(title: pauseText)
		
		if isPaused {
			let resumeItem = NSMenuItem(title: "Resume", action: #selector(unpause), keyEquivalent: "t")
			resumeItem.target = self
			pauseSubmenu.addItem(resumeItem)
		} else {
			let resumeItem = NSMenuItem(title: "Pause", action: #selector(pause), keyEquivalent: "t")
			resumeItem.target = self
			pauseSubmenu.addItem(resumeItem)
		}
		
		pauseSubmenu.addItem(NSMenuItem.separator())
		
		let durations: [(String, TimeInterval)] = [
			("5 minutes", 	5 * 60),
			("10 minutes", 	10 * 60),
			("15 minutes", 	15 * 60),
			("30 minutes", 	30 * 60),
			("1 hour", 		60 * 60),
			("2 hours", 	2 * 60 * 60),
			("4 hours", 	4 * 60 * 60),
			("8 hours", 	8 * 60 * 60)
		]
		
		for (label, seconds) in durations {
			let item = NSMenuItem(title: label, action: #selector(handlePauseMenuItem(_:)), keyEquivalent: "")
			item.representedObject = seconds
			item.target = self
			pauseSubmenu.addItem(item)
		}
		
		pauseItem.submenu = pauseSubmenu
		menu.addItem(pauseItem)
		
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: "Quit \(Bundle.main.name)", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
		return menu
	}
	
	@objc func handlePauseMenuItem(_ sender: NSMenuItem) {
		guard let seconds = sender.representedObject as? TimeInterval else { return }
		ClipboardMonitorManager.shared.pauseMonitoring(for: seconds)
	}
}

// MARK: - AppDelegate (Extension): NotificationCenter Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
	/*
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification,
		withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
	) {
		// by default we allow sounds and banners, afterwards
		// we can let the user customize these in settings
		completionHandler([.banner, .sound])
	}
	*/
}
