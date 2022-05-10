//
//  ViewController.swift
//  unZipImg
//
//  Created by dfpo on 2021/1/24.
//

import Cocoa
import ZIPFoundation

public class ReNameVC: NSViewController {
    /// 输入框
    @IBOutlet weak var m_textField: NSSearchField!
    private var imgNames = [String]()
    public static func vc() -> ReNameVC {
        return ReNameVC(nibName: "ReNameVC", bundle: Util.getLibBundle())
    }
    @IBOutlet private weak var m_tableView: NSTableView!
    lazy var m_xcassetsFolderPaths = [String]()
    
    @IBOutlet weak var m_listBox: NSComboBox!
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "图片zip重命名"
        
        // 回显历史的重命名
        imgNames.append(contentsOf: Util.getStrsFromUserDefaults(key: "zip_img_names"))
        m_tableView.reloadData()
        
        // 给table的cell添加右键菜单
        let menu = NSMenu()
        menu.delegate = self
        m_tableView.menu = menu
        
        m_listBox.dataSource = self
        m_listBox.delegate  = self
        m_xcassetsFolderPaths.append(contentsOf: Util.getStrsFromUserDefaults(key: "spFolderPath"))
        m_listBox.reloadData()
        if !m_xcassetsFolderPaths.isEmpty {
            m_listBox.selectItem(at: 0)
        }

        // 不要搜索图标
        (m_textField.cell as? NSSearchFieldCell)?.searchButtonCell = nil
    }
     
     
    func unZipAtURL(_ zipFileURL: URL){
       
        /// 指定了路径
        if  m_listBox.stringValue.contains(".xcassets") {
            // 直接解压到文件夹xcassets，同时生成Contents.json
            zipToXcassetsFolder(zipFileURL)
        } else {
            // zip在哪里就在哪里解压
            zipToDefaultFolder(zipFileURL)
        }
    }
    
    func zipToXcassetsFolder (_ zipFileURL: URL) {
        let fm = FileManager()
        let unzipFolderPath =  m_listBox.stringValue
        let imgNewName = m_textField.stringValue
        // 文件夹下有没有同名 的 te.imageset
        let findFolderPath = "\(unzipFolderPath)/\(imgNewName).imageset"
        if Util.isFolderExists(findFolderPath) {
            Util.showAlter(msg: "有同名了，换个名字吧")
            return
        }
        Util.createFolder(findFolderPath)
        let findFolderURL = URL(fileURLWithPath: findFolderPath)
            do {
                try fm.unzipItem(at: zipFileURL, to: findFolderURL)
                let secStr = "@2x.png"
                let thrStr = "@3x.png"
                guard let fileNames = fm.enumerator(atPath: findFolderURL.path)?.allObjects as? [String], !fileNames.isEmpty else {
                    return
                }
                var ContentsJson: String?
                if let jsonFilePath = Util.getLibBundle()?.path(forResource: "Contents", ofType: "json") {
                    do {
                        ContentsJson = try String(contentsOfFile: jsonFilePath, encoding: .utf8)
                    } catch {
                        print("操作遇到了错误：\(error.localizedDescription)")
                    }
                }
                for element in fileNames  {
                    
                    if !element.contains(imgNewName) && (element.hasSuffix(secStr) || element.hasSuffix(thrStr)) {
                        var pngFileURL = findFolderURL
                        pngFileURL.appendPathComponent(element)
                        
                        let fileName = element.hasSuffix(secStr) ? (imgNewName+secStr) : (imgNewName+thrStr)
                        let newPngFileURL = findFolderURL.appendingPathComponent(fileName)
                             do {
                               try fm.moveItem(at: pngFileURL, to: newPngFileURL)
    
                               
                               let newNames = Util.saveStrToStrArr(key: "zip_img_names" , saveStr: imgNewName )
                               if !newNames.isEmpty {
                                   imgNames.removeAll()
                                   imgNames.append(contentsOf: newNames)
                                   m_tableView.reloadData()
                               }
                                 if element.hasSuffix(secStr) {
                                     ContentsJson = ContentsJson?.replacingOccurrences(of: "编组 5@2x.png", with: fileName)
                                 }
                                 else if element.hasSuffix(thrStr) {
                                     ContentsJson = ContentsJson?.replacingOccurrences(of: "编组 5@3x.png", with: fileName)
                                 }
                                 
                           } catch {
                               print("操作遇到了错误：\(error.localizedDescription)")
                           }
                        
                         
                    } else {
                        print(element)
                    }
                     
                }
                // 写入content.json
                if let json = ContentsJson, !json.isEmpty {
                    do {
                         try Data(json.utf8).write(to: URL(fileURLWithPath: "\(findFolderPath)/Contents.json"), options: .atomic)
                    } catch {
                        print(error)
                    }
                }
                // 删除zip文件
                delZip(zipFileURL, isNeedDelZip: false)
            } catch {
                print("操作遇到了错误：\(error)")
            }
        
    }
    private func delZip(_ zipFileURL:URL?, isNeedDelZip: Bool?) {
        if let zipFileURL = zipFileURL, let isNeedDelZip = isNeedDelZip, isNeedDelZip {
            do {
                try FileManager.default.removeItem(atPath: zipFileURL.path)
            } catch {
                print("操作遇到了错误：\(error)")
            }
        }
    }
    func zipToDefaultFolder(_ zipFileURL: URL){
        let fm = FileManager()
        
        let unzipFolderPath =  zipFileURL.pathComponents.dropLast().joined(separator: "/").dropFirst().appending("/unzipData")
        
        let unzipFolderURL = URL(fileURLWithPath: unzipFolderPath)
        
        let unzipTempFolderPath =  zipFileURL.pathComponents.dropLast().joined(separator: "/").dropFirst().appending("/unzipDataTemp")
        let unzipTempFolderURL = URL(fileURLWithPath: unzipTempFolderPath)
        
         
            Util.removeFolderAtPath(unzipTempFolderPath)
            Util.createFolder(unzipTempFolderPath)
            
            if Util.isFolderExists(unzipFolderPath) {
                // 文件夹存在
            } else {
                Util.createFolder(unzipFolderPath)
            }
         
        let imgNewName = m_textField.stringValue
       do {
            // 解压切换zip到 下载下的unzipData文件夹
            try fm.unzipItem(at: zipFileURL, to: unzipTempFolderURL)
            let secStr = "@2x.png"
            let thrStr = "@3x.png"
            
            while let element = fm.enumerator(atPath: unzipTempFolderURL.path)?.nextObject() as? String {
                
                if element.hasSuffix(secStr) || element.hasSuffix(thrStr) {
                    var pngFileURL = unzipTempFolderURL
                    pngFileURL.appendPathComponent(element)
                    
                    let fileName = element.hasSuffix(secStr) ? (imgNewName+secStr) : (imgNewName+thrStr)
                    let newPngFileURL = unzipTempFolderURL.appendingPathComponent(fileName)
                    let newPngFileURL2 = unzipFolderURL.appendingPathComponent(fileName)
                    do {
                        try fm.moveItem(at: pngFileURL, to: newPngFileURL)
                        try fm.moveItem(at: newPngFileURL, to: newPngFileURL2)
                        
                        
                        let newNames = Util.saveStrToStrArr(key: "zip_img_names" , saveStr: imgNewName )
                        if !newNames.isEmpty {
                            imgNames.removeAll()
                            imgNames.append(contentsOf: newNames)
                            m_tableView.reloadData()
                        }
                    } catch {
                        print("操作遇到了错误：\(error.localizedDescription)")
                    }
                }
                 
            }
            
           // 删除zip文件
           delZip(zipFileURL, isNeedDelZip: false)
        } catch {
            print("操作遇到了错误：\(error)")
        }
    }
    
    @IBAction func doubleAction(_ sender: NSTableView) {
        let idx = sender.selectedRow
        if idx >= 0, idx < imgNames.count {
            m_textField.stringValue = imgNames[idx]
        }
       
    }
    // 指定文件病例
    @IBAction func chooseFolder(_ sender: NSButton) {
        
        Util.chooseFolder(for: view.window) { folderPath in
            if folderPath.contains(".xcassets") {
                let folderPaths = Util.saveStrToStrArr(key: "spFolderPath", saveStr: folderPath)
                
                if !folderPaths.isEmpty {
                    self.m_xcassetsFolderPaths.removeAll()
                    self.m_xcassetsFolderPaths.append(contentsOf: folderPaths)
                    self.m_listBox.reloadData()
                    if let desIdx = self.m_xcassetsFolderPaths.firstIndex(of: folderPath) {
                        self.m_listBox.selectItem(at: desIdx)
                    }
                }
            }
        }
    }
    
    @IBAction func clickClearBtn(_ sender: NSButton) {
        m_listBox.stringValue = ""
        UserDefaults.standard.set(nil, forKey: "spFolderPath")
        m_xcassetsFolderPaths.removeAll()
        m_listBox.reloadData()
    }
}
extension ReNameVC: FileDragDelegate {
    func didFinishDrag(_ URLs: [URL]) {
        
        let fileURL = URLs[0]
        let ext = fileURL.pathExtension
        switch ext {
        case "zip":
            unZipAtURL(fileURL)
        default:
            print(ext)
        }
    }
}
// MARK: - NSTableViewDataSource
extension ReNameVC: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return imgNames.count
    }
}
// MARK: - NSTableViewDelegate
extension ReNameVC: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let imgName = imgNames[row]
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("his"), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = imgName
            return cell
        }
        return nil
    }
}
// MARK: - NSMenuDelegate
extension ReNameVC: NSMenuDelegate {
    public func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        // 在这里动态添加 menu item
        menu.addItem(NSMenuItem(title: "删除引用", action: #selector(handleDeleteClickedRow), keyEquivalent: ""))
    }
    @objc func handleDeleteClickedRow(){
        let idx = m_tableView.selectedRow
        guard idx >= 0,
              m_tableView.clickedColumn >= 0,
              let row: NSTableRowView = m_tableView.rowView(atRow: idx, makeIfNecessary: false),
              let cellView = row.view(atColumn: m_tableView.clickedColumn) as? NSTableCellView  else {
                  return
              }
        
        //                刷新
        imgNames.remove(at: idx)
        m_tableView.reloadData()
        //                偏好同步
        UserDefaults.standard.set(imgNames, forKey: "zip_img_names")
       
    }
}
extension ReNameVC: NSComboBoxDataSource {
    public func comboBox(_ aComboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        guard index < m_xcassetsFolderPaths.count else {
            return nil
        }
        return m_xcassetsFolderPaths[index]
    }
    
    public func numberOfItems(in aComboBox: NSComboBox) -> Int {
        return m_xcassetsFolderPaths.count
    }
}
extension ReNameVC: NSComboBoxDelegate {
    public func comboBoxSelectionDidChange(_ notification: Notification) {
        if let comboBox = notification.object as? NSComboBox, comboBox === m_listBox {
            guard comboBox.indexOfSelectedItem < m_xcassetsFolderPaths.count else { return }
            
        }
    }
}
