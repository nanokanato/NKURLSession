NKURLSession
=============
http://nanoka.wpcloud.net  

機能
-----
SwiftのNSURLSessionを使って通信する。
シングル㌧でNKSessionのインスタンスを管理。
通信時にNKSessionDelegateとNSURLRequestを引数として渡します。
非同期通信とバックグラウンド通信が行えます。
通信結果は通信途中,通信終了,SessionのTask終了後の3つのメソッドからの通信情報をdelegateで受け取れます。
  
○取得できるもの
・通信結果のNSData
・通信後のNSError
・通信途中の受取データ量と分割データ量,総データ量
  
使用方法
-----
・非同期通信(loadURLSession)
```
NKSession.sharedInstance.loadURLSession(/*NSURLRequestクラス*/, delegate: self)
```
  
・バックグラウンド通信(backgroundURLSession)
```
NKSession.sharedInstance.backgroundURLSession(/*NSURLRequestクラス*/, delegate: self)
```