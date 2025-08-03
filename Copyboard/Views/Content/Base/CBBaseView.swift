//
//  CBBaseView.swift
//  Copyboard
//
//  Created by samara on 27.06.2025.
//

import Cocoa

class CBBaseView: NSView {
	private func _blurBackground() -> NSVisualEffectView {
		let effectView = NSVisualEffectView()
		effectView.state = .active
		effectView.material = .hudWindow
		effectView.blendingMode = .behindWindow
		return effectView
	}
	
	// MARK: Init
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		_setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		wantsLayer = true
	}
	
	// MARK: Setup
	
	private func _setupViews() {
		wantsLayer = true
		layer?.backgroundColor = .clear
		
		let blurView = _blurBackground()
		blurView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(blurView)

		Self.pinToEdges(blurView, of: self)
	}
}
