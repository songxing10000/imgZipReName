//
//  FileDragView.swift
//  FileDrag
//
//  Created by iDevFans on 16/7/26.
//  Copyright © 2016年 macdev.io. All rights reserved.
//

import Cocoa

//文件拖放应用代理协议
@objc protocol FileDragDelegate:AnyObject {
    func didFinishDrag(_ URLs: [URL])
}

class FileDragView: NSView {
    
    @IBOutlet weak var delegate: FileDragDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //注册文件拖放类型
        self.registerForDraggedTypes([.fileURL])
    }
    
    //MARK: NSDraggingDestination
    //开始拖放，返回拖放类型
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let sourceDragMask = sender.draggingSourceOperationMask
        if sender.draggingPasteboard.types?.contains(.fileURL) == true {
            if sourceDragMask.contains([.link]) {
                return .link
            }
            if sourceDragMask.contains([.copy]) {
                return .copy
            }
        }
        return .generic
    }
    
    //拖放文件进入拖放区，返回拖放操作类型
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let fileURLs = sender.draggingPasteboard.readObjects( forClasses: [NSURL.self], options: nil) as? [URL],
            !fileURLs.isEmpty {
            
            delegate?.didFinishDrag(fileURLs)
        }
        return true
    }
}

