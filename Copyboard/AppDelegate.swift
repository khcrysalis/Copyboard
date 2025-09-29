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
#if !DEBUG
import Sparkle
#endif

// MARK: - AppDelegate

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
	/// We store this for later so we can access
	/// our existing functions in the extension
	static var main: AppDelegate!
	
	var menuBar: MBMenuBar?
	private var _settingsWindowController: NSWindowController?
	#if !DEBUG
	static var updaterController: SPUStandardUpdaterController!
	#endif
	
	// MARK: Load
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Self.main = self
//		UNUserNotificationCenter.current().delegate = self
		_ = ClipboardMonitorManager.shared
		_ = CBNotificationManager.shared
		#if !DEBUG
		Self.updaterController = SPUStandardUpdaterController(
			startingUpdater: true, 
			updaterDelegate: nil, 
			userDriverDelegate: nil
		)
		Self.updaterController.updater.automaticallyChecksForUpdates = UserDefaults.standard.bool(forKey: "CB.automaticUpdates")
		Self.updaterController.updater.updateCheckInterval = 3600
		#endif
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
	
	private func _setupKeybinds() {
		KeyboardShortcuts.onKeyUp(for: .togglePanel) {
			self.menuBar?.statusItem.showWindowAtPoint(
				at: UserDefaults.standard.bool(forKey: "CB.panelShouldAppearAtMenuBar") == true 
				? nil 
				: NSEvent.mouseLocation
			)
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
		menu.addItem(NSMenuItem(title: .localized("About %@", arguments: Bundle.main.name), action: #selector(showAboutWindow), keyEquivalent: ""))
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: .localized("Settings..."), action: #selector(showSettingsWindow), keyEquivalent: ","))
		menu.addItem(NSMenuItem.separator())
		
		let isPaused = ClipboardMonitorManager.shared.isPaused
		let pauseDuration = ClipboardMonitorManager.shared.pauseDiration
		
		var pauseText: String = .localized("Pause %@", arguments: Bundle.main.name)
		
		if ClipboardMonitorManager.shared.isPaused {
			if pauseDuration == 0 {
				pauseText = .localized("Resume %@", arguments: Bundle.main.name)
			} else {
				let resumeDate = Date.now + pauseDuration
				
				let formatter = DateFormatter()
				formatter.timeStyle = .short
				formatter.dateStyle = .none
				
				let formatted = formatter.string(from: resumeDate)
				pauseText = .localized("Until %@", arguments: formatted)
			}
		}
		
		let pauseItem = NSMenuItem(title: pauseText, action: nil, keyEquivalent: "")
		let pauseSubmenu = NSMenu(title: pauseText)
		
		if isPaused {
			let resumeItem = NSMenuItem(title: .localized("Resume"), action: #selector(unpause), keyEquivalent: "t")
			resumeItem.target = self
			pauseSubmenu.addItem(resumeItem)
		} else {
			let resumeItem = NSMenuItem(title: .localized("Pause"), action: #selector(pause), keyEquivalent: "t")
			resumeItem.target = self
			pauseSubmenu.addItem(resumeItem)
		}
		
		pauseSubmenu.addItem(NSMenuItem.separator())
		
		let durations: [(String, TimeInterval)] = [
			String.localizedDuration(minutes: 5),
			String.localizedDuration(minutes: 10),
			String.localizedDuration(minutes: 15),
			String.localizedDuration(minutes: 30),
			String.localizedDuration(hours: 1),
			String.localizedDuration(hours: 2),
			String.localizedDuration(hours: 4),
			String.localizedDuration(hours: 8)
		]
		
		for (label, seconds) in durations {
			let item = NSMenuItem(title: label, action: #selector(_handlePauseMenuItem(_:)), keyEquivalent: "")
			item.representedObject = seconds
			item.target = self
			pauseSubmenu.addItem(item)
		}
		
		pauseItem.submenu = pauseSubmenu
		menu.addItem(pauseItem)
		
		menu.addItem(NSMenuItem.separator())
		
		let deleteAllItem = NSMenuItem(title: .localized("Erase History..."), action: #selector(deleteHistoryWithAlert), keyEquivalent: "\u{8}")
		deleteAllItem.target = self
		menu.addItem(deleteAllItem)
		
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: .localized("Quit %@", arguments: Bundle.main.name), action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
		return menu
	}
	
	@objc private func _handlePauseMenuItem(_ sender: NSMenuItem) {
		guard let seconds = sender.representedObject as? TimeInterval else { return }
		ClipboardMonitorManager.shared.pauseMonitoring(for: seconds)
	}
	
	@objc func deleteHistoryWithAlert() {
		let alert = NSAlert()
		alert.messageText = String.localized ("Erase")
		alert.informativeText = String.localized("Are you sure you want to erase your history?")
		alert.alertStyle = .warning
		alert.addButton(withTitle: String.localized ("Erase"))
		alert.addButton(withTitle: String.localized ("Cancel"))
		
		if (alert.runModal() == .alertFirstButtonReturn){
			StorageManager.shared.eraseHistory()
		}
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
