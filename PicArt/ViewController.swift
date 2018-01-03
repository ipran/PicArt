//
//  ViewController.swift
//  PicArt
//
//  Created by Pranil on 10/11/17.
//  Copyright © 2017 pranil. All rights reserved.
//

import UIKit
import PKHUD

class ViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var styles = [String]()
    var draggingImageName = [String]()
    var selectedPoint       = CGPoint()
    var changinImageView = UIImageView()
    var imgView_width: CGFloat = CGFloat()
    var imgView_height: CGFloat = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        styles = ["celebration.jpg",
                  "fire.png",
                  "love.png",
                  "loveface.jpeg",
                  "thumbsup.png",
                  "tongeout.jpg",
                  "victory.png",
                  "feel.png",
                  "meh.jpg"
                   ]
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(mainViewPinched(sender:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc func mainViewPinched(sender: UIPinchGestureRecognizer) {
        if sender.state == .ended || sender.state == .changed {

            let currentScale = self.mainImageView.frame.size.width / self.mainImageView.bounds.size.width
            var newScale = currentScale*sender.scale

            if newScale < 1 {
                newScale = 1
            }
            if newScale > 9 {
                newScale = 9
            }

            let transform = CGAffineTransform(scaleX: newScale, y: newScale)

            self.changinImageView.transform = transform
            imgView_width = changinImageView.frame.width
            imgView_height = changinImageView.frame.height
            sender.scale = newScale

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return styles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CollectionViewCell
        
        let image = UIImage(named: styles[indexPath.row])
        cell.imageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        draggingImageName.append(styles[indexPath.row])
    }
    
    @IBAction func photoDownloadBtn(_ sender: Any) {
        getPhotoFromPhotoLibrary()
    }
    @IBAction func photoUploadBtn(_ sender: Any) {
    }
    
    override  func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?) {
        
        if imgView_width == 0.0 && imgView_height == 0.0{
            imgView_width = 50.0
            imgView_height = 50.0
        }
        
        let image = UIImage(named: draggingImageName[0])
        let touch = touches.first!
        selectedPoint = touch.location(in: self.view)
        changinImageView.image = image
        changinImageView.frame = CGRect(x: selectedPoint.x, y: selectedPoint.y, width: imgView_width, height: imgView_height)
        if mainImageView.image == nil{
            HUD.flash(HUDContentType.label("Oops! Upload an image first.."), onView: self.view)
        }
        else{
            mainImageView.addSubview(changinImageView)
        }
        
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with  event: UIEvent?) {
        let touch = touches.first!
        selectedPoint = touch.location(in: self.view)
        changinImageView.frame = CGRect(x: selectedPoint.x, y: selectedPoint.y, width: imgView_width, height: imgView_height)
        mainImageView.addSubview(changinImageView)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
    }

    
}


extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func getPhotoFromPhotoLibrary() {
        let camera = DSCameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        mainImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
}

