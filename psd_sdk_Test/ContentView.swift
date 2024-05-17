//
//  ContentView.swift
//  psd_sdk_Test
//
//  Created by Bee on 2024/04/25.
//

import SwiftUI
import psd_sdk

struct ContentView: View {
    @State var psdDocument: PsdDocument = PsdDocument()
    @State var psdImage: NSImage = NSImage()
    
    var body: some View {
        VStack {
            Button("読み込み") {
                // 日本語ファイル名を使用できるようにしたいためsetlocaleを設定する
                let currentLocale = Locale.preferredLanguages.first!.replacingOccurrences(of: "-", with: "_")
                setlocale(LC_ALL, "\(currentLocale).UTF-8")

                // PSDファイルを読み込む
                let psdManager = PsdManager()
                let importPsdResult = psdManager.importPsd(filePath: "/users/username/pictures/test.psd")

                if importPsdResult.reslt.type != .success {
                    print("PSDファイルの読み込みに失敗しました。")
                    return
                }

                psdDocument = importPsdResult.psdDocument!
                let combineImageResult = PsdDocument.combineImages(layers: psdDocument.layers)
                if combineImageResult.result.type != .success {
                    print("レイヤー合成に失敗しました。")
                    return
                }
                
                psdImage = NSImage(cgImage: combineImageResult.cgImage!, size: NSZeroSize)
            }
            
            Image(nsImage: psdImage)
                .resizable()
                .frame(width: CGFloat(psdDocument.width) * 0.2, height: CGFloat(psdDocument.height) * 0.2)

            List(psdDocument.layers) { layer in
                HStack {
                    Image(nsImage: NSImage(cgImage: layer.image!, size: NSZeroSize))
                        .resizable()
                        .frame(width: CGFloat(psdDocument.width) * 0.05, height: CGFloat(psdDocument.height) * 0.05)
                    Text(layer.name)
                }
            }
            
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
