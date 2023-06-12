//
//  ShareManager.swift
//  Boswell
//
//  Created by MyMac on 17/04/23.
//

import UIKit

class ShareManager: NSObject, UIActivityItemSource {
    private var conversationHistory: [AIPromptModel] = []
    
    init(conversationHistory: [AIPromptModel]) {
        self.conversationHistory = conversationHistory
    }
    
    func share(vc: UIViewController) {
        let attributedString = NSMutableAttributedString(string: "")
        for history in conversationHistory {
            if history.isDisplay == true && history.role != nil {
                attributedString.append(self.getFormattedString(prompt: history))
            }
        }
        let print = UISimpleTextPrintFormatter(attributedText: attributedString)
        let activityViewController = UIActivityViewController(activityItems: [self, print], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = vc.view // so that iPads won't crash
        // present the view controller
        vc.present(activityViewController, animated: true, completion: nil)
    }
    
    func getFormattedString(prompt: AIPromptModel) -> NSAttributedString {
        if let image = prompt.image {
            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            let oldWidth = textAttachment.image!.size.width
            //I'm subtracting 10px to make the image display nicely, accounting
            //for the padding inside the textView
            let scaleFactor = oldWidth / (UIScreen.main.bounds.size.width - 40);
            textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
            let attrStringWithImage = NSMutableAttributedString(attachment: textAttachment)
            attrStringWithImage.append(NSAttributedString(string: "\n\n"))
            return attrStringWithImage
        }
        else {
            if prompt.role == .user { // User Prompt
                let attributedString = NSMutableAttributedString(attributedString: Utility.getFormattedUser(input: (prompt.content ?? "")))
                attributedString.append(NSAttributedString(string: "\n"))
                return attributedString
            }
            else if prompt.role == .assistant || prompt.role == .system { // AI Response
                var content = prompt.content ?? ""
                if let range = content.range(of: "-*---photo-question:") {
                    let upperBound = content.index(range.upperBound, offsetBy: 8)
                    let modifiedRange = range.lowerBound..<upperBound
                    content.removeSubrange(modifiedRange)
                    content = content.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let attributedString = NSMutableAttributedString(attributedString: Utility.getFormattedAI(response: content))
                attributedString.append(NSAttributedString(string: "\n\n"))
                return attributedString
            }
            else { // Display messsage
                let attributedString = NSMutableAttributedString(attributedString: Utility.getFormattedDisplay(message: (prompt.content ?? "")))
                attributedString.append(NSAttributedString(string: "\n\n"))
                return attributedString
            }
        }
    }
    
    func getInterviewFilename() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd hh-mma"
        let strDate = formatter3.string(from: Date())
        var username: String = "User"
        if let name = UserDefaultsManager.getFirstname(), name != "" {
            username = name
        }
        let filename = "\(username) \(strDate.lowercased()) - Boswell Interview Text.pdf"
        return filename
    }
    
    func getSharePdfUrl() -> URL {
        let attributedString = NSMutableAttributedString(string: "")
        for history in conversationHistory {
            if history.isDisplay == true && history.role != nil {
                attributedString.append(self.getFormattedString(prompt: history))
            }
        }
        
        let printFormatter = UISimpleTextPrintFormatter(attributedText: attributedString)
        
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)

        // Use this to get US Letter size instead
        // let pageSize = CGSize(width: 612, height: 792)

        // create some sensible margins
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)

        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)

        // and here's the overall paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        
        let pdfData = NSMutableData()

        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        
        let bounds = UIGraphicsGetPDFContextBounds()

        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()

            renderer.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self.getInterviewFilename())
        do {
            try pdfData.write(to: tempURL)
        } catch {
            print(error.localizedDescription)
        }
        return tempURL
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Conversation History"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        switch activityType?.rawValue {
        case UIActivity.ActivityType.mail.rawValue:
            let attributedString = NSMutableAttributedString(string: "")
            for history in conversationHistory {
                if history.isDisplay == true && history.role != nil {
                    attributedString.append(self.getFormattedString(prompt: history))
                }
            }
            return attributedString.toHtml()
        case UIActivity.ActivityType.print.rawValue, UIActivity.ActivityType.markupAsPDF.rawValue:
            let attributedString = NSMutableAttributedString(string: "")
            for history in conversationHistory {
                if history.isDisplay == true && history.role != nil {
                    attributedString.append(self.getFormattedString(prompt: history))
                }
            }
            let print = UISimpleTextPrintFormatter(attributedText: attributedString)
            return print
        default:
            return self.getSharePdfUrl()
        }
    }
}
