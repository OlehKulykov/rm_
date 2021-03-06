//
//  RM_NetworkIndicator.swift
//  RM_
//
//  Created by Oleh Kulykov on 27/04/16.
//  Copyright © 2016 Oleh Kulykov. All rights reserved.
//

import UIKit

/**
Threadsafe application network indicator.
Used `UIApplication.sharedApplication().networkActivityIndicatorVisible` and could be
updated recursivly from any thread.
Use `visible` static variable to change visibility.

- Note: Based on counter logic, so if you want to change this value you need to set reverse value same times.

Example: 

```swift
RM_NetworkIndicator.visible = true // visible
RM_NetworkIndicator.visible = true // visible
...
RM_NetworkIndicator.visible = false // still visible
RM_NetworkIndicator.visible = false // now it's invisible
```
*/
open class RM_NetworkIndicator {

	//MARK: Private variables and functions

	/// Counts number of visible calls. Positive value is visible, otherwice invisible.
	/// - Warning: Get/set value from main thread. Min value is zero - invisible.
	fileprivate static var visibilityCounter: Int = 0 {
		didSet {
			UIApplication.shared.isNetworkActivityIndicatorVisible = visibilityCounter > 0
		}
	}


	/// Increment or decrement visibility counter
	/// - Parameter visible: Required visibility. `true` - increment, `false` - decrement to min, zero value.
	fileprivate static func updateVisibilityCounter(_ visible: Bool) {
		let newValue = visible ? visibilityCounter + 1 : visibilityCounter - 1
		visibilityCounter = max(newValue, 0)
	}


	//MARK: Public variables

	/**
	Set/get network indicator visibility.
	Threadsafe. Actual value will be set/get within main thread.

	- Note: Based on counter logic, so if you want to change this value you need to set reverse value same times.
	*/
	open static var visible: Bool {
		get {
			if Thread.isMainThread {
				return visibilityCounter > 0
			} else {
				var value = false
				DispatchQueue.main.sync {
					value = visibilityCounter > 0
				}
				return value
			}
		}
		set {
			if Thread.isMainThread {
				updateVisibilityCounter(newValue)
			} else {
				DispatchQueue.main.async {
					updateVisibilityCounter(newValue)
				}
			}
		}
	}
}
