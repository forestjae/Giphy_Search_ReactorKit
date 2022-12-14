//
//  Color.swift
//  Giphy_Search_RxSwift
//
//  Created by Lee Seung-Jae on 2022/10/25.
//

import UIKit

private enum Color {
    case mainBackground
    case mainFont
    case secondFont
    case mainTint

    var color: UIColor {
        guard let color = UIColor(named: String(describing: self)) else {
            return .white
        }

        return color
    }
}

extension UIColor {
    static let mainBackground = Color.mainBackground.color
    static let mainFont = Color.mainFont.color
    static let secondFont = Color.secondFont.color
    static let mainTint = Color.mainTint.color
}

