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
		switch event.keyCode {
		case 36: // Return key
			if let indexPath = selectionIndexPaths.first {
				_copyItemFromIndex(for: indexPath)
				deselectItems(at: [indexPath])
			} else {
				selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
			}
		case 49: // Space key
			if let indexPath = selectionIndexPaths.first {
				_showPreviewPopover(for: indexPath)
			}
		case 51: // Delete key
			if let indexPath = selectionIndexPaths.first {
				_deleteHistoryItemFromIndex(for: indexPath)
			}
		case 53: // Escape key
			AppDelegate.main.menuBar?.statusItem.toggleWindow()
		case 125, 126: // Down-Up arrow keys
			if selectionIndexes.first != nil {
				super.keyDown(with: event)
			} else {
				selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
			}
		case 18...26 where event.keyCode != 27: // 1–9 keys
			let index = _numberKeyIndex(for: event.keyCode)
			if
				index >= 0,
				index < numberOfItems(inSection: 0)
			{
				selectionIndexes = IndexSet()
				let indexPath = IndexPath(item: index, section: 0)
				selectItems(at: [indexPath], scrollPosition: .centeredVertically)
				_copyItemFromIndex(for: indexPath)
			}
		default:
			super.keyDown(with: event)
		}
	}
	
	// MARK: Actions
	
	private func _numberKeyIndex(for keyCode: UInt16) -> Int {
		Int(keyCode) - 18
	}
	
	private func _copyItemFromIndex(for indexPath: IndexPath) {
		guard let item = item(at: indexPath) as? CBContentViewItem else { return }
		item.animateClickFeedback()
	}
	
	private func _deleteHistoryItemFromIndex(for indexPath: IndexPath) {
		guard let item = item(at: indexPath) as? CBContentViewItem else { return }
		StorageManager.shared.deleteHistory(for: item.object)
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
	override var acceptsFirstResponder: Bool { true }
}

// MARK: - CBCollectionViewDelegate
protocol CBCollectionViewDelegate: NSObjectProtocol {
	func collectionView(_ collectionView: NSCollectionView, menu: NSMenu?, at indexPath: IndexPath?) -> NSMenu?
}
