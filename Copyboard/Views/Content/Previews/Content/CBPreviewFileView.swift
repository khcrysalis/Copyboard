//
//  CBPreviewFileView.swift
//  Copyboard
//
//  Created by samara on 30.06.2025.
//

import Cocoa
import QuickLookThumbnailing

class CBPreviewFileView: CBPreviewBaseView {
	override func setupViews() {
		guard
			let fileData = item.typedData[.fileURL],
			let filePath = String(data: fileData, encoding: .utf8),
			let fileURL = URL(string: filePath)
		else {
			return
		}
		
		let stackView = NSStackView()
		stackView.orientation = .vertical
		stackView.spacing = 8
		stackView.alignment = .centerX
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.setHuggingPriority(.defaultLow, for: .vertical)
		stackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		
		let thumbnailImageView = NSImageView()
		thumbnailImageView.wantsLayer = true
		thumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
		thumbnailImageView.layer?.masksToBounds = true
		thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
		thumbnailImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
		thumbnailImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		
		let maxHeight: CGFloat = 120
		let heightConstraint = thumbnailImageView.heightAnchor.constraint(equalToConstant: maxHeight)
		heightConstraint.priority = .defaultHigh
		heightConstraint.isActive = true
		
		thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor).isActive = true
		
		stackView.addArrangedSubview(thumbnailImageView)
		
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
			stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
		])
		
		QLThumbnailGenerator.generateThumbnail(for: fileURL, representation: .all) { image in
			thumbnailImageView.image = image
		}
	}
}
