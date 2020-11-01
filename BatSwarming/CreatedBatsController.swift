//
//  CreatedBatsController.swift
//  BatSwarming
//
//  Created by Volker Runkel on 30.12.15.
//  Copyright © 2015 Volker Runkel. All rights reserved.
//

import Cocoa

class CreatedBatsController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    
    var batList: Array<Bat>! = Array()
    let dF = DateFormatter()

    override func windowDidLoad() {
        super.windowDidLoad()
        dF.dateStyle = DateFormatter.Style.short
        dF.timeStyle = DateFormatter.Style.none

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func close(_ sender:AnyObject?) {
        (NSApp.delegate as! AppDelegate).window!.endSheet(self.window!)
        self.close()
    }
    
    @IBAction func saveAsCSV(_:AnyObject?) {
        let csvString = self.createCSV()
        let op = NSSavePanel()
        op.allowedFileTypes = ["csv","txt"]
        if op.runModal() == .OK {
            do {
                try csvString.write(to: op.url!, atomically: true, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                NSApp.presentError(error)
            }
        }
    }
    
    func createCSV() -> String {
        var outputString: String = ""

        outputString += "season;transponder;sex;age_at_marking;age_at_season_start;season_count;marking_date;marking_location;first_read_date_in_ES;last_read_date_in_ES;days_with_readings_in_ES;ES_readings;duration_of_ES;first_read_date_in_season;last_read_date_before_ES;start_LHI;end_LHI;days_with_readings_before_LHI;days_with_readings_after LHI;LHI_length;last_read_date_in_season;loggers;number_readings"
        
        for aBat in batList {
            outputString += "\n"
            outputString += aBat.season + ";"
            outputString += "\"" + aBat.transponder + "\";"
            outputString += aBat.sex + ";"
            outputString += aBat.age_at_marking + ";"
            outputString += aBat.age_at_season_start + ";"
            //outputString += "\(aBat.age_in_years)" + ";"
            outputString += "\(aBat.count_of_seasons)" + ";"
            outputString += dF.string(from: aBat.marking_date as Date) + ";"
            outputString += aBat.marking_location + ";"
            
            if let date = aBat.first_read_date_in_ES {
                outputString += dF.string(from: date as Date) + ";"
            }
            else {
                outputString += ";"
            }
            
            if let date = aBat.last_read_date_in_ES {
                outputString += dF.string(from: date as Date) + ";"
            }
            else {
                outputString += ";"
            }
            outputString += "\(aBat.days_with_readings_in_ES)" + ";"
            
            outputString += "\(aBat.days_in_ES)" + ";"
            outputString += "\(aBat.ES_readings)" + ";"
            
            if let date = aBat.first_read_date_in_season {
                outputString += dF.string(from: date as Date) + ";"
            }
            else {
                outputString += ";"
            }
            
            if let date = aBat.last_read_date_before_ES {
                outputString += dF.string(from: date as Date) + ";"
            }
            else {
                outputString += ";"
            }
            
            if let date = aBat.start_LHI {
                outputString += dF.string(from: date as Date) + ";"
            }
            else {
                outputString += ";"
            }
            
            if let date = aBat.end_LHI {
                outputString += dF.string(from: date as Date) + ";"
            }
            else {
                outputString += ";"
            }
            
            outputString += "\(aBat.days_with_readings_before_LHI)" + ";"
            outputString += "\(aBat.days_with_readings_after_LHI)" + ";"
            outputString += "\(aBat.LHI_length)" + ";"
            outputString += dF.string(from: aBat.last_read_date_in_season! as Date) + ";"
            outputString += "\(String(describing: aBat.loggers));"
            outputString += "\(aBat.number_of_readings)"
        }
        
        return outputString
    }
    
    // MARK: - TableView datasource, delegate functions
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return batList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let colIdentifier = "standardCell"
        let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(colIdentifier), owner: self) as! NSTableCellView
        
        if let identifier = tableColumn?.identifier {
            
            cell.textField?.stringValue = ""
            
            switch convertFromNSUserInterfaceItemIdentifier(identifier) {
            case "transponder": cell.textField?.stringValue = batList[row].transponder
            case "season": cell.textField?.stringValue = batList[row].season
            case "reads": cell.textField?.integerValue = batList[row].number_of_readings
            case "age_at_marking": cell.textField?.stringValue = batList[row].age_at_marking
            case "age_at_season_start": cell.textField?.stringValue = batList[row].age_at_season_start
            case "sex": cell.textField?.stringValue = batList[row].sex
            case "first_ES": if let date = batList[row].first_read_date_in_ES {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "last_ES": if let date = batList[row].last_read_date_in_ES {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "days_ES": cell.textField?.integerValue = batList[row].days_with_readings_in_ES
            case "first_season": if let date = batList[row].first_read_date_in_season {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "last_season": if let date = batList[row].last_read_date_in_season {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "last_bef_es": if let date = batList[row].last_read_date_before_ES {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "lhi_start": if let date = batList[row].start_LHI {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "lhi_end": if let date = batList[row].end_LHI {
                cell.textField?.stringValue = dF.string(from: date as Date)
                }
            case "lhi_length": cell.textField?.integerValue = batList[row].LHI_length
            default: cell.textField?.stringValue = "???"
            }
        }
        return cell
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
