//
//  TextTests.swift
//  Parser
//
//  Created by Rajiv Jhoomuck on 16/11/2016.
//  Copyright © 2016 Zeitgeist Software Ltd. All rights reserved.
//

import XCTest
@testable import Parser

class TextTests: XCTestCase {
    // MARK: Text LaTex
    func testCanReplaceSpacePaddedTextLaTex() {
        // {someText}$${space}{LaTex Expression}{space}$${someText}
        let testString = "Before $$ \\text{This is a day, that. ...3456 - Steve Jobs} $$ after"
        let sanitizedString = testString.sanitizedLaTexString()
        
        print(sanitizedString)
        print(NSAttributedString(string: "Before This is a day, that. ...3456 - Steve Jobs after"))
        
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "Before This is a day, that. ...3456 - Steve Jobs after"))
    }
    
    func testCanReplaceNoSpacePaddedTextLaTex() {
        // {someText}$${LaTex Expression}$${someText}
        let testString = "Before $$\\text{This is a day, that. ...3456 - Steve Jobs}$$ after"
        let sanitizedString = testString.sanitizedLaTexString()
        XCTAssertEqual(sanitizedString, NSAttributedString(string: "Before This is a day, that. ...3456 - Steve Jobs after"))
    }
}
