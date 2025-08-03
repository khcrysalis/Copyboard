import UniformTypeIdentifiers
import SwiftUI
import AppKit

/// DataType is basically like UTType from UniformTypeIdentifiers, however
/// we want to be able to expand it with other identifiers ourselves without some
/// of the functionality UTType provides since its out of scope.
@available(macOS 13, *)
public struct DataType: Sendable {
	/// Initialize a DataType object from an existing UTType.
	/// - Parameter utType: The UTType
	public init(from utType: UTType) {
		self.utType = utType
		self._identifier = utType.identifier
		self._description = nil // never used for UTType
	}
	
	
	/// Find a defined DataType or UTType, or nil if information couldn't be found.
	/// - Parameter identifier: The UT Identifier
	public init?(_ identifier: String) {
		if let dataType = Self._additionalTypes.first(where: { $0.identifier == identifier }) {
			self.init(identifier: dataType.identifier, description: dataType._description)
		} else
		// look for existing uttype
		if let utType: UTType = .init(identifier) {
			self.init(from: utType)
		} else {
			return nil
		}
	}
	
	
	/// Special initializer for defining a DataType, to be used to extend DataType
	/// with static constants for safe use.
	/// - Parameters:
	///   - identifier: The UT Identifier
	///   - description: A short description like "PNG image" etc.
	init(identifier: String, description: LocalizedStringResource?) {
		self._identifier = identifier
		self._description = description
		self.utType = nil
	}
	
	// if the datatype is from a uttype we just store it
	let utType: UTType?
	
	let _identifier: String
	let _description: LocalizedStringResource?
	
	// similar properties to uttype
	
	public var identifier: String { utType?.identifier ?? _identifier }
	public var localizedDescription: String {
#warning("fix localization")
		return utType?.localizedDescription ?? (self._description == nil ? "" : String(localized: self._description!))
	}
}

extension DataType: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
}
