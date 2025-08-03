//
//  StorageManager.swift
//  Copyboard
//
//  Created by samara on 11.05.2025.
//

import CoreData

// MARK: - StorageManager
final public class StorageManager: ObservableObject, @unchecked Sendable {
	static public let shared = StorageManager()

	public let container: NSPersistentContainer
	
	private let _name: String = "ClipKit"
	
	public init(inMemory: Bool = false) {
		guard
			let modelURL = Bundle.module.url(forResource: _name, withExtension: "momd"),
			let model = NSManagedObjectModel(contentsOf: modelURL)
		else {
			fatalError("Failed to load model from Swift Package")
		}
		
		container = NSPersistentContainer(name: _name, managedObjectModel: model)
		
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		
		#if DEBUG
		if let storeURL = container.persistentStoreDescriptions.first?.url {
			print("Core Data store location: \(storeURL.path)")
		}
		#endif
		
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		
		container.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	public var context: NSManagedObjectContext {
		container.viewContext
	}
	
	public func saveContext() throws {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				context.rollback()
				throw error
			}
		}
	}
	
	public func clearContext<T: NSManagedObject>(request: NSFetchRequest<T>) {
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
		batchDeleteRequest.resultType = .resultTypeObjectIDs

		do {
			let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
			if let objectIDs = result?.result as? [NSManagedObjectID] {
				let changes = [NSDeletedObjectsKey: objectIDs]
				NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
			}
			context.reset()
		} catch {
			print("Failed to clear context: \(error)")
		}
	}

}
