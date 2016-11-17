//
//  String+ Parser.swift
//  LaTexParser
//
//  Created by Rajiv Jhoomuck on 15/11/2016.
//  Copyright © 2016 Zeitgeist Software Ltd. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    public func sanitizedLaTexString() -> NSAttributedString {
        let pattern = "\\${2}\\s*(.*?)\\s*\\${2}"
        // Matches: "$$ {LaTex Expression} $$"
        if let matches = matchesForPattern(pattern) {
            return replaceLaTexMatches(matches)
        }
        
        print("Could not find the pattern in the string: \(self)")
        return NSAttributedString(string: self)
    }
    
    public func replaceLaTexMatches(matches: [NSTextCheckingResult]) -> NSAttributedString {
        let laTexString = NSMutableAttributedString(string: self)    // Because we want superscript text
        let reversedMatches = matches.reverse() // Take care of that for Swift 3
        for match in reversedMatches {   // Note: We are reverse enumerating
            // We are using groups in regex
            let laTexExpressionRange = match.rangeAtIndex(0)
            // This is the range that we have to replace
            let laTexSubStringRange = match.rangeAtIndex(1)
            // This is the expression, sans the $$
            
            let laTexSubString = laTexString.string.subStringWithRange(laTexSubStringRange)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                .stringByReplacingOccurrencesOfString("\\times", withString: "x")
                .stringByReplacingOccurrencesOfString("\\div", withString: "/")
                .stringByReplacingOccurrencesOfString("^{\\circ}", withString: "º")
                .scanLaTexText()
                .scanLaTexFraction()
                .scanLaTexSuperscripts()
            // Extension on String, unsafe for bounds! Use with caution
                        
            laTexString.replaceCharactersInRange(laTexExpressionRange, withAttributedString: laTexSubString) //laTexAttributedSubString)
        }
        
        return laTexString
    }
}

// MARK: Expression parsers
private extension String {
    // MARK : LaTex: \\text
    func scanLaTexText() -> String {  // \text{Quelque chose} => Quelque chose
        let pattern = "\\\\text\\{([\\w\\s,-.\'\"=+]{1,})\\}"
        if let matches = matchesForPattern(pattern) {
            var resultString = self
            
            for match in matches.reverse() {
                let rangeToReplace = match.rangeAtIndex(0)
                let rangeOfText = match.rangeAtIndex(1)
                
                let textRange =  rangeFromNSRange(rangeOfText)
                let text = resultString.substringWithRange(textRange)
                
                let fullRangeToReplace = rangeFromNSRange(rangeToReplace)
                resultString.replaceRange(fullRangeToReplace, with: text)
            }
            
            return resultString
        }
        return self
    }
    
    // MARK : LaTex: \\[df]rac
    func scanLaTexFraction() -> String {
        let pattern = "\\\\[df]rac\\{(.*)\\}\\{(.*)\\}"
        if let matches = matchesForPattern(pattern) {
            var resultString = self
            
            for match in matches.reverse() {
                guard  match.numberOfRanges == 3 else {
                    print("We either have a data problem or specs have changed.")
                    print("More than 2 numbers defining a fraction, returning original string")
                    return self
                }
                
                let rangeToReplace = match.rangeAtIndex(0)
                let numeratorRange = match.rangeAtIndex(1)   // numerator
                let denominatorRange = match.rangeAtIndex(2)   // denominator
                
                let numerator = subStringWithRange(numeratorRange)
                let denominator = subStringWithRange(denominatorRange)
                
                let fullRangeToReplace = rangeFromNSRange(rangeToReplace)
                
                resultString.replaceRange(fullRangeToReplace, with: numerator + " / " + denominator)
            }
            
            return resultString
        }
        
        return self
    }
    
    // MARK : LaTex: ^{ABCD}
    func scanLaTexSuperscripts() -> NSAttributedString {   // ^{ABCD} ==> mettre en exposant le contenu des {}
        let pattern = "\\^\\{?(\\w*)\\}?"
        if let matches = matchesForPattern(pattern) {
            let characterSet = NSCharacterSet(charactersInString: "^{}")
            let attributes = [
                NSBaselineOffsetAttributeName : 5,
                NSFontAttributeName : UIFont.systemFontOfSize(10.0) //Swift 3: systemFont(ofSize: 10.0)
                ] as [String : AnyObject]  // Maybe we should decrease the font size
            
            let resultString = NSMutableAttributedString(string: self)
            
            // var rangeToReplacementMapping = [(range: NSRange, replacement: String)]()
            
            for match in matches.reverse() where match.numberOfRanges > 1 {
                // Note: We are not traversing the matches in reverse since we will do that when
                let replacementRange = match.rangeAtIndex(0)
                let superscriptRange = match.rangeAtIndex(1)
                let replacementString = subStringWithRange(superscriptRange).stringByTrimmingCharactersInSet(characterSet)
                let replacementAttributedString = NSAttributedString(string: replacementString, attributes: attributes)
                
                resultString.replaceCharactersInRange(replacementRange, withAttributedString: replacementAttributedString)
            }
            
            return resultString
        }
        
        return NSMutableAttributedString(string: self)
    }
}

// MARK: Helpers
private extension String {
    private func matchesForPattern(pattern: String) -> [NSTextCheckingResult]? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let originalStringFullRange = NSMakeRange(0, self.characters.count)
            return regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: originalStringFullRange)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func rangeFromNSRange(range: NSRange) -> Range<Index> {
        let start = startIndex.advancedBy(range.location)   // Swift 3: index(startIndex, offsetBy: range.location)
        let end = start.advancedBy(range.length)    // Swift 3: index(start, offsetBy: range.length)
        return start..<end
    }
    
    private func subStringWithRange(range: NSRange) -> String {
        let r = rangeFromNSRange(range)
        return self[r]
    }
}
