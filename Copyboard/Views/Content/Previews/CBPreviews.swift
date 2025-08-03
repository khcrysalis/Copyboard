//
//  CBPreviews.swift
//  Copyboard
//
//  Created by samara on 30.06.2025.
//

import Cocoa
import ClipKit
import DataTypesKit

// MARK: - Supported Previews
enum CBPreviews {
	// Add your cool preview types here
	static let PreviewViews: [DataType: CBPreviewBaseView.Type] = [
		// Text
		.text: CBPreviewRichTextView.self,
		.rtf: CBPreviewRichTextView.self,
		.utf8PlainText: CBPreviewPlainTextView.self,
		.html: CBPreviewRichTextView.self,
		.xcodeSourceCode: CBPreviewRichTextView.self,
		
		// Images
		.png: CBPreviewImageView.self,
		.jpeg: CBPreviewImageView.self,
		
		// Files
		.fileURL: CBPreviewFileView.self,
		
		// TODO: Embeds? (this may be dangerous.)
	]
	
	static let PreviewViewsCompact: [DataType: CBPreviewBaseView.Type] = [
		// Images
		.png: CBPreviewImageView.self,
		.jpeg: CBPreviewImageView.self,
		
		// Files
		.fileURL: CBPreviewFileView.self,
	]
}

// MARK: - Preview Priorities
extension CBPreviews {
	static let priorities: [DataType] = [
		// first
		.xcodeSourceCode, // Purely for naming, so keep it up here
		//
		.fileURL,
		.url,
		.png,
		.html,
		.text,
		.rtf,
		.utf8PlainText
		// last
	]
	
	static let names: [DataType] = [
		.utf8PlainText
	]
	
	static func findHighestPriorityType(from types: [DataType]) -> DataType? {
		priorities.first { types.contains($0) }
	}
	
	static func findNameForCompactType(from types: [DataType]) -> DataType? {
		names.first { types.contains($0) }
	}
}

extension CBPreviews {
	static func Preview(
		for types: [DataType],
		using direction: NSCollectionView.ScrollDirection
	) -> (CBPreviewBaseView.Type)? {
		if
			let priority = findHighestPriorityType(from: types),
			let preview = direction == .vertical ? PreviewViewsCompact[priority] : PreviewViews[priority]
		{
			preview
		} else {
			nil
		}
	}
}

// MARK: - NSView Base
class CBPreviewBaseView: NSView {
	var item: CBObjectItem
	var types: Set<DataType>
	var direction: NSCollectionView.ScrollDirection
	
	required init(
		_ item: CBObjectItem,
		types: Set<DataType>,
		using direction: NSCollectionView.ScrollDirection
	) {
		self.item = item
		self.types = types
		self.direction = direction
		super.init(frame: .zero)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	/// You must override this if you inheret from this class
	/// to start setting up custom views for data types
	open func setupViews() {}
}

extension CBPreviewBaseView {
	// makes the view not clickable
	override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

// MARK: - NSView Base Example
/*
class CBPreviewExampleView: CBPreviewBaseView {
	override func setupViews() {
		let label = NSTextField(labelWithString: "\(item.item)")
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: centerXAnchor),
			label.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
 }
*/

extension CBObjectItem {
	var typedData: [DataType: Data] {
		Dictionary(uniqueKeysWithValues: self.data!.compactMap { key, value in
			(DataType(key), value)
		}.compactMap { (type, data) in
			if type == nil { return nil }
			return (type!, data)
		})
	}
	
	func stringForCompactType() -> String? {
		guard
			let types = self.types?.compactMap({ DataType($0) }),
			let compactType = CBPreviews.findNameForCompactType(from: types),
			let data = self.typedData[compactType],
			let string = String(data: data, encoding: .utf8)
		else {
			return nil
		}
		
		return string
			.replacingOccurrences(of: "\r", with: "")
			.replacingOccurrences(of: "\n", with: "")
			.replacingOccurrences(of: "\t", with: " ")
	}
}
