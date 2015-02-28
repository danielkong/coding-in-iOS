//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by daniel on 11/9/14.
//  Copyright (c) 2014 DK. All rights reserved.
//

import Foundation
import CoreData

// interact with object C
@objc (FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData

}
