//
//  QLThumbnailGenerator+generate.swift
//  Copyboard
//
//  Created by samara on 28.06.2025.
//

import AppKit.NSScreen
import AppKit.NSImage
import QuickLookThumbnailing.QLThumbnailGenerator

extension QLThumbnailGenerator {
	static func generateThumbnail(
		for url: URL?,
		size: CGSize = CGSize(width: 128, height: 128),
		scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 1.0,
		representation: QLThumbnailGenerator.Request.RepresentationTypes = .icon,
		completion: @escaping (NSImage?) -> Void
	) {
		guard let url else { return }
		
		let request = QLThumbnailGenerator.Request(
			fileAt: url,
			size: size,
			scale: scale,
			representationTypes: representation
		)
		
		QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
			DispatchQueue.main.async {
				let image = thumbnail?.nsImage
				completion(image)
			}
		}
	}
}
