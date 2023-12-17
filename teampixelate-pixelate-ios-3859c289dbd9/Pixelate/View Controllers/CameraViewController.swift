//
//  CameraViewController.swift
//  Pixelate
//
//  Created by Taneja-Mac on 13/08/18.
//  Copyright © 2018 Taneja-Mac. All rights reserved.
//

import UIKit
import Gallery

enum PixelateMode: String {
    case auto = "Auto"
    case manual = "Manual"
}

enum PixelateManualMode: String {
    case iso = "ISO"
    case exposure = "Exposure"
}

class CameraViewController: UIViewController, GalleryControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraSourceButton: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var isoButton: UIButton!
    @IBOutlet weak var exposureButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var pixelateDataButton: UIButton!
    @IBOutlet weak var pixelateDataCollectionView: UICollectionView!
    
    var cameraController: CameraController!
    var selectedImage: UIImage?
    var imageConfig: ImageConfiguration?
    var pixelateMode: PixelateMode = .auto
    var pixelateManualMode: PixelateManualMode?
    var dataSource: CameraControllerDataSource?
    var delegate: CameraControllerDelegate?
    var pixelateDataSource: PixelateManualModeDataSource?
    var pixelateData: [PixelateData] = [PixelateData]()
    var selectedPixelateData: PixelateData?
    var metaData: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initializeView() {
        self.setUpViews()
        self.initializeNetworkPixelateData()
        self.cameraController = CameraController()
        self.dataSource = self.cameraController
        self.delegate = self.cameraController
        self.pixelateDataSource = self.cameraController
        self.addSwipeUpGesture()
        cameraController.prepare { (error:Error?) in
            error != nil ? self.showError() : try! self.cameraController.displayPreview(on: self.view)
        }
    }
    
    fileprivate func initializeNetworkPixelateData() {
        ModelFactory.pixelateData().add(PixelateData(dictionary: ["gps":"73.204496,22.298450"])) { (error:NSError?, result:Any?) in
            let resultDic = result as? [String:Any] ?? [String:Any]()
            let pixelateArrayData = resultDic["object"] as? [[String:Any]]
            self.pixelateData = PixelateData.toArray(pixelateArrayData)
            self.pixelateDataButton.isHidden = false
            self.pixelateDataCollectionView.reloadData()
        }
    }
    
    fileprivate func setUpViews() {
        self.modeButton.borderMe(thickness: 2.5)
        self.modeButton.borderColor(color: .white)
        self.isoButton.borderMe(thickness: 2.5)
        self.isoButton.borderColor(color: .white)
        self.exposureButton.borderMe(thickness: 2.5)
        self.exposureButton.borderColor(color: .white)
        self.pixelateDataButton.borderMe(thickness: 2.5)
        self.pixelateDataButton.borderColor(color: .white)
    }
    
    fileprivate func addSwipeUpGesture() {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(CameraViewController.swipeUpGestureRecogonized))
        swipeUpGesture.direction = .up
        self.view.addGestureRecognizer(swipeUpGesture)
    }
    
    @objc func swipeUpGestureRecogonized() {
        let gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = [.imageTab]
        self.present(gallery, animated: true, completion: nil)

    }
    
    fileprivate func showError() {
        // show error 
    }
    
    @IBAction func modeButtonClicked(_ sender: Any) {
        self.pixelateMode == .auto ? self.activateManualMode() : self.activateAutoMode()
    }
    
    fileprivate func activateAutoMode() {
        self.pixelateMode = .auto
        self.dataSource?.switchToAutoMode()
        self.isoButton.isHidden = true
        self.exposureButton.isHidden = true
        self.sliderView.isHidden = true
//        self.pixelateDataButton.isHidden = true
        self.modeButton.setTitle("M", for: .normal)
    }
    
    fileprivate func activateManualMode() {
        self.pixelateMode = .manual
        self.dataSource?.switchToManualMode()
        self.isoButton.isHidden = false
        self.exposureButton.isHidden = false
//        self.pixelateDataButton.isHidden = false
        self.modeButton.setTitle("A", for: .normal)
        
    }
    @IBAction func pixelateDataButtonClicked(_ sender: Any) {
        self.pixelateData.count > 0 ? self.showNetworkPixelateData() : Alert.shared.show(self, alert: "No pixelate data found")
    }
    
    fileprivate func showNetworkPixelateData() {
        self.sliderView.isHidden = true
        self.pixelateDataCollectionView.isHidden = false
        self.captureButton.isHidden = true
        self.modeButton.isHidden = true
        self.view.bringSubviewToFront(self.pixelateDataCollectionView)
    }
    
//    Collection View Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pixelateData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PixelateDataCell", for: indexPath) as! PixelateDataCollectionViewCell
        cell.setData(self.pixelateData[indexPath.section])
        return cell
    }
    
//    Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.sliderView.isHidden = true
        self.pixelateDataCollectionView.isHidden = true
        self.captureButton.isHidden = false
        self.modeButton.isHidden = false
        self.selectedPixelateData = self.pixelateData[indexPath.section]
        self.selectedPixelateData?.iso != nil ? self.dataSource?.setISO(Float(self.selectedPixelateData!.iso!) ?? 0.00) : ()
        self.selectedPixelateData?.shutterSpeed != nil ? self.dataSource?.setExposureDuration(Float(self.selectedPixelateData!.shutterSpeed!) ?? 0.00) : ()
    }
    
    @IBAction func captureButtonClicked(_ sender: Any) {
        self.cameraController.captureImage { (image:UIImage?, imageConfig: ImageConfiguration?, pixelateData: PixelateData?, metaData: [String:Any]?, error:Error?) in
            error == nil && image != nil ? self.storeImage(image!, imageConfig: imageConfig ?? ImageConfiguration(dictionary: [:]), pixelateData: pixelateData ?? PixelateData(dictionary: [:]), metaData: metaData ?? [:]) : self.showError()
        }
    }
    
    fileprivate func storeImage(_ image: UIImage, imageConfig: ImageConfiguration, pixelateData: PixelateData, metaData: [String:Any]) {
        pixelateData.mode = self.pixelateMode.rawValue
        self.selectedImage = image
        self.imageConfig = imageConfig
        self.selectedPixelateData = pixelateData
        self.metaData = metaData
        self.performSegue(withIdentifier: "CameraImageSegue", sender: self)
    }
    
    @IBAction func cameraSourceButtonClicked(_ sender: Any) {
        do { try self.cameraController.switchCameras() }
        catch { print(error) }
    }
    
    @IBAction func flashButtonClicked(_ sender: Any) {
        self.cameraController.flashMode == .auto ? self.setFlashOn() : self.cameraController.flashMode == .on ? self.setFlashOff() : self.setFlashAuto()
    }
    
    fileprivate func setFlashAuto() {
        self.cameraController.flashMode = .auto
        self.flashButton.setImage(UIImage(named: "flash-auto"), for: .normal)
    }
    
    fileprivate func setFlashOn() {
        self.cameraController.flashMode = .on
        self.flashButton.setImage(UIImage(named: "flash-on"), for: .normal)
    }
    
    fileprivate func setFlashOff() {
        self.cameraController.flashMode = .off
        self.flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
    }
    
    @IBAction func isoButtonClicked(_ sender: Any) {
        self.minValueLabel.text = "1"//"\(self.pixelateDataSource?.getMinISO() ?? 0.00)"
        self.maxValueLabel.text = "10"//"\(self.pixelateDataSource?.getMaxISO() ?? 0.00)"
        self.sliderView.isHidden = !self.sliderView.isHidden
        self.pixelateDataCollectionView.isHidden = true
        self.captureButton.isHidden = false
        self.pixelateManualMode = .iso
    }
    
    @IBAction func exposureButtonClicked(_ sender: Any) {
        self.minValueLabel.text = "1"//"\(self.pixelateDataSource?.getMinExposureDuration().value ?? Int64(0.00))"
        self.maxValueLabel.text = "10"//"\(self.pixelateDataSource?.getMaxExposureDuration().value ?? Int64(0.00))"
        self.sliderView.isHidden = !self.sliderView.isHidden
        self.pixelateDataCollectionView.isHidden = true
        self.captureButton.isHidden = false
        self.pixelateManualMode = .exposure
    }
    
    
    @IBAction func didSlideSlider(_ sender: Any, forEvent event: UIEvent) {
        let value = (sender as! UISlider).value
        self.pixelateManualMode == .iso ? self.dataSource?.setISO(value) : self.dataSource?.setExposureDuration(value)
    }
    
    
    // Gallery Delegate
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        images[0].resolve(completion: { (image:UIImage?) in
            self.dismiss(animated: false, completion: {
                self.selectedImage = image
                self.performSegue(withIdentifier: "CameraImageSegue", sender: nil)
            })
        })
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("Not Allowed.")
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        print("Not Allowed.")
    }
    func galleryControllerDidCancel(_ controller: GalleryController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        segue.identifier == "CameraImageSegue" ? self.showEditImageViewController(segue: segue) : self.showGalleryViewController()
    }
 
    func showGalleryViewController() {
        
    }
    
    func showEditImageViewController(segue: UIStoryboardSegue) {
        let vc = segue.destination as! EditImageViewController
        vc.image = self.selectedImage
        vc.imageConfig = self.imageConfig
        vc.imagePixelateData = self.selectedPixelateData
        vc.metaData = self.metaData
    }
}
