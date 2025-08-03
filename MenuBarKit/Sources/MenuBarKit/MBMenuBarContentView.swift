//
//  MenuBarContentView.swift
//  MenuBarKit
//
//  Created by samsam on 7/27/25.
//

import AppKit

final public class MBMenuBarContentView: NSPanel {
	weak var statusItem: MBMenuBarStatusItem? = nil
	
	private lazy var visualEffectView: NSVisualEffectView = {
		let view = NSVisualEffectView()
		view.blendingMode = .behindWindow
		view.state = .active
		view.material = .popover
		view.translatesAutoresizingMaskIntoConstraints = true
		return view
	}()
	
	public init(
		title: String,
		content: NSView,
		animation: NSWindow.AnimationBehavior = .none
	) {
		super.init(
			contentRect: content.frame,
			styleMask: [.titled, .nonactivatingPanel, .utilityWindow, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)

		self.title = title
		content.autoresizingMask = [.width, .height]
		
		isMovable = false
		isMovableByWindowBackground = false
		isFloatingPanel = true
		level = .statusBar
		isOpaque = false
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		
		animationBehavior = animation
		collectionBehavior = [.stationary, .moveToActiveSpace, .fullScreenAuxiliary]
		isReleasedWhenClosed = false
		hidesOnDeactivate = false
		
		standardWindowButton(.closeButton)?.isHidden = true
		standardWindowButton(.miniaturizeButton)?.isHidden = true
		standardWindowButton(.zoomButton)?.isHidden = true
		
		contentView = visualEffectView
		visualEffectView.addSubview(content)
		
		content.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			content.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
			content.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
			content.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
			content.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
		])
		
		DispatchQueue.main.async { [weak self] in
			self?._applyRoundedCorners()
		}
	}
	
	private func _applyRoundedCorners() {
		self.isOpaque = false
		self.backgroundColor = .clear

		contentView?.wantsLayer = true
		
		if let windowBackdrop = contentView?.superview {
			windowBackdrop.wantsLayer = true
			windowBackdrop.layer?.cornerRadius = MBConstants.windowCornerRadius
			windowBackdrop.layer?.maskedCorners = [
				.layerMinXMaxYCorner,
				.layerMaxXMaxYCorner,
				.layerMaxXMinYCorner,
				.layerMinXMinYCorner
			]
			windowBackdrop.layer?.cornerCurve = .continuous
			windowBackdrop.layer?.masksToBounds = true
		}

		if let layer = contentView?.layer {
			layer.cornerRadius = MBConstants.windowCornerRadius
			layer.cornerCurve = .continuous
			layer.maskedCorners = [
				.layerMinXMinYCorner,
				.layerMaxXMinYCorner,
				.layerMaxXMaxYCorner,
				.layerMinXMaxYCorner
			]
			layer.masksToBounds = true
			layer.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
			layer.borderWidth = 1
		}
	}
	
	public override func makeKey() {
		super.makeKey()
		_applyRoundedCorners()
	}
	
	public override var canBecomeKey: Bool { true }
	public override var canBecomeMain: Bool { true }
}
