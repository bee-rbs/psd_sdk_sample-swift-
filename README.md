## 概要

c++で作成されたOSSの[psd_sdk](https://github.com/MolecularMatters/psd_sdk)をSwiftから利用するサンプルコードです。

## 詳細

- PSDファイルのレイヤー情報と各レイヤーを合成した画像を表示
- Swiftの「C++ interoperability」を使用（Xcode15以上が必要）

## ソースについての補足

PsdNativeFile_Mac.cppを使用するとメモリリークするため、Linux用のPsdNativeFile_Linux.cppを使用しています。

## psd_sdkについて

Copyright 2011-2020, Molecular Matters GmbH <office@molecular-matters.com>
All rights reserved.
