//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by William Brosnan on 3/21/15.
//  Copyright (c) 2015 William Brosnan. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject
{
    init (filePathUrl: NSURL, title: String)
    {
        self.filePathUrl = filePathUrl
        self.title = title
        
        super.init()
    }
    
    var filePathUrl: NSURL!
    var title: String!
}
