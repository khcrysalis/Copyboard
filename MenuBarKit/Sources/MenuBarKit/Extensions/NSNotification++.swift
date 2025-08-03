//
//  NSNotification++.swift
//  MenuBarKit
//
//  Created by samsam on 7/27/25.
//

import Foundation.NSNotification

extension Notification.Name {
	static let beginMenuTracking = Notification.Name("com.apple.HIToolbox.beginMenuTrackingNotification")
	static let endMenuTracking = Notification.Name("com.apple.HIToolbox.endMenuTrackingNotification")
}
