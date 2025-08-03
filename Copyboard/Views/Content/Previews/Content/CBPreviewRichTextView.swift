//
//  CBPreviewTextView.swift
//  Copyboard
//
//  Created by samara on 30.06.2025.
//

import Cocoa

class CBPreviewRichTextView: CBPreviewBaseView {
	override func setupViews() {
		let attrString = _generatePreviewAttributedString()
		
		let textStorage = NSTextStorage(attributedString: attrString)
		let layoutManager = NSLayoutManager()
		let textContainer = NSTextContainer(size: bounds.size)
		textContainer.widthTracksTextView = true
		textContainer.heightTracksTextView = true
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)
		
		let textView = NSTextView(frame: .zero, textContainer: textContainer)

		textView.isEditable = false
		textView.isSelectable = true
		textView.drawsBackground = true
		
		if
			attrString.length > 0,
			let bgColor = attrString.attribute(.backgroundColor, at: 0, effectiveRange: nil) as? NSColor
		{
			textView.backgroundColor = bgColor
		} else {
			textView.backgroundColor = .clear
		}

		textView.textContainerInset = NSSize(width: 5, height: 5)
		
		addSubview(textView)
		Self.pinToEdges(textView, of: self)
	}
	
	private func _generatePreviewAttributedString() -> NSAttributedString {
		let maxLength = 1024
		
		if
			let html = item.typedData[.html],
			let str = try? NSAttributedString(
				data: html,
				options: [.documentType: NSAttributedString.DocumentType.html],
				documentAttributes: nil
			),
			str.attribute(.backgroundColor, at: 0, effectiveRange: nil) != nil
		{
			return str._truncated(to: maxLength)
		}
		
		if
			let rtf = item.typedData[.rtf],
			let str = try? NSAttributedString(
				data: rtf,
				options: [.documentType: NSAttributedString.DocumentType.rtf],
				documentAttributes: nil
			),
			str.attribute(.backgroundColor, at: 0, effectiveRange: nil) != nil
		{
			return str._truncated(to: maxLength)
		}
		
		// Fallback to plain text if no attributed content with background color
		if
			let text = item.typedData[.utf8PlainText] ?? item.typedData[.text],
			let string = String(data: text, encoding: .utf8)
		{
			let paragraph = NSMutableParagraphStyle()
			paragraph.lineSpacing = 4
			paragraph.paragraphSpacing = 6
			paragraph.lineBreakMode = .byWordWrapping
			
			let attributes: [NSAttributedString.Key: Any] = [
				.font: NSFont.systemFont(ofSize: 13, weight: .regular),
				.foregroundColor: NSColor.labelColor,
				.paragraphStyle: paragraph
			]
			
			let styled = NSAttributedString(string: string, attributes: attributes)
			return styled._truncated(to: maxLength)
		}
		
		return NSAttributedString(string: "")
	}

}

private extension NSAttributedString {
	func _truncated(to length: Int) -> NSAttributedString {
		if self.length > length {
			self.attributedSubstring(from: NSRange(location: 0, length: length))
		} else {
			self
		}
	}
}
