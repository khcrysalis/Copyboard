//
//  StorageManager+history.swift
//  ClipKit
//
//  Created by samara on 26.06.2025.
//

import Foundation
import CoreData
import AppKit.NSPasteboardItem

// MARK: - StorageManager (Extension): History Management
extension StorageManager {
	/// Fetches objects in database sorted by date.
	/// - Returns: Array of history objects
	public func fetchAllCBObjectsSortedByDate() -> [CBObject] {
		let fetchRequest: NSFetchRequest<CBObject> = CBObject.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CBObject.dateAdded, ascending: false)]
		
		let objects = try? context.fetch(fetchRequest)
		return objects ?? []
	}
	/// Creates database object for specified clipboard items.
	/// - Parameters:
	///   - items: NSPasteboardItem's
	public func createHistory(
		uuid: String = UUID().uuidString,
		items: [NSPasteboardItem],
		completion: @escaping (Error?) -> Void
	) {
		let newObjectItems = createItems(using: items) // [CBObjectItem]
		let newObjectApplication = createApplication() // CBApplication?
		
		// unlikely this would return for newly created items
		if newObjectApplication?.shouldIgnore == true {
			print("we're ignoring this history item")
			return
		}
		
		let newObject = CBObject(context: context)
		newObject.uuid = uuid
		newObject.dateAdded = Date()
		newObject.application = newObjectApplication
		newObject.items = NSSet(array: newObjectItems)
		
		var objectsToObtainIDs = newObjectItems.map { $0 as NSManagedObject }
		if let application = newObjectApplication {
			objectsToObtainIDs.append(application)
		}
		objectsToObtainIDs.append(newObject)
		
		do {
			try context.obtainPermanentIDs(for: objectsToObtainIDs)
			try saveContext()
			completion(nil)
			NotificationCenter.default.post(name: .clipboardDidChange, object: nil)
		} catch {
			completion(error)
		}
	}
	/// Deletes database object entirely.
	/// - Parameter object: History object
	public func deleteHistory(for object: CBObject) {
		context.delete(object)
		try? saveContext()
		NotificationCenter.default.post(name: .clipboardDidChange, object: nil)
	}
	/// Deletes all database objects based on an int from `ErasureTarget`
	/// - Parameter rawValue: Int
	public func deleteAllHistoryBeforeDate(for rawValue: Int) {
		print(rawValue)
		deleteAllHistoryBeforeDate(using: ErasureTarget.erasureDate(for: rawValue))
	}
	/// Deletes all database objects based on `ErasureTarget`
	/// - Parameter target: ErasureTarget
	public func deleteAllHistoryBeforeDate(using target: ErasureTarget) {
		let fetchRequest: NSFetchRequest<CBObject> = CBObject.fetchRequest()
		let cutoffDate = target.findErasureDate
		fetchRequest.predicate = NSPredicate(format: "dateAdded < %@", cutoffDate as NSDate)
		clearContext(request: fetchRequest)
	}
	/// "Favorites/Unfavorites" a database object.
	/// - Parameter object: History object
	public func toggleFavoriteHistory(for object: CBObject) {
		object.isFavorited.toggle()
		try? saveContext()
		NotificationCenter.default.post(name: .clipboardDidChange, object: nil)
	}
	
	public func eraseHistory() {
		clearContext(request: CBObject.fetchRequest())
		clearContext(request: CBObjectItem.fetchRequest())
		NotificationCenter.default.post(name: .clipboardDidChange, object: nil)
	}
}

// MARK: - ErasureTarget
public enum ErasureTarget: Int, CaseIterable, Hashable {
	case forever = 0
	case day = 1
	case week = 2
	case month = 3
	case year = 4
	
	public var findErasureDate: Date {
		switch self {
		case .day:		Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
		case .week: 	Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
		case .month: 	Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
		case .year: 	Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
		case .forever: 	Date.distantPast
		}
	}
	
	public static func erasureDate(for rawValue: Int) -> ErasureTarget {
		if let target = Self(rawValue: rawValue) {
			target
		} else {
			.forever
		}
	}
}
