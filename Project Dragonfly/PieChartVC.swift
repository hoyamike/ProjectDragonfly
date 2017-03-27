//
//  PieChartVC.swift
//  Project Dragonfly
//
//  Created by Rob Koch on 3/27/17.
//  Copyright © 2017 cse.miamioh. All rights reserved.
//

import UIKit
import Charts

class PieChartVC: ChartVC {

    var pieDataEntries = [ChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pieChart = chartView as! PieChartView
        pieChartEnable(pieChart: pieChart)
        // Do any additional setup after loading the view.
    }

    func pieChartEnable(pieChart: PieChartView) {
        chartTitle.text = investigation.title
        var i = 0
        for values in investigation.getInfo() {
            let dataEntry = PieChartDataEntry(value: Double(i), label: values.name, data: Double(values.value) as AnyObject?)
            pieDataEntries.append(dataEntry)
            i += 1
        }
        
        let pieDataSet = PieChartDataSet(values: pieDataEntries, label: "")
        pieDataSet.sliceSpace = 4.0
        
        pieDataSet.colors = colors
        
        let data = PieChartData(dataSet: pieDataSet)
        
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9.0))
        data.setValueTextColor(UIColor.black)
        
        pieChart.data = data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
