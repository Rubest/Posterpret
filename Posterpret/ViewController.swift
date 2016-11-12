//
//  ViewController.swift
//  Posterpret
//
//  Created by Ruban Hussain on 11/11/16.
//  Copyright © 2016 Ruban Hussain. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var addImg: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        img.image = image
    }

    @IBAction func addImg(sender: AnyObject) {
        presentViewController(imagePicker, animated: true, completion: nil)
        addImg.setTitle("", forState: .Normal)
    }

}

