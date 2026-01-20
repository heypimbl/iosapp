//
//  ImageStamper.swift
//  pimbl
//
//  Created by Claude on 01/19/26.
//

import UIKit

struct ImageStamper {

    /// Adds a date/time stamp to the bottom right of the image
    static func addTimestamp(to image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { context in
            image.draw(at: .zero)

            // Format: MM/DD/YYYY, HH:MM:SS TZ
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm:ss zzz"
            let dateString = dateFormatter.string(from: Date())

            let fontSize = max(image.size.width * 0.025, 14)
            let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]

            let textSize = dateString.size(withAttributes: textAttributes)
            let padding: CGFloat = fontSize * 0.6
            let margin = fontSize * 0.8

            let backgroundWidth = textSize.width + padding * 2
            let backgroundHeight = textSize.height + padding * 2
            let backgroundX = image.size.width - backgroundWidth - margin
            let backgroundY = image.size.height - backgroundHeight - margin

            let backgroundRect = CGRect(x: backgroundX, y: backgroundY, width: backgroundWidth, height: backgroundHeight)
            UIColor.black.withAlphaComponent(0.6).setFill()
            UIBezierPath(roundedRect: backgroundRect, cornerRadius: 4).fill()

            let textX = backgroundX + padding
            let textY = backgroundY + padding
            dateString.draw(at: CGPoint(x: textX, y: textY), withAttributes: textAttributes)
        }
    }
}
