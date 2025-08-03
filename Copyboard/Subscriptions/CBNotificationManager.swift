//
//  CBNotificationManager.swift
//  Copyboard
//
//  Created by samara on 7.07.2025.
//

import Foundation
import Combine
import UserNotifications
import ClipKit
import AppKit

// MARK: - CBNotificationManager
class CBNotificationManager {
	static let shared = CBNotificationManager()
	
	private var _firstRun = true
	private var _cancellables = Set<AnyCancellable>()
	
	init() {
		NotificationCenter.default.publisher(for: .clipboardDidChange)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				guard let self = self else { return }
				guard !self._firstRun else { self._firstRun = false; return }
//				self._sendNotification()
				self._sendSound()
			}
			.store(in: &_cancellables)
	}
	
	
	private func _sendSound() {
		guard UserDefaults.standard.bool(forKey: "CB.playSoundWhenCopying") else { return }
		if let url = Bundle.main.url(forResource: "clip", withExtension: "caf") {
			let sound = NSSound(contentsOf: url, byReference: false)
			sound?.play()
		}
	}
	
	/*
	private func _sendNotification() {
		guard UserDefaults.standard.bool(forKey: "CB.displayNotificationWhenCopying") else { return }
		checkStatus { if !$0 { return } }
		//
	}
	
	#warning("request auth during onboarding")
	func requestAuthorization(completion: @escaping (Bool) -> Void) {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { authorized, _ in
			DispatchQueue.main.async {
				completion(authorized)
			}
		}
	}
	
	func checkStatus(completion: @escaping (Bool) -> Void) {
		UNUserNotificationCenter.current().getNotificationSettings() { settings in
			DispatchQueue.main.async {
				completion(settings.authorizationStatus == .authorized)
			}
		}
	}
	
	func buildNotification() {
		 UNUserNotificationCenter.current().getNotificationSettings() { settings in
			 if settings.authorizationStatus == .authorized {
				 let content = UNMutableNotificationContent()
				 content.title = "cheese"
				 content.subtitle = "balls"
				 content.body = "body"
				 
				 let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
				 let request = UNNotificationRequest(
					identifier: UUID().uuidString,
					content: content,
					trigger: trigger
				 )
				 
				 UNUserNotificationCenter.current().add(request)
			 }
		 }
	}
	*/
}
