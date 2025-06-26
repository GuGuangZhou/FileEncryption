//
//  ViewController.swift
//  FileEncryption
//
//  Created by jiangShuiQing 的MacBok on 2025/6/26.
//

import UIKit

class ViewController: UIViewController {
    let PASSWORD = "fwe&*^123213"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 解密plist
        var filePath = mainBundleFilePath("myPlist")
        if let myPlist = decodeResourceFile(path: filePath, type: "plist") as? [String: Any] {
            print(myPlist)
        }
        
        // 解密image
        filePath = mainBundleFilePath("myImage")
        if let myImage = decodeResourceFile(path: filePath, type: "image") as? UIImage {
            print(myImage)
        }
        
        // 解密html
        filePath = mainBundleFilePath("baidu")
        if let html = decodeResourceFile(path: filePath, type: "string") as? String {
            print(html)
        }
        
        // 解密MP3
        filePath = mainBundleFilePath("button")
        let mp3Data = decodeResourceFile(path: filePath, type: nil)
    }
    
    func mainBundleFilePath(_ fileName: String) -> String {
        return Bundle.main.path(forResource: fileName, ofType: nil) ?? ""
    }
    
    func decodeResourceFile(path filePath: String, type fileType: String?) -> Any? {
        guard !filePath.isEmpty else { return nil }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let decryptedData = CCOpenSSLHelper.decryptData(data, password: PASSWORD) else {
            return nil
        }
        
        switch fileType {
        case "plist":
            return try? PropertyListSerialization.propertyList(from: decryptedData, options: [], format: nil)
        case "string":
            return String(data: decryptedData, encoding: .utf8)
        case "image":
            return UIImage(data: decryptedData)
        default:
            return decryptedData
        }
    }
}
