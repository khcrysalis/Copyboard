//
//  NSView+pinToEdges.swift
//  Copyboard
//
//  Created by samara on 30.06.2025.
//

import AppKit.NSView

extension NSView {
	static func pinToEdges(_ child: NSView, of parent: NSView) {
		child.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			child.topAnchor.constraint(equalTo: parent.topAnchor),
			child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
			child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
			child.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
		])
	}
}
