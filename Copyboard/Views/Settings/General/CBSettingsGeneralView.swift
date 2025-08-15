//
//  CBSettingsGeneralView.swift
//  Copyboard
//
//  Created by samara on 3.07.2025.
//

import SwiftUI
import ServiceManagement
import UserNotifications
import ClipKit

#warning("fix koda weird padding isuse??")
#warning("add uhm a app whitelist for HTML because it sucks lol")
#warning("add preview settings from clipper (theyre fancy)")
#warning("add support for paste modes, clicking should allow either copying to clipboard or pasting to active app")

// MARK: - CBSettingsGeneralView
struct CBSettingsGeneralView: View {
	#if !DEBUG
	@AppStorage("CB.launchAtLogin") private var _launchAtLogin = {
		SMAppService.mainApp.status == .enabled
	}()
	#endif
	@AppStorage("CB.copyAsPlainText")
	private var _copyAsPlainText: Bool = false
	
	@AppStorage("CB.clearHistoryOnQuit")
	private var _clearHistoryOnQuit: Bool = false
	
	@AppStorage("CB.playSoundWhenCopying")
	private var _playSoundWhenCopying: Bool = false
	
	@AppStorage("CB.displayNotificationWhenCopying")
	private var _displayNotificationWhenCopying: Bool = false
	
	@AppStorage("CB.erasureTargetIndex")
	private var _erasureTargetIndex: Int = 0
	
	@AppStorage("CK.shouldPasteAutomatically")
	private var _shouldPasteAutomatically: Bool = false
	
	@State private var _isEraseAlertPresenting: Bool = false

	
	/*
	@State private var _notificationsAllowed: Bool = true
	
	private let _notificationURL: URL = .init(
		string: "x-apple.systempreferences:com.apple.preference.notifications?id="
		+ Bundle.main.bundleIdentifier!
	)!
	 */
	
	var body: some View {
		Form {
			_generalSection()
			_notificationsSection()
			_historySection()
		}
		.formStyle(.grouped)
		/*
		.onAppear {
			CBNotificationManager.shared.checkStatus { allowed in
				_notificationsAllowed = allowed
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
			CBNotificationManager.shared.checkStatus { allowed in
				_notificationsAllowed = allowed
			}
		}
		 */
		#if !DEBUG
		.onChange(of: _launchAtLogin) { _ in
			Task {
				if _launchAtLogin {
					try SMAppService.mainApp.register()
				} else {
					try SMAppService.mainApp.unregister()
				}
			}
		}
		#endif
//		.animation(.interactiveSpring, value: _notificationsAllowed)
	}
}

// MARK: - CBSettingsGeneralView (Extension): Builders
extension CBSettingsGeneralView {
	
	// MARK: General
	
	@ViewBuilder
	private func _generalSection() -> some View {
		/*
		if !_notificationsAllowed {
			Section {
				VStack(alignment: .leading) {
					Text("Notifications are disabled, which limits features like alerts when you copy something.")
					Button("Open Settings") {
						NSWorkspace.shared.open(_notificationURL)
					}
				}
			}
		}
		 */
		
		Section {
			Toggle(.localized("Check for Updates Automatically"), isOn: .constant(false)).disabled(true)
			#if !DEBUG
			Toggle(.localized("Launch at Login"), isOn: $_launchAtLogin)
			#endif
			Toggle(.localized("Copy Without Formatting"), isOn: $_copyAsPlainText)
			Toggle(.localized("Erase History on Quit"), isOn: $_clearHistoryOnQuit)
			Toggle(.localized("Paste Automatically"), isOn: $_shouldPasteAutomatically)
		}
	}
	
	// MARK: Notifications
	
	@ViewBuilder
	private func _notificationsSection() -> some View {
		Section {
			Toggle(.localized("Play Sound"), isOn: $_playSoundWhenCopying)
			/*
			if _notificationsAllowed {
				Toggle("Show Notification", isOn: $_displayNotificationWhenCopying)
			}
			if #unavailable(macOS 15.0) {
				Button("System Notification Settings") {
					NSWorkspace.shared.open(_notificationURL)
				}
			}
			 */
		} header: {
			CBSettingsHeaderView(
				.localized("Sounds & Notifications"),
				subtitle: .localized("Customize the notifications events when copying.")
			)
		}
	}
	
	// MARK: History
	
	@ViewBuilder
	private func _historySection() -> some View {
		Section {
			VStack {
				Slider(
					value: Binding(
						get: { Double(_erasureTargetIndex) },
						set: { _erasureTargetIndex = Int(round($0)) }
					),
					in: 0...Double(ErasureTarget.allCases.count - 1),
					step: 1
				)
				.labelsHidden()
				.accentColor(.gray)

				ZStack {
					ForEach(Array(ErasureTarget.allCases.enumerated()), id: \.element) { index, target in
						HStack {
							ForEach(0..<index, id: \.self) { _ in
								Spacer()
							}
							
							Text(target.label)
								
							ForEach(0..<(ErasureTarget.allCases.count - index - 1), id: \.self) { _ in
								Spacer()
							}
						}
					}
				}
				.font(.footnote)
				.padding(.top, 2)
			}
			.disabled(_clearHistoryOnQuit)
		} header: {
			CBSettingsHeaderView(
				.localized("History"),
				subtitle: .localized("Choose when the app priodically deletes your clipboards.")
			)
		}

		Section {
			Button(.localized("Erase History...")) {
				_isEraseAlertPresenting = true
			}
			.alert(.localized("Erase"), isPresented: $_isEraseAlertPresenting, actions: {
				Button(.localized("Erase"), role: .destructive) { StorageManager.shared.eraseHistory() }
				Button(.localized("Cancel"), role: .cancel) {}
			}, message: {
				Text(.localized("Are you sure you want to erase your history?"))
			})
		}
	}
}

// MARK: ErasureTarget (extension): Label
private extension ErasureTarget {
	var label: LocalizedStringKey {
		switch self {
		case .day: 		.localized("Day")
		case .week: 	.localized("Week")
		case .month: 	.localized("Month")
		case .year: 	.localized("Year")
		case .forever: 	.localized("Forever")
		}
	}
}
