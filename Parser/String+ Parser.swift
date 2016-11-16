//
//  String+ Parser.swift
//  LaTexParser
//
//  Created by Rajiv Jhoomuck on 15/11/2016.
//  Copyright © 2016 Zeitgeist Software Ltd. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func sanitizedLaTexString() -> NSAttributedString {
        let pattern = "[\\$]{2}\\s*?([-\\\\A-Za-z0-9\\s{}^.,_\\+\'\",]{1,})\\s*?[\\$]{2}" // "[\\$]{2}\\s([\\\\A-Za-z0-9\\s{}^.,\'\"]{1,})\\s[\\$]{2}"
        // Matches: "$$ {LaTex Expression} $$"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let originalStringFullRange = NSMakeRange(0, self.characters.count)
            let matches = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: originalStringFullRange)
            // Swift 3: matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: originalStringFullRange)
            
            return replaceLaTexMatches(matches)
        } catch let error {
            print(error)
        }
        
        print("Could not find the pattern in the string: \(self)")
        return NSAttributedString(string: self)
    }
}

extension String {
    func rangeFromNSRange(range: NSRange) -> Range<Index> {
        let start = startIndex.advancedBy(range.location)   // Swift 3: index(startIndex, offsetBy: range.location)
        let end = start.advancedBy(range.length)    // Swift 3: index(start, offsetBy: range.length)
        return start..<end
    }
    
    func subStringWithRange(range: NSRange) -> String {
        let r = rangeFromNSRange(range)
        return self[r]
    }
    
    func attributedStringByReplacingOccurrences(of occurrence: String, with replacement: String) -> NSAttributedString {
        let str: String = stringByReplacingOccurrencesOfString(occurrence, withString: replacement)
        // Swift 3 : replacingOccurrences(of: occurrence, with: replacement)
        return NSAttributedString(string: str)
    }
    
    // MARK : LaTex: \\text
    func scanLaTexText() -> NSAttributedString {
        return NSAttributedString(string: self.scanLaTexText())
    }
    
    func scanLaTexText() -> String {  // \text{Quelque chose} => Quelque chose
        let pattern = "([\\\\]\\text{(.{0,})})" //".{0,}\\{([+\\w\\s,-.\'\"]{1,})\\}.{0,}" // "\\{([\\w\\s,-.\'\"]{1,})\\}"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let matches = regex.matchesInString(self, options: NSMatchingOptions(rawValue: UInt(0)), range: NSMakeRange(0, characters.count))
            // Swift 3:regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            if let range = matches.first?.rangeAtIndex(1) {
                return self.subStringWithRange(range)
            }
        } catch let error {
            print("Failed to create regex pattern: \(error)")
        }
        return self
    }
    
    // MARK : LaTex: \\frac
    func scanLaTexFraction() -> NSAttributedString {
        return NSAttributedString(string: self.scanLaTexFraction())
    }
    
    func scanLaTexFraction() -> String {
        let pattern = "\\d{1,}"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let matches = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            //matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            guard matches.count == 2 else {
                print("We either have a data problem or specs have changed.")
                print("More than 2 numbers defining a fraction, returning original string")
                return self
            }
            let numeratorRange = matches[0].range
            let denominatorRange = matches[1].range
            let numerator = subStringWithRange(numeratorRange)
            let denominator = subStringWithRange(denominatorRange)
            
            return numerator + " / " + denominator
        } catch let error {
            print(error)
        }
        return self
    }
    
    // MARK : LaTex: ^{ABCD}
    func scanLaTexMultiCharacterSuperscript() -> NSAttributedString {   // ^{ABCD} ==> mettre en exposant le contenu des {}
        let pattern = ".{0,}(\\^\\{\\w{1,}\\}).{0,}"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let matches = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            // Swift 3: matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            if let rawSuperscriptRange = matches.first?.rangeAtIndex(1), let _ = matches.first?.rangeAtIndex(0) {
                
                // Grab the whole ^{text} at range 1 and trim the culprits
                let characterSet = NSCharacterSet(charactersInString: "^{}")
                let strippedString = self.subStringWithRange(rawSuperscriptRange).stringByTrimmingCharactersInSet(characterSet)
                
                let attributes = [
                    NSBaselineOffsetAttributeName : 5,
                    NSFontAttributeName : UIFont.systemFontOfSize(10.0) //Swift 3: systemFont(ofSize: 10.0)
                    ] as [String : AnyObject]  // Maybe we should decrease the font size
                let superscriptedString = NSMutableAttributedString(string: strippedString, attributes: attributes)
                
                let location = rawSuperscriptRange.location  //superscriptInsertionLocation
                
                let rangeToReplace = rangeFromNSRange(rawSuperscriptRange)
                let str = stringByReplacingCharactersInRange(rangeToReplace, withString: "")
                
                let fullString = NSMutableAttributedString(string: str)
                fullString.insertAttributedString(superscriptedString, atIndex: location)
                
                return fullString
            } else {
                return NSMutableAttributedString(string: self) // No matches
            }
        } catch let error {
            print(error)
        }
        
        return NSMutableAttributedString(string: self)
    }
    
    // MARK: LaTex: ^A
    func scanLaTexSingleCharacterSuperscript() -> NSAttributedString {   // ^{ABCD} ==> mettre en exposant le contenu des {}
        let pattern = ".{0,}(\\^\\w{1}).{0,}" // "[\\^](\\w){1}"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let matches = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            // Swift 3: matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            if let range = matches.first?.rangeAtIndex(1) {
                // Grab the whole ^{text} at range 1 and trim the culprits
                let characterSet = NSCharacterSet(charactersInString: "^{}")
                let strippedString = self.subStringWithRange(range).stringByTrimmingCharactersInSet(characterSet)
                
                let attributes = [
                    NSBaselineOffsetAttributeName : 5,
                    NSFontAttributeName : UIFont.systemFontOfSize(10.0) //Swift 3: systemFont(ofSize: 10.0)
                    ] as [String : AnyObject]  // Maybe we should decrease the font size
                let superscriptedString = NSMutableAttributedString(string: strippedString, attributes: attributes)
                
                let location = range.location  //superscriptInsertionLocation
                
                let rangeToReplace = rangeFromNSRange(range)
                let str = stringByReplacingCharactersInRange(rangeToReplace, withString: "")
                
                let fullString = NSMutableAttributedString(string: str)
                fullString.insertAttributedString(superscriptedString, atIndex: location)
                
                return fullString
            }
        } catch let error {
            print(error)
        }
        
        return NSMutableAttributedString(string: self)
    }
    
    func replaceLaTexMatches(matches: [NSTextCheckingResult]) -> NSAttributedString {
        let laTexString = NSMutableAttributedString(string: self)    // Because we want superscript text
        let reversedMatches = matches.reverse() // Take care of that for Swift 3
        for match in reversedMatches {   // Note: We are reverse enumerating
            // We are using groups in regex
            let laTexExpressionRange = match.rangeAtIndex(0)
            // This is the range that we have to replace
            let laTexSubStringRange = match.rangeAtIndex(1)
            // This is the expression, sans the $$
            
            let laTexSubString = laTexString.string.subStringWithRange(laTexSubStringRange).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                // Extension on String, unsafe for bounds! Use with caution
            
            var laTexAttributedSubString = NSAttributedString()
            
            if laTexSubString.containsString("\\times") {
                laTexAttributedSubString = laTexSubString.attributedStringByReplacingOccurrences(of: "\\times", with: "x")
            } else if laTexSubString.containsString("\\div") {
                laTexAttributedSubString = laTexSubString.attributedStringByReplacingOccurrences(of: "\\div", with: "/")
            } else if laTexSubString.containsString("^{\\circ}") {
                laTexAttributedSubString = laTexSubString.attributedStringByReplacingOccurrences(of: "^{\\circ}", with: "º")
            } else if laTexSubString.containsString("\\text") {
                laTexAttributedSubString = laTexSubString.scanLaTexText()
            } else if laTexSubString.containsString("\\frac") {
                laTexAttributedSubString = laTexSubString.scanLaTexFraction()
            } else if laTexSubString.containsString("^{") {
                laTexAttributedSubString = laTexSubString.scanLaTexMultiCharacterSuperscript()
            } else if laTexSubString.containsString("^") {
                laTexAttributedSubString = laTexSubString.scanLaTexSingleCharacterSuperscript()
            } else {
                // CrashHandler.logContentException(ContentException.laTexParsingFailure, objectID: "Expression: " + laTexSubString)
                continue    // yeah...
            }
            
            laTexString.replaceCharactersInRange(laTexExpressionRange, withAttributedString: laTexAttributedSubString)
        }
        
        return laTexString
    }
}
