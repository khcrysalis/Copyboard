//
//  CBSettingsShortcutsView.swift
//  Copyboard
//
//  Created by samsam on 7/30/25.
//

import SwiftUI
import KeyboardShortcuts

#warning("Add plain text key modifier")

struct CBSettingsShortcutsView: View {
	var body: some View {
		Form {
			Section {
				KeyboardShortcuts.Recorder(for: .togglePanel) {
					Text("Show \(Bundle.main.name)")
				}
				.padding(.top, 3)
			}
			
			Section {
				Text("""
				These are the default keybinds that can be used when you're interacting with the clipboard items.
				• Quick Copy: `1...9`
				• Selection: `↑ ↓`
				• Copy: `⏎`
				• Preview: `␣`
				""").foregroundStyle(.secondary)
			}
			
			Section {
				Button("Reset shortcuts to default...") {
					KeyboardShortcuts.reset(.togglePanel)
				}
			}
		}
		.formStyle(.grouped)
	}
}
