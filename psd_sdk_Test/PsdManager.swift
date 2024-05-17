//
//  PsdManager.swift
//  psd_sdk_Test
//
//  Created by rbs on 2024/05/01.
//

import Foundation
import AppKit
import psd_sdk

// -------------------------------------------------------------------------------------------------
// MARK: PsdManager Class

class PsdManager {
    private var mallocAllocatorPtr: UnsafeMutablePointer<psd.MallocAllocator>
    private var allocatorPtr: UnsafeMutablePointer<psd.Allocator>
    
    private var nativeFilePtr: UnsafeMutablePointer<psd.NativeFile>
    private var filePtr: UnsafeMutablePointer<psd.File>

    
    // ---------------------------------------------------------------------------------------------
    // MARK: Initialize
    
    init() {
        mallocAllocatorPtr = .allocate(capacity: 1)
        mallocAllocatorPtr.initialize(to: psd.MallocAllocator())
        allocatorPtr = UnsafeMutableRawPointer(mallocAllocatorPtr).assumingMemoryBound(to: psd.Allocator.self)
        
        nativeFilePtr = .allocate(capacity: 1)
        nativeFilePtr.initialize(to: psd.NativeFile(allocatorPtr))
        filePtr = UnsafeMutableRawPointer(nativeFilePtr).assumingMemoryBound(to: psd.File.self)
    }

    
    // ---------------------------------------------------------------------------------------------
    // MARK: Cleanup
    
    deinit {
        nativeFilePtr.deinitialize(count: 1)
        nativeFilePtr.deallocate()
        mallocAllocatorPtr.deinitialize(count: 1)
        mallocAllocatorPtr.deallocate()
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: Pubric Function
    
    public func importPsd(filePath: String) -> (reslt: Result, psdDocument: PsdDocument?) {
        var documentPtr: UnsafeMutablePointer<psd.Document>?

        // PSDファイルの読み込み
        let result = filePath.withCString(encodedAs: UTF32.self) { cString -> Bool in
            cString.withMemoryRebound(to: CWideChar.self, capacity: strlen(cString)) { reboundCString in
                if !nativeFilePtr.pointee.OpenRead(reboundCString) {
                    return false
                }
                return true
            }
        }
        if !result {
            return (Result("Cannot open file."), nil)
        }
       
        // psd.Documentの作成
        documentPtr = psd.CreateDocument(filePtr, allocatorPtr)
        if documentPtr == nil {
            nativeFilePtr.pointee.Close()
            return (Result("Cannot create document."), nil)
        }
#if DEBUG
        print("Document width: \(documentPtr.pointee.width) height: \(documentPtr.pointee.height)")
#endif
        
        if documentPtr.pointee.colorMode != psd.colorMode.RGB.rawValue {
            psd.DestroyDocument(&documentPtr, allocatorPtr)
            nativeFilePtr.pointee.Close();
            return (Result("Document is not in RGB color mode.(\(documentPtr.pointee.colorMode)"), nil)
        }

        if documentPtr.pointee.bitsPerChannel != 8 {
            psd.DestroyDocument(&documentPtr, allocatorPtr)
            nativeFilePtr.pointee.Close();
            return (Result("Image is not 8bit.(\(documentPtr.pointee.bitsPerChannel)"), nil)
        }

        // レイヤー＆マスクセクションの取得
        var layerMaskSectionPtr = psd.ParseLayerMaskSection(documentPtr, filePtr, allocatorPtr)
        if layerMaskSectionPtr == nil {
            psd.DestroyDocument(&documentPtr, allocatorPtr)
            nativeFilePtr.pointee.Close();
            return (Result("Layer Secsion Error."), nil)
        }

        // レイヤーデータの展開、psdDocumentの作成
        let psdDocument = PsdDocument()
        psdDocument.width = Int(documentPtr.pointee.width)
        psdDocument.height = Int(documentPtr.pointee.height)

        for i in 0..<layerMaskSectionPtr.pointee.layerCount {
            let psdLayer = PsdLayer()
            var layer = layerMaskSectionPtr.pointee.layers[Int(i)]
            psdLayer.name = String(decodingCString: layer.utf16Name, as: UTF16.self)
            psdLayer.visible = layer.isVisible
            
            psd.ExtractLayer(documentPtr, filePtr, allocatorPtr, &layer)
            let readLayerResult = readLayer(layer: &layer,
                                            width: documentPtr.pointee.width,
                                            height: documentPtr.pointee.height)
            if readLayerResult.result.type != .success {
                return (Result("Layer Extract Error."), nil)
            }
            
            psdLayer.image = readLayerResult.image
            psdDocument.layers.append(psdLayer)
        }

        psd.DestroyLayerMaskSection(&layerMaskSectionPtr, allocatorPtr);
        psd.DestroyDocument(&documentPtr, allocatorPtr)
        
        return (Result(.success), psdDocument)
    }
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: Private Function
    
    private func readLayer(layer: inout psd.Layer, width: UInt32, height: UInt32) -> (result: Result, image: CGImage?) {
#if DEBUG
        let layerName = String(decodingCString: layer.utf16Name, as: UTF16.self)
        print("レイヤー名:\(layerName) Top: \(layer.top) Bottom:\(layer.bottom) Left:\(layer.left) Right:\(layer.right)")
#endif
        
        let findChannelResultR = findChannel(layer: layer, channelType: psd.channelType.R.rawValue)
        let findChannelResultG = findChannel(layer: layer, channelType: psd.channelType.G.rawValue)
        let findChannelResultB = findChannel(layer: layer, channelType: psd.channelType.B.rawValue)
        let findChannelResultA = findChannel(layer: layer, channelType: psd.channelType.TRANSPARENCY_MASK.rawValue)

        if findChannelResultA.resut.type != .success &&
            findChannelResultA.resut.type != .success &&
            findChannelResultA.resut.type != .success &&
            findChannelResultA.resut.type != .success {
            
            return (Result("Unknown channel type for any of the RGBAs."), nil)
        }
        
        var canvasData: [UnsafeMutableRawPointer?] = []
        
        canvasData.append(expandChannelToCanvas(allocatorPtr, layer, layer.channels[findChannelResultR.channelNo], width, height))
        canvasData.append(expandChannelToCanvas(allocatorPtr, layer, layer.channels[findChannelResultG.channelNo], width, height))
        canvasData.append(expandChannelToCanvas(allocatorPtr, layer, layer.channels[findChannelResultB.channelNo], width, height))
        canvasData.append(expandChannelToCanvas(allocatorPtr, layer, layer.channels[findChannelResultA.channelNo], width, height))
        
        let image = expandCanvasToImage(canvasR: canvasData[0]!,
                                        canvasG: canvasData[1]!,
                                        canvasB: canvasData[2]!,
                                        canvasA: canvasData[3]!,
                                        width: width,
                                        height: height)
        allocatorPtr.pointee.Free(canvasData[0])
        allocatorPtr.pointee.Free(canvasData[1])
        allocatorPtr.pointee.Free(canvasData[2])
        allocatorPtr.pointee.Free(canvasData[3])

        return (Result(.success), image)
    }


    func findChannel(layer: psd.Layer, channelType: Int32) -> (resut: Result, channelNo: Int) {
        for i: UInt32 in 0..<layer.channelCount {
            let channel = layer.channels[Int(i)]
            if channel.data != nil && channel.type == Int16(channelType) {
                return (Result(.success), Int(i))
            }
        }
        
        return (Result("Unknown channel type.") , -1)
    }
    
    
    func expandChannelToCanvas(_ allocatorPtr: UnsafeMutablePointer<psd.Allocator>,
                               _ layer: psd.Layer,
                               _ channel: psd.Channel,
                               _ canvasWidth: UInt32,
                               _ canvasHeight: UInt32) -> UnsafeMutableRawPointer? {
        let canvasData = allocatorPtr.pointee.Allocate(MemoryLayout<UInt8>.size * Int(canvasWidth) * Int(canvasHeight), 16)
        memset(canvasData, 0, MemoryLayout<UInt8>.size * Int(canvasWidth) * Int(canvasHeight))
        psd.imageUtil.CopyLayerData(channel.data, canvasData, layer.left, layer.top, layer.right, layer.bottom, canvasWidth, canvasHeight)
        
        return canvasData
    }

    
    private func expandCanvasToImage(canvasR: UnsafeMutableRawPointer,
                                     canvasG: UnsafeMutableRawPointer,
                                     canvasB: UnsafeMutableRawPointer,
                                     canvasA: UnsafeMutableRawPointer,
                                     width: UInt32,
                                     height: UInt32) -> CGImage? {
        var pixelData = [UInt8](repeating: 0, count: Int(width) * Int(height) * 4)
        pixelData.withUnsafeMutableBytes { pixelDataArrayPtr in
            let pixelDataPtr = pixelDataArrayPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)
            psd.imageUtil.InterleaveRGBA(canvasR, canvasG, canvasB, canvasA, pixelDataPtr, width, height)
        }
        
        let image = createImage(from: pixelData, width: Int(width), height: Int(height))
        
        return image
    }
    
    
    private func createImage(from pixelData: [UInt8], width: Int, height: Int) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let providerRef = CGDataProvider(data: Data(pixelData) as CFData) else {
            return nil
        }

        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bytesPerPixel * bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            return nil
        }

        return cgImage
    }
}
