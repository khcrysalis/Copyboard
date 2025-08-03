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
