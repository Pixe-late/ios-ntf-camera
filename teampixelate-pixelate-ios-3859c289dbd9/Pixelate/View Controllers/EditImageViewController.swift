//
//  EditImageViewController.swift
//  Pixelate
//
//  Created by Taneja-Mac on 03/09/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import UIKit
import Photos
import ImageIO
import MobileCoreServices

class EditImageViewController: UIViewController {

    @IBOutlet weak var selectedImageView: UIImageView!
    
    var image: UIImage?
    var imageConfig: ImageConfiguration?
    var imagePixelateData: PixelateData?
    var metaData: [String:Any]?
    var fileManager: FileManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.intializeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func intializeView() {
        self.fileManager = FileManager.default
        self.initializeImageConfig()
    }
    
    fileprivate func initializeImageConfig() {
        self.selectedImageView.image = self.image
        self.imageConfig?.filetype = "jpg"
        let scale = self.image?.scale ?? 1
        self.imageConfig?.dimension?.height = "\((self.image?.size.height ?? 1) * scale)"
        self.imageConfig?.dimension?.width = "\((self.image?.size.width ?? 1) * scale)"
        self.imageConfig?.file_size = self.getFileSize()
        self.imageConfig?.device = UIDevice.current.type.rawValue
        self.imageConfig?.location?.coordinates = ["73.204496", "22.298450"]
        self.imageConfig?.location?.type = "Point"
        self.imageConfig?.filter = "default"
        self.imageConfig?.created_at = Formatter.iso8601.string(from: Date())
        self.imagePixelateData?.gps = "73.204496,22.298450" // hard coding location for now
        self.imagePixelateData?.imageNumber = "\(Int.random(in: 0 ..< 1000))"
    }
    
    fileprivate func getFileSize() -> String {
        let imgData = self.image!.jpegData(compressionQuality: 1.0)
        let bfc = ByteCountFormatter()
        bfc.allowedUnits = [.useMB]
        bfc.countStyle = .file
        return bfc.string(fromByteCount: Int64(imgData?.count ?? 1))
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        Loader.shared.start("Uploading....")
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).last?.appending("/image.jpg") ?? ""
        let cfPath = CFURLCreateWithFileSystemPath(nil, filePath  as CFString, CFURLPathStyle.cfurlposixPathStyle, false)
        let destination = CGImageDestinationCreateWithURL(cfPath!, kUTTypeJPEG, 1, nil)
        CGImageDestinationAddImageAndMetadata(destination!, self.image!.cgImage!, nil, self.metaData! as! CFDictionary)
        CGImageDestinationFinalize(destination!)
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
            self.sendDataToServer()
        }
    }
    
    fileprivate func sendDataToServer() {
        ModelFactory.networkPixelateData().add(self.imagePixelateData!) { (error:NSError?, resultPixelate:Any?) in
            ModelFactory.imageConfiguration().add(self.imageConfig!) { (error: NSError?, result: Any?) in
                let resultObj = result as? [String:Any]
                Loader.shared.stop()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
