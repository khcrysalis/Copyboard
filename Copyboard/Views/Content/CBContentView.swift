//
//  CBContentView.swift
//  Copyboard
//
//  Created by samara on 27.06.2025.
//

import Cocoa
import Combine
import ClipKit
import SwiftUI

// MARK: - CBContentView
class CBContentView: CBBaseView {
	// could be private maybe
	var clipboardItems: [CBObject] = [] {
		didSet {
			collectionView.reloadSections(IndexSet(integer: 0))
			unavailableView.isHidden = !clipboardItems.isEmpty
		}
	}
	
	var filteredItems: [CBObject]? = nil
	
	var reloadWorkItem: DispatchWorkItem?
	private var _cancellables = Set<AnyCancellable>()
	
	// MARK: Views
	
	lazy var collectionView: NSCollectionView = {
		let view = CBCollectionView()
		view.collectionViewLayout = .paddedListLayout(direction: .vertical)
		view.dataSource = self
		view.delegate = self
		view.cbDelegate = self
		view.registerForDraggedTypes(NSPasteboard.PasteboardType.supportedDragTypes)
		view.register(
			CBContentViewItem.self,
			forItemWithIdentifier: .init(CBContentViewItem.reuseIdentifier)
		)
		return view
	}()
	
	lazy var scrollView: NSScrollView = {
		let view = NSScrollView()
		view.drawsBackground = false
		view.hasVerticalScroller = true
		view.hasHorizontalScroller = false
		view.scrollerStyle = .overlay
		view.documentView = collectionView
		view.automaticallyAdjustsContentInsets = false
		return view
	}()
	
	lazy var searchView: NSView = {
		let view = CBContentSearchView()
		view.delegate = self
		return view
	}()
	
	lazy var unavailableView: NSHostingView<AnyView> = {
		NSHostingView(rootView: AnyView(
			VStack {
				Text(.localized("No Clipboard Items")).font(.title3).bold()
				Text(.localized("Your clipboard history will appear here."))
			}
			.foregroundStyle(.secondary)
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		))
	}()
	
	// MARK: Init

	override init(frame: NSRect) {
		super.init(frame: frame)
		_setupViews()
		_setupBindings()
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Overrides
	
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		_updateLayout()
	}

	override func layout() {
		super.layout()
		_updateLayout()
	}
	
	private func _updateLayout() {
		collectionView.collectionViewLayout?.invalidateLayout()
	}
	
	// MARK: Setup
	
	private func _setupViews() {
		[searchView, scrollView, unavailableView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			searchView.leadingAnchor.constraint(equalTo: leadingAnchor),
			searchView.trailingAnchor.constraint(equalTo: trailingAnchor),
			searchView.topAnchor.constraint(equalTo: topAnchor),
			searchView.heightAnchor.constraint(equalToConstant: 44),
			
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			unavailableView.leadingAnchor.constraint(equalTo: leadingAnchor),
			unavailableView.trailingAnchor.constraint(equalTo: trailingAnchor),
			unavailableView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
			unavailableView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Bindings
	
	@objc private func _setupBindings() {
		NotificationCenter.default.publisher(for: .clipboardDidChange)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?._reloadClipboardItems()
			}
			.store(in: &_cancellables)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(_makeCollectionViewFirstResponder),
			name: .collectionViewGetFirstResponder,
			object: nil
		)
		
		// on first run, we post a didchange notification after setting up listeners
		NotificationCenter.default.post(name: .clipboardDidChange, object: nil)
	}
	
	@objc private func _reloadClipboardItems() {
		DispatchQueue.global(qos: .userInitiated).async {
			let results = StorageManager.shared.fetchAllCBObjectsSortedByDate()
			DispatchQueue.main.async {
				self.clipboardItems = results
			}
		}
	}
	
	@objc private func _makeCollectionViewFirstResponder() {
		window?.makeFirstResponder(collectionView)
	}
	
	func copyItemFromIndex(row: Int) {
		let indexPath = IndexPath(item: row, section: 0)
		if let item = collectionView.item(at: indexPath) as? CBContentViewItem {
			item.animateClickFeedback()
		}
	}
	
	func performDelete(at indexPath: IndexPath) {
		let source = filteredItems ?? clipboardItems;

		guard indexPath.item < source.count else { return };
		let object = source[indexPath.item];
		
		_deleteItem(for: object);
	}
}

// MARK: - CBContentView (Extension): DataSource / Layout
extension CBContentView: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		filteredItems?.count ?? clipboardItems.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = filteredItems?[indexPath.item] ?? clipboardItems[indexPath.item]
		let viewItem = collectionView.makeItem(withIdentifier: .init(CBContentViewItem.reuseIdentifier), for: indexPath)
		if let roundedCell = viewItem as? CBContentViewItem {
			roundedCell.configure(using: item)
		}
		return viewItem
	}
	
	func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
		let item = filteredItems?[indexPath.item] ?? clipboardItems[indexPath.item]
		guard let objectItems = item.items as? Set<CBObjectItem> else { return nil }
		
		let pasteboardItems: [NSPasteboardItem] = ClipboardMonitorManager.shared.createPasteboardObjects(
			using: objectItems,
			asPlain: UserDefaults.standard.bool(forKey: "CB.copyAsPlainText")
		)
		
		return pasteboardItems.count == 1 ? pasteboardItems.first : nil
	}

	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		guard let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout else { return .zero}
		
		let horizontalInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
		
		let width = max(collectionView.bounds.width - horizontalInsets, 0)
		return NSSize(width: width, height: 64)
	}
}

// MARK: - CBContentView (Extension): Custom Actions
extension CBContentView: CBCollectionViewDelegate {
	func collectionView(_ collectionView: NSCollectionView, menu: NSMenu?, at indexPath: IndexPath?) -> NSMenu? {
		guard let indexPath else { return nil }
		let item = filteredItems?[indexPath.item] ?? clipboardItems[indexPath.item]
		
		let menu = NSMenu()
		
		let favoriteTitle: String = item.isFavorited ? .localized("Unfavorite") : .localized("Favorite")
		let favoriteItem = NSMenuItem(title: favoriteTitle, action: #selector(_handleFavoriteMenuItem(_:)), keyEquivalent: "")
		favoriteItem.target = self
		favoriteItem.representedObject = item
		menu.addItem(favoriteItem)
		
		menu.addItem(NSMenuItem.separator())
		
		let copyItem = NSMenuItem(title: .localized("Copy"), action: #selector(_handleCopyMenuItem(_:)), keyEquivalent: "")
		copyItem.target = self
		copyItem.representedObject = item
		menu.addItem(copyItem)
		
		let copyPlainItem = NSMenuItem(title: .localized("Copy Without Formatting"), action: #selector(_handleCopyPlainMenuItem(_:)), keyEquivalent: "")
		copyPlainItem.target = self
		copyPlainItem.representedObject = item
		menu.addItem(copyPlainItem)
		
		menu.addItem(NSMenuItem.separator())
		
		let deleteItem = NSMenuItem(title: .localized("Delete"), action: #selector(_handleDeleteMenuItem(_:)), keyEquivalent: "")
		deleteItem.target = self
		deleteItem.representedObject = item
		menu.addItem(deleteItem)
		
		let deleteAllItem = NSMenuItem(title: .localized("Delete All"), action: #selector(_handleDeleteAllMenuItem(_:)), keyEquivalent: "");
		deleteAllItem.target = self;
		menu.addItem(deleteAllItem);
		
		return menu
	}
	/// Helper function for copying, for NSMenuItem.
	@objc private func _handleCopyMenuItem(_ sender: NSMenuItem) {
		guard let object = sender.representedObject as? CBObject else { return }
		_copyItem(for: object)
	}
	/// Helper function for deletion, for NSMenuItem.
	@objc private func _handleDeleteMenuItem(_ sender: NSMenuItem) {
		guard let object = sender.representedObject as? CBObject else { return }
		_deleteItem(for: object)
	}
	/// Helper function for deletion, for NSMenuItem.
	@objc private func _handleFavoriteMenuItem(_ sender: NSMenuItem) {
		guard let object = sender.representedObject as? CBObject else { return }
		_favoriteItem(for: object)
	}
	/// Helper function for mass deletion, for NSMenuItem.
	@objc private func _handleDeleteAllMenuItem(_ sender: NSMenuItem) {
		let alert = NSAlert();
		alert.messageText = String.localized ("Erase History?");
		alert.informativeText = String.localized("Are you sure you want to erase your clipboard history?");
		alert.alertStyle = .warning;
		alert.addButton(withTitle: String.localized ("Erase"));
		alert.addButton(withTitle: String.localized ("Cancel" ));
		
		if (alert.runModal() == .alertFirstButtonReturn){
			StorageManager.shared.eraseHistory();
		}
	}
	/// Helper function for deletion (as plain), for NSMenuItem.
	@objc private func _handleCopyPlainMenuItem(_ sender: NSMenuItem) {
		guard let object = sender.representedObject as? CBObject else { return }
		_copyItem(for: object, asPlain: true)
	}
	/// Deletes history object entirely.
	/// - Parameter object: History object
	private func _deleteItem(for object: CBObject) {
		StorageManager.shared.deleteHistory(for: object)
	}
	/// Copy the contents of the history object to your clipboard.
	/// - Parameter object: History object
	/// - Parameter asPlain: Whether to strip non-plain types like RTF/HTML
	private func _copyItem(for object: CBObject, asPlain: Bool = false) {
		ClipboardMonitorManager.shared.addToClipboard(using: object, asPlain: asPlain)
	}
	/// Favorites history item.
	/// - Parameter object: History object
	private func _favoriteItem(for object: CBObject) {
		StorageManager.shared.toggleFavoriteHistory(for: object)
	}
}

// MARK: - CBContentView (Extension): CBSearchDelegate
extension CBContentView: CBSearchDelegate {
	func searchFieldDidChange(_ text: String) {
		filteredItems = filteredObjects(with: text, in: clipboardItems)
		collectionView.reloadSections(IndexSet(integer: 0))
	}
	
	// MARK: Filter
	
	func filteredObjects(with searchText: String, in objects: [CBObject]) -> [CBObject]? {
		let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return nil }
		
		return objects.filter { cbObject in
			guard let itemsSet = cbObject.items as? Set<CBObjectItem> else { return false }
			
			return itemsSet.contains { item in
				let matchesDataKeys = item.data?.keys.contains { key in
					key.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
				} ?? false
				
				let matchesDataValues = item.data?.values.contains { dataValue in
					if let stringValue = String(data: dataValue, encoding: .utf8) {
						stringValue.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
					} else {
						false
					}
				} ?? false
				
				let matchesTypesArray = item.types?.contains { type in
					type.range(of: trimmed, options: [.caseInsensitive, .diacriticInsensitive]) != nil
				} ?? false
				
				return matchesDataKeys || matchesDataValues || matchesTypesArray
			}
		}
	}
}
