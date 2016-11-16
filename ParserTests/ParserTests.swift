//
//  ParserTests.swift
//  ParserTests
//
//  Created by Rajiv Jhoomuck on 15/11/2016.
//  Copyright © 2016 Zeitgeist Software Ltd. All rights reserved.
//

import XCTest
@testable import Parser

let multiplicationString = "Bonjour $$ 3 \\times 4 $$ some other text,"
let fractionString = "this is the start of a fraction $$ \\frac{3}{4} $$ end of a fraction"
let circString = "Some text $$ 99^{\\circ} $$ trailing text"
let textString = "Before $$ \\text{This is a day, that. ...3456 - Steve Jobs} $$ after"
let multiCharacterSuperscript = "Before a superscript  $$ ^{Hello} $$  after the superscript"

let superscriptAttributes = [ NSBaselineOffsetAttributeName : 5, NSFontAttributeName : UIFont.systemFontOfSize(10.0) ] as [String : AnyObject]

class ParserTests: XCTestCase {
    // MARK: Degrees LaTex
    func testCanReplaceSpacePaddedDegreesLaTex() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Some text $$ 99^{\\circ} $$ trailing text"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "Some text 99º trailing text"))
    }
    
    func testCanReplaceNoSpacePaddedDegreesLaTex() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Some text $$99^{\\circ}$$ trailing text"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "Some text 99º trailing text"))
    }
    
    func testCanReplaceSpacePaddedMultiplicationLaTex() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "this is the start of a fraction $$ \\frac{3}{4} $$ end of a fraction"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "this is the start of a fraction 3 / 4 end of a fraction"))
    }
    
    func testCanReplaceNoSpacePaddedFractionLaTex() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "this is the start of a fraction $$\\frac{3}{4}$$ end of a fraction"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "this is the start of a fraction 3 / 4 end of a fraction"))
    }
    
    func testCanReplaceSpacePaddedFractionLaTex() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Bonjour $$ 3 \\times 4 $$ some other text,"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "Bonjour 3 x 4 some other text,"))
    }
    
    func testCanReplaceNoSpacePaddedMultiplicationLaTex() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Bonjour $$3 \\times 4$$ some other text,"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "Bonjour 3 x 4 some other text,"))
    }
}
