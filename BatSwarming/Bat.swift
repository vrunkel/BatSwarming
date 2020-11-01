//
//  Bat.swift
//  BatSwarming
//
//  Created by Volker Runkel on 28.11.15.
//  Copyright © 2015 Volker Runkel. All rights reserved.
//

import Foundation

func == (lhs: Bat, rhs: Bat) -> Bool {
    let trans = lhs.transponder == rhs.transponder
    let seas = lhs.season == rhs.season
    return trans && seas
}

func unifiedDifferenceInDays(start:Date, end:Date) -> Int {
    let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    var dateCompsOne = gregorian!.components(NSCalendar.Unit(rawValue: UInt.max), from: start as Date)
    var dateCompsTwo = gregorian!.components(NSCalendar.Unit(rawValue: UInt.max), from: end as Date)
    dateCompsOne.hour = 0
    dateCompsOne.minute = 0
    dateCompsOne.second = 0
    dateCompsTwo.hour = 0
    dateCompsTwo.minute = 0
    dateCompsTwo.second = 0
    let days = gregorian!.components(.day, from: dateCompsOne, to: dateCompsTwo, options: NSCalendar.Options(rawValue: 0)).day
    return labs(days!)
}

class Bat: CustomStringConvertible, Equatable {

    /*
    
    season 1.7. - 30.6.
    LHI 1.7. - 30.4. | 1.5. - 30.6. ES 
                        ES == xx.5. und xx.6.
    
    im jetzigen Output geht eine Saison vom 15.7.-14.7.
    Das hätten wir gerne auf den 1.7.-30.6. geändert.
    Auch Alterswechsel würden dann bei dem Datum geschehen.
    
    Derzeit wird nach längsten Überwinterungsphasen vom 15.7.-14.4 gesucht. Hier hätten wir gerne eine Änderung auf den Zeitraum 1.7.-30.4.
    Entsprechend werden Lesungen  vom 1.5.- 30.6. der Frühsommerschwärmphase (ES) zugeordnet.
    Letzendlich sind natürlich sämtliche Kategorien betroffen, die durch diese Daten eingegrenzt werden.
    */
    
    
    var season: String! // Neu: von 1.7. bis 30.6. -> alt: immer vom 15.7. bis 14.7. -> zB 2010-2011
    var endAfterLHI : Date? {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        //return gregorian!.date(1, year: Int(season.substringFromIndex(season.startIndex.advancedBy(5)))!, month:4  , day: 15, hour: 00, minute: 00, second: 00, nanosecond: 00)
        let indexStartOfText = season.index(season.startIndex, offsetBy: 5)
        return gregorian!.date(era: 1, year: Int(season[indexStartOfText...])!, month:4  , day: 15, hour: 00, minute: 00, second: 00, nanosecond: 00)! as Date
    }
    var transponder: String! // -> bat-id
    var sex: String! // -> aus erstmarkierung
    var age_at_marking: String! // -> aus erstmarkierung
    var age_at_season_start: String! // -> aus erstmarkierung in erster season, dann ad
        {
        didSet {
            if self.age_at_marking == "vj" && self.age_at_season_start == "vj" {
                self.age_in_years = 1
            }
            let indexStartOfText = season.index(season.startIndex, offsetBy: 5)
            let season_year = Int(season[indexStartOfText...])!
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
            var markedYear: Int = (gregorian?.component(.year, from: self.marking_date as Date))!
            let markedMonth = gregorian?.component(.month, from: self.marking_date as Date)
            if markedMonth! > 6 {
                markedYear += 1
            }
            self.age_in_years += (season_year - markedYear)
            if self.age_at_marking == "vj" {
                self.age_in_years += 1
            }
            
            self.count_of_seasons = (season_year - markedYear)
            
        }
    }
    
    var count_of_seasons: Int = 0
    var age_in_years: Int = 0
    var marking_date: Date! // -> aus erstmarkierung
    var marking_location: String! // -> aus erstmarkierung
    var first_read_date_in_ES: Date? // Neu: 1.5. - 30.6. alt:-> 15.4. bis 14.7.
    var last_read_date_in_ES: Date? // Neu: 1.5. - 30.6. alt:-> 15.4. bis 14.7.
    var days_in_ES: Int {
        if self.last_read_date_in_ES != nil && self.first_read_date_in_ES != nil {
            return unifiedDifferenceInDays(start: first_read_date_in_ES!, end: last_read_date_in_ES!)
        }
        return 0
    }
    var ES_readings: Int = 0

    var days_with_readings_in_ES: Int = 0 // -> anzahl tage in neu 1.5. - 30.6. alt: 15.4. bis 14.7.
    
    var first_read_date_in_season: Date? // (after 1.7.) -> erstes auftreten in season
    var allReadings: Array<Date> = Array()
    var last_read_date_before_ES: Date? //(1.5.) -> letztes auftreten vor dem 1.5.
    var start_LHI: Date? // -> start longest hibernation interval lhi = längste periode ohne lesung
    var end_LHI: Date? //  -> end longest hibernation interval
    var days_with_readings_before_LHI: Int { // -> differenz tage zwischen start LHI und 1.7.
        if nil == self.start_LHI {
            return 0
        }
        var counter = 0
        for aDate in allReadings {
            //if aDate.isLessThan(self.start_LHI!)  {
            if aDate < self.start_LHI! {
                counter += 1
            }
        }
        return counter
    }
    
    var days_with_readings_after_LHI: Int // (bis 15.4.) -> differenz tage zwischen end LHI und 1.5.
    {
        if self.start_LHI != nil && self.end_LHI != nil {
            //return (self.number_of_readings - self.days_with_readings_before_LHI - 2)
            var counter = 0
            for aDate in allReadings {
                print(self.endAfterLHI!)
                if aDate > self.end_LHI! && aDate < self.endAfterLHI! {
                //if aDate.isGreaterThan(self.end_LHI!) && aDate.isLessThan(self.endAfterLHI) {
                    counter += 1
                }
            }
            return counter
        }
        return 0
    }
    var LHI_length: Int = 0 // -> tage lhi
    var last_read_date_in_season: Date? // -> letzte lesung
    {
        didSet {
            allReadings.append(self.last_read_date_in_season!)
        }
    }
    var loggers: Array<String>!
    var number_of_readings: Int = 0
    
    var description: String { return self.transponder + " " + season }
    
    func updateBatES(inDate: Date) {
        if self.first_read_date_in_ES == nil {
            self.first_read_date_in_ES = inDate
            self.last_read_date_in_ES = inDate
            self.ES_readings += 1
            return
        }
        if (self.last_read_date_in_ES!.timeIntervalSince(inDate as Date)) < -(12*60*60) {
            self.last_read_date_in_ES = inDate
            self.days_with_readings_in_ES += 1
        }
        else {
            self.last_read_date_in_ES = inDate
        }
        self.ES_readings += 1
    }
    
}
