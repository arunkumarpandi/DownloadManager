//
//  SharedClass.swift
//  Task
//
//  Created by Arunkumar on 24/01/22.
//

import Foundation
import UIKit
class SharedClass: NSObject {//This is shared class
static let sharedInstance = SharedClass()

    //Show alert
    func alert(view: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
        })
        alert.addAction(defaultAction)
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true)
        })
    }

    private override init() {
    }
}
