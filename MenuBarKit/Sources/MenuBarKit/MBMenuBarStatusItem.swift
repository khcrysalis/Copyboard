//
//  MenuBarStatusItem.swift
//  MenuBarKit
//
//  Created by samsam on 7/27/25.
//

import AppKit

// MARK: - MenuBarStatusItem
@MainActor
final public class MBMenuBarStatusItem: NSObject, NSWindowDelegate {
	var _localEventMonitor: MBEventMonitor?
	var _globalEventMonitor: MBEventMonitor?
	
	// MARK: Init
	
	public let window: NSWindow
	public var menu: NSMenu?
	@objc let _statusItem: NSStatusItem
	private var _onClick: (() -> Void)?
	
	public init(
		title: String,
		systemImage: String,
		window: NSWindow,
		menu: NSMenu? = nil,
		onClick: (() -> Void)? = nil
	) {
		self.window = window
		self.menu = menu
		self._onClick = onClick
		
		_statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		_statusItem.button?.image = NSImage(
			systemSymbolName: systemImage,
			accessibilityDescription: title
		)
		_statusItem.button?.setAccessibilityTitle(title)

		super.init()
		
		_setupMonitors()
		window.delegate = self
		_localEventMonitor?.start()
	}
	
	deinit {
		weak var weakSelf = self
		Task { @MainActor in
			if let item = weakSelf?._statusItem {
				NSStatusBar.system.removeStatusItem(item)
			}
		}
	}
	
	// MARK: Setup
	
	private func _setupMonitors() {
		_localEventMonitor = MBLocalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
			guard
				let self,
				let button = self._statusItem.button,
				event.window == button.window
			else {
				return event
			}
			
			switch (event.type, self.menu) {
			case (.leftMouseDown, _):
				if !event.modifierFlags.contains(.command) {
					if let action = self._onClick {
						action()
					} else {
						self.didPressStatusBarButton(button)
					}
					return nil
				}
			case (.rightMouseDown, let menu?):
				self._statusItem.menu = menu
				button.performClick(nil)
				self._statusItem.menu = nil
				return nil
			default:
				break
			}
			
			return event
		}
		
		_globalEventMonitor = MBGlobalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
			if
				let window = self?.window,
				window.isKeyWindow
			{
				window.resignKey()
			}
		}
	}
	
	// MARK: Actions
	
	private func didPressStatusBarButton(_ sender: NSStatusBarButton) {
		showWindowAtPoint(at: nil)
	}
	
	public func showWindowAtPoint(at screenPoint: CGPoint?) {
		if window.isVisible {
			dismissWindow()
			return
		}
		
		setWindowFrame(screenPoint: screenPoint)
		
		// Tells the system to persist the menu bar in full screen mode.
		DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
		window.makeKeyAndOrderFront(nil)
	}
	
	public func showWindow() {
		guard
			!window.isVisible,
			let button = _statusItem.button
		else {
			return
		}
		
		didPressStatusBarButton(button)
	}
	
	public func dismissWindow(_ sendNotification: Bool = false) {
		// Tells the system to cancel persisting the menu bar in full screen mode.
		DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
		
		NSAnimationContext.runAnimationGroup { context in
			context.duration = 0.3
			context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			
			window.animator().alphaValue = 0
			
		} completionHandler: { [weak self] in
			if let self {
				DispatchQueue.main.async {
					self.window.orderOut(nil)
					self.window.alphaValue = 1
					self._setStatusItemHighlighted(false)
					if sendNotification {
						NotificationCenter.default.post(name: .windowDidDisappear, object: nil)
					}
				}
			}
		}
	}
	
	public func toggleWindow() {
		if window.isVisible {
			dismissWindow()
		} else {
			showWindow()
		}
	}
	
	func _setStatusItemHighlighted(_ highlight: Bool) {
		_statusItem.button?.highlight(highlight)
	}

	// MARK: Frame

	public func setWindowFrame(
		size: CGSize? = nil,
		animate: Bool = false,
		screenPoint: CGPoint? = nil
	) {
		let newSize = size ?? window.frame.size
		var origin = CGPoint.zero

		let screen = _statusItem.button?.window?.screen ?? NSScreen.main
		let visibleFrame = screen?.visibleFrame ?? NSScreen.main!.visibleFrame

		if let point = screenPoint {
			// Niche: show at point
			var y = point.y - newSize.height - MBConstants.windowMargin
			if y < visibleFrame.minY {
				y = point.y + MBConstants.windowMargin
			}

			var x = point.x - newSize.width / 2
			
			x = min(
				max(x, visibleFrame.minX + MBConstants.windowMargin), 
				visibleFrame.maxX - newSize.width - MBConstants.windowMargin
			)
			
			origin = CGPoint(x: x, y: y)
		} else if let statusWindow = _statusItem.button?.window {
			// Default: below status item
			var x = statusWindow.frame.midX - newSize.width / 2
			
			x = min(
				max(x, visibleFrame.minX + MBConstants.windowBorderSize + MBConstants.windowMargin),
				visibleFrame.maxX - newSize.width - MBConstants.windowBorderSize - MBConstants.windowMargin
			)
			
			let y = statusWindow.frame.minY - newSize.height - MBConstants.windowMargin
			origin = CGPoint(x: x, y: y)
		} else {
			// Fallback: center screen
			origin = CGPoint(
				x: visibleFrame.midX - newSize.width / 2,
				y: visibleFrame.midY - newSize.height / 2
			)
		}

		let newFrame = CGRect(origin: origin, size: newSize)
		guard newFrame != window.frame else { return }
		window.setFrame(newFrame, display: true, animate: animate)
	}
}

// MARK: - MenuBarStatusItem (extension): Overrides
extension MBMenuBarStatusItem {
	public func windowDidBecomeKey(_ notification: Notification) {
		_globalEventMonitor?.start()
		_setStatusItemHighlighted(true)
	}
	
	public func windowDidResignKey(_ notification: Notification) {
		_globalEventMonitor?.stop()
		dismissWindow()
	}
}
