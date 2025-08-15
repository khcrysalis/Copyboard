//
//  NSNotification++.swift
//  ClipKit
//
//  Created by samara on 26.06.2025.
//

import struct AppKit.Notification

// MARK: - Notifications
extension Notification.Name {
	static public let clipboardDidChange = Notification.Name("CK.clipboardDidChange")
	#warning("we gotta implemtn this!")
	static public let clipboardDidChangeWithObject = Notification.Name("CK.clipboardDidChangeWithObject")
	
	static let windowDidDisappear = Notification.Name("MBK.windowDidDisappear")
}
