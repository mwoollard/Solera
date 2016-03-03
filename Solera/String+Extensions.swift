//
//  String+Extensions.swift
//  Spotlist
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Mark Woollard
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public extension String {
    
    /**
     Trim whitespace from string
     
     - returns: string with pre and post whitespace removed
     */
    func stringByTrimmingWhiteSpace() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

    /**
     Trim whitespace and newlines from string
     
     - returns: string with pre and post whitespace/newlines removed
     */
    func stringByTrimmingWhiteSpaceAndNewlines() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /**
     Encode the string as a url parameter value
     
     - returns: encoded string
     */
    func stringByURLEncodingAsQueryParameterValue() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryParameterValueAllowedCharacterSet())!
    }

}