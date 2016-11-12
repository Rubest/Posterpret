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
    
    
    @IBOutlet weak var addToCalButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    
    
    
    
    
}

