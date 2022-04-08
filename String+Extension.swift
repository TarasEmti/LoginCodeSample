//
//  String+Extension.swift
//

import Foundation

extension String {

    typealias Validator = (String) -> Bool

    static let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    static let passwordRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,32}$"

    func format(with mask: String) -> String {
        var result = ""
        var index = self.startIndex

        for char in mask where index < self.endIndex {
            if char == "X", char != self[index] {
                result.append(self[index])
                index = self.index(after: index)
            } else {
                result.append(char)
            }
        }
        return result
    }
}

enum Validator {

    static let email: String.Validator = { text in
        let emailPred = NSPredicate(
            format:"SELF MATCHES %@", String.emailRegEx
        )
        return emailPred.evaluate(with: text)
    }

    static let password: String.Validator = { text in
        let passPred = NSPredicate(
            format:"SELF MATCHES %@", String.passwordRegEx
        )
        return passPred.evaluate(with: text)
    }
}
