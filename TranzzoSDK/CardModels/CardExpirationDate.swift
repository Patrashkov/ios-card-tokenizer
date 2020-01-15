/*
* Copyright (c) TRANZZO LTD - All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
*/

import Foundation

public enum CardExpirationDateError: Int, Error {
    case stringTooShort
    case generalParsingError
    
    var message: String {
        switch self {
        case .stringTooShort:
            return "Raw date string is too short"
        case .generalParsingError:
            return "Raw date string could not be parsed into a valid date"
        }
    }
    
    var code: Int {
        return self.rawValue
    }
}

public struct CardExpirationDate: Equatable {
    let month: Int
    let year: Int
    
    public init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
    
    /// Fetches month and year from a raw string, if possible
    ///
    /// - parameter rawDateString:          Raw expiration date string.
    /// - Returns: `ExpirationDate`, if raw string could be converted, nil otherwise
    public init(rawDateString: String) throws {
        var filteredDate = rawDateString
        if filteredDate.containsNonDigits {
            filteredDate = filteredDate.digitsOnly
        }
        var month: Int?
        var year: Int?
        var indexEndMonth: String.Index
        switch filteredDate.count {
        case 3:
            indexEndMonth = filteredDate.index(filteredDate.startIndex, offsetBy: 1)
            
        case 4...:
            indexEndMonth = filteredDate.index(filteredDate.startIndex, offsetBy: 2)
            if let tempMonth = Int(filteredDate[..<indexEndMonth]) {
                if tempMonth > 12 {
                    indexEndMonth = filteredDate.index(filteredDate.startIndex, offsetBy: 1)
                }
            }
            
        default:
            throw CardExpirationDateError.stringTooShort
        }
        month = Int(filteredDate[..<indexEndMonth])
        year = Int(filteredDate[indexEndMonth...].suffix(2))
        if let month = month, let year = year {
            self.init(month: month, year: year)
        } else {
            throw CardExpirationDateError.generalParsingError
        }
    }
}
