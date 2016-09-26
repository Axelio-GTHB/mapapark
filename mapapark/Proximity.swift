//
//  proximity.swift
//  mapapark
//
//  Created by Christian Axel Waltier Barraza on 9/24/16.
//  Copyright © 2016 Christian Axel Waltier Barraza. All rights reserved.
//

import Foundation

enum Proximity : Int
{
    case m200 = 200 ,m100 = 100 ,m50 = 50 ,m10 = 10, outerLimit, none
}

extension Proximity: CustomStringConvertible
{
    var description: String
        {
        get
        {
            switch self
            {
            case .outerLimit:
                return "Estás muy lejos del punto objetivo"
            case .m200:
                return "Estás lejos del punto objetivo"
            case .m100:
                return "Estás próximo al punto objetivo"
            case .m50:
                return "Estás muy próximo al punto objetivo"
            case .m10:
                return "Estás en el punto objetivo"
            case .none:
                return ""
            }
        }
    }
}
