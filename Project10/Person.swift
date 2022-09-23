//
//  Person.swift
//  Project10
//
//  Created by Lucas Rocha on 23/09/22.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    
    init(_ name: String, _ image: String) {
        self.name = name
        self.image = image
    }
}
