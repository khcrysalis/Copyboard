//
//  CBSearchField.swift
//  Copyboard
//
//  Created by samsam on 7/31/25.
//

import Cocoa

class CBSearchField: NSSearchField {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		_setup()
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func _setup() {
		wantsLayer = true
		layer?.backgroundColor = .clear
		layer?.borderWidth = 0
		layer?.cornerRadius = 0
		
		isBordered = false
		drawsBackground = true
		backgroundColor = .clear
		textColor = .textColor
		
		if let cell = self.cell as? NSSearchFieldCell {
			cell.searchButtonCell = nil
			cell.cancelButtonCell = nil
			cell.focusRingType = .none
			cell.drawsBackground = false
			cell.isBordered = false
		}
		
		focusRingType = .none
	}
}

// This is a silly fix, essentially to stop the textView from responding
// to certain events, we override some operations and instead point them
// to the operations done by the CBContentView
// https://github.com/khcrysalis/Copyboard/pull/3
// MARK: - Shortcuts
extension CBSearchField {
	override func becomeFirstResponder() -> Bool {
		if let editor = self.currentEditor() {
			editor.delegate = self
		}
		return super.becomeFirstResponder()
	}
	
	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		guard 
			event.type == .keyDown,
			let content = self.superview?.superview as? CBContentView
		else {
			return super.performKeyEquivalent(with: event) 
		}
				
		switch (
			event.modifierFlags.contains(.command), 
			event.charactersIgnoringModifiers ?? "", 
			event.keyCode
		) {
		case
			(false, _, 125),
			(false, _, 126),
			(true, 	_, 35),
			(true, 	_, 3),
			(true, 	_, 51):
			content.collectionView.keyDown(with: event)
			return true
		case (true, let n, _) where Int(n).map({ 1...9 ~= $0 }) ?? false: // Cmd+1–9
			content.collectionView.keyDown(with: event)
			return true
		default:
			return super.performKeyEquivalent(with: event)
		}
	}
}

extension CBSearchField: NSTextViewDelegate {
	func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		guard let content = self.superview?.superview as? CBContentView else { return false }
		
		switch commandSelector {
		case #selector(NSResponder.cancelOperation(_:)): // Escape key
			content.collectionView.keyDown(with: NSEvent.keyEvent(
				 with: .keyDown,
				 location: .zero,
				 modifierFlags: [],
				 timestamp: ProcessInfo.processInfo.systemUptime,
				 windowNumber: 0,
				 context: nil,
				 characters: "",
				 charactersIgnoringModifiers: "",
				 isARepeat: false,
				 keyCode: 53
			)!)
			return true
		case #selector(NSResponder.insertNewline(_:)): // Return key
			content.collectionView.keyDown(with: NSEvent.keyEvent(
				 with: .keyDown,
				 location: .zero,
				 modifierFlags: [],
				 timestamp: ProcessInfo.processInfo.systemUptime,
				 windowNumber: 0,
				 context: nil,
				 characters: "\n",
				 charactersIgnoringModifiers: "\n",
				 isARepeat: false,
				 keyCode: 36
			)!)
			return true
		default:
			return false
		}
	}
}
