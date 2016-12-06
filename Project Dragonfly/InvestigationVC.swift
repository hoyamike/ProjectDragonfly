//
//  InvestigationViewController.swift
//  Project Dragonfly
//
//  Created by Rob Koch on 10/31/16.
//  Copyright © 2016 cse.miamioh. All rights reserved.
//

import UIKit

class InvestigationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DateUpdated {

    let alert = UIAlertController(title: "New Component", message: "Enter a name for this component:", preferredStyle: .alert)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var investigation: Investigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if investigation.componentType != .IntervalCounter {
            print("test???")
//            timerContainerView.bounds.size.height = 0
//            timerContainerView.clipsToBounds = true
//            timerContainerView.isHidden = true
            print("Timer x: \(timerContainerView.frame.origin.x)")
            print("Timer y: \(timerContainerView.frame.origin.y)")
//            tableView.frame = CGRect(x: timerContainerView.frame.origin.x, y: timerContainerView.frame.origin.y, width: timerContainerView.frame.width, height: tableView.frame.height)
        }
        
        setupNewComponentAlert()
        
        dateLabel.text = investigation?.lastUpdated
        
        // Sets the category to the curent category name
        categoryLabel.text = investigation?.category
        questionLabel.text = investigation?.question
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false
        navigationItem.title = investigation?.title
    }
    
    @IBAction func addComponent(_ sender: Any) {
        self.present(self.alert, animated: true, completion: nil)
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
    
    
    // MARK: tableview stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return investigation!.components.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // need to: switch (component), then get component cell of that type.
        
        switch investigation!.componentType {
        case .Counter, .IntervalCounter :
            let comp: Counter = investigation!.components[indexPath.row] as! Counter
            let cell = tableView.dequeueReusableCell(withIdentifier: "component") as! CounterTVCell
            
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
        default:
            break;

        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "component") as! ComponentTVCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
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
        investigation?.date = date
        dateLabel.text = investigation?.lastUpdated
    }
}


protocol DateUpdated {
    func updated(date: Date)
}

