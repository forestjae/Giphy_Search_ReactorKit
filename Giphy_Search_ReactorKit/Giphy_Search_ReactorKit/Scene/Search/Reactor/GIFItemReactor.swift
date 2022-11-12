//
//  GIFItemReactor.swift
//  Giphy_Search_ReactorKit
//
//  Created by Lee Seung-Jae on 2022/11/07.
//

import Foundation

struct GIFItemReactor: Hashable {
    var image: GIF
    var aspectRatio: Double
}

extension GIFItemReactor {
    init(image: GIF) {
        self.image = image
        self.aspectRatio = image.gifBundle.originalHeight / image.gifBundle.originalWidth
    }
}
