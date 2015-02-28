//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by daniel on 11/8/14.
//  Copyright (c) 2014 DK. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {    // does not conform to protocol collectionView Datasource

    var thisFeedItem: FeedItem! //!really important
    
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    
    var filters: [CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()    // ios 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
        // using filters 
        
        filters = photoFilters()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UICollectionView DataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        if cell.imageView.image == nil {

            // implementation Filters (after refactor with GCD, bring it back)
            cell.imageView.image = placeHolderImage
            
            // refactor with GCD async
            let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            dispatch_async(filterQueue, { () -> Void in
                
                // replace cache
                
                let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])     // thisFeedItem.image
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
                
                // tutorial bug, always show the first image since cache is wrong
//                let filterImage = self.getCachedImage(indexPath.row)
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    cell.imageView.image = filterImage
//                })
                
            })
            
            //        cell.imageView.image = filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])

        }
        
        return cell
    }
    
    // UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        createUIAlertController(indexPath)
        
    }

    
    // helper function composite filters
    
    func photoFilters() -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
    }
    
    // using filters
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        // refactor here, actually see the spped of iamge.
        let finalImage = UIImage(CGImage: cgImage)  // bring it back
//        let finalImage = UIImage(CIImage: filteredImage)   // delay show up speed, very slow
        
        return finalImage
    }
    
    
    func saveFilterToCoreData (indexPath: NSIndexPath, caption: String) {
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        
        // saving captions
        self.thisFeedItem.caption = caption
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    // re-direct
    func shareToFacebook (indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        let photos:NSArray = [filterImage]      //NSArray from objC, array from swift
        var params = FBPhotoParams()
        params.photos = photos
        
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            if (result? != nil) {
                println(result)
            } else {
                println(error)
            }
        }

    }
    
    // caching functions
    
    func cacheImage(imageNumber: Int) {
        var fileName = String(imageNumber)
        var uniquePath = tmp.stringByAppendingPathComponent(fileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage (imageNumber: Int) -> UIImage {
        var fileName = String(imageNumber)
        var uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)
        }
        return image
    }
    
    // UIAlertController helper functions
    
    func createUIAlertController (indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        var text: String
        
        let textField = alert.textFields![0] as UITextField
        
        if textField.text != nil {
            text = textField.text
        }
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            // Remember when we are working inside Closures, we must use the keyword "self".
            self.shareToFacebook(indexPath)
            
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            // Remember when we are working inside Closures, we must use the keyword "self".
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
        }
        alert.addAction(cancelAction)

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
