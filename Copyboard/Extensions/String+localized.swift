//
//  String+localized.swift
//  NimbleKit
//
//  Created by samara on 20.03.2025.
//

import Foundation.NSString
import SwiftUI

extension String {
	// from: https://github.com/NSAntoine/Antoine/blob/main/Antoine/Backend/Extensions/Foundation.swift#L43-L55
	// was given permission to use any code from antoine as I like - thank you Serena!~
	
	static public func localized(_ name: String) -> String {
		NSLocalizedString(name, comment: "")
	}
	
	static public func localized(_ name: String, arguments: CVarArg...) -> String {
		String(format: NSLocalizedString(name, comment: ""), arguments: arguments)
	}
	
	static func pluralized(_ key: String, _ value: Int) -> String {
		String.localizedStringWithFormat(NSLocalizedString(key, comment: ""), value)
	}
	
	/// Localizes the current string using the main bundle.
	///
	/// - Returns: The localized string.
	public func localized() -> String {
		String.localized(self)
	}
}

extension LocalizedStringKey {
	static public func localized(_ key: String) -> LocalizedStringKey {
		LocalizedStringKey(key)
	}
	
	static func pluralized(_ key: String, _ value: Int) -> LocalizedStringKey {
		LocalizedStringKey(String.localizedStringWithFormat(NSLocalizedString(key, comment: ""), value))
	}
}

// MARK: - Helpers
extension String {
	static func localizedDuration(minutes: Int) -> (String, TimeInterval) {(
		String.pluralized("%d minutes", minutes), 
		TimeInterval(minutes * 60)
	)}

	static func localizedDuration(hours: Int) -> (String, TimeInterval) {(
		String.pluralized("%d hours", hours), 
		TimeInterval(hours * 3600)
	)}
}
