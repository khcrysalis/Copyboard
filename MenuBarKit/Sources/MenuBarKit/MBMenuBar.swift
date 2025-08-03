//
//  MenuBarKit.swift
//  MenuBarKit
//
//  Created by samara on 5.07.2025.
//

import AppKit

// MARK: - MenuBar
@MainActor
public final class MBMenuBar {
	
	public let statusItem: MBMenuBarStatusItem
	public let statusWindow: NSPanel
	
	// MARK: Init
	
	public init(
		_ title: String,
		systemImage: String,
		animation: NSWindow.AnimationBehavior = .none,
		menu: NSMenu? = nil,
		content: NSView,
		onClick: (() -> Void)? = nil
	) {
		statusWindow = MBMenuBarContentView(
			title: title,
			content: content,
			animation: animation
		)
		
		statusItem = MBMenuBarStatusItem(
			title: title,
			systemImage: systemImage,
			window: statusWindow,
			menu: menu,
			onClick: onClick
		)
	}
}
