//
//  NKSession.swift
//  NKSession
//
//  Created by nanoka____ on 2015/07/14.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

/*--------------------------------------------------------------------
; import : FrameworkやObjective-cを読み込む場合に使用
---------------------------------------------------------------------*/
import UIKit

/*--------------------------------------------------------------------
; protocol : Delegateの記述
---------------------------------------------------------------------*/
protocol NKSessionDelegate : NSObjectProtocol {
    func didWriteDataNKSession(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    func didFinishDownloadingToURLNKSession(data: NSData)
    func didCompleteWithErrorNKSession(error: NSError?)
}

/*=====================================================================
; NKSession
======================================================================*/
class NKSession: NSObject {
    
    //シングル㌧
    static let sharedInstance = NKSession()
    //変数
    private var delegateDictionary:NSMutableDictionary! = NSMutableDictionary()
    private var identifierNum: Int = 1
    
    /*-----------------------------------------------------------------
    ; loadURLSession : 通常のURLSession通信を開始する
    ;             in : urlRequest(NSURLRequest!)
    ;                : delegate(NKSessionDelegate)
    ;            out :let request:NSURLRequest = NSURLRequest(URL: url)
    ------------------------------------------------------------------*/
    func loadURLSession(urlRequest:NSURLRequest!, delegate:NKSessionDelegate) {
        //config作成
        identifierNum += 1
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.sharedContainerIdentifier = String(identifierNum)

        //delegate保存
        delegateDictionary.setObject(delegate, forKey: String(identifierNum))
        
        //Session作成
        let session = NSURLSession(configuration: config, //Sessionのconfig
                                        delegate: self, //delegateの設定
                                   delegateQueue: NSOperationQueue.mainQueue()) //メインスレッドでdelegateを呼ぶ
        
        //タスクを作成
        let task:NSURLSessionDownloadTask = session.downloadTaskWithRequest(urlRequest)
        
        //タスク開始
        task.resume()
    }
    
    /*-----------------------------------------------------------------
    ; backgroundURLSession : バックグラウンドでのURLSession通信を開始する
    ;                   in : urlRequest(NSURLRequest!)
    ;                      : delegate(NKSessionDelegate)
    ;                  out :let request:NSURLRequest = NSURLRequest(URL: url)
    ------------------------------------------------------------------*/
    func backgroundURLSession(urlRequest:NSURLRequest!, delegate:NKSessionDelegate) {
        //config作成
        identifierNum += 1
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("BackgronundSession")
        config.sharedContainerIdentifier = String(identifierNum)
        
        //delegate保存
        delegateDictionary.setObject(delegate, forKey: String(identifierNum))
        
        //Session作成
        let session = NSURLSession(configuration: config, //Sessionのconfig
                                        delegate: self, //delegateの設定
                                   delegateQueue: NSOperationQueue.mainQueue()) //メインスレッドでdelegateを呼ぶ 
        
        //タスクを作成
        let task:NSURLSessionDownloadTask = session.downloadTaskWithRequest(urlRequest)
        
        //タスク開始
        task.resume()
    }
    
    /*-----------------------------------------------------------------
    ; didFinishConnectionDataWithError : URLConnectionの通信終了
    ;                               in : response(NSURLResponse?)
    ;                                  : data(NSData?)
    ;                                  : error(NSError?)
    ;                              out :
    ------------------------------------------------------------------*/
    func didFinishConnectionDataWithError(response:NSURLResponse?,data:NSData?,error:NSError?){
        // 帰ってきたデータを文字列に変換.
        var myData:NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        println(myData)
    }
}

/*=====================================================================
; NSURLSessionDownloadDelegate
======================================================================*/
extension NKSession: NSURLSessionDownloadDelegate {
    /*-----------------------------------------------------------------
    ; didWriteData : ダウンロード中
    ;           in : session(NSURLSession)
    ;              : downloadTask(NSURLSessionDownloadTask)
    ;              : bytesWritten(Int64)
    ;              : totalBytesWritten(Int64)
    ;              : totalBytesExpectedToWritez(Int64)
    ;          out :
    ------------------------------------------------------------------*/
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //delegateに通信情報を通知
        if delegateDictionary != nil {
            var key = session.configuration.sharedContainerIdentifier
            if key != nil {
                var dele: AnyObject? = delegateDictionary.objectForKey(key!)
                if((dele) != nil){
                    var delegate: NKSessionDelegate = dele as! NKSessionDelegate
                    delegate.didWriteDataNKSession(bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
                }
            }
        }
    }
    
    /*-----------------------------------------------------------------
    ; didFinishDownloadingToURL : ダウンロード完了
    ;                        in : session(NSURLSession)
    ;                           : downloadTask(NSURLSessionDownloadTask)
    ;                           : location(NSURL)
    ;                       out :
    ------------------------------------------------------------------*/
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        //ダウンロードしたデータを取り出す
        let data: NSData = NSData(contentsOfURL: location)!
        //データをdelegateに返す
        if delegateDictionary != nil {
            var key = session.configuration.sharedContainerIdentifier
            if key != nil {
                var dele: AnyObject? = delegateDictionary.objectForKey(key!)
                if dele != nil {
                    var delegate: NKSessionDelegate = dele as! NKSessionDelegate
                    delegate.didFinishDownloadingToURLNKSession(data)
                }
            }
        }
    }
    
    /*-----------------------------------------------------------------
    ; didCompleteWithError : ダウンロード完了後
    ;                   in : session(NSURLSession)
    ;                      : downloadTask(NSURLSessionDownloadTask)
    ;                      : error(NSError?)
    ;                  out :
    ------------------------------------------------------------------*/
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        //delegateにSessionの終了を通知
        if delegateDictionary != nil {
            var key = session.configuration.sharedContainerIdentifier
            if key != nil {
                var dele: AnyObject? = delegateDictionary.objectForKey(key!)
                if dele != nil {
                    var delegate: NKSessionDelegate = dele as! NKSessionDelegate
                    delegate.didCompleteWithErrorNKSession(error)
                }
            }
        }
        
        //delegateを消去
        delegateDictionary.removeObjectForKey(session.configuration.sharedContainerIdentifier!)
        //Sessionのタスクを終了させる
        session.finishTasksAndInvalidate()
    }
}