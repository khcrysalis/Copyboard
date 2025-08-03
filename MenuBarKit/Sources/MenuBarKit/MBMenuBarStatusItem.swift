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
		if window.isVisible {
			dismissWindow()
			return
		}
		
		setWindowFrame()
		
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
	
	public func dismissWindow() {
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
		animate: Bool = false
	) {
		guard let statusItemWindow = _statusItem.button?.window else {
			// Fallback: place window in center of screen
			if let size {
				window.setFrame(
					NSRect(origin: window.frame.origin, size: size),
					display: true,
					animate: false
				)
			}
			window.center()
			return
		}

		let statusItemFrame = statusItemWindow.frame
		let newSize = size ?? window.frame.size

		// Center horizontally below the status item
		let centeredX = statusItemFrame.midX - (newSize.width / 2)
		var newFrame = CGRect(
			origin: CGPoint(x: centeredX, y: statusItemFrame.minY - newSize.height - MBConstants.windowMargin),
			size: newSize
		)

		// Clamp within visible screen bounds
		if let screen = statusItemWindow.screen {
			let visibleFrame = screen.visibleFrame
			if newFrame.maxX > visibleFrame.maxX {
				newFrame.origin.x = visibleFrame.maxX - newFrame.width - MBConstants.windowBorderSize - MBConstants.windowMargin
			}
			if newFrame.minX < visibleFrame.minX {
				newFrame.origin.x = visibleFrame.minX + MBConstants.windowBorderSize + MBConstants.windowMargin
			}
		}

		guard newFrame != window.frame else {
			return
		}

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
