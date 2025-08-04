//
//  CBContentSearchView.swift
//  Copyboard
//
//  Created by samara on 5.07.2025.
//

import Cocoa

// MARK: CBContentSearchView
class CBContentSearchView: NSView {
	
	var delegate: CBSearchDelegate?
	
	// MARK: Views
	
	let bottomBorder: CALayer = {
		let border = CALayer()
		border.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
		return border
	}()
	
	let searchField: NSSearchField = {
		let field = CBSearchField()
		field.placeholderString = .localized("Search")
		field.font = NSFont.systemFont(ofSize: CBConstants.headerFontSize)
		return field
	}()
	
	let ellipsisButton: NSButton = {
		let button = NSButton()
		button.bezelStyle = .texturedRounded
		button.isBordered = false

		let config = NSImage.SymbolConfiguration(pointSize: CBConstants.headerFontSize, weight: .bold)
		button.image = NSImage(
			systemSymbolName: "paperclip",
			accessibilityDescription: Bundle.main.name
		)?.withSymbolConfiguration(config)
		button.imagePosition = .imageOnly
		return button
	}()
	
	// MARK: Init
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		_setupViews()
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Setup
	
	private func _setupViews() {
		wantsLayer = true
		
		[ellipsisButton, searchField].forEach {
			$0.target = self
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		ellipsisButton.action = #selector(showGeneralAppMenu(_:))
		searchField.action = #selector(searchFieldDidChange(_:))
		
		layer?.addSublayer(bottomBorder)
		
		NSLayoutConstraint.activate([
			ellipsisButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CBConstants.padding),
			ellipsisButton.topAnchor.constraint(equalTo: topAnchor, constant: CBConstants.padding),
			ellipsisButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CBConstants.padding),
			
			searchField.leadingAnchor.constraint(equalTo: ellipsisButton.trailingAnchor, constant: CBConstants.padding),
			searchField.centerYAnchor.constraint(equalTo: centerYAnchor),
			searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CBConstants.padding),
			searchField.heightAnchor.constraint(equalToConstant: 22)
		])
	}
	
	override func layout() {
		super.layout()
		bottomBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1.0)
	}
	
	// MARK: Actions
	
	@objc func showGeneralAppMenu(_ sender: NSButton) {
		guard let menu = (NSApp.delegate as? AppDelegate)?.makeGeneralAppMenu() else { return }
		let buttonBounds = sender.bounds
		menu.popUp(positioning: nil, at: NSPoint(x: 0, y: buttonBounds.height), in: sender)
	}
	
	@objc private func searchFieldDidChange(_ sender: NSSearchField) {
		delegate?.searchFieldDidChange(sender.stringValue)
	}
}

// MARK: - CBSearchDelegate
protocol CBSearchDelegate {
	func searchFieldDidChange(_ text: String)
}
