//
//  UserProfileViewController.swift
//  LineNinja
//
//  Created by David Sandor on 11/2/14.
//  Copyright (c) 2014 David Sandor. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileViewController : ResponsiveTextFieldViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var ChangePictureButton: UIButton!
    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var EmailAddress: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var SaveButton: UIButton!

    @IBAction func OnTouchChangePicture(sender: AnyObject) {
        
        var imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        }
        else
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        imagePickerController.allowsEditing = true
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.ProfileImageView.image = image
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.watchTextField(self.FirstName)
        self.watchTextField(self.LastName)
        self.watchTextField(self.EmailAddress)
        self.watchTextField(self.Password)
    }
    
    @IBAction func OnTouchSave(sender: AnyObject) {
        
        // init paramters Dictionary
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        // add addtionial parameters
        parameters["userId"] = "27"
        parameters["body"] = "This is the body text."
        
        // example image data
        let imageData = UIImagePNGRepresentation(self.ProfileImageView.image)
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = urlRequestWithComponents("http://localhost:8080/saveprofile", parameters: parameters, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
        }

        // http://stackoverflow.com/questions/26121827/uploading-file-with-parameters-using-alamofire
        //Alamofire.upload(.POST, "http://httpbin.org/post", self.ProfileImageView.image)
        
        /*
        var url = NSURL(string: "http://localhost:8080/saveprofile")
        var request = NSMutableURLRequest()
        
        request.URL = url
        request.HTTPMethod = "POST"
        request.HTTPBody = UIImageJPEGRepresentation(self.ProfileImageView.image, 0.5)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            println("uploaded image")
            
            if (error != nil)
            {
                println("error: " + error.localizedDescription)
            }
            else
            {
                println("No errors.")
            }
            
        })
        */
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "12345_ga_big_bonus_54321";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
}
