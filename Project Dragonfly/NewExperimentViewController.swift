//
//  NewExperimentViewController.swift
//  Project Dragonfly
//
//  Created by Rob Koch on 10/17/16.
//  Copyright © 2016 cse.miamioh. All rights reserved.
//

import UIKit
import DropDown
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NewExperimentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var experimentTitleTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var toolPickerView: UIPickerView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let dropdown = DropDown()
    @IBOutlet weak var categoryButton: UIButton!
    var categoryButtonHeight: CGFloat = 0.0
    // test categories, need to store real categories
    let cats = [
        "Backyard",
        "School",
        "Aquatic",
        ]
    
    let alert = UIAlertController(title: "New Category", message: "Enter a category name", preferredStyle: .alert)
    
    var experiment: Experiment?
    
    let tools = [
        "Comparative Timer",
        "Counter",
        "Interval Counter",
        "Stopwatch",
        ]

    
    @IBAction func buttonTap(_ sender: UIButton) {
        dropdown.show()
    }

    
    @IBAction func experimentName(_ sender: UITextField) {
        experiment?.experimentName = sender.text
        checkExperiment()
    }
    
    @IBAction func questionText(_ sender: UITextField) {
        experiment?.question = sender.text
        checkExperiment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        experiment = Experiment(experimentName: "", question: "", date: Date())
        
        setUpToolPicker()
        setUpTextFields()
        
        setupDropDown()
        setupNewCategoryAlert()
        
        doneButton.isEnabled = false
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryButtonHeight = categoryButton.frame.height
        dropdown.topOffset = CGPoint(x: 0, y: -categoryButtonHeight)
    }
    
    // MARK: DropDown
    
    func setupDropDown() {
        dropdown.anchorView = categoryButton
        var temp = ["New", "None"]
            temp += cats
        dropdown.dataSource = temp
        
        dropdown.direction = DropDown.Direction.top
        // have to set dropdown offset in viewDidLayoutSubviews. otherwise the button height does not return correct value
        
        dropdown.selectionAction = { [unowned self] (index, item) in
            self.categoryButton.setTitle(item, for: .normal)
            if(item == temp[0]){
                print("yay!")
                self.present(self.alert, animated: true, completion: nil)
            }
        }
        dropdown.selectRow(at: 1)
        self.categoryButton.setTitle(temp[1], for: .normal)
    }
    
    // MARK: New Category Alert
    
    func setupNewCategoryAlert() {
        alert.addTextField { (textField) in
            textField.placeholder = "Category name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textField = self.alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            var temp = [""]
            temp[0] = textField.text!
            self.dropdown.dataSource += temp
            let index = self.dropdown.dataSource.count - 1
            self.dropdown.selectRow(at: index)
            self.categoryButton.setTitle(self.dropdown.dataSource[index], for: .normal)
            

        }))
            }
    
    
    // MARK: Picker View
    func setUpToolPicker() {
        toolPickerView.delegate = self
        toolPickerView.dataSource = self
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tools.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tools[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: TextField Stuff
    func setUpTextFields() {
        experimentTitleTextField.delegate = self
        questionTextField.delegate = self
    
        experimentTitleTextField.tag = 0
        questionTextField.tag = 1
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.text?.characters.count < 120
    }
    
    func checkExperiment() -> Bool {
        doneButton.isEnabled = experiment?.experimentName?.characters.count > 0 &&
            experiment?.question!.characters.count > 0
        return doneButton.isEnabled
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExperiment" {
            Experiments.instance.experiments.insert(self.experiment!, at: 0)
            let vc = segue.destination as! ExperimentsTableViewController
            vc.index = 0
        }
    }
}
