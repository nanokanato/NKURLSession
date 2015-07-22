//
//  NKViewController.swift
//  NKSession
//
//  Created by nanoka____ on 2015/07/09.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

/*--------------------------------------------------------------------
; import : FrameworkやObjective-cを読み込む場合に使用
---------------------------------------------------------------------*/
import UIKit

/*=====================================================================
; NKViewController
======================================================================*/
class NKViewController : UIViewController {
    
    var oImageView:UIImageView!
    var progressView:UIProgressView!
    
    /*-----------------------------------------------------------------
    ; viewDidLoad : 初回Viewの読み込み時に呼び出される
    ;          in :
    ;         out :
    ------------------------------------------------------------------*/
    override func viewDidLoad() {
        //背景を白色にする
        self.view.backgroundColor = UIColor.whiteColor()
        
        //背景画像
        oImageView = UIImageView(frame: self.view.bounds)
        oImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(oImageView)
        
        //非同期通信
        var loadButton = UIButton(frame: CGRectMake(self.view.frame.size.width/2-130/2, self.view.frame.size.height-44-10, 130, 44))
        loadButton.setTitle("非同期通信開始", forState: UIControlState.Normal)
        loadButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        loadButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        loadButton.addTarget(self, action: "loadButtonTaped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loadButton)
        
        //バックグラウンド通信
        var backgroundButton = UIButton(frame: CGRectMake(self.view.frame.size.width/2-200/2, self.view.frame.size.height-44-10-44-10, 200, 44))
        backgroundButton.setTitle("バックラウンド通信開始", forState: UIControlState.Normal)
        backgroundButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        backgroundButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        backgroundButton.addTarget(self, action: "backgroundButtonTaped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backgroundButton)
        
        //プログレスビュー
        progressView = UIProgressView(frame: CGRectMake((self.view.frame.size.width-200)/2, (self.view.frame.size.height-20)/2, 200, 20))
        progressView.backgroundColor = UIColor.blackColor()
        progressView.alpha = 0.0;
        progressView.progressTintColor = UIColor.blackColor()
        progressView.trackTintColor = UIColor.lightGrayColor()
        progressView.progress = 0.0;
        self.view.addSubview(progressView);
    }
    
    /*-----------------------------------------------------------------
    ; loadButtonTaped : 非同期通信開始
    ;              in : sender(UIButton)
    ;             out :
    ------------------------------------------------------------------*/
    func loadButtonTaped(sender: UIButton) {
        //プログレスバーを表示
        progressView.progress = 0.0;
        oImageView.image = nil
        UIView.animateWithDuration(0.3,
                          delay: 0,
                        options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.progressView.alpha = 1.0
                },
                completion: { finished in
                    //通信開始
                    let url = NSURL(string:"http://nanoka.wpcloud.net/wp-content/uploads/2015/07/IMG_1549.png")!
                    let request:NSURLRequest = NSURLRequest(URL: url)
                    NKSession.sharedInstance.loadURLSession(request, delegate: self)
                }
        )
    }
    
    /*-----------------------------------------------------------------
    ; backgroundButtonTaped : バックラウンド通信開始
    ;                    in : sender(UIButton)
    ;                   out :
    ------------------------------------------------------------------*/
    func backgroundButtonTaped(sender: UIButton) {
        //プログレスバーを表示
        progressView.progress = 0.0;
        oImageView.image = nil
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.progressView.alpha = 1.0
            },
            completion: { finished in
                //通信開始
                let url = NSURL(string:"http://nanoka.wpcloud.net/wp-content/uploads/2015/07/IMG_1549.png")!
                let request:NSURLRequest = NSURLRequest(URL: url)
                NKSession.sharedInstance.backgroundURLSession(request, delegate: self)
            }
        )
    }
}

/*=====================================================================
; NKSessionDelegate
======================================================================*/
extension NKViewController : NKSessionDelegate{
    /*-----------------------------------------------------------------
    ; didWriteDataNKSession : ダウンロード中
    ;                       in : bytesWritten(Int64)
    ;                          : totalBytesWritten(Int64)
    ;                          : totalBytesExpectedToWrite(Int64)
    ;                      out :
    ------------------------------------------------------------------*/
    func didWriteDataNKSession(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        println("通信中:+\(bytesWritten) (\(totalBytesWritten) / \(totalBytesExpectedToWrite))")
        self.progressView.setProgress(Float(totalBytesWritten/totalBytesExpectedToWrite), animated: true)
    }
    
    /*-----------------------------------------------------------------
    ; didFinishDownloadingToURL : 通信終了
    ;                        in : data(NSData)
    ;                       out :
    ------------------------------------------------------------------*/
    func didFinishDownloadingToURLNKSession(data: NSData) {
        println("通信終了")
        var image = UIImage(data: data)
        if image != nil {
            if image!.isKindOfClass(UIImage) {
                oImageView.image = image
            }
        }
    }
    
    /*-----------------------------------------------------------------
    ; didCompleteWithErrorNKSession : 通信完了後
    ;                            in : error(NSError?)
    ;                           out :
    ------------------------------------------------------------------*/
    func didCompleteWithErrorNKSession(error: NSError?) {
        println("通信完了:" + String(stringInterpolationSegment:error))
        if error != nil {
            oImageView.image = nil
        }
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.progressView.alpha = 0.0
            },
            completion: { finished in
            }
        )
    }
}
