//
//  Theme.swift
//  HerCycle
//
//  Created by Ana on 7/23/24.
//

import UIKit

struct Theme {
    let name: String
    let imageName: String
    
    var image: UIImage {
        UIImage(named: imageName) ?? UIImage()
    }
}
