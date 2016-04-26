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
    @IBOutlet var miniIndicator: WKInterfaceGroup!
    @IBOutlet var mainHolder: WKInterfaceGroup!
    @IBOutlet var topLabel: WKInterfaceLabel!
    @IBOutlet var btmLabel: WKInterfaceLabel!
    @IBOutlet var bar: WKInterfaceGroup!
    @IBOutlet var topImg: WKInterfaceGroup!
    @IBOutlet var btmImg: WKInterfaceGroup!
    let times = [
        ["time":[0,0], "name":"Home", "type":"home"],
        ["time":[8,30], "name":"Work", "type":"work"],
        ["time":[12,0], "name":"Lunch", "type":"eat"],
        ["time":[13,0], "name":"Work", "type":"work"],
        ["time":[16,0], "name":"Gym", "type":"other"],
        ["time":[17,30], "name":"Home", "type":"home"]
    ]
    let scheduledTimes = [
        ["time": [11,0], "duration": 30, "name":"Meeting", "type":"work"],
        ["time": [15,6], "duration": 15, "name":"Fika", "type":"other"]
    ]
    let maxHeight: Float = 130.0
    let colors = [
        "work": UIColor(red: 82/255, green: 98/255, blue: 1, alpha: 1), //blue
        "home": UIColor(red: 18/255, green: 1, blue: 80/255, alpha: 1), //green
        "eat": UIColor(red: 200/255, green: 34/255, blue: 205/255, alpha: 1), //purple
        "other": UIColor(red: 200/255, green: 100/255, blue: 50/255, alpha: 1)
    ]
    var timer = NSTimer()
    var barColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1) //almost white
    var nextColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1) //almost white
    
    var h: Int = 0
    var nextH: Int = 0
    var nextScheduledH: Int = 0
    var m: Int = 0
    var nextM: Int = 0
    var nextScheduledM: Int = 0
    var nextScheduledDuration: Int = 0
    var startTime: Int = 0
    var nextType: String = ""
    var activity: String = ""
    var nextActivity: String = ""
    
    var duration: Int = 0
    
    var currentSection: Float!
    var currentSectionProgress: Float!
    var currentSectionLength: Float!
    var nextSection: Float!
    var currentTime: Float!
    var barHeight: Float!
    var heightIncrement: Float!
    var time: NSArray!
    var setup = false
    
    let animationTime: Double = 0.5
    let refreshRate: Double = 1
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("awakeWithContext")
        // Configure interface objects here.
        if setup == false {
            setUpBar()
        }
    }
    func setUpBar() {
        print("setupbar")
        setup = true
        var scheduledActivity = false
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
        let hour = components.hour
        let minute = components.minute
        let current = hour*60 + minute

        var i = 0

        while i < times.count {
            time  = (times[i]["time"] as! NSArray?)!
            nextH = time[0] as! Int
            nextM = time[1] as! Int
            startTime = nextH*60 + nextM
            nextType = (times[i]["type"] as! String?)!
            if startTime >= current {
                let currentBlock = times[max(0,i-1)]
                h = (currentBlock["time"]![0] as! Int?)!
                m = (currentBlock["time"]![1] as! Int?)!
                activity = (currentBlock["name"] as! String?)!
                barColor = (colors[currentBlock["type"]! as! String])!
                nextColor = colors[nextType]!
                nextActivity = times[min(i, times.count-1)]["name"]! as! String
                print("Breaking: " + activity + " --> " + nextActivity)
                break
            }
            
            i += 1
        }
        i = 0
        while i < scheduledTimes.count{
            print("Check Schedule")
            time  = (scheduledTimes[i]["time"] as! NSArray?)!
            nextScheduledDuration = (scheduledTimes[i]["duration"] as! Int?)!
            nextScheduledH = time[0] as! Int
            nextScheduledM = time[1] as! Int
            startTime = nextScheduledH*60 + nextScheduledM
            if current >= startTime && current < (startTime + nextScheduledDuration){
                print("gick in")
                h = nextScheduledH
                m = nextScheduledM
                duration = nextScheduledDuration
                activity = (scheduledTimes[i]["name"] as! String?)!
                barColor = (colors[scheduledTimes[i]["type"]! as! String])!
                scheduledActivity = true
            }
            else if startTime > current && startTime < nextH*60+nextM {
                print("Gick in 2")
                nextH = nextScheduledH
                nextM = nextScheduledM
                nextType = (times[i]["type"] as! String?)!
                nextColor = colors[nextType]!
                nextActivity = scheduledTimes[i]["name"]! as! String
                break
            }
            i+=1
        }
        
        print("Done with loops: " + activity + " --> " + nextActivity)
    
        if nextH == h && nextM == m{  //If current and next section are one and the same, just set the end time to the end of the day for now
            nextH = 24
            nextM = 0
        }
        print("h: " + String(h))
        print("m: " + String(m))
        print("nextH: " + String(nextH))
        print("nextM: " + String(nextM))
        print("hour: " + String(hour))
        print("minute: " + String(minute))
        
        nextSection = Float(nextH*60 + nextM) //Start Time of Next Section
        currentSection = Float(h*60 + m)      //Start Time of Current Section
        currentTime = Float(hour*60 + minute) //Current Time
        
        print("nextSection: " + String(nextSection))
        print("currentSection: " + String(currentSection))
        print("currentTime: " + String(currentTime))
        
        if scheduledActivity == true { //Calculate length of current section
            currentSectionLength = Float(duration)
        }
        else {
            currentSectionLength = nextSection - currentSection
        }
        
        print("currentSectionLength: " + String(currentSectionLength))
        currentSectionProgress = currentTime - currentSection //Calculate how far into the current section we are
        
        //Calculate height increase per minute and what height the bar should be now
        heightIncrement = maxHeight/currentSectionLength
        barHeight = maxHeight * (currentSectionProgress/currentSectionLength)
        
        animateWithDuration(self.animationTime, animations: {
            self.bar.setHeight(CGFloat(self.barHeight))
            self.bar.setBackgroundColor(self.barColor)
        })
        
        miniIndicator.setBackgroundColor(nextColor)
        btmLabel.setText(activity)
        topLabel.setText(nextActivity)

    }
    func checkBars(){
        print("checkBars")
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
        let hour = components.hour
        let minute = components.minute
        
        if (Float((hour*60)+minute) >= currentSection+currentSectionLength){
            print("nextSection")
            WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
            setUpBar()
        }
        else {
            print("currentSection, increase bar")
            barHeight = barHeight + (heightIncrement * Float(refreshRate/60))
            animateWithDuration(self.animationTime, animations: {
                self.bar.setHeight(CGFloat(self.barHeight))
            })
            
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("willActivate setup: " + String(setup))
        if setup == false {
            setUpBar()
        }
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(self.refreshRate, target: self, selector: #selector(InterfaceController.checkBars), userInfo: nil, repeats: true)
    }

    override func didDeactivate() {
        print("didDeactivate()")
        // This method is called when watch view controller is no longer visible
        setup = false
        super.didDeactivate()
        timer.invalidate()
    }

}
