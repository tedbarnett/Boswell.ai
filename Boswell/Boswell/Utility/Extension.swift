//
//  Extension.swift
//  Boswell
//
//  Created by MyMac on 17/04/23.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hex)
        // scanner.scanLocation = hex.hasPrefix("#") ? 1 : 0
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func hexStringFromColor() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
     }
}

extension NSAttributedString {
    func toHtml() -> String? {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try self.data(from: NSMakeRange(0, self.length), documentAttributes:documentAttributes)
            if let htmlString = String(data:htmlData, encoding:String.Encoding.utf8) {
                return htmlString
            }
        }
        catch {
            print("error creating HTML from Attributed String")
        }
        return nil
    }
    
    convenience init(data: Data, documentType: DocumentType, encoding: String.Encoding = .utf8) throws {
        try self.init(attributedString: .init(data: data, options: [.documentType: documentType, .characterEncoding: encoding.rawValue], documentAttributes: nil))
    }
    
    func data(_ documentType: DocumentType) -> Data {
        // Discussion
        // Raises an rangeException if any part of range lies beyond the end of the receiver’s characters.
        // Therefore passing a valid range allow us to force unwrap the result
        try! data(from: .init(location: 0, length: length),
                  documentAttributes: [.documentType: documentType])
    }
    
    var text: Data { data(.plain) }
    var html: Data { data(.html)  }
    var rtf:  Data { data(.rtf)   }
    var rtfd: Data { data(.rtfd)  }
    
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.width)
    }
}

extension UIApplication {
//    var keyWindow: UIWindow? {
//        // Get connected scenes
//        return UIApplication.shared.connectedScenes
//            // Keep only active scenes, onscreen and visible to the user
//            .filter { $0.activationState == .foregroundActive }
//            // Keep only the first `UIWindowScene`
//            .first(where: { $0 is UIWindowScene })
//            // Get its associated windows
//            .flatMap({ $0 as? UIWindowScene })?.windows
//            // Finally, keep only the key window
//            .first(where: \.isKeyWindow)
//    }
    
    var keyWindow: UIWindow? {
        connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    }
    
}

//MARK:- Image Orientation fix

extension UIImage {

    func fixOrientation() -> UIImage {

        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImage.Orientation.up ) {
            return self;
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity

        if ( self.imageOrientation == UIImage.Orientation.down || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }

        if ( self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        }

        if ( self.imageOrientation == UIImage.Orientation.right || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0));
        }

        if ( self.imageOrientation == UIImage.Orientation.upMirrored || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        if ( self.imageOrientation == UIImage.Orientation.leftMirrored || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                                      bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                                      space: self.cgImage!.colorSpace!,
                                                      bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;

        ctx.concatenate(transform)

        if ( self.imageOrientation == UIImage.Orientation.left ||
            self.imageOrientation == UIImage.Orientation.leftMirrored ||
            self.imageOrientation == UIImage.Orientation.right ||
            self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }

        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
}

extension String {
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ??  CGSize(width: 1720, height: NSAttributedString(string: self, attributes: attributes).height(withConstrainedWidth: 1720))
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1080, height: size.height + 200))
//        view.backgroundColor = UIColor.black
//        let label = UILabel(frame: CGRect(x: 140, y: 100, width: 800, height: size.height))
//        label.attributedText = NSAttributedString(string: self, attributes: attributes)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        view.addSubview(label)
        
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            let padding: CGFloat = 100
            let textRect = CGRect(x: padding, y: padding, width: size.width - (2 * padding), height: size.height - (2 * padding))
            (self as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
    
}

