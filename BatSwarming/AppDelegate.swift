//
//  AppDelegate.swift
//  BatSwarming
//
//  Created by Volker Runkel on 28.11.15.
//  Copyright © 2015 Volker Runkel. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var rawTable: NSTableView!
    @IBOutlet weak var speciesFilter: NSPopUpButton!
    
    var resultController: CreatedBatsController?
    
    var rawDataArray = Array<Array<AnyObject>>()
    var filteredDataArray = Array<Array<AnyObject>>()
    var dateToString = DateFormatter()
    
    /*func unifiedDifferenceInDays(start:Date, end:Date) -> Int {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let dateCompsOne = gregorian?.components(NSCalendarUnit(rawValue: UInt.max), fromDate: start)
        let dateCompsTwo = gregorian?.components(NSCalendarUnit(rawValue: UInt.max), fromDate: end)
        dateCompsOne?.hour = 0
        dateCompsOne?.minute = 0
        dateCompsOne?.second = 0
        dateCompsTwo?.hour = 0
        dateCompsTwo?.minute = 0
        dateCompsTwo?.second = 0
        let days = gregorian?.components(.Day, fromDateComponents: dateCompsOne!, toDateComponents: dateCompsTwo!, options: NSCalendarOptions(rawValue: 0)).day
        return labs(days!)
    }*/

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        dateToString.dateStyle = .medium
        dateToString.timeStyle = .medium
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func chooseInputFile(_ sender:AnyObject?) {
        dateToString.dateStyle = .medium
        dateToString.timeStyle = .medium
        let op = NSOpenPanel()
        op.canChooseDirectories = false
        op.canChooseFiles = true
        op.allowedFileTypes = ["csv", "tsv"]
        if op.runModal() == .OK {
            let fileURL = op.url!
            DispatchQueue.global(qos: .background).async {
                var usedEncoding: String.Encoding = String.Encoding(rawValue: 0)
                var inputString: String! = String()
                do {
                    inputString = try String(contentsOf: fileURL, usedEncoding: &usedEncoding)
                } catch let error as NSError {
                    NSApp.presentError(error)
                }
                catch {
                    print("Other error")
                }
                
                let linesArray = inputString.components(separatedBy:NSCharacterSet.newlines)
                DispatchQueue.main.async {
                    self.progressBar.maxValue = Double(linesArray.count)
                    self.progressBar.doubleValue = 0
                    self.progressBar.startAnimation(nil)
                }
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                for (index,aLine) in linesArray.enumerated() {
                    DispatchQueue.main.async {
                        self.progressBar.increment(by: 1)
                    }
                    let innerArray = aLine.components(separatedBy: NSCharacterSet(charactersIn: "\t") as CharacterSet)
                    if index == 0 {
                        DispatchQueue.main.sync {
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "0"))?.headerCell.stringValue = innerArray[0]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "1"))?.headerCell.stringValue = innerArray[2]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "2"))?.headerCell.stringValue = innerArray[3]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "3"))?.headerCell.stringValue = innerArray[4]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "4"))?.headerCell.stringValue = innerArray[5]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "5"))?.headerCell.stringValue = innerArray[7]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "6"))?.headerCell.stringValue = innerArray[8]
                            self.rawTable.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "7"))?.headerCell.stringValue = innerArray[9]
                        }
                        continue
                    }
                    if innerArray.count < 2 {
                        continue
                    }
                    var lineAsArray = [AnyObject]()
                    
                    let readDate = df.date(from: innerArray[0] +  " " + innerArray[1])
                    if let readDate = readDate {
                        lineAsArray.append(Date(timeInterval: (-12*60*60), since: readDate) as AnyObject) // corrected for "bat day" by subtracting 12 hours
                    }
                    else {
                        // the error occurs because the date is in an undefined time (dst change at that date)
                        if let readDateCorrected = df.date(from: innerArray[0] +  " " + "01:59:59") {
                            lineAsArray.append(Date(timeInterval: (-12*60*60), since: readDateCorrected) as AnyObject) // corrected for "bat day" by subtracting 12 hours
                        }
                        else {
                            Swift.print("Final error with \(innerArray[0]) \(innerArray[1])")
                            continue
                        }
                    }
                    let lineString : String = innerArray[2]
                    lineAsArray.append(lineString.lowercased() as AnyObject)
                    lineAsArray.append(innerArray[3] as AnyObject)
                    lineAsArray.append(innerArray[4] as AnyObject)
                    let markDate = df.date(from: innerArray[5] +  " " + innerArray[6])
                    if let markDate = markDate {
                        lineAsArray.append(markDate as AnyObject)
                    }
                    else {
                        // the error occurs because the date is in an undefined time (dst change at that date)
                        Swift.print("Error with markdate \(innerArray[5]) \(innerArray[6])")
                        continue
                    }
                    lineAsArray.append(innerArray[7] as AnyObject)
                    lineAsArray.append(innerArray[8] as AnyObject)
                    lineAsArray.append(innerArray[9].uppercased() as AnyObject)
                    
                    self.rawDataArray.append(lineAsArray)
                }
                self.rawDataArray.sort {
                    (item1, item2) in
                    return item1[1].compare(item2[1]) == ComparisonResult.orderedAscending
                }
                self.rawDataArray.sort {
                    (item1, item2) in
                    return (item1[0] as! Date).compare((item2[0] as! Date) as Date) == ComparisonResult.orderedSame
                }
                DispatchQueue.main.async {
                    self.progressBar.stopAnimation(nil)
                    self.progressBar.doubleValue = 0
                    self.filterData(nil)
                }
            }
        }
    }
    
    @IBAction func filterData(_ sender:AnyObject?) {
        if self.speciesFilter.indexOfSelectedItem > 0 {
            if self.speciesFilter.indexOfSelectedItem == 1 {
                filteredDataArray = rawDataArray.filter({$0[7].uppercased == "MD"})
                /*
                if innerArray[9].uppercaseString == "MN" {
                    continue
                }*/
            }
            else if self.speciesFilter.indexOfSelectedItem == 2 {
                filteredDataArray = rawDataArray.filter({$0[7].uppercased == "MN"})
            }
        }
        else {
            filteredDataArray = rawDataArray
        }
        self.rawTable.reloadData()
    }
    
    @IBAction func createBats(_ sender:AnyObject?) {
        
        var uniqueBats = Array<String>()
        
        if rawTable.selectedRowIndexes.count > 1 {
            (rawTable.selectedRowIndexes as NSIndexSet).enumerate({ (idx, run) -> Void in
                if !uniqueBats.contains(self.filteredDataArray[idx][1] as! String) {
                    uniqueBats.append(self.filteredDataArray[idx][1] as! String)
                }
           })
        }
        else {
            for aBat in filteredDataArray {
                if !uniqueBats.contains(aBat[1] as! String) {
                    uniqueBats.append(aBat[1] as! String)
                }
            }
        }
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        
        var batsArray = Array<Bat>()
        for aBat in uniqueBats {
            //let aBatsLife = filteredDataArray.filter({$0[1] as! String == aBat}).sort({($0[0] as! Date).compare(($1[0] as! Date)) == ComparisonResult.OrderedAscending})
            let sortedData = filteredDataArray.sorted(by: {($0[0] as! Date).compare(($1[0] as! Date)) == .orderedAscending}) //})  .sort()
            let aBatsLife = sortedData.filter({$0[1] as! String == aBat})
            var firstOccurence = true
            
            for uniqueBat in aBatsLife {
                let myBat = Bat()
                
                guard let component = gregorian?.components([.day, .month, .year], from: uniqueBat[0] as! Date) else {
                    continue
                }
                
                if component.month! < 7 {
                    myBat.season = "\((component.year!)-1)-\(component.year!)"
                }
                else if component.month! >= 7 {
                    myBat.season = "\((component.year!))-\((component.year!)+1)"
                }
                /*else {
                    if component.day < 15 {
                        myBat.season = "\((component.year)-1)-\(component.year)"
                    }
                    else {
                        myBat.season = "\((component.year))-\((component.year)+1)"
                    }
                }*/
                
                
                myBat.marking_date = (uniqueBat[4] as! Date)
                myBat.transponder = (uniqueBat[1] as! String)
                
                if uniqueBat[1] as! String == "708d7d1" {
//                    Swift.print("Here")
                }
                
                if batsArray.last == myBat {
                    if let lastBat = batsArray.last {
                        
                        if !lastBat.loggers.contains(uniqueBat[2] as! String)
                        {
                            lastBat.loggers.append(uniqueBat[2] as! String)
                        }
                        let day = Calendar.current.ordinality(of: .day, in: .year, for: uniqueBat[0] as! Date)
                        let lastDay = Calendar.current.ordinality(of: .day, in: .year, for: lastBat.last_read_date_in_season!)
                        //let day = NSCalendar.currentCalendar.ordinalityOfUnit(NSCalendar.Unit.Day, inUnit: NSCalendar.Unit.Year, forDate: uniqueBat[0] as! Date)
                        //let lastDay = NSCalendar.currentCalendar.ordinalityOfUnit(NSCalendar.Unit.Day, inUnit: NSCalendar.Unit.Year, forDate:lastBat.last_read_date_in_season!)
                        
                        /*if gregorian?.component(.Day, fromDate: uniqueBat[0] as! Date) == gregorian?.component(.Day, fromDate: lastBat.last_read_date_in_season!) {*/
                        if day == lastDay {
                            if component.month! >= 5 && component.month! <= 6 {
                                lastBat.ES_readings += 1
                            }
                            continue
                        }
                        
                        //if unifiedDifferenceInDays(uniqueBat[0] as! Date, end: lastBat.last_read_date_in_season!) < 1 {
                        //    continue
                        //}
                        
                        if component.month! >= 5 && component.month! <= 6 {
                            lastBat.updateBatES(inDate: uniqueBat[0] as! Date)
                        }
                        /*else if component.month == 4 && component.day > 14 {
                            lastBat.updateBatES(uniqueBat[0] as! Date)
                        }
                        else if component.month == 7 && component.day < 15 {
                            lastBat.updateBatES(uniqueBat[0] as! Date)
                        }*/
                        else {
                            lastBat.last_read_date_before_ES = uniqueBat[0] as? Date
                            if lastBat.LHI_length == 0 {
                                lastBat.start_LHI = lastBat.last_read_date_in_season
                                //let numberDays = gregorian?.components(.Day, fromDate: lastBat.start_LHI!, toDate: uniqueBat[0] as! Date, options: NSCalendarOptions()).day
                                let numberDays = unifiedDifferenceInDays(start: lastBat.start_LHI!, end: uniqueBat[0] as! Date)
                                lastBat.LHI_length = numberDays
                                lastBat.end_LHI = uniqueBat[0] as? Date
                            }
                            else {
                                //let numberDays = gregorian?.components(.Day, fromDate: lastBat.last_read_date_in_season! /*end_LHI!*/, toDate: uniqueBat[0] as! Date, options: NSCalendarOptions()).day
                                let numberDays = unifiedDifferenceInDays(start: lastBat.last_read_date_in_season!, end: uniqueBat[0] as! Date)
                                if numberDays >= lastBat.LHI_length {
                                    lastBat.start_LHI = lastBat.last_read_date_in_season! //lastBat.end_LHI
                                    lastBat.LHI_length = numberDays
                                    lastBat.end_LHI = uniqueBat[0] as? Date
                                }
                            }
                        }
                        
                        lastBat.last_read_date_in_season = uniqueBat[0] as? Date
                        
                        lastBat.number_of_readings += 1
                    }
                }
                else {
                    myBat.sex = (uniqueBat[5] as! String)
                    myBat.age_at_marking = (uniqueBat[6] as! String)
                    myBat.marking_location = (uniqueBat[3] as! String)
                    if firstOccurence {
                        myBat.age_at_season_start = (uniqueBat[6] as! String)
                    }
                    else {
                        myBat.age_at_season_start = "ad"
                    }
                    
                    firstOccurence = false
                    myBat.loggers = [uniqueBat[2] as! String]
                    myBat.first_read_date_in_season = uniqueBat[0] as? Date
                    myBat.last_read_date_in_season = uniqueBat[0] as? Date
                    myBat.last_read_date_before_ES = uniqueBat[0] as? Date
                    
                    if component.month! >= 5 && component.month! <= 6 {
                        myBat.first_read_date_in_ES = uniqueBat[0] as? Date
                        myBat.last_read_date_in_ES = uniqueBat[0] as? Date
                        myBat.days_with_readings_in_ES = 1
                    }
                    /*else if component.month == 4 && component.day > 14 {
                        myBat.first_read_date_in_ES = uniqueBat[0] as? Date
                        myBat.last_read_date_in_ES = uniqueBat[0] as? Date
                        myBat.days_with_readings_in_ES = 1
                    }
                    else if component.month == 7 && component.day < 15 {
                        myBat.first_read_date_in_ES = uniqueBat[0] as? Date
                        myBat.last_read_date_in_ES = uniqueBat[0] as? Date
                        myBat.days_with_readings_in_ES = 1
                    }*/
                    
                    myBat.number_of_readings += 1
                    
                    batsArray.append(myBat)
                }
            }
        }
        
        if batsArray.count > 0 {
            resultController = CreatedBatsController(windowNibName: "CreatedBatsController")
            resultController!.batList = batsArray
            self.window.beginSheet(resultController!.window!, completionHandler: { (response) -> Void in
                print("Done")
            })
        }
    }
    
    // MARK: - TableView datasource, delegate functions
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredDataArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let colIdentifier = "standardCell"
        let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(colIdentifier), owner: self) as! NSTableCellView

        if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "0" {
            cell.textField!.stringValue = dateToString.string(from: (filteredDataArray[row][0] as! Date) as Date)
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "1" {
            cell.textField!.stringValue = filteredDataArray[row][1] as! String
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "2" {
            cell.textField!.stringValue = filteredDataArray[row][2] as! String
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "3" {
            cell.textField!.stringValue = filteredDataArray[row][3] as! String
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "4" {
            cell.textField!.stringValue = dateToString.string(from: (filteredDataArray[row][4] as! Date) as Date)
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "5" {
            cell.textField!.stringValue = filteredDataArray[row][5] as! String
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "6" {
            cell.textField!.stringValue = filteredDataArray[row][6] as! String
        }
        else if convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "7" {
            cell.textField!.stringValue = filteredDataArray[row][7] as! String
        }
        return cell;
    }

    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
    return NSUserInterfaceItemIdentifier(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
    return input.rawValue
}
