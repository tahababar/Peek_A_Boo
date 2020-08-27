//
//  ViewController.swift
//  SeeFood-CoreML
//

//

import UIKit
import CoreML
import Vision   //to deal with pictures and camera

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     //these 2 protocols are required for camera functionality
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answer: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
     //created this function to detect the image using MLImage and CoreML
    func detect(image: CIImage) {
        
        // Load the ML model through its generated class //creating a new model for image analysis
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("can't load ML model")
        }
        //creating request of detector
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            
                DispatchQueue.main.async {
                    print(topResult.identifier);
                    self.answer.text = topResult.identifier.capitalized;
                }
        }
        //to link image with detector to get final results
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    //a function from protocol
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            //imageView.image = image       //assigning that image to our image view
            imagePicker.dismiss(animated: true, completion: nil)
            //to get rid of imagePicker after all this is done

            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            detect(image: ciImage)
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary //to allow camera functionality //do .camera if u want to access photos from photo library
        imagePicker.allowsEditing = false //to disable editing on pictures by users
        present(imagePicker, animated: true, completion: nil)  //to open camera
    }
    
}


//use info.plist, add privacy permissions for camera and/or photo library.
