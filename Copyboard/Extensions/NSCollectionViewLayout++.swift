//
//  NSCollectionViewLayout++.swift
//  Copyboard
//
//  Created by samara on 27.06.2025.
//

import AppKit.NSCollectionViewLayout

extension NSCollectionViewLayout {
	static func paddedListLayout(direction: NSCollectionView.ScrollDirection) -> NSCollectionViewFlowLayout {
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.scrollDirection = direction
		
		flowLayout.sectionInset = NSEdgeInsets(
			top: CBConstants.padding,
			left: CBConstants.padding,
			bottom: CBConstants.padding,
			right: CBConstants.padding
		)
		
		flowLayout.minimumLineSpacing = CBConstants.padding
		flowLayout.minimumInteritemSpacing = CBConstants.padding
		return flowLayout
	}
}
