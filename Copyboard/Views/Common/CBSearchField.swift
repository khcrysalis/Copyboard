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
	override func becomeFirstResponder() -> Bool {
		if let editor = self.currentEditor() {
			editor.delegate = self
		}
		return super.becomeFirstResponder()
	}
}

extension CBSearchField: NSTextViewDelegate {
	func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		switch commandSelector {
		case #selector(NSResponder.moveUp(_:)):
			if let content = self.superview?.superview as? CBContentView {
				content.collectionView.keyDown(with: NSEvent.keyEvent(
					 with: .keyDown,
					 location: .zero,
					 modifierFlags: [],
					 timestamp: ProcessInfo.processInfo.systemUptime,
					 windowNumber: 0,
					 context: nil,
					 characters: "",
					 charactersIgnoringModifiers: "",
					 isARepeat: false,
					 keyCode: 126
				)!)
			}
			return true
		case #selector(NSResponder.moveDown(_:)):
			if let content = self.superview?.superview as? CBContentView {
				content.collectionView.keyDown(with: NSEvent.keyEvent(
					 with: .keyDown,
					 location: NSPoint(x: 0, y: 0),
					 modifierFlags: [],
					 timestamp: ProcessInfo.processInfo.systemUptime,
					 windowNumber: 0,
					 context: nil,
					 characters: "",
					 charactersIgnoringModifiers: "",
					 isARepeat: false,
					 keyCode: 125
				)!)
			}
			return true
		case #selector(NSResponder.cancelOperation(_:)):
			if let content = self.superview?.superview as? CBContentView {
				content.collectionView.keyDown(with: NSEvent.keyEvent(
					 with: .keyDown,
					 location: NSPoint(x: 0, y: 0),
					 modifierFlags: [],
					 timestamp: ProcessInfo.processInfo.systemUptime,
					 windowNumber: 0,
					 context: nil,
					 characters: "",
					 charactersIgnoringModifiers: "",
					 isARepeat: false,
					 keyCode: 53
				)!)
			}
			return true
		case #selector(NSResponder.insertNewline(_:)):
			if let content = self.superview?.superview as? CBContentView {
				content.collectionView.keyDown(with: NSEvent.keyEvent(
					 with: .keyDown,
					 location: NSPoint(x: 0, y: 0),
					 modifierFlags: [],
					 timestamp: ProcessInfo.processInfo.systemUptime,
					 windowNumber: 0,
					 context: nil,
					 characters: "\n",
					 charactersIgnoringModifiers: "\n",
					 isARepeat: false,
					 keyCode: 36
				)!)
			}
			return true
		default:
			return false
		}
	}
}
