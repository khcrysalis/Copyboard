//
//  CBQuickLookIconView.swift
//  Copyboard
//
//  Created by samara on 6.07.2025.
//

import SwiftUI
import QuickLookThumbnailing

struct CBQuickLookIconView: View {
	let url: URL
	@State private var image: NSImage? = nil
	
	var body: some View {
		Group {
			if let image {
				Image(nsImage: image)
					.resizable()
					.scaledToFit()
			} else {
				Color.clear
			}
		}
		.onAppear {
			QLThumbnailGenerator.generateThumbnail(for: url, size: CGSize(width: 48, height: 48)) { image in
				self.image = image
			}
		}
	}
}
