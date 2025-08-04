//
//  CBSettingsView.swift
//  Copyboard
//
//  Created by samara on 3.07.2025.
//

import SwiftUI

enum TabEnum: String, CaseIterable, Hashable {
	case general
	case monitor
 	case shortcuts
	
	var title: String {
		switch self {
		case .general:		.localized("General")
		case .shortcuts:	.localized("Shortcuts")
		case .monitor:		.localized("Monitor")
		}
	}
	
	var icon: String {
		switch self {
		case .general:		"gear"
		case .shortcuts:	"keyboard"
		case .monitor:		"eye"
		}
	}
	
	@ViewBuilder
	static func view(for tab: TabEnum) -> some View {
		switch tab {
		case .general:		CBSettingsGeneralView()
		case .shortcuts:	CBSettingsShortcutsView()
		case .monitor:		CBSettingsMonitorView()
		}
	}
	
	// I'm not normal so I put "," in front of
	// each case so I can comment it out later
	static var defaultTabs: [TabEnum] {[
		.general
		,.shortcuts
		,.monitor
	]}
}

extension TabEnum: Identifiable {
	var id: String { rawValue }
}

struct CBSettingsView: View {
	@State private var _selectedTab: TabEnum = .general
	
	var body: some View {
		NavigationSplitView {
			List(TabEnum.defaultTabs, selection: $_selectedTab) { tab in
				Label(tab.title, systemImage: tab.icon).tag(tab)
			}
		} detail: {
			TabEnum.view(for: _selectedTab).navigationTitle(_selectedTab.title)
		}
	}
}
