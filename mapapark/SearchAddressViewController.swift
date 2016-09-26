//
//  SearchAddressViewController.swift
//  mapapark
//
//  Created by Christian Axel Waltier Barraza on 9/23/16.
//  Copyright © 2016 Christian Axel Waltier Barraza. All rights reserved.
//

import UIKit

protocol LocalizationDelegate
{
    func locate(lon:Double, lat:Double, title:String)
}

class SearchAddressViewController: UITableViewController
{
    
    var searchResults: [String]!
    var delegate: LocalizationDelegate!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.dismiss(animated: true, completion: nil)
        
        let completeAddress: String! = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.symbols)
        let stringURL  = "https://maps.googleapis.com/maps/api/geocode/json?address=\(completeAddress!)&sensor=false"
        let url = URL(string: stringURL )
        let request = URLRequest(url: url! as URL)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data,response,error) -> Void in
        
            do
            {
                if data != nil
                {
                    let dictionaryRoot = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    
                    let results = (dictionaryRoot["results"] as! NSArray)[0] as! NSDictionary
                    let geometry = results["geometry"] as! NSDictionary
                    let location = geometry["location"] as! NSDictionary
                    
                    
                    let latitude = location["lat"] as! Double
                    let longitude = location["lng"] as! Double
                    
                    self.delegate.locate(lon: longitude, lat: latitude, title: self.searchResults[indexPath.row])

                 }
            }
            catch
            {
                print("Intentelo nuevamente")
            }
        })
    
        task.resume()
    }
    
    
    
    func reloadDataWithArray(array:[String])
    {
        self.searchResults = array
        self.tableView.reloadData()
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
