//
//  StringtoLong-Convertor.swift
//
//  Created by elan on 5/12/16.
//  Copyright © 2016 Chezhian Arulraj. All rights reserved.
//

import Foundation

//ErrorType definition handling invalid character
enum StringError:ErrorType {
    case CharacterError
}
//String extension to convert string to Long
extension String {
    func stringToInt() throws -> CLong {
        var value:Int = 0
        var counter:Int = 1
        for  digit in self.utf8 {
            if digit < 48 ||  digit > 57{
                //Added error handler for the
                throw StringError.CharacterError
            }
            value = value + Int(pow(10.0,Double(str.characters.count - counter))) * Int(digit - 48)
            counter += 1
        }
        return value
    }
}
//Sample class to test the extension.
class TestClass {
    init() {
        do {
            var string = "25464723"
            let integer = try string.stringToInt(str)
            print(integer)
        } catch StringError.CharacterError {
            print("Enter Valid integers")
        } catch {
            print("Unknown Exception")
        }
    }
}
