//
//  CBSettingsHeaderView.swift
//  Copyboard
//
//  Created by samara on 6.07.2025.
//


import SwiftUI

struct CBSettingsHeaderView: View {
	var _title: String
	var _subtitle: String?
	
	init(_ title: String, subtitle: String? = nil) {
		self._title = title
		self._subtitle = subtitle
	}
	
	var body: some View {
		Text(_title)
		if let _subtitle {
			Text(_subtitle)
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
	}
}
