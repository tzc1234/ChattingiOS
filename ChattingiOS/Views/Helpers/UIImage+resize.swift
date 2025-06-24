//
//  UIImage+resize.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/06/2025.
//

import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
