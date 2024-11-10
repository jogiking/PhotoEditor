//
//  ViewController.swift
//  PhotoEditorDemo
//
//  Created by giwan jo on 11/10/24.
//

import UIKit

import PhotoEditor

class ViewController: UIViewController {
    
    @IBAction func openPhotoEditorButtonTouched(_ sender: Any) {
        let vc = EditPhotoViewController()
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

