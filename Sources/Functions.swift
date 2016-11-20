//
//  Functions.swift
//  Bison
//

import Foundation

func _convertToBytes<T>(_ value: T, capacity: Int) -> [Byte] {
    
    var mutableValue = value
    return withUnsafePointer(to: &mutableValue) {
        
        return $0.withMemoryRebound(to: Byte.self, capacity: capacity) {
            
            return Array(UnsafeBufferPointer(start: $0, count: capacity))
        }
    }
}

@inline(__always)
func _md5(_ bytes: [UInt8]) -> [UInt8] {

    let shiftAmounts: [UInt32] = [7, 12, 17, 22, 5,  9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21]
    
    let sineTable: [UInt32] = [
        0xD76AA478, 0xE8C7B756, 0x242070DB, 0xC1BDCEEE, 0xF57C0FAF, 0x4787C62A, 0xA8304613, 0xFD469501,
        0x698098D8, 0x8B44F7AF, 0xFFFF5BB1, 0x895CD7BE, 0x6B901122, 0xFD987193, 0xA679438E, 0x49B40821,
        0xF61E2562, 0xC040B340, 0x265E5A51, 0xE9B6C7AA, 0xD62F105D, 0x02441453, 0xD8A1E681, 0xE7D3FBC8,
        0x21E1CDE6, 0xC33707D6, 0xF4D50D87, 0x455A14ED, 0xA9E3E905, 0xFCEFA3F8, 0x676F02D9, 0x8D2A4C8A,
        0xFFFA3942, 0x8771F681, 0x6D9D6122, 0xFDE5380C, 0xA4BEEA44, 0x4BDECFA9, 0xF6BB4B60, 0xBEBFBC70,
        0x289B7EC6, 0xEAA127FA, 0xD4EF3085, 0x04881D05, 0xD9D4D039, 0xE6DB99E5, 0x1FA27CF8, 0xC4AC5665,
        0xF4292244, 0x432AFF97, 0xAB9423A7, 0xFC93A039, 0x655B59C3, 0x8F0CCC92, 0xFFEFF47D, 0x85845DD1,
        0x6FA87E4F, 0xFE2CE6E0, 0xA3014314, 0x4E0811A1, 0xF7537E82, 0xBD3AF235, 0x2AD7D2BB, 0xEB86D391,
    ]

    let bitsCount = UInt64(bytes.count) * 8
    
    var message = bytes + [0x80]
    
    while message.count % 64 != 56 { message.append(0x00) }
    
    message += bitsCount._bytes
    
    var hash: [UInt32] = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476]
    
    for offset in stride(from: 0, to: message.count, by: 64) {
        
        var r1 = hash[0], r2 = hash[1], r3 = hash[2], r4 = hash[3]
        
        for position in 0 ..< 64 {
            
            var functionResult = UInt32(0)
            var chunkIndex = position
            let round = position >> 4
            
            switch round {
                
            case 0:
                functionResult = (r2 & r3) | (~r2 & r4)
                
            case 1:
                functionResult = (r2 & r4) | (r3 & ~r4)
                chunkIndex = (chunkIndex * 5 + 1) % 16
                
            case 2:
                functionResult = r2 ^ r3 ^ r4
                chunkIndex = (chunkIndex * 3 + 5) % 16
                
            case 3:
                functionResult = r3 ^ (r2 | ~r4)
                chunkIndex = (chunkIndex * 7) % 16
                
            default:
                fatalError()
            }
            
            let chunks = (0 ..< 16).flatMap {
                
                chunk in
                message.withUnsafeBufferPointer {
                    
                    $0.baseAddress?
                        .advanced(by: offset + chunk * 4)
                        .withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
                    }
                }
                .map { UInt32(littleEndian: $0) }
            
            let temp = r1 &+ functionResult
                          &+ chunks[chunkIndex]
                          &+ sineTable[position]
            
            let amount = shiftAmounts[(round << 2) | (position & 3)]
            
            r1 = r4
            r4 = r3
            r3 = r2
            r2 = r2 &+ (temp << amount | temp >> (32 - amount))
        }
        
        hash[0] = hash[0] &+ r1
        hash[1] = hash[1] &+ r2
        hash[2] = hash[2] &+ r3
        hash[3] = hash[3] &+ r4
    }
    
    var result = [UInt8]()
    
    hash.forEach { result.append(contentsOf: $0._bytes) }
    
    return result
}
