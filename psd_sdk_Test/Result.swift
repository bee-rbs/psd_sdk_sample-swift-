//
//  Result.swift
//  psd_sdk_Test
//
//  Created by rbs on 2024/05/17.
//

import Foundation

// -------------------------------------------------------------------------------------------------
// MARK: PsdResult Structure

struct Result {
    enum ResultType: String {
        case success = "Success"
        case warning = "Warning"
        case error = "Error"
    }
    
    var type: ResultType
    var code: Int
    var message: String = ""

    
    // ---------------------------------------------------------------------------------------------
    // MARK: Initialize
    
    init(_ resultType: ResultType) {
        self.type = resultType
        self.code = 0
        self.message = ""
#if DEBUG
        if self.message != "" {
            print("Debug Message: Type: \(self.type.rawValue) code: \(self.code) message: \(self.message)")
        }
#endif
    }

    
    init(_ message: String) {
        self.type = .error
        self.code = -1
        self.message = message
#if DEBUG
        print("Debug Message: Type: \(self.type.rawValue) code: \(self.code) message: \(self.message)")
#endif
    }
    

    init(_ resultType: ResultType, _ resultCode: Int, _ message: String) {
        self.type = resultType
        self.code = resultCode
        self.message = message
#if DEBUG
        print("Debug Message: Type: \(self.type.rawValue) code: \(self.code) message: \(self.message)")
#endif
    }

}
