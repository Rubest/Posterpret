//
//  ViewController.swift
//  Posterpret
//
//  Created by Ruban Hussain on 11/11/16.
//  Copyright © 2016 Ruban Hussain. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var startTime: String = "";
    var endTime:String = "";
    var eventTitle:String = "";
    var date:String = "";
    
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
            "gcsImageUri":"gs://posterpret-buck/myObject\(counter).jpeg"
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
                
                var final:String;
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    let snd = result!.first!.1 as! [AnyObject]
                    let tird = (snd[0] as! [String: AnyObject]).first
                    if (tird == nil) {
                        final = ""
                    } else {
                        let third = (((snd[0] as! [String: AnyObject]).first!.1 as! [AnyObject])[0]) as! [String:AnyObject]
                        final = (third["description"]! as! String)
                        self.eventTitle = final.componentsSeparatedByString("\n")[0]
                        final = final.stringByReplacingOccurrencesOfString("\n", withString: " ")
                    }
                    self.date = self.findADate(final)
                    self.autofillCalendar(final)
                    self.natLang(final);
                    
                    
                    
                } catch {
                    final = ""
                }
                
//                do {
////                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
////                    
////                    print("Result -> \(result)")
//                    
//                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
//                    let snd = result!.first!.1 as! [AnyObject]
//                    let third = (((snd[0] as! [String: AnyObject]).first!.1 as! [AnyObject])[0]) as! [String:AnyObject]
//                    let final = (third["description"]! as! String).stringByReplacingOccurrencesOfString("\n", withString: " ")
//                    print(final)
//                    
//                    self.natLang(final);
//                    
//                } catch {
//                    print("Error -> \(error)")
//                }
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
                "content": "\(json)"
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
    
    
   
    
    
    func findADate(txt: String) -> String {
        
        let arrayOfMonthOptions: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
        
        
        var foundMonth : String? = nil
        var dateNum : String = ""
        
        // iterate over every possible month (for now, disregarding number months)
        for month in arrayOfMonthOptions {
            let search = (txt.rangeOfString(month))
            if ((search) != nil){
                //let stIndex: String.CharacterView.Index = search!.startIndex
                let enIndex: String.CharacterView.Index = search!.endIndex
                
                let wordsAfterMonth = txt.substringWithRange(enIndex ..< txt.endIndex)
                
                var frstNum = -1
                var scndNum = -1
                var counter = 0
                
                // Check next three characters for numbers
                for c in wordsAfterMonth.characters {
                    counter += 1
                    // try converting character to int
                    let num:Int? = Int(String(c))
                    if (frstNum == -1 && num != nil) {
                        frstNum = num!
                    } else if (frstNum != -1 && scndNum == -1 && num != nil) {
                        scndNum = num!
                        break
                    }
                    // Stop looking after 3 characters
                    if (counter >= 3) {
                        break
                    }
                }
                
                // one digit number
                if (frstNum != -1 && scndNum == -1) {
                    foundMonth = month
                    dateNum = String(frstNum)
                    break
                }
                    // two digit number
                else if (frstNum != -1 && scndNum != -1) {
                    foundMonth = month
                    dateNum = String(10*frstNum + scndNum)
                    break
                }
            }
        }
        
        // get current year
        let date = NSDate()
        let components = NSCalendar.currentCalendar().components([.Year], fromDate: date)
        let year = String(components.year)
        
        // Return proper date if found
        if (foundMonth != nil){
            return foundMonth! + " " + dateNum + ", " + year
        }
        
        // Otherwise return empty string
        return ""
        
    }

    
    
    
    
    
    
    func autofillCalendar(input: String) {
        var upper = input.uppercaseString
        var state = 0
        
        while (state < 2) {
            let pmRange = upper.rangeOfString("PM")
            let amRange = upper.rangeOfString("AM")
            var toCheck = ""
            if ((pmRange == nil) && (amRange == nil)) { return }
            else if (pmRange == nil) {
                //let bef = upper.substringToIndex(amRange!.startIndex)
                var index = amRange!.startIndex.predecessor();
                var curChar = upper[index]
                let startIdx = upper.startIndex;
                while (index >= startIdx && ((curChar == " ") || (curChar == ":") || (Int(String(curChar)) != nil))) {
                    index = index.predecessor()
                    curChar = upper[index]
                }
                index = index.successor()
                toCheck = upper.substringWithRange(Range(start: index, end: amRange!.endIndex)).stringByReplacingOccurrencesOfString(" ", withString: "")
                upper.replaceRange(Range(start: index, end: amRange!.endIndex), with: " ")
                //foundStart = true
                
            } else if (amRange == nil) {
                var index = pmRange!.startIndex.predecessor();
                var curChar = upper[index]
                let startIdx = upper.startIndex;
                while (index >= startIdx && ((curChar == " ") || (curChar == ":") || (Int(String(curChar)) != nil))) {
                    index = index.predecessor()
                    curChar = upper[index]
                }
                index = index.successor()
                toCheck = upper.substringWithRange(Range(start: index, end: pmRange!.endIndex)).stringByReplacingOccurrencesOfString(" ", withString: "")
                upper.replaceRange(Range(start: index, end: amRange!.endIndex), with: " ")
            } else {
                if (pmRange!.startIndex < amRange!.startIndex) {
                    var index = pmRange!.startIndex.predecessor();
                    var curChar = upper[index]
                    let startIdx = upper.startIndex;
                    while (index >= startIdx && ((curChar == " ") || (curChar == ":") || (Int(String(curChar)) != nil))) {
                        index = index.predecessor()
                        curChar = upper[index]
                    }
                    index = index.successor()
                    toCheck = upper.substringWithRange(Range(start: index, end: pmRange!.endIndex)).stringByReplacingOccurrencesOfString(" ", withString: "")
                    upper.replaceRange(Range(start: index, end: amRange!.endIndex), with: " ")
                } else {
                    var index = amRange!.startIndex.predecessor();
                    var curChar = upper[index]
                    let startIdx = upper.startIndex;
                    while (index >= startIdx && ((curChar == " ") || (curChar == ":") || (Int(String(curChar)) != nil))) {
                        index = index.predecessor()
                        curChar = upper[index]
                    }
                    index = index.successor()
                    toCheck = upper.substringWithRange(Range(start: index, end: amRange!.endIndex)).stringByReplacingOccurrencesOfString(" ", withString: "")
                    upper.replaceRange(Range(start: index, end: amRange!.endIndex), with: " ")            }
            }
            if (check(toCheck)) {
                if (state == 0) {
                    startTime = toCheck;
                } else {
                    endTime = toCheck;
                }
                state += 1
            }
            //print(upper)
        }
        if (startTime != "") {
            startTime = cleanTime(startTime);
        }
        if (endTime != "") {
            endTime = cleanTime(endTime);
        }
    }
    
    func check(s : String) -> Bool  {
        let fst = s[s.startIndex]
        return (Int(String(fst)) != nil)
    }
    
    func cleanTime(time : String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateFormat =  "hh:mma"
        var date = dateFormatter.dateFromString(time)
        if (date == nil) {
            dateFormatter.dateFormat =  "hha"
            date = dateFormatter.dateFromString(time)
        }
        dateFormatter.dateFormat =  "hh:mma"
        return dateFormatter.stringFromDate(date!)
    }
    
    
}

