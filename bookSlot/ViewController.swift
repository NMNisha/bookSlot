//
//  ViewController.swift
//  bookSlot
//
//  Created by Mitosis on 07/03/17.
//  Copyright © 2017 Mitosis. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {

    //Initialise Location manager
    var manager = CLLocationManager()
   
    
    //IBOutlets
    
    @IBOutlet var search: UIButton!
    @IBOutlet var address: UITextField!
    
    
    //Initialise image slides
    @IBOutlet var myImage: UIImageView!
    var slide: Int = 0
    let animationDuration: TimeInterval = 1.0
    let switchingInterval: TimeInterval = 15
    var slides = [UIImage(named:"slide1")!,UIImage(named:"slide2")!,UIImage(named:"slide3")!, UIImage(named:"slide4")!,UIImage(named:"slide5")!,UIImage(named:"slide6")!]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load Location Search
        manager = CLLocationManager()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        
        
        search.layer.cornerRadius = 10
        //Load Images slides
        animateImageView()

        myImage.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_gesture:)))
        
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        myImage.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        myImage.addGestureRecognizer(swipeLeft)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
    }

    @IBAction func detectLocation(_ sender: AnyObject) {
                self.manager.startUpdatingLocation()
        
    }
    
    //Functions for Location Search
 func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
        
            let userLocation = location.coordinate
            print(userLocation)
        self.manager.stopUpdatingLocation()
            reverseGeocodeCoordinate(userLocation)
        }
        
    }
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            if let address = response?.firstResult() {
                let lines = address.lines
                self.address.text = lines?.joined(separator: "\n")

                print(coordinate)
                let latitude = coordinate.latitude
                let longitude = coordinate.longitude
                UserDefaults.standard.set(latitude, forKey: "latitude")
                UserDefaults.standard.set(longitude, forKey: "longitude")
             UserDefaults.standard.synchronize()
            }
        }
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
       
       let UserSearchLocation = place.coordinate
        print(UserSearchLocation)
        reverseGeocodeCoordinate(UserSearchLocation)
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    
    @IBAction func didType(_ sender: AnyObject) {

    let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    func  displayMyAlert(_ userMessage:String)
    {
        let myAlert=UIAlertController(title:"Alert",message: userMessage,preferredStyle: UIAlertControllerStyle.alert);
        let okAction=UIAlertAction(title:"ok",style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
    }
  
   
    @IBAction func didSearch(_ sender: AnyObject) {
        let addressField = address.text
        if (addressField?.isEmpty )!{
            displayMyAlert("Please Enter Your Location")
        }
        else{
            performSegue(withIdentifier: "searched", sender: self)
    }
    }
    
//To direct to another ViewController
 func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
                    self.navigationController!.pushViewController(destViewController, animated: true)
    
    }
  
//Functions for image slide and gestures
    
   
    func animateImageView() {
        if(slide  < 5){
            CATransaction.begin()
            
            CATransaction.setAnimationDuration(animationDuration)
            CATransaction.setCompletionBlock {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval)
                {
                    
                    self.animateImageView()
                }
            }
            
            let transition = CATransition()
            // transition.type = kCATransitionFade
            
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            
            myImage.layer.add(transition, forKey: kCATransition)
            myImage.image = slides[slide]
            
            CATransaction.commit()
            print("\(slide)")
            slide+=1
            
        }
        else if(slide > 5 || slide == 5 ){
            slide = 0
            CATransaction.begin()
            
            CATransaction.setAnimationDuration(animationDuration)
            CATransaction.setCompletionBlock {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval)
                {
                    
                    self.animateImageView()
                }
            }
            
            let transition = CATransition()
            // transition.type = kCATransitionFade
            
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            
            myImage.layer.add(transition, forKey: kCATransition)
            myImage.image = slides[slide]
            
            CATransaction.commit()
            print("\(slide)")
            slide+=1
            
        }
        
    }
    func swiped(_gesture: UIGestureRecognizer) {
        
        if let swipeGesture = _gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right :
                if (self.slide == 0) {
                    
                    self.slide = 5
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(animationDuration)
                    let transition = CATransition()
                    // transition.type = kCATransitionFade
                    
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    
                    myImage.layer.add(transition, forKey: kCATransition)
                    myImage.image = slides[slide]
                    CATransaction.commit()
                    
                    print("\(slide)")
                }
                else if(slide > 5)
                {
                    slide = 5
                    self.slide-=1
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(animationDuration)
                    let transition = CATransition()
                    // transition.type = kCATransitionFade
                    
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    
                    myImage.layer.add(transition, forKey: kCATransition)
                    myImage.image = slides[slide]
                    CATransaction.commit()
                    print("\(slide)")
                    
                }
                    
                else
                {
                    self.slide-=1
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(animationDuration)
                    let transition = CATransition()
                    // transition.type = kCATransitionFade
                    
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    
                    myImage.layer.add(transition, forKey: kCATransition)
                    myImage.image = slides[slide]
                    CATransaction.commit()
                    print("\(slide)")
                }
                
                
            case UISwipeGestureRecognizerDirection.left:
                
                if (self.slide == 5) {
                    
                    self.slide = 0
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(animationDuration)
                    let transition = CATransition()
                    // transition.type = kCATransitionFade
                    
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    
                    myImage.layer.add(transition, forKey: kCATransition)
                    myImage.image = slides[slide]
                    CATransaction.commit()
                    print("\(slide)")
                }
                else if(self.slide < 5){
                    
                    self.slide+=1
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(animationDuration)
                    let transition = CATransition()
                    // transition.type = kCATransitionFade
                    
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    
                    myImage.layer.add(transition, forKey: kCATransition)
                    myImage.image = slides[slide]
                    CATransaction.commit()
                    print("\(slide)")
                    
                }
                
            default:
                break //stops the code/codes nothing.
                
            }
        }
    }

}




