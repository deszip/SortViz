//
//  DebugAlertController.swift
//  SortViz
//
//  Created by Deszip on 16/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit

class DebugAlertController {
    
    class func presentAlert(title: String, onController controller: UIViewController, completion: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: completion)
        alert.addAction(cancelAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
}
