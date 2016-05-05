//
//  RM_BackgroundedSectionTableView.swift
//  RM_
//
//  Created by Oleh Kulykov on 27/04/16.
//  Copyright © 2016 Oleh Kulykov. All rights reserved.
//

import UIKit

/**
Base table view section background view.
Use subclass to make view customization.
*/
public class RM_TableViewSectionBackground : UIView {

	/**
	Calculated by the `RM_BackgroundedSectionTableView` section frame.
	*/
	private(set) var calculatedFrame = CGRectZero
}


/**
Delegate to the `RM_BackgroundedSectionTableView` table view.
Table view have no delegate property for this type, so, extend you `UITableViewDataSource` with this type.
*/
@objc
public protocol RM_BackgroundedSectionTableViewDelegate {
	/**
	Ask gelegate object to create section background view for the section by it's index.
	By default no section background, e.g. `nil`.
	
	- Parameter tableView: The table view that required for the section view.
	
	- Parameter section: Requested section index.
	
	- Returns: Initialized section background view or nil if no background needed. 
	*/
	optional func tableView(tableView: RM_BackgroundedSectionTableView, sectionBackground section: Int) -> RM_TableViewSectionBackground?


	/**
	Ask gelegate object for the section background edge insets. Provide positive values to decrease section background size.
	Default is `UIEdgeInsetsZero`.

	- Parameter tableView: The table view that required for the section insets.

	- Parameter section: Requested section index.
	
	- Returns: Section background edge insets.
	*/
	optional func tableView(tableView: RM_BackgroundedSectionTableView, sectionBackgroundEdgeInsets section: Int) -> UIEdgeInsets


	/**
	Ask gelegate object that section background should be placed also under section footer.
	Default is `false` - ignore section footer.

	- Parameter tableView: The table view that could place section background under footer.
 
	- Parameter section: Requested section index.
	
	- Returns: `true` - section background also locates under footer, `false` - ignore section footer.
	*/
	optional func tableView(tableView: RM_BackgroundedSectionTableView, sectionBackgroundUnderFooter section: Int) -> Bool


	/**
	Ask gelegate object that section background should be placed also under section header.
	Default is `false` - ignore section header.

	- Parameter tableView: The table view that could place section background under header.

	- Parameter section: Requested section index.

	- Returns: `true` - section background also locates under header, `false` - ignore section header.
	*/
	optional func tableView(tableView: RM_BackgroundedSectionTableView, sectionBackgroundUnderHeader section: Int) -> Bool
}


public class RM_BackgroundedSectionTableView : UITableView {

	private func tagForSection(section: Int) -> Int {
		return -section - 100 // any value
	}

	private func removeBackgroundViews() {
		for subview in self.subviews {
			if let back = subview as? RM_TableViewSectionBackground {
				back.removeFromSuperview()
			}
		}
	}

	private var numberOfSectionsInDataSource: Int {
		return self.dataSource?.numberOfSectionsInTableView?(self) ?? 0
	}

	private func createBackgroundViews() {
		for section in 0..<numberOfSectionsInDataSource {
			createBackgroundViewForSection(section)
		}
	}

	private func backgroundViewForSection(section: Int) -> RM_TableViewSectionBackground? {
		return viewWithTag(tagForSection(section)) as? RM_TableViewSectionBackground
	}

	private func createBackgroundViewForSection(section: Int) {
		if backgroundViewForSection(section) == nil {
			guard let view = (delegate as? RM_BackgroundedSectionTableViewDelegate)?.tableView?(self, sectionBackground: section) else {
				return
			}
			view.tag = tagForSection(section)
			self.addSubview(view)
			self.sendSubviewToBack(view)
		}
	}

	private func calculateSectionBackgroundFrames() {
		let sectionDelegate = delegate as? RM_BackgroundedSectionTableViewDelegate
		for section in 0..<numberOfSectionsInDataSource {
			if let back = backgroundViewForSection(section) {
				var frame = rectForSection(section)

				let insets = sectionDelegate?.tableView?(self, sectionBackgroundEdgeInsets: section) ?? UIEdgeInsetsZero

				frame.origin.x += insets.left
				frame.origin.y += insets.top
				frame.size.width -= insets.left + insets.right
				frame.size.height -= insets.top + insets.bottom

				let includeHeader = sectionDelegate?.tableView?(self, sectionBackgroundUnderHeader: section) ?? false
				if !includeHeader {
					let header = rectForHeaderInSection(section)
					frame.origin.y += header.height
					frame.size.height -= header.height
				}

				let includeFooter = sectionDelegate?.tableView?(self, sectionBackgroundUnderFooter: section) ?? false
				if !includeFooter {
					let footer = rectForFooterInSection(section)
					frame.size.height -= footer.height
				}

				back.frame = frame
				back.calculatedFrame = frame
			}
		}
	}

	private func reloadBackgroundViews() {
		removeBackgroundViews()
		createBackgroundViews()
	}

	public func onDidScroll() {
		calculateSectionBackgroundFrames()
	}

	public override func reloadData() {
		super.reloadData()
		reloadBackgroundViews()
		setNeedsLayout()
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		calculateSectionBackgroundFrames()
		for section in 0..<numberOfSectionsInDataSource {
			if let back = backgroundViewForSection(section) {
				back.frame = back.calculatedFrame
			}
		}
	}
}
