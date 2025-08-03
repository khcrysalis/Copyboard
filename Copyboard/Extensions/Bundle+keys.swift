//
//  Bundle+versions.swift
//  Loader
//
//  Created by samara on 18.03.2025.
//

import Foundation.NSBundle

extension Bundle {
	/// Get the name of the app
	public var name: String {
		if let name = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
			name
		} else if let name = object(forInfoDictionaryKey: "CFBundleName") as? String {
			name
		} else {
			object(forInfoDictionaryKey: "CFBundleExecutable") as? String ?? Bundle.main.executableURL?.lastPathComponent ?? ""
		}
	}
}
