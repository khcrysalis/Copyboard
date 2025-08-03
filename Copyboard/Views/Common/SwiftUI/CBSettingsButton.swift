//
//  CBSettingsButton.swift
//  Copyboard
//
//  Created by samara on 6.07.2025.
//

import SwiftUI

struct CBSettingsButton: View {
	private var _title: String
	private var _systemImage: String
	private let _action: () -> Void
	
	init(_ title: String, systemImage: String, action: @escaping () -> Void) {
		self._title = title
		self._systemImage = systemImage
		self._action = action
	}
	
	var body: some View {
		Button(action: _action) {
			Label(_title, systemImage: _systemImage)
		}
		.buttonStyle(.borderless)
		.labelStyle(.iconOnly)
	}
}
