//
//  StorageManager+historyItems.swift
//  ClipKit
//
//  Created by samara on 27.06.2025.
//

import Foundation
import AppKit.NSPasteboardItem

// MARK: - StorageManager (Extension): History Item Management
extension StorageManager {
	/// Creates and sorts an array for history items.
	/// - Parameter pasteboardItems: NSPasteboardItem's
	/// - Returns: Array of history item object's
	public func createItems(using pasteboardItems: [NSPasteboardItem]) -> [CBObjectItem] {
		pasteboardItems.enumerated().compactMap { index, item -> CBObjectItem? in
			let types = _sortPasteboardTypes(item.types.map { $0.rawValue })
			
			let data = types.reduce(into: [String: Data]()) { result, type in
				if let data = item.data(forType: .init(type)) {
					result[type] = data
				}
			}
			
			let itemObject = CBObjectItem(context: context)
			itemObject.item = Int64(index)
			itemObject.types = types
			itemObject.data = data
			return itemObject
		}
	}
	
	private func _sortPasteboardTypes(_ types: [String]) -> [String] {
		types.sorted { lhs, rhs in
			let isDynLhs = lhs.hasPrefix("dyn.")
			let isDynRhs = rhs.hasPrefix("dyn.")
			let isPublicLhs = lhs.hasPrefix("public.")
			let isPublicRhs = rhs.hasPrefix("public.")
			
			if isDynLhs != isDynRhs {
				return isDynLhs // "dyn." types first
			}
			
			if isPublicLhs != isPublicRhs {
				return !isPublicLhs // "public." types last
			}
			
			return lhs.count < rhs.count // Sort by length
		}
	}
}
