//
//  PsdDocument.swift
//  psd_sdk_Test
//
//  Created by rbs on 2024/05/02.
//

import Foundation
import AppKit

// -------------------------------------------------------------------------------------------------
// MARK: PsdLayer Class

class PsdLayer: Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var visible: Bool = false
    var image: CGImage?
    
}


// -------------------------------------------------------------------------------------------------
// MARK: PsdDocument Class

class PsdDocument {
    var width: Int = 0
    var height: Int = 0
    var layers: [PsdLayer] = []
    var thumbnail: CGImage?
    
    // ---------------------------------------------------------------------------------------------
    // MARK: Static Function
    
    static func combineImages(layers: [PsdLayer]) -> (result: Result, cgImage: CGImage?) {
        guard let firstLayer = layers.first else {
            return (Result("Layer data is missing."), nil)
        }
        
        let contextSize = CGSize(width: firstLayer.image!.width, height: firstLayer.image!.height)
        
        guard let context = CGContext(
            data: nil,
            width: Int(contextSize.width),
            height: Int(contextSize.height),
            bitsPerComponent: firstLayer.image!.bitsPerComponent,
            bytesPerRow: 0,
            space: firstLayer.image!.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: firstLayer.image!.bitmapInfo.rawValue
        ) else {
            return (Result("Failed to create CGContext."), nil)
        }
        
        // 背景を透明に設定
        context.clear(CGRect(origin: .zero, size: contextSize))

        for layer in layers {
            if layer.visible {
                context.draw(layer.image!, in: CGRect(origin: .zero, size: contextSize))
            }
        }
        
        return (Result(.success), context.makeImage())
    }
}


