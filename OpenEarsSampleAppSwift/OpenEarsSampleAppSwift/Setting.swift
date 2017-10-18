//
//  Setting.swift
//  OpenEarsSampleAppSwift
//
//  Created by Christopher James Lebioda on 10/14/17.
//  Copyright © 2017 Politepix. All rights reserved.
//

import UIKit


class Setting {
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        
    }
}
