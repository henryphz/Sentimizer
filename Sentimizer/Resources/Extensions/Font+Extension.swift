//
//  Font+Extension.swift
//  Sentimizer
//
//  Created by Samuel Ginsberg, 2022.
//

import SwiftUI

extension Font {
    /// The custom Sentimizer font.
    ///  - parameter size: Preferred font size.
    ///  - returns: The custom font.
    static func sentiBold(size: CGFloat) -> Font {
        return .custom("Poppins-Bold", size: size)
    }
    
    static func sentiLight(size: CGFloat) -> Font {
        return .custom("Poppins-Regular", size:size)
    }
    
    static func sentiSemiBold(size: CGFloat) -> Font {
        return .custom("Poppins-SemiBold", size:size)
    }
    
    static func sentiMedium(size: CGFloat) -> Font {
        return .custom("Poppins-Medium", size:size)
    }
    // Old: Helvetica Neue Bold, Helvetica Neue, Helvetica Neue Medium
}

