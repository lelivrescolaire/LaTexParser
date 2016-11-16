//
//  SuperscriptTests.swift
//  Parser
//
//  Created by Rajiv Jhoomuck on 16/11/2016.
//  Copyright © 2016 Zeitgeist Software Ltd. All rights reserved.
//

import XCTest
@testable import Parser

class SuperscriptTests: XCTestCase {
    
    // Mark Single-Character Superscript
    func testCanReplaceSpacePaddedSingleCharacterSuperscriptLaTexThatHasTextBeforeAndAfter() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Pre E$$ Bonzy^XParo $$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EBonzyXParo post")
        let range = NSMakeRange(10, 1)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    func testCanReplaceNoSpacePaddedSingleCharacterSuperscriptLaTexThatHasTextBeforeAndAfter() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Pre E$$Bonzy^XParo$$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EBonzyXParo post")
        let range = NSMakeRange(10, 1)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    func testCanReplaceSpacePaddedSingleCharacterSuperscriptLaTex() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Pre E$$ ^X $$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EX post")
        let range = NSMakeRange(5, 1)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    func testCanReplaceNoSpacePaddedSingleCharacterSuperscriptLaTex() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Pre E$$^X$$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EX post")
        let range = NSMakeRange(5, 1)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    // Mark Multi-Character Superscript
    func testCanReplaceSpacePaddedMultiCharacterSuperscriptLaTexThatHasTextBeforeAndAfter() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Pre E$$ Bonzy^{Hello}Paro $$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EBonzyHelloParo post")
        let range = NSMakeRange(10, 5)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    func testCanReplaceNoSpacePaddedMultiCharacterSuperscriptLaTexThatHasTextBeforeAndAfter() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Pre E$$Bonzy^{Hello}Paro$$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EBonzyHelloParo post")
        let range = NSMakeRange(10, 5)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    func testCanReplaceSpacePaddedMultiCharacterSuperscriptLaTex() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Pre E$$ ^{Hello} $$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EHello post")
        let range = NSMakeRange(5, 5)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
    
    func testCanReplaceNoSpacePaddedMultiCharacterSuperscriptLaTex() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Pre E$$^{Hello}$$ post"
        
        let expectedString = NSMutableAttributedString(string: "Pre EHello post")
        let range = NSMakeRange(5, 5)
        expectedString.addAttributes(superscriptAttributes, range: range)
        
        let sanitizedString = testString.sanitizedLaTexString()
        
        XCTAssertEqual(sanitizedString, expectedString)
    }
}
