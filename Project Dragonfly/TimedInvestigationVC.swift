//
//  TimedInvestigationVC.swift
//  Project Dragonfly
//
//  Created by Willard, Marian on 12/8/16.
//  Copyright © 2016 cse.miamioh. All rights reserved.
//

import UIKit

class TimedInvestigationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, InvestigationDelegate {
    var timerLength: Double = 0.0
    
    let alert = UIAlertController(title: "New Component", message: "Enter a name for this component:", preferredStyle: .alert)
    
    var investigation: Investigation!
    
    var pickerDataSource = Array(repeating: Array(repeating: "", count: 60), count: 3)

    
    // for timer
    var startTime = TimeInterval()
    var timer = Timer()

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var timerPickerView: UIPickerView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBAction func timerButton(_ sender: UIButton) {
        if !timer.isValid {
            let hours = timerPickerView.selectedRow(inComponent: 0)
            let mins = timerPickerView.selectedRow(inComponent: 1)
            let secs = timerPickerView.selectedRow(inComponent: 2)
            
            let time = secs + (mins * 60) + (hours * 60)
            timerLength = Double(time)
            
            let aSelector : Selector = #selector(TimedInvestigationVC.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.99, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
            
            timeButton.setTitle("Stop", for: .normal)
        } else {
            timer.invalidate()
            
            timeButton.setTitle("Start", for: .normal)
            updated(date: Date())
        }
    }
    
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        
        let elapsedTime: TimeInterval = currentTime - startTime
        
        
        if ( elapsedTime > (timerLength)) {
            timer.invalidate()
            //formatTime(eTime: TimeInterval(timerLength))
            timeButton.setTitle("Start", for: .normal)
            updated(date: Date())
            // disable counters?
        } else {
            formatTime(eTime: elapsedTime)
        }
        
    }
    // format time
    func formatTime(eTime: TimeInterval) {
        var elapsedTime = UInt8(floor(timerLength - eTime)) // in seconds with fractions
        //elapsedTime = floor(elapsedTime)
        print("elapsedTime 1: \(elapsedTime)")
        let seconds = UInt8(elapsedTime) % 60
        elapsedTime -= seconds
        print("elapsedTime 2: \(elapsedTime)")
        var min = UInt8(elapsedTime) % 60
        if(min == 0 && elapsedTime >= 60) {
            min = 1
        }
        elapsedTime -= min * 60
        print("elapsedTime 3: \(elapsedTime)")
        let hours = UInt8(elapsedTime / 60)
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        print("seconds : \(seconds)")
        print("mins : \(min)")
        print("hours : \(hours)")
       // let strMinutes = String(format: "%02d", min)
       // let strSeconds = String(format: "%02d", seconds)
        //let strHours = String(format: "%02d", hours)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        // Make picker display count down
        //stopwatchTimeText.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        timerPickerView.selectRow(Int(hours), inComponent: 0, animated: true)
        timerPickerView.selectRow(Int(min), inComponent: 1, animated: true)
        timerPickerView.selectRow(Int(seconds), inComponent: 2, animated: true)
        
    }
    
    func setupTimerDataSource() {
        for i in 0..<3 {
            for j in 0..<60 {
                pickerDataSource[i][j] = "\(j)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNewComponentAlert()
        setupTimerDataSource()

        dateLabel.text = "Last Edited: \(investigation!.lastUpdated)"
        
        // Sets the category to the curent category name
        categoryLabel.text = investigation?.category
        questionLabel.text = investigation?.question
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false
        navigationItem.title = investigation?.title
        
        timerPickerView.dataSource = self
        timerPickerView.delegate = self
    }
    
    func setupNewComponentAlert() {
        alert.addTextField { (textField) in
            textField.placeholder = "Component name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textField = self.alert.textFields![0] // Force unwrapping because we know it exists.
            // set created component's name
            let indexPath = IndexPath(row: self.investigation!.components.count, section: 0)
            let comp = Component.componentFromEnum(e: (self.investigation?.componentType.rawValue)!)!
            comp.title = textField.text!
            
            self.investigation!.components.append(comp)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }))
    }
    
    // MARK: pickerview stuff
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource[component].count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[component][row]
    }
    
    
    // MARK: tableview stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return investigation!.components.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == investigation.components.count {
            let addComp = tableView.dequeueReusableCell(withIdentifier: "button") as! AddComponentTVCell
            addComp.delegate = self
            addComp.separatorInset = UIEdgeInsetsMake(0, addComp.bounds.size.width, 0, 0)
            addComp.selectionStyle = .none
            return addComp
        }
        
        switch investigation!.componentType {
        case .Counter, .IntervalCounter :
            let comp: Counter = investigation!.components[indexPath.row] as! Counter
            let cell = tableView.dequeueReusableCell(withIdentifier: "counter") as! CounterTVCell
            cell.selectionStyle = .none
            cell.counter = comp
            cell.investigationController = self
            return cell
        case .Stopwatch :
            let comp: Stopwatch = investigation!.components[indexPath.row] as! Stopwatch
            let cell = tableView.dequeueReusableCell(withIdentifier: "stopwatchCell") as! StopwatchTVCell
            cell.selectionStyle = .none
            cell.component = comp
            cell.investigationController = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 && indexPath.row != investigation.components.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            investigation.components.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as? UIViewController
        if let navcon = segue.destination as? UINavigationController {
            destination = navcon.visibleViewController
        }
        if let dest = destination as? ResultsVC {
            dest.investigation = investigation
        }
    }
    
    func updated(date: Date) {
        if let i = investigation {
            i.date = date
            dateLabel.text = "Last Edited: \(i.lastUpdated)"
        }
    }
    
    func addComponent() {
        self.present(self.alert, animated: true, completion: nil)
    }
    
}
