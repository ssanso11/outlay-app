//
//  Extensions.swift
//  Outlay
//
//  Created by Sebastian Sanso on 1/21/18.
//  Copyright © 2018 Sebastian Sanso. All rights reserved.
//

import UIKit
import Kingfisher


extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.kf.setImage(with: url)
            }
        }).resume()
    }
    
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Arial-BoldMT", size: 15)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}

extension Int {
    var degreesToRadians: Double {
        return Double(self) * .pi/180
    }
}
