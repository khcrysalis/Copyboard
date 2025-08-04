//
//  CBSettingsMonitorView.swift
//  Copyboard
//
//  Created by samara on 6.07.2025.
//

import SwiftUI
import ClipKit

// MARK: - CBSettingsMonitorView
struct CBSettingsMonitorView: View {
	@AppStorage("CK.ignoreApps") private var _ignoreApps: Bool = true
	@AppStorage("CK.ignoreTransient") private var _ignoreTransient: Bool = true
	@AppStorage("CK.ignoreConfidential") private var _ignoreConfidential: Bool = true
	
	@State private var _isAppImporterPresenting = false
	@State private var _selectedApps: Set<CBApplication> = []
	
	private var _filteredSources: [CBApplication] {
		_sources.sorted {
			Bundle(url: $0.bundleUrl!)?.name ?? ""
			<
			Bundle(url: $1.bundleUrl!)?.name ?? ""
		}
	}
	
	@FetchRequest(
		entity: CBApplication.entity(),
		sortDescriptors: [],
		predicate: NSPredicate(format: "shouldIgnore == %@", NSNumber(value: true)),
		animation: .snappy
	) private var _sources: FetchedResults<CBApplication>
	
	var body: some View {
		Form {
			Section {
				Toggle(isOn: $_ignoreApps) {
					CBSettingsHeaderView(
						"Ignore 'app' explicit markers",
						subtitle: "Does not save content from applications such as 1Password, Keeweb, and Maccy."
					)
				}
				Toggle(isOn: $_ignoreTransient) {
					CBSettingsHeaderView(
						"Ignore 'transient' markers",
						subtitle: "Does not save content that are considered temporary."
					)
				}
				Toggle(isOn: $_ignoreConfidential) {
					CBSettingsHeaderView(
						"Ignore 'confidential' markers",
						subtitle: "Does not save content that is meant to be considered private and not stored."
					)
				}
			}
			
			Section {
				if !_filteredSources.isEmpty {
					List(_filteredSources, id: \.self, selection: $_selectedApps) { app in
						_application(for: app.bundleUrl!)
					}
				} else {
					Text("No blacklisted applications.")
						.foregroundStyle(.secondary)
				}
				
				HStack {
					CBSettingsButton("Add", systemImage: "plus") {
						_isAppImporterPresenting = true
					}
					
					CBSettingsButton("Delete", systemImage: "minus") {
						for app in Array(_selectedApps) {
							StorageManager.shared.ignoreApplication(for: app, false)
						}
						try? StorageManager.shared.saveContext()
					}
					.disabled(_selectedApps.isEmpty || _filteredSources.isEmpty)
					
					Spacer()
				}
			} header: {
				CBSettingsHeaderView(
					"Blacklisted Applications",
					subtitle: "See what applications the monitor should ignore when copying."
				)
			}
		}
		.formStyle(.grouped)
		.fileImporter(
			isPresented: $_isAppImporterPresenting,
			allowedContentTypes: [.applicationBundle]
		) { result in
			if case .success(let url) = result {
				if let application = StorageManager.shared.createApplication(for: url) {
					StorageManager.shared.ignoreApplication(for: application)
				}
			}
		}
	}
}

// MARK: - CBSettingsMonitorView (Extension): Builders
extension CBSettingsMonitorView {
	@ViewBuilder
	private func _application(for bundle: URL) -> some View {
		HStack(spacing: 8) {
			Image(nsImage: NSWorkspace.shared.icon(forFile: bundle.path))
				.resizable()
				.scaledToFit()
				.frame(width: 32, height: 32)
			
			Text(bundle.deletingPathExtension().lastPathComponent)
		}
	}
}
