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
	@AppStorage("CB.panelShouldAppearAtMenuBar") 
	private var _panelShouldAppearAtMenuBar: Bool = false
	
	var body: some View {
		Form {
			Section {
				KeyboardShortcuts.Recorder(for: .togglePanel) {
					Text(verbatim: .localized("Show %@", arguments: Bundle.main.name))
				}.padding(.top, 3)
				Toggle(String.localized("Show %@ under menu bar", arguments: Bundle.main.name), isOn: $_panelShouldAppearAtMenuBar)
			}
			
			Section {
				#warning("unfinished")
				Text("""
				These are the default keybinds that can be used when you're interacting with the clipboard items.
				• Quick Copy: `⌘ 1...9`
				• Selection: `↑ ↓`
				• Copy: `⏎`
				• Preview: `⌘ + p`
				• Favorite: `⌘ + f`
				• Delete: `⌘ + ⌫`
				""").foregroundStyle(.secondary)
			}
			
			Section {
				Button(.localized("Reset shortcuts to default...")) {
					KeyboardShortcuts.reset(.togglePanel)
				}
			}
		}
		.formStyle(.grouped)
	}
}
