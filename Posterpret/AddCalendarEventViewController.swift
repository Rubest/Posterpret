//
//  AddCalendarEventViewController.swift
//  Posterpret
//
//  Created by Ruban Hussain on 11/12/16.
//  Copyright © 2016 Ruban Hussain. All rights reserved.
//

import UIKit
import EventKit

class AddCalendarEventViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var addToCalButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    // TextField fillers from previous page
    var eventTitle:String = "hi"
    var location:String = "hi"
    var startTime: String = "hi"
    var endTime:String = "hi"
    var startDate:String = "hi"
    var endDate:String = "ho"
    
    // Current active textField
    var firstResponderATM: UITextField!
    
    // textFields
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var locationTitleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startDateTextField.delegate = self
        self.endDateTextField.delegate = self
        self.startTimeTextField.delegate = self
        self.endTimeTextField.delegate = self
        self.eventTitleTextField.delegate = self
        self.locationTitleTextField.delegate = self
        
        self.startDateTextField.text = startDate
        self.endDateTextField.text = endDate
        self.startTimeTextField.text = startTime
        self.endTimeTextField.text = endTime
        self.eventTitleTextField.text = eventTitle
        self.locationTitleTextField.text = location
        
        self.errorMessage.text = ""
        
        addToCalButton.layer.borderWidth = 2
        addToCalButton.layer.cornerRadius = 7
        addToCalButton.layer.borderColor = UIColor(red:0.91, green:0.53, blue:0.25, alpha:1.0).CGColor
        
        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat =  "HH:mm"
//        let date = dateFormatter.dateFromString("3:00")
//        startTimePicker.date = date!
        
        
        // Create and set attributes of the toolbar that will be above a datePickerView or timePickerView
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        toolBar.tintColor = UIColor(red:0.95, green:0.93, blue:0.93, alpha:1.0)
        toolBar.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.40, alpha:1.0) //UIColor.blackColor()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        //let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedToolBarBtn))
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(self.donePressed))
        toolBar.setItems([/*todayBtn,*/flexSpace,okBarBtn], animated: true)
        
        // Assign toolbar to specific textFields
        startDateTextField.inputAccessoryView = toolBar
        endDateTextField.inputAccessoryView = toolBar
        startTimeTextField.inputAccessoryView = toolBar
        endTimeTextField.inputAccessoryView = toolBar
        eventTitleTextField.inputAccessoryView = toolBar
        locationTitleTextField.inputAccessoryView = toolBar
        
    }
    
    //https://www.andrewcbancroft.com/2016/06/02/creating-calendar-events-with-event-kit-and-swift/ 
    
    
    
    @IBAction func addtoCalendarClicked(sender: AnyObject) {
        
        if (self.eventTitleTextField.text! == "" ||
            self.startDateTextField.text! == "" ||
            self.startTimeTextField.text! == "" ||
            self.endDateTextField.text! == "" ||
            self.endTimeTextField.text! == ""
            //|| self.locationTitleTextField.text! == ""
            ) {
            // Display error message
            self.errorMessage.text = "Fill in the name and times first!"
            return;
        }
        
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType( EKEntityType.Event, completion:{(granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event = EKEvent(eventStore: eventStore)
                
                
                let dateFormatter = NSDateFormatter()
                //dateFormatter.dateFormat = "yyyy.MM.dd 'at' HH:mm:ss zzz"
                dateFormatter.dateFormat = "MM dd, yyyy hh:mma"
                /* date_format_you_want_in_string from
                 * http://userguide.icu-project.org/formatparse/datetime
                 */
                //let date = dateFormatter.dateFromString("2016.11.14 at 15:08:56 EST"/* your_date_string */)
                
                
                event.title = self.eventTitleTextField.text!
                let start = self.startDateTextField.text! + " " + self.startTimeTextField.text!
                event.startDate = dateFormatter.dateFromString(start)!
                let end = self.endDateTextField.text! + " " + self.endTimeTextField.text!
                event.endDate = dateFormatter.dateFromString(end)!
                event.location = self.locationTitleTextField.text!
                event.notes = "Event Details Here"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                var event_id = ""
                do{
                    try eventStore.saveEvent(event, span: .ThisEvent)
                    event_id = event.eventIdentifier
                    
                    self.performSegueWithIdentifier("posterpretSeque", sender: nil)
                }
                catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                    self.errorMessage.text = "\(error.localizedDescription)"
                }
                
                if(event_id != ""){
                    print("event added !")
                    
                }
            } else {
                self.errorMessage.text = "Pls enable calendar permissions from Settings"
            }
        })
    }
    
    // Function called when the done button above a datePickerView is called
    func donePressed(sender: UIBarButtonItem) {
        firstResponderATM.resignFirstResponder()
        firstResponderATM = nil
    }
    
    // Function thats called by a specific datePickerView when the date is changed.
    // It sets the active textField's text to the updated date
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        firstResponderATM.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func datePickerViewDisplayer(sender: UITextField) {
        // Resign any other textfields if they're active
        if (firstResponderATM != nil && firstResponderATM != sender) {
            firstResponderATM.resignFirstResponder()
        }
        
        // Sender is the first responder at the moment!
        firstResponderATM = sender
        
        // Create datePickerView (will look like a keyboard on bottom) and set input type
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        // Change color of text
        datePickerView.setValue(UIColor(red:0.95, green:0.93, blue:0.93, alpha:1.0), forKeyPath: "textColor")
        datePickerView.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.40, alpha:1.0)
        
        // Set initial date value of datePickerView
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "MM dd, yyyy"
        let txt = sender.text
        if (txt != "") { // Check if textField's text is empty or has a date
            let date = dateFormatter.dateFromString(txt!)
            datePickerView.date = date!
            
            // Set value of textField upon click if it was empty intially
        } else {
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
            sender.text = dateFormatter.stringFromDate(datePickerView.date)
        }
        
        // Set minimum and maximum time ranges from the user's current time (NOT hardcoded!) (up to one year prior to two years ahead)
        let currentDate: NSDate = NSDate()
        let calendar: NSCalendar = NSCalendar.currentCalendar() //let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.timeZone = NSTimeZone(name: "UTC")!
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar
        // Min date
        components.year = -1
        let minDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        datePickerView.minimumDate = minDate
        // Max date
        components.year = 2
        let maxDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        datePickerView.maximumDate = maxDate
        
        // Im not really sure what this does, thinking about it
        sender.inputView = datePickerView
        
        // Adds a listener that updates the textField everytime the datePickerView is changed
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // Function thats called by a specific datePickerView when the date is changed.
    // It sets the active textField's text to the updated date
    func timePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        firstResponderATM.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func timePickerViewDisplayer(sender: UITextField) {
        // Resign any other textfields if they're active
        if (firstResponderATM != nil && firstResponderATM != sender) {
            firstResponderATM.resignFirstResponder()
        }
        
        // Sender is the first responder at the moment!
        firstResponderATM = sender
        
        // Create datePickerView (will look like a keyboard on bottom) and set input type
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Time
        
        // Change color of text
        datePickerView.setValue(UIColor(red:0.95, green:0.93, blue:0.93, alpha:1.0), forKeyPath: "textColor")
        datePickerView.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.40, alpha:1.0)
        
        // Set initial date value of datePickerView
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "h:mma"
        let txt = sender.text
        if (txt != "") { // Check if textField's text is empty or has a date
            let date = dateFormatter.dateFromString(txt!)
            datePickerView.date = date!
            
            // Set value of textField upon click if it was empty intially
        } else {
            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            sender.text = dateFormatter.stringFromDate(datePickerView.date)
        }
        
        // Im not really sure what this does, thinking about it
        sender.inputView = datePickerView
        
        // Adds a listener that updates the textField everytime the datePickerView is changed
        datePickerView.addTarget(self, action: #selector(self.timePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }

    
    
    // Function thats called when a date textField begins being edited
    @IBAction func dateTextFieldEditing(sender: UITextField) {
        datePickerViewDisplayer(sender)
    }
    @IBAction func dateTextFieldEditing2(sender: UITextField) {
        datePickerViewDisplayer(sender)
    }

    @IBAction func timeTextFieldEditing(sender: UITextField) {
        timePickerViewDisplayer(sender)
    }

    @IBAction func timeTextFieldEditing2(sender: UITextField) {
        timePickerViewDisplayer(sender)
    }
    
    
    @IBAction func titleTextFieldEditing(sender: UITextField) {
        // Resign any other textfields if they're active
        if (firstResponderATM != nil && firstResponderATM != sender) {
            firstResponderATM.resignFirstResponder()
        }
        
        // Sender is the first responder at the moment!
        firstResponderATM = sender
    }
    
    @IBAction func locationTextFieldEditing(sender: UITextField) {
        // Resign any other textfields if they're active
        if (firstResponderATM != nil && firstResponderATM != sender) {
            firstResponderATM.resignFirstResponder()
        }
        
        // Sender is the first responder at the moment!
        firstResponderATM = sender
    }
    
    
}

