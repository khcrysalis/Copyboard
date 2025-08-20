//
//  CBCollectionView.swift
//  Copyboard
//
//  Created by samara on 5.07.2025.
//

import Cocoa
import ClipKit

// MARK: - CBCollectionView
class CBCollectionView: NSCollectionView {
	weak open var cbDelegate: CBCollectionViewDelegate?
	private var _trackingArea: NSTrackingArea?
	private var previewPopover: NSPopover?
	
	// MARK: Init
	
	init() {
		super.init(frame: .zero)
		backgroundColors = [.clear]
		isSelectable = true
		allowsMultipleSelection = false
		allowsEmptySelection = false
		setDraggingSourceOperationMask(.copy, forLocal: false)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Overrides
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		if let trackingArea = _trackingArea {
			removeTrackingArea(trackingArea)
		}
		
		let options: NSTrackingArea.Options = [
			.mouseMoved,
			.activeInKeyWindow,
			.inVisibleRect,
			.mouseEnteredAndExited
		]
		
		_trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
		addTrackingArea(_trackingArea!)
	}

	override func mouseMoved(with event: NSEvent) {
		let point = convert(event.locationInWindow, from: nil)
		if let indexPath = indexPathForItem(at: point) {
			if selectionIndexPaths != [indexPath] {
				selectionIndexes = IndexSet()
				selectItems(at: [indexPath], scrollPosition: [])
			}
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		selectionIndexes = IndexSet()
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		var menu = super.menu(for: event)
		let point = convert(event.locationInWindow, from: nil)
		let indexPath = indexPathForItem(at: point)
		if let cbDelegate = cbDelegate {
			menu = cbDelegate.collectionView(self, menu: menu, at: indexPath)
		}
		return menu
	}
	
	override func keyDown(with event: NSEvent) {
		switch (
			event.modifierFlags.contains(.command),
			event.charactersIgnoringModifiers ?? "",
			event.keyCode
		) {
		case (true, let index, _) where Int(index).map({ 1...9 ~= $0 }) ?? false: // Cmd+1–9
			if 
				let index = Int(index),
				index - 1 >= 0 && index - 1 < numberOfItems(inSection: 0) 
			{
				selectionIndexes = IndexSet()
				let indexPath = IndexPath(item: index - 1, section: 0)
				selectItems(at: [indexPath], scrollPosition: .centeredVertically)
				_copyItemFromIndex(for: indexPath)
			}
		case (true, _, 51): // Cmd+Delete
			if let indexPath = selectionIndexPaths.first {
				_deleteHistoryItemFromIndex(for: indexPath)
			}
		case (false, _, 53): // Escape key
			AppDelegate.main.menuBar?.statusItem.toggleWindow()
		case (true, _, 35): // P Key
			if let indexPath = selectionIndexPaths.first {
				_showPreviewPopover(for: indexPath)
			}
		case (true, _, 3): // F Key
			if let indexPath = selectionIndexPaths.first {
				_favoriteHistoryItemFromIndex(for: indexPath)
			}
		case (false, _, 36): // Return key
			if let indexPath = selectionIndexPaths.first {
				_copyItemFromIndex(for: indexPath)
				deselectItems(at: [indexPath])
			} else {
				selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
			}
		case (false, _, 125), (false, _, 126): // Down/Up arrows
			if selectionIndexes.first != nil {
				super.keyDown(with: event)
			} else {
				selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
			}
		default:
			super.keyDown(with: event)
		}
	}
	
	// MARK: Actions
	
	private func _copyItemFromIndex(for indexPath: IndexPath) {
		guard let item = item(at: indexPath) as? CBContentViewItem else { return }
		item.animateClickFeedback()
	}
	
	private func _deleteHistoryItemFromIndex(for indexPath: IndexPath) {
		guard let item = item(at: indexPath) as? CBContentViewItem else { return }
		StorageManager.shared.deleteHistory(for: item.object)
	}
	
	private func _favoriteHistoryItemFromIndex(for indexPath: IndexPath) {
		guard let item = item(at: indexPath) as? CBContentViewItem else { return }
		StorageManager.shared.toggleFavoriteHistory(for: item.object)
	}
	
	private func _showPreviewPopover(for indexPath: IndexPath) {
		guard let item = item(at: indexPath) as? CBContentViewItem else { return }
		
		// Avoid showing multiple
		if previewPopover?.isShown == true {
			previewPopover?.close()
		}
		
		let popover = NSPopover()
		popover.behavior = .transient
		popover.animates = true
		
		let vc = NSViewController()
		vc.view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
		vc.view.wantsLayer = true
		
		popover.contentViewController = vc
		popover.show(relativeTo: item.view.bounds, of: item.view, preferredEdge: .maxY)
		
		self.previewPopover = popover
	}
}

extension CBCollectionView {
	override var acceptsFirstResponder: Bool { false }
}

// MARK: - CBCollectionViewDelegate
protocol CBCollectionViewDelegate: NSObjectProtocol {
	func collectionView(_ collectionView: NSCollectionView, menu: NSMenu?, at indexPath: IndexPath?) -> NSMenu?
}
