//
//  RM_Entity+CoreDataProperties.swift
//  RM_
//
//  Created by Oleh Kulykov on 25/04/16.
//  Copyright © 2016 Oleh Kulykov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension RM_Entity {

	/**
	Core Data entity identifier fileld.
	*/
    @NSManaged public var oId: String

}
