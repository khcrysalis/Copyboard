//
//  CBPreviewImageView.swift
//  Copyboard
//
//  Created by samara on 30.06.2025.
//

import Cocoa

class CBPreviewImageView: CBPreviewBaseView {
	override func setupViews() {
		guard
			let data = item.typedData[.png] ?? item.typedData[.jpeg],
			let image = NSImage(data: data)
		else {
			return
		}
		
		wantsLayer = true
		layer?.contentsGravity = .resizeAspectFill
		layer?.contents = image
	}
}
