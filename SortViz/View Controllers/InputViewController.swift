//
//  InputViewController.swift
//  SortViz
//
//  Created by Deszip on 16/05/2017.
//  Copyright © 2017 Deszip. All rights reserved.
//

import UIKit

class InputViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    var dataLoadingHandler: (([Int64]) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions -
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        let data = InputParser.values(fromString: textField.text)
        if data.count == 0 {
            DebugAlertController.presentAlert(title: "Nothing to sort", onController: self)
        } else {
            dataLoadingHandler?(data)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
