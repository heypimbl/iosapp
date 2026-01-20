//
//  ImageStamper.swift
//  pimbl
//
//  Created by Claude on 01/19/26.
//

import UIKit
import CoreLocation

struct ImageStamper {

    /// Adds a date/time stamp to the bottom right of the image
    /// If location is nil, shows "Location data will go here" as placeholder
    static func addTimestamp(to image: UIImage, location: CLLocationCoordinate2D? = nil) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { context in
            image.draw(at: .zero)

            // Format: MM/DD/YYYY, HH:MM:SS TZ
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm:ss zzz"
            let dateString = dateFormatter.string(from: Date())

            // Location line
            let locationString: String
            if let location = location {
                let latDirection = location.latitude >= 0 ? "N" : "S"
                let lonDirection = location.longitude >= 0 ? "E" : "W"
                locationString = String(format: "%.6f°%@, %.6f°%@", abs(location.latitude), latDirection, abs(location.longitude), lonDirection)
            } else {
                locationString = "Location data will go here"
            }

            let fontSize = max(image.size.width * 0.025, 14)
            let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]

            let dateSize = dateString.size(withAttributes: textAttributes)
            let locationSize = locationString.size(withAttributes: textAttributes)
            let padding: CGFloat = fontSize * 0.6
            let lineSpacing: CGFloat = fontSize * 0.3
            let margin = fontSize * 0.8

            let textWidth = max(dateSize.width, locationSize.width)
            let textHeight = dateSize.height + lineSpacing + locationSize.height

            let backgroundWidth = textWidth + padding * 2
            let backgroundHeight = textHeight + padding * 2
            let backgroundX = image.size.width - backgroundWidth - margin
            let backgroundY = image.size.height - backgroundHeight - margin

            let backgroundRect = CGRect(x: backgroundX, y: backgroundY, width: backgroundWidth, height: backgroundHeight)
            UIColor.black.withAlphaComponent(0.6).setFill()
            UIBezierPath(roundedRect: backgroundRect, cornerRadius: 4).fill()

            let textX = backgroundX + padding
            let dateY = backgroundY + padding
            dateString.draw(at: CGPoint(x: textX, y: dateY), withAttributes: textAttributes)

            let locationY = dateY + dateSize.height + lineSpacing
            locationString.draw(at: CGPoint(x: textX, y: locationY), withAttributes: textAttributes)
        }
    }
}
