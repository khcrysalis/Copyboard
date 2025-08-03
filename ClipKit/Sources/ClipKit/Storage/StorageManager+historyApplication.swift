//
//  StorageManager+historyApplication.swift
//  ClipKit
//
//  Created by samara on 27.06.2025.
//

import Foundation
import CoreData
import AppKit.NSWorkspace

// MARK: - StorageManager (Extension): History Application Management
extension StorageManager {
	/// Gets application object from database if applicable.
	/// - Parameter bundleUrl: File URL to bundle
	/// - Returns: Application object
	public func getApplication(for bundleUrl: URL) -> CBApplication? {
		let fetchRequest: NSFetchRequest<CBApplication> = CBApplication.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "bundleUrl == %@", bundleUrl as CVarArg)
		fetchRequest.fetchLimit = 1
		
		return try? context.fetch(fetchRequest).first
	}
	/// Creates an application for the current frontmost application if needed.
	/// - Returns: Application object
	public func createApplication(for bundle: URL? = nil) -> CBApplication? {
		guard let applicationBundleUrl = bundle ?? NSWorkspace.shared.frontmostApplication?.bundleURL else {
			return nil
		}
		
		if let existingApp = getApplication(for: applicationBundleUrl) {
			print("already exists skiping!")
			return existingApp
		}
		
		let newObject = CBApplication(context: context)
		newObject.uuid = UUID().uuidString
		newObject.bundleUrl = applicationBundleUrl
		return newObject
	}
	/// Creates database application object for specified bundle path if needed.
	/// - Parameters:
	///   - bundle: Path to bundle
	public func createApplication(
		uuid: String = UUID().uuidString,
		for bundle: URL,
		shouldIgnore: Bool = false,
		completion: @escaping (Error?) -> Void
	) {
		if getApplication(for: bundle) != nil {
			print("already exists skiping!")
			return
		}
		
		let newObject = CBApplication(context: context)
		newObject.uuid = uuid
		newObject.bundleUrl = bundle
		newObject.shouldIgnore = shouldIgnore
		
		do {
			try saveContext()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	/// "Ignores/Unignores" a database application object.
	/// - Parameter object: Application object
	public func ignoreApplication(for object: CBApplication, _ shouldIgnore: Bool = true) {
		object.shouldIgnore = shouldIgnore
		// shouldIgnore is usually done for once instance
		// and we're usually doing batch updates for un-
		// -setting it, so we ignore the save until later
		if shouldIgnore { try? saveContext() }
	}
}
