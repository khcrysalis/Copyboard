//
//  StorageManager+history.swift
//  ClipKit
//
//  Created by samara on 26.06.2025.
//

import AppKit
import Combine
import Carbon

// MARK: - ClipboardMonitorManager
public final class ClipboardMonitorManager: @unchecked Sendable, ObservableObject {
	public static let shared = ClipboardMonitorManager()
	
	@Published public private(set) var pauseDiration: TimeInterval = 0
	@Published public private(set) var isPaused: Bool = false
	
	public var monitorInterval: CGFloat = 0.25
	public var cancellable: AnyCancellable? // Combine
	public var pauseWorkItem: DispatchWorkItem?
	
	private let _clipboardQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".Queue")
	private let _pasteboard = NSPasteboard.general
	private var _lastChangeCount: Int = NSPasteboard.general.changeCount

	public init() {
		start()
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(_pasteCurrentClipboard),
			name: .windowDidDisappear,
			object: nil
		)
	}
	
	// MARK: Startup
	
	public func start() {
		isPaused = false
		pauseDiration = 0
		guard cancellable == nil else { return }
		cancellable = Timer.publish(every: TimeInterval(monitorInterval), on: .main, in: .common)
			.autoconnect()
			.receive(on: _clipboardQueue)
			.sink { [weak self] _ in
				self?._didChange()
			}
	}
	
	public func stop() {
		cancellable?.cancel()
		cancellable = nil
		isPaused = true
		pauseDiration = 0
	}
	
	public func pauseMonitoring(for seconds: TimeInterval = 60) {
		print("paused")
		pauseWorkItem?.cancel()
		stop()
		isPaused = true
		pauseDiration = seconds
		
		let workItem = DispatchWorkItem { [weak self] in
			self?.start()
			self?.pauseWorkItem = nil
		}
		
		pauseWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: workItem)
	}
	
	public func unpauseMonitoring() {
		print("unpaused")
		pauseWorkItem?.cancel()
		pauseWorkItem = nil
		if cancellable == nil { start() }
		isPaused = false
		pauseDiration = 0
	}
}

// MARK: - ClipboardMonitorManager (Extension): Checks
extension ClipboardMonitorManager {
	private func _didChange() {
		let current = _pasteboard.changeCount
		guard current != _lastChangeCount else { return }
		_lastChangeCount = current
		_checkClipboardItems()
	}
	
	private func _checkClipboardItems() {
		/// we check if its empty, we also check if the pasteboard
		/// item should pass this check, we check for some settings
		/// the user has chosen for ignoring certain types of
		/// pasteboards, for example transient and confidential.
		///
		/// we also fail this check if we're copying from ourself,
		/// or some other clipboard manager apps.
		guard
			let items = _pasteboard.pasteboardItems,
			!items.isEmpty,
			!items.contains(where: _shouldIgnorePasteboardItem)
		else {
			print("skipping this history item fully")
			return
		}
		
		DispatchQueue.main.async {
			StorageManager.shared.createHistory(items: items) { _ in }
		}
	}
	
	private func _shouldIgnorePasteboardItem(_ item: NSPasteboardItem) -> Bool {
		if item.types.contains(where: NSPasteboard.PasteboardType.ignoredTypes.contains) {
			return true
		}
		
		if
			UserDefaults.standard.bool(forKey: "CK.ignoreApps"),
			item.types.contains(where: NSPasteboard.PasteboardType.appTypes.contains)
		{
			return true
		}
		
		if
			UserDefaults.standard.bool(forKey: "CK.ignoreTransient"),
			item.types.contains(where: NSPasteboard.PasteboardType.transientTypes.contains)
		{
			return true
		}
		
		if
			UserDefaults.standard.bool(forKey: "CK.ignoreConfidential"),
			item.types.contains(where: NSPasteboard.PasteboardType.confidentialTypes.contains)
		{
			return true
		}
		
		return false
	}
}

#warning("send a notification out with pasteboard data")

// MARK: - ClipboardMonitorManager (Extension): Add
extension ClipboardMonitorManager {
	/// Adds database object to your clipboard.
	/// - Parameters:
	///   - object: History object
	///   - asPlain: Whether to strip non-plain types like RTF/HTML
	public func addToClipboard(
		using object: CBObject?,
		asPlain: Bool = false
	) {
		guard let itemsSet = object?.items as? Set<CBObjectItem> else { return }
		
		let pasteboardItems: [NSPasteboardItem] = createPasteboardObjects(using: itemsSet, asPlain: asPlain)
		// theres tons of data in a clipboard, how we do it is
		// we save every single piece of data from the clipboard
		// without stripping anything (if wanted), so when adding
		// to your clipboard, you recieve a 1 to 1 replica of
		// what was initially copied
		_pasteboard.clearContents()
		_pasteboard.writeObjects(pasteboardItems)
	}
	
	public func createPasteboardObjects(
		using itemsSet: Set<CBObjectItem>,
		asPlain: Bool = false
	) -> [NSPasteboardItem] {
		Array(itemsSet).map { item in
			let pasteboardItem = NSPasteboardItem()
			pasteboardItem.setData(Data(), forType: .mainBundle)
			if let typedData = item.data {
				let filteredData: [String: Data]
				
				if asPlain {
					let disallowedTypes: Set<NSPasteboard.PasteboardType> = [
						.rtf,
						.rtfd,
						.html
					]
					
					filteredData = typedData.filter { key, _ in
						let type = NSPasteboard.PasteboardType(key)
						return !disallowedTypes.contains(type)
					}
				} else {
					filteredData = typedData
				}
				
				for (type, data) in filteredData {
					pasteboardItem.setData(data, forType: NSPasteboard.PasteboardType(type))
				}
			}
			
			return pasteboardItem
		}
	}
	
	@objc private func _pasteCurrentClipboard() {
		guard
			UserDefaults.standard.bool(forKey: "CK.shouldPasteAutomatically"),
			AXIsProcessTrustedWithOptions(nil) 
		else {
			return 
		}
		
		let source = CGEventSource(stateID: .combinedSessionState)
		
		source?.setLocalEventsFilterDuringSuppressionState(
			[.permitLocalMouseEvents, .permitSystemDefinedEvents],
			state: .eventSuppressionStateSuppressionInterval
		)
		
		let cmdFlag = CGEventFlags(rawValue: UInt64(NSEvent.ModifierFlags.command.rawValue))
		
		let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
		let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
		keyVDown?.flags = cmdFlag
		keyVUp?.flags = cmdFlag
		keyVDown?.post(tap: .cgSessionEventTap)
		keyVUp?.post(tap: .cgSessionEventTap)
	}
}
