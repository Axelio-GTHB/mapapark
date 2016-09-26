//
//  ViewController.swift
//  mapapark
//
//  Created by Christian Axel Waltier Barraza on 9/22/16.
//  Copyright © 2016 Christian Axel Waltier Barraza. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Social

class MapViewController: UIViewController,CLLocationManagerDelegate,LocalizationDelegate, UISearchBarDelegate, GMSMapViewDelegate
{

    var locationManager = CLLocationManager()
    var searchAddressViewController:SearchAddressViewController!
    var resultsArray = [String]()
    
    var initialZoom = 16.0
    
    var marker:GMSMarker!
    
    var isStarted = false;
    var isConfirmed = false;
    
    var proximity = Proximity.none
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var buttonSearchAddress: UIButton!
    @IBOutlet weak var buttonConfirmation: UIButton!
    @IBOutlet weak var labelMeters: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.mapType = kGMSTypeNormal
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.mapView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.searchAddressViewController = SearchAddressViewController()
        self.searchAddressViewController.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // LOCALIZACION DE USUARIO
    
    // Esta funcion obtiene la localizaciòn del usuario, es delegado de CLLocationManager
    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!, zoom: Float(self.initialZoom))
        var distance = 1000.0;
        
        if(!isStarted)
        {
            self.mapView?.animate(to: camera)
            isStarted = true
        }
        
        if(isConfirmed && (self.marker != nil))
        {
            let selectedLocation = CLLocation(latitude: self.marker.position.latitude, longitude: self.marker.position.longitude)
            
            distance = selectedLocation.distance(from: userLocation!)
            
            if distance < 10
            {
                if(self.proximity != .m10)
                {
                    self.proximity = .m10
                    self.labelDistance.text = self.proximity.description
                    sendNotification()
                    sendTweet()
                }
            }
            else if distance < 50
            {
                if(self.proximity != .m50)
                {
                    self.proximity = .m50
                    self.labelDistance.text = self.proximity.description
                    sendNotification()
                }
            }
            else if distance < 100
            {
                if(self.proximity != .m100)
                {
                    proximity = .m100
                    self.labelDistance.text = self.proximity.description
                    sendNotification()
                    
                }
            }
            else if distance < 200
            {
                if(self.proximity != .m200)
                {
                    proximity = .m200
                    self.labelDistance.text = self.proximity.description
                    sendNotification()
                }
            }
            else
            {
                if(self.proximity != .outerLimit)
                {
                    proximity = .outerLimit
                    self.labelDistance.text = self.proximity.description
                    sendNotification()
                }
            }
            self.labelMeters.text = "\(Int(round(distance)))m"
        }
        
        //self.locationManager.stopUpdatingLocation()
    }
    
    // SELECCION DE MARCADOR POR DIRECCION
    
    // Esta función cumple con el delegado de SearchAddressViewController para poner la marca de una coordenada obtenida por una dirección
    func locate(lon: Double, lat: Double, title: String)
    {
        DispatchQueue.main.async
        {
            let position = CLLocationCoordinate2DMake(lat, lon)
            self.marker = GMSMarker(position: position)
            
            self.mapView.clear()
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(self.initialZoom))
            self.mapView.camera = camera
            
            self.marker.title = title
            self.marker.map = self.mapView
        }
    }
    
    func searchBar(_ searchBar:UISearchBar, textDidChange searchText:String)
    {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil, callback: { ( results, error:Error?) in
            
            self.resultsArray.removeAll()
            if results == nil
            {
                return
            }
            for result in results!
            {
                if let result = result as? GMSAutocompletePrediction
                {
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchAddressViewController.reloadDataWithArray(array: self.resultsArray)
        })
    }

    // SELECCION DE MARCADOR DIRECTA A MAPA
    
    func mapView(_:  GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        if(!isConfirmed)
        {
            mapView.clear()
        
            self.marker = GMSMarker(position: coordinate)
            self.marker.map = self.mapView
        }
    }
    
    
    // ACCIONES
    
    
    @IBAction func showSearchController()
    {
        let searchController = UISearchController(searchResultsController: self.searchAddressViewController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func startTracking()
    {
        if(buttonConfirmation.tag == 0)
        {
            if(self.marker != nil)
            {
                drawNearCircleMarker(marker: self.marker, meters: 200, color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.2))
                drawNearCircleMarker(marker: self.marker, meters: 100, color: UIColor(red: 1, green: 1, blue: 0, alpha: 0.3))
                drawNearCircleMarker(marker: self.marker, meters: 50, color: UIColor(red: 0, green: 0, blue: 1, alpha: 0.4))
                drawNearCircleMarker(marker: self.marker, meters: 10, color: UIColor(red: 0, green: 1, blue: 0.5, alpha: 0.5))
        
                self.locationManager.allowsBackgroundLocationUpdates = true

        
                isConfirmed = true
        
                self.buttonSearchAddress.isEnabled = false
            
                buttonConfirmation.tag = 1
                buttonConfirmation.setTitle("Terminar", for: .normal)
                labelDistance.text = "Calculando..."
                labelMeters.text = "...m"
            }
            else
            {
                let alert = UIAlertController(title: "Falta Objetivo", message: "Selecciona una ubicación en el mapa.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            stopTracking()
            restart()
            buttonConfirmation.tag = 0
        }
        
     
    }
    
    func drawNearCircleMarker( marker: GMSMarker, meters: CLLocationDistance, color: UIColor)
    {
        let center = marker.position
        let circle = GMSCircle(position: center, radius: meters)
        circle.fillColor = color
        circle.map = self.mapView
    }
    
    func stopTracking()
    {
        isConfirmed = false
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.buttonSearchAddress.isEnabled = true
        self.mapView.clear()
        self.marker = nil
    }
    
    func sendNotification()
    {
        let localNotification = UILocalNotification();
        localNotification.alertBody = self.proximity.description;
        localNotification.alertAction = "mapamark";
        localNotification.hasAction = true;
        UIApplication.shared.presentLocalNotificationNow(localNotification)

    }
    
    func restart()
    {
        buttonConfirmation.setTitle("Confirmar punto", for: .normal)
        labelDistance.text = "Selecciona un punto en el mapa"
        labelMeters.text = "...m"
    }
    
    func sendTweet()
    {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
        {
            
            let tweet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweet.setInitialText("He llegado a mi objetivo, lat: \(self.marker.position.latitude) lon: \(self.marker.position.longitude)")
            let googleMapURL = URL(string: "http://maps.google.com/maps?z=\(initialZoom)&t=m&q=loc:\(self.marker.position.latitude)+\(self.marker.position.longitude)")
            
            tweet.add(googleMapURL)
            self.present(tweet, animated: true, completion: nil)
            
        }
        else
        {
            
            let alert = UIAlertController(title: "Objetivo alcanzado", message: "Has llegado a tu objetivo, si quieres publicarlo en twitter necesitas hacer Login.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
   

}

