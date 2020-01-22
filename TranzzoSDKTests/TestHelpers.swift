/*
* Copyright (c) TRANZZO LTD - All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
*/

import Foundation
@testable import TranzzoSDK

final class TestHelpers {
    struct MockRequstData: Encodable {
        let b: String
        let a: String
        let c: String
    }
    
    static func createValidCardRequestData() -> CardRequestData {
        return CardRequestData(cardNumber: "4242424242424242", cardExpMonth: 11, cardExpYear: 22, cardCvv: "123")
    }
    
    static func createInvalidCardRequestData() -> CardRequestData {
        CardRequestData(cardNumber: "4242424242424241", cardExpMonth: 22, cardExpYear: 22, cardCvv: "123")
    }
}