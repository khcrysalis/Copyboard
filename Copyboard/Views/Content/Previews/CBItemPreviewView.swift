//
//  CBItemPreviewView.swift
//  Copyboard
//
//  Created by samara on 30.06.2025.
//

import Cocoa
import ClipKit
import DataTypesKit

class CBItemPreviewView: NSView {
	var items: [CBObjectItem] {
		didSet { _setupViews() }
	}
	
	var scrollDirection: NSCollectionView.ScrollDirection
	
	private var _types: [CBObjectItem: Set<DataType>] {
		Dictionary(uniqueKeysWithValues: items.map {
			($0, Set($0.types?.compactMap { DataType($0) } ?? []))
		})
	}
	
	init(
		items: [CBObjectItem]?,
		direction: NSCollectionView.ScrollDirection = .vertical
	) {
		self.items = items ?? []
		self.scrollDirection = direction
		super.init(frame: .zero)
		_setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func _setupViews() {
		wantsLayer = true
		layer?.cornerRadius = 6
		layer?.masksToBounds = true
		subviews.forEach { $0.removeFromSuperview() }
		
		let contentView: NSView
		// multiple
		if _types.count > 1 {
			contentView = _makeGridView(for: items)
		// one
		} else if
			let item = items.first,
			let types = _types[item]
		{
			contentView = _makeItemPreview(item: item, types: types)
		// unknown
		} else {
			contentView = Self._makeNoPreviewFallback()
		}
		
		addSubview(contentView)
		Self.pinToEdges(contentView, of: self)
	}
	
	private func _makeGridView(for items: [CBObjectItem]) -> NSView {
		let container = NSStackView()
		container.orientation = .vertical
		container.spacing = CBConstants.innerPadding
		container.alignment = .centerX
		container.distribution = .fillEqually
		
		let maxItems = scrollDirection == .vertical ? 4 : 6
		let limitedItems = Array(items.prefix(maxItems))
		
		let itemsPerRow = limitedItems.count > 4 ? 3 : 2
		let rows = _chunkArray(limitedItems, into: itemsPerRow)
		
		for row in rows {
			let rowStack = NSStackView()
			rowStack.orientation = .horizontal
			rowStack.spacing = CBConstants.innerPadding
			rowStack.distribution = .fillEqually
			
			for item in row {
				let view = _makeItemPreview(item: item, types: _types[item] ?? [])
				rowStack.addArrangedSubview(view)
			}
			
			container.addArrangedSubview(rowStack)
		}
		
		return container
	}
	
	private func _makeItemPreview(item: CBObjectItem, types: Set<DataType>) -> NSView {
		if let PreviewType = CBPreviews.Preview(for: Array(types), using: scrollDirection) {
			PreviewType.init(item, types: types, using: scrollDirection)
		} else {
			NSView()
		}
	}
	
	private static func _makeNoPreviewFallback() -> NSView {
		let imageView = NSImageView(
			image: NSImage(
				systemSymbolName: "eye.trianglebadge.exclamationmark.fill",
				accessibilityDescription: nil
			) ?? NSImage()
		)
		imageView.symbolConfiguration = .init(pointSize: 24, weight: .regular)
		imageView.contentTintColor = .secondaryLabelColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}
	
	private func _chunkArray<T>(_ array: [T], into size: Int) -> [[T]] {
		var result: [[T]] = []
		var row: [T] = []
		
		for element in array {
			row.append(element)
			if row.count == size {
				result.append(row)
				row.removeAll()
			}
		}
		
		if !row.isEmpty {
			result.append(row)
		}
		
		return result
	}
}
