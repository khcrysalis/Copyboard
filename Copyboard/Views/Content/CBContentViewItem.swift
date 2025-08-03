//
//  CBContentViewItem.swift
//  Copyboard
//
//  Created by samara on 7.07.2025.
//

import Cocoa
import ClipKit
import QuickLookThumbnailing
import DataTypesKit
import SwiftUI

// MARK: - Class
class CBContentViewItem: CBBaseContentViewItem {
	static let reuseIdentifier = "ClipCell.Compact"

	// MARK: Views
	
	private var itemsContainerView = CBItemPreviewView(items: nil, direction: .vertical)
	
	// MARK: Setup
	
	override func setupViews() {
		super.setupViews()
		
		iconThumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
		iconThumbnailImageView.wantsLayer = true
		iconThumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
		iconThumbnailImageView.setContentHuggingPriority(.required, for: .horizontal)
		iconThumbnailImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		iconThumbnailImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
		iconThumbnailImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
		subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
		
		let bottomRowStack = NSStackView(views: [iconThumbnailImageView, subtitleLabel])
		bottomRowStack.orientation = .horizontal
		bottomRowStack.spacing = 7
		bottomRowStack.alignment = .centerY
		bottomRowStack.translatesAutoresizingMaskIntoConstraints = false
		
		let leftPadding = NSView()
		leftPadding.translatesAutoresizingMaskIntoConstraints = false
		leftPadding.widthAnchor.constraint(equalToConstant: 1.8).isActive = true
		
		let titleRowStack = NSStackView(views: [leftPadding, titleLabel])
		titleRowStack.orientation = .horizontal
		titleRowStack.alignment = .firstBaseline
		titleRowStack.spacing = 0
		titleRowStack.translatesAutoresizingMaskIntoConstraints = false
		
		let infoStack = NSStackView(views: [titleRowStack, bottomRowStack])
		infoStack.orientation = .vertical
		infoStack.spacing = 7
		infoStack.alignment = .leading
		infoStack.translatesAutoresizingMaskIntoConstraints = false
		
		itemsContainerView.translatesAutoresizingMaskIntoConstraints = false
		
		[itemsContainerView, infoStack].forEach {
			view.addSubview($0)
		}
		
		let padding: CGFloat = CBConstants.innerPadding
		
		NSLayoutConstraint.activate([
			infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
			infoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
			infoStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(padding-2)),
			
			itemsContainerView.leadingAnchor.constraint(equalTo: infoStack.trailingAnchor, constant: padding),
			itemsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
			itemsContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
			itemsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
			itemsContainerView.widthAnchor.constraint(lessThanOrEqualTo: itemsContainerView.heightAnchor)
		])
	}
	
	// MARK: Configuration
	
	override func configure(using object: CBObject) {
		super.configure(using: object)
		let items = (object.items as? Set<CBObjectItem>) ?? []
		
		self.itemsContainerView.items = Array(items)
		
		switch items.count {
		case 0:
			titleLabel.stringValue = "Unknown"
		case 1:
			if let item = items.first {
				if let string = item.stringForCompactType() {
					titleLabel.stringValue = string
				} else if let highestPriorityType = CBPreviews.findHighestPriorityType(
					from: item.types?.compactMap(DataType.init) ?? []
				) {
					titleLabel.stringValue = highestPriorityType.localizedDescription
				} else {
					titleLabel.stringValue = "Unknown"
				}
			}
		default:
			titleLabel.stringValue = "\(items.count) Items"
		}
	}
}
