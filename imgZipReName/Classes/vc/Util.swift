//
//  Util.swift
//  imgZipReName
//
//  Created by dfpo on 26/02/2022.
//

import Foundation
final class Util {
    static func getLibBundle() -> Bundle? {
        let fb = Bundle(for: Util.self)
        guard let path = fb.path(forResource: "imgZipReName", ofType: "bundle") else {
            return nil
        }
        return Bundle(path: path)
        
    }
    static func getImg(_ imgName: String?) -> NSImage? {
        guard let imgName = imgName else {
            return nil
        }
        return getLibBundle()?.image(forResource: imgName)
    }
    // 取字符串数组
    static func getStrsFromUserDefaults(key: String?) -> [String] {
        guard let key = key else {
            return [String]()
        }
        if let strs = UserDefaults.standard.object(forKey: key) as? [String] {
            return strs
        }
        return [String]()
    }
    /// 存字符串数组
    static func saveStrToStrArr(key:String?, saveStr:String?) -> [String] {
        guard let key = key, let saveStr = saveStr else {
            return [String]()
        }
        let usde = UserDefaults.standard
        // 是文件
        if var strs = usde.object(forKey: key) as? [String], !strs.isEmpty {
            if !strs.contains(saveStr) {
                strs.append(saveStr)
            }
            
            if let oldIdx = strs.firstIndex(of: saveStr) {
                strs.remove(at: oldIdx)
            }
            strs.insert(saveStr, at: 0)
            usde.set(strs, forKey:key)
            return strs
        }
        usde.set([saveStr], forKey: key)
        return [saveStr]
    }
    
    /// 文件夹存在不
    static func isFolderExists(_ folderPath: String) -> Bool {
        let fileManager = FileManager()
        var isDir: ObjCBool = false
        return fileManager.fileExists(atPath: folderPath, isDirectory: &isDir) && isDir.boolValue
    }
    /// 文件存在不
    static func isFileExists(_ filePath: String) -> Bool {
        let fileManager = FileManager()
        var isDir: ObjCBool = false
        return fileManager.fileExists(atPath: filePath, isDirectory: &isDir) && !isDir.boolValue
    }
    static func removeFolderAtPath(_ folderPath: String) {
        if isFolderExists(folderPath) {
            do {
                try FileManager().removeItem(at: URL(fileURLWithPath: folderPath))
            } catch {
                print("删除文件夹失败：\(error)")
            }
        }
    }
    static func createFolder(_ folderPath: String) {
        if !isFolderExists(folderPath) {
            do {
                try FileManager().createDirectory(at: URL(fileURLWithPath: folderPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建文件夹失败：\(error)")
            }
        }
    }
    
    /// 功能：选择文件夹
    static func chooseFolder(for window: NSWindow?, completionHandler handler: @escaping ((String) -> Void)) {
        guard let window = window else {
            return
        }
        let panel:NSOpenPanel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.resolvesAliases = true
        
        panel.beginSheetModal(for: window) { (response) in
            if response == .OK, let folderPath = panel.urls.first?.path, !folderPath.isEmpty {
                handler(folderPath)
            }
        }
    }
    static func showAlter(msg: String?) {
        guard let msg = msg else {
            return
        }

        let alert = NSAlert()
        
        alert.messageText = "Something went wrong"
        
        alert.informativeText = msg
        
        alert.alertStyle = NSAlert.Style.warning
        
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
}
