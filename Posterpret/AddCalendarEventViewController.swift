//
//  AddCalendarEventViewController.swift
//  Posterpret
//
//  Created by Ruban Hussain on 11/12/16.
//  Copyright © 2016 Ruban Hussain. All rights reserved.
//

import UIKit
import EventKit

class AddCalendarEventViewController: UIViewController {
    
    var firstResponderATM: UITextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var addToCalButton: UIButton!
    
    @IBOutlet weak var startDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.dateFromString("3:00")
        startTimePicker.date = date!
        
        
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.backgroundColor = UIColor.blackColor()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        //let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedToolBarBtn))
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(self.donePressed))
        
        toolBar.setItems([/*todayBtn,*/flexSpace,okBarBtn], animated: true)
        startDateTextField.inputAccessoryView = toolBar
        
    }
    
    //https://www.andrewcbancroft.com/2016/06/02/creating-calendar-events-with-event-kit-and-swift/ 
    
    
    
    @IBAction func addtoCalendarClicked(sender: AnyObject) {
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType( EKEntityType.Event, completion:{(granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event = EKEvent(eventStore: eventStore)
                
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.dd 'at' HH:mm:ss zzz"
                /* date_format_you_want_in_string from
                 * http://userguide.icu-project.org/formatparse/datetime
                 */
                let date = dateFormatter.dateFromString("2016.11.14 at 15:08:56 EST"/* your_date_string */)
                
                
                event.title = "Event Title"
                event.startDate = NSDate()
                event.endDate = date!
                event.notes = "Event Details Here"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                var event_id = ""
                do{
                    try eventStore.saveEvent(event, span: .ThisEvent)
                    event_id = event.eventIdentifier
                }
                catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
                
                if(event_id != ""){
                    print("event added !")    
                }
            }
        })
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        firstResponderATM.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    
    func donePressed(sender: UIBarButtonItem) {
        firstResponderATM.resignFirstResponder()
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateformatter.timeStyle = NSDateFormatterStyle.NoStyle
        startDateTextField.text = dateformatter.stringFromDate(NSDate())
        startDateTextField.resignFirstResponder()
    }
    
    @IBAction func dateTextFieldEditing(sender: UITextField) {
        
        // Sender is the first responder at the moment!
        firstResponderATM = sender
        
        // Create datePickerView (will look like a keyboard on bottom) and set input type
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        // Change color of text
        datePickerView.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        datePickerView.backgroundColor = UIColor.blueColor()
        
        // Set initial date value of datePickerView
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "MM dd, yyyy"
        let txt = sender.text
        if (txt != "") { // Check if textField's text is empty or has a date
            let date = dateFormatter.dateFromString(txt!)
            datePickerView.date = date!
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

        // Setup logistics
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    
    
    
}

