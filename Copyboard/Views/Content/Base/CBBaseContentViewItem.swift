//
//  CBBaseContentViewItem.swift
//  Copyboard
//
//  Created by samsam on 7/28/25.
//

import Cocoa
import ClipKit
import QuickLookThumbnailing

open class CBBaseContentViewItem: NSCollectionViewItem {
	var object: CBObject!
	
	// MARK: Views
	
	lazy var titleLabel: NSTextField = {
		let label = NSTextField(labelWithString: "")
		label.alignment = .left
		label.font = NSFont.systemFont(ofSize: 14, weight: .medium)
		label.lineBreakMode = .byTruncatingTail
		label.usesSingleLineMode = true
		return label
	}()
	
	lazy var subtitleLabel: NSTextField = {
		let label = NSTextField(labelWithString: "")
		label.alignment = .left
		label.font = NSFont.systemFont(ofSize: 13)
		label.textColor = .secondaryLabelColor
		label.lineBreakMode = .byTruncatingTail
		label.usesSingleLineMode = true
		return label
	}()
	
	lazy var iconThumbnailImageView: NSImageView = {
		let imageView = NSImageView()
		imageView.imageScaling = .scaleProportionallyUpOrDown
		imageView.wantsLayer = true
		imageView.image = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
		return imageView
	}()
	
	// MARK: Load
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(animateClickFeedback))
		view.addGestureRecognizer(clickGesture)
		_updateSelectionAppearance()
	}
	
	open override func prepareForReuse() {
		super.prepareForReuse()
		iconThumbnailImageView.image = nil
	}
	
	open override var isSelected: Bool {
		didSet { _updateSelectionAppearance() }
	}
	
	private func _updateSelectionAppearance() {
		if isSelected {
			view.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.7).cgColor
		} else {
			view.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.1).cgColor
		}
	}
	
	@objc func animateClickFeedback() {
		ClipboardMonitorManager.shared.addToClipboard(
			using: object,
			asPlain: UserDefaults.standard.bool(forKey: "CB.copyAsPlainText")
		)
		NotificationCenter.default.post(name: .collectionViewGetFirstResponder, object: nil)
		AppDelegate.main.menuBar?.statusItem.dismissWindow()
	}
	
	// MARK: Open
	
	open func setupViews() {
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.1).cgColor
		view.layer?.cornerRadius = CBConstants.cellCornerRadius
		view.layer?.cornerCurve = .continuous
	}
	
	open func configure(using object: CBObject) {
		self.object = object

		if let url = object.application?.bundleUrl?.path {
			iconThumbnailImageView.image = NSWorkspace.shared.icon(forFile: url)
		}
				
		let appName: String = {
			if let url = object.application?.bundleUrl {
				Bundle(url: url)?.name ?? "Unknown"
			} else {
				"Unknown"
			}
		}()
		
		let calendar = Calendar.current
		let dateFormatter = DateFormatter()
		let date = object.dateAdded!
		dateFormatter.timeStyle = .short
		dateFormatter.dateStyle = calendar.isDateInToday(date) || calendar.isDateInYesterday(date) ? .none : .medium

		subtitleLabel.stringValue = "\(appName) • \(dateFormatter.string(from: date))"
	}
}
