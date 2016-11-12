//
//  ViewController.swift
//  Posterpret
//
//  Created by Ruban Hussain on 11/11/16.
//  Copyright © 2016 Ruban Hussain. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var testimg: UIImageView!
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var addImg: UIButton!
    @IBOutlet weak var takePic: UIButton!
    @IBOutlet weak var apiButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        img.image = image
        counter += 1
        sendImageAPI(image)
    }
    
    @IBAction func addImg(sender: AnyObject) {
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        addImg.setTitle("", forState: .Normal)
    }
    
    @IBAction func takePic(sender: UIButton) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = false
        self.navigationController?.pushViewController(imagePicker, animated: true)
        takePic.setTitle("", forState: .Normal)
    }
    
    
    @IBAction func apiButton(sender: AnyObject) {
        let jsonRequest: [String: AnyObject] = [
            "requests": [
                "features": [
                "type":"TEXT_DETECTION"
            ],
            "image": [
            "source": [
            "gcsImageUri":"gs://posterpret-buck/poster.png"
        ]
        ]
        ]
        ]
        
        data_request("https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDcXIushxfZ3Bf2Dl-MDxVitmBw0hE8LBE", json: jsonRequest);
    }
    
    
    func sendImageAPI(image: UIImage) {
        let url = NSURL(string: "https://www.googleapis.com/upload/storage/v1/b/posterpret-buck/o?uploadType=media&name=myObject\(counter).jpeg")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        let image_data = UIImageJPEGRepresentation(image, 0.5)
        let body = NSMutableData()
        body.appendData(image_data!)
        
        request.HTTPBody = body
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil {
                print("Error -> \(error)")
                return
            }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                print("Result -> \(result)")
            } catch {
                print("Error -> \(error)")
            }
        }
        task.resume()
    }
    
    func data_request(url_to_request: String, json: AnyObject) {
        
//        let json = [
//            "requests": [
//                "features": [
//                "type":"TEXT_DETECTION"
//            ],
//            "image": [
//            "source": [
//            "gcsImageUri":"gs://posterpret-buck/poster.png"
//        ]
//        ]
//        ]
//        ]
        
        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(json)
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            // create post request
            let url = NSURL(string: url_to_request)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    
                    print("Result -> \(result)")
                    
//                    print("here1")
//                    let parsedJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Array<AnyObject>
//                    
//                    if let textAnnotations = parsedJSON?[0] as? [String: AnyObject] {
//                        print("here2")
//                        print("\(textAnnotations)")
//                        if let person = textAnnotations["description"] as? [String: AnyObject] {
//                            
//                        }
//                    }
                    
                    
                    self.natLang(result!);
//                    let myArray = JSONArray(result);
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            task.resume()
        } catch {
            print(error)
        }
    }
    
    
    func jsonToString(json: AnyObject) -> String {
        do {
            let data1 =  try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: NSUTF8StringEncoding) // the data will be converted to the string
            print(convertedString)
            return(convertedString!) // <-- here is ur string
            
        } catch let myJSONError {
            return "";
        }
    }
    
    
    func natLang(json: AnyObject) {
        let text = [
            "document": [
                "type": "PLAIN_TEXT",
                "language": "EN",
                "content": "Michelangelo Caravaggio, Italian painter, is known for 'The Calling of Saint Matthew'."
            ],
            "encodingType":"UTF8"
        ]
//        print("\(text)")
        nat_lang_request("https://language.googleapis.com/v1beta1/documents:analyzeEntities?key=AIzaSyDcXIushxfZ3Bf2Dl-MDxVitmBw0hE8LBE", json: text);
    }
    
    func nat_lang_request(url_to_request: String, json: AnyObject) {
        
//        let json = [
//            "document": [
//                "type": "PLAIN_TEXT",
//                "language": "EN",
//                "content": "Hello my name is Noah!!!"
//            ],
//            "encodingType":"UTF8"
//        ]
        print("\(json)")
        
        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(json)
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            // create post request
            let url = NSURL(string: url_to_request)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    
                    print("Result -> \(result)")
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            task.resume()
        } catch {
            print(error)
        }
    }
    
}

