//
//  InterfaceController.swift
//  watch Extension
//
//  Created by Marcus on 4/4/16.
//  Copyright © 2016 Marcus. All rights reserved.
//

import WatchKit
import Foundation



class InterfaceController: WKInterfaceController {
    @IBOutlet var nextActivityTimeLabel: WKInterfaceLabel!
    @IBOutlet var nextActivityLabel: WKInterfaceLabel!
    @IBOutlet var currentActivityLabel: WKInterfaceLabel!
    @IBOutlet var currentActivityBar: WKInterfaceGroup!
    @IBOutlet var nextActivityBar: WKInterfaceGroup!
    @IBOutlet var currentActivityIcon: WKInterfaceImage!
    @IBOutlet var nextActivityIcon: WKInterfaceImage!
    @IBOutlet var nextActivityFiller: WKInterfaceGroup!
    @IBOutlet var currentActivityFiller: WKInterfaceGroup!

    let times1 = [
        ["time":[0,0], "end":[8,30], "name":"Home", "type":"home"],
        ["time":[8,30], "end":[12,0], "name":"Work", "type":"work"]
    ]
    let times2 = [
        ["time":[12,0], "end":[13,0], "name":"Lunch", "type":"food"],
        ["time":[13,0], "end":[16,30], "name":"Work", "type":"work"],
        ["time":[16,30], "end":[17,40], "name":"Gym", "type":"gym"],
        ["time":[17,30], "end":[24,0], "name":"Home", "type":"home"]
    ]
    let maxHeight: Float = 130.0
    let colors = [
        "work": UIColor(red: 82/255, green: 98/255, blue: 1, alpha: 1), //blue
        "home": UIColor(red: 18/255, green: 1, blue: 80/255, alpha: 1), //green
        "food": UIColor(red: 200/255, green: 34/255, blue: 205/255, alpha: 1), //purple
        "gym": UIColor(red: 200/255, green: 100/255, blue: 50/255, alpha: 1),
        "other": UIColor(red: 100/255, green: 50/255, blue: 200/255, alpha: 1)
    ]
    var timer = NSTimer()
    
    var barColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1) //almost white
    var nextColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1) //almost white
    
    var h: Int = 0
    var endH: Int = 0
    var nextH: Int = 0
    var nextEndH: Int = 0
    var nextScheduledH: Int = 0
    
    var m: Int = 0
    var endM: Int = 0
    var nextM: Int = 0
    var nextEndM: Int = 0
    var nextScheduledM: Int = 0
    var nextScheduledDuration: Int = 0
    
    var startTime: Int = 0
    var endTime: Int = 0
    var type: String = ""
    var nextType: String = ""
    var activity: String = ""
    var nextActivity: String = ""
    
    var duration: Int = 0
    
    let dayLength: Int = 24*60
    let minuteDeltaOnScreen: Float = 30 //Distance in minutes from middle of screen to edge
    let activityMaxLength: Float = 156 //Max Length of bar on screen
    
    var currentSection: Float!
    var currentSectionEnd: Float!
    var currentSectionProgress: Float!
    var currentSectionLength: Float!
    var nextSection: Float!
    var nextSectionEnd: Float!
    var currentTime: Float!
    var barHeight: Float!
    var heightIncrement: Float!
    var time: NSArray!
    var end: NSArray!
    var setup = false
    
    let animationTime: Double = 0.5
    let refreshRate: Double = 1
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("awakeWithContext")
        setUpBar()
    }
    func setUpBar() {
        print("setUpBar()")
        let times = times1 + times2
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
        let hour = components.hour
        let minute = components.minute
        let current = hour*60 + minute //Current time in minutes from midnight
        
        let ppm = activityMaxLength/(minuteDeltaOnScreen*2) //pixles per minute
        
        var i = 0
        
        while i < times.count {
            time  = (times[i]["time"] as! NSArray?)!
            end = (times[i]["end"] as! NSArray?)!
            h = time[0] as! Int
            endH = end[0] as! Int
            m = time[1] as! Int
            endM = end[1] as! Int
            startTime = h*60 + m
            endTime = endH*60 + endM
            print("startTime: " + String(startTime))
            print("current: " + String(current))
            print("endTime: " + String(endTime))
            
            if startTime <= current && current < endTime { //Find the currently ongoing activity
                let currentBlock = times[i]
                activity = (currentBlock["name"] as! String?)!
                type = currentBlock["type"]! as! String
                barColor = (colors[type])!
                var j = i+1
                print("activity: " + activity)
                while j < times.count { //Find the next unfinished activity
                    let nextBlock = times[j]
                    nextH = (nextBlock["time"]![0] as! Int?)!
                    nextEndH = (nextBlock["end"]![0] as! Int?)!
                    nextM = (nextBlock["time"]![1] as! Int?)!
                    nextEndM = (nextBlock["end"]![1] as! Int?)!
                    let nextEndTime = nextEndH*60 + nextEndM
                    nextActivity = (nextBlock["name"] as! String?)!
                    nextType = nextBlock["type"]! as! String
                    nextColor = colors[nextType]!
                    print("nextActivity: " + nextActivity)
                    if nextEndTime > current{
                        
                        print("Breaking: " + activity + " --> " + nextActivity)
                        break
                    }
                    j += 1
                }
                break
            }
            i += 1
        }

        print("Done with loops: " + activity + " --> " + nextActivity)
        
        if nextH == h && nextM == m{  //If current and next section are one and the same, just set the end time to the end of the day for now
            nextH = 24
            nextM = 0
        }
        
        nextSection = Float(nextH*60 + nextM) //Start Time of Next Section
        nextSectionEnd = Float(nextEndH*60 + nextEndM) //End Time of Next Section
        
        currentSection = Float(h*60 + m)      //Start Time of Current Section
        currentSectionEnd = Float(endH*60 + endM) //End Time of Current Section
        
        currentTime = Float(hour*60 + minute) //Current Time
        
        print("CurrentTime: " + String(currentTime))
        print("currentSectionEnd: " + String(currentSectionEnd))
        print("nextSection: " + String(nextSection))
        
        //Setup the icons
        currentActivityIcon.setImageNamed(type+"icon.png")
        nextActivityIcon.setImageNamed(nextType+"icon.png")
        
        //Calculate length of the bar for the current activity


        var leftSide = 0
        var rightSide = 0
        leftSide = min(Int(minuteDeltaOnScreen), Int(currentTime-currentSection))
        rightSide = min(Int(minuteDeltaOnScreen), Int(currentSectionEnd-currentTime))
        let currentBarWidth = (Float(leftSide + rightSide)*ppm)
        let currentBarFiller = Float(Int(minuteDeltaOnScreen) - leftSide)
        print("leftSide1: " + String(leftSide))
        print("rightSide1: " + String(rightSide))
            
        if currentBarWidth < 40 { //Hide the icon if the bar is too short
            currentActivityIcon.setAlpha(0)
        }
        else {
            currentActivityIcon.setAlpha(1)
        }
        animateWithDuration(2){
            self.currentActivityBar.setWidth(CGFloat(currentBarWidth))
            self.currentActivityFiller.setWidth(CGFloat(currentBarFiller*ppm))
        }
        
        currentActivityLabel.setText(activity)
        
        var hoursLeft = nextH - hour
        var minutesLeft = nextM - minute
        if minutesLeft < 0 {
            hoursLeft = hoursLeft - 1
            minutesLeft = 60 + minutesLeft
        }
        nextActivityLabel.setText(nextActivity)
        nextActivityTimeLabel.setText(String(hoursLeft) + " h " + String(minutesLeft) + " m")
        
        
        //Calculate the length of the bar for the next activity
        if currentTime + minuteDeltaOnScreen < nextSection {
            animateWithDuration(1){
                self.nextActivityBar.setWidth(0)
            }
            nextActivityIcon.setAlpha(0)
        }
        else if currentTime + minuteDeltaOnScreen > nextSection {
            var leftSide: Float = 0
            var rightSide: Float = 0
            var fillerWidth: Float = 0
            if nextSectionEnd < currentTime+minuteDeltaOnScreen {
                leftSide = min(minuteDeltaOnScreen, max(0,currentTime-nextSection))
                rightSide = min(minuteDeltaOnScreen, max(0,nextSectionEnd-currentTime))
            
                print("leftSide: " + String(leftSide))
                print("rightSide: " + String(rightSide))
                fillerWidth = (minuteDeltaOnScreen - Float(rightSide))*ppm
            }
            else {
                leftSide = (minuteDeltaOnScreen - (nextSection - currentTime))
                print("leftSide2: " + String(leftSide))
            }
            
            let nextBarWidth = ((leftSide + rightSide)*ppm)
            print("nextBarWidth: " + String(nextBarWidth))
            print("fillerWidth: " + String(fillerWidth))
            
            
            if nextBarWidth < 40 {
                nextActivityIcon.setAlpha(0)
            }
            else {
                nextActivityIcon.setAlpha(1)
            }
            animateWithDuration(2){
                self.nextActivityBar.setWidth(CGFloat(nextBarWidth))
                self.nextActivityFiller.setWidth(CGFloat(fillerWidth))
            }
        }
        currentActivityBar.setBackgroundColor(barColor)
        nextActivityBar.setBackgroundColor(nextColor)
        

        return

        }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("willActivate")
        setUpBar()
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(InterfaceController.setUpBar), userInfo: nil, repeats: true)
        super.willActivate()
    }

    override func didDeactivate() {
        print("didDeactivate()")
        // This method is called when watch view controller is no longer visible
        setup = false
        timer.invalidate()
        super.didDeactivate()
    }

}
