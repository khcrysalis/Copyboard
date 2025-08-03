//
//  CBPreviewPlainTextView.swift
//  Copyboard
//
//  Created by samara on 3.07.2025.
//

import Cocoa

class CBPreviewPlainTextView: CBPreviewBaseView {
	override func setupViews() {
		guard
			let data = item.typedData[.utf8PlainText],
			let string = String(data: data, encoding: .utf8)
		else {
			return
		}
		
		let textView = NSTextView(frame: .zero)
		textView.string = string
		textView.isEditable = false
		textView.isSelectable = false
		textView.drawsBackground = false
		textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
		textView.textColor = .labelColor
		textView.isHorizontallyResizable = false
		textView.isVerticallyResizable = true
		textView.autoresizingMask = [.width]
		
		addSubview(textView)
		Self.pinToEdges(textView, of: self)
	}
}
