//
//  CountriesTVC.swift
//  NambaOne
//
//  Created by Kuba Kadyrbekov on 02.03.2018.
//  Copyright © 2018 Namba Soft OsOO. All rights reserved.
//

import UIKit

protocol CountriesDelegate{
    func didChooseCountry(country: Country)
}

class CountriesTVC: UITableViewController, UISearchResultsUpdating {

    var countries = [Country]()
    var firstLetter = [String]()
    var countryDict = [String: [Country]]()
    var allCountriesDict = [String: [Country]]()
    var delegate : CountriesDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Страны"
        registerCountryXib()
        self.generateAlphabetArray()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .minimal
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.sectionIndexColor = UIColor.gray
        self.tableView.sectionIndexBackgroundColor = .clear
        self.getCountries()
        self.generateAlphabetArray()
    }
    
    func getCountries(){
        if let path = Bundle.main.path(forResource: "countries", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                
                countries = [Country]()
                
                for line in data.components(separatedBy: .newlines){
                    
                    let countryDetails = line.split(separator: ";")

                    let country = Country()
                    
                    if countryDetails.count > 0{
                        country.flag = String(countryDetails[0])
                    }
                    
                    if countryDetails.count > 1{
                        country.isoNumber = String(countryDetails[1])
                    }
                    
                    if countryDetails.count > 2{
                        country.isoCode = String(countryDetails[2])
                    }
                    
                    if countryDetails.count > 3{
                        country.name = String(countryDetails[3])
                    }
                    
                    if countryDetails.count > 4{
                        country.mask = String(countryDetails[4])
                    }
                    
                    countries.append(country)
                }
            } catch let error{
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func registerCountryXib(){
        self.tableView.register(UINib(nibName: "CountriesTableViewCell", bundle: nil), forCellReuseIdentifier: "CountriesTableViewCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return firstLetter.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return firstLetter[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryDict[self.firstLetter[section]]!.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return firstLetter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountriesTableViewCell", for: indexPath) as! CountriesTableViewCell
        let countryKey = self.firstLetter[indexPath.section]
        cell.setupWithCountry(country: countryDict[countryKey]![indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let delegate = self.delegate{
            let countryKey = self.firstLetter[indexPath.section]
            let country = countryDict[countryKey]![indexPath.row]
            delegate.didChooseCountry(country: country)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func generateAlphabetArray(isUpdate: Bool = false){
        
        if isUpdate {
            self.firstLetter.removeAll()
            self.countryDict.removeAll()
        }
        if !countries.isEmpty{
            for country in self.countries {
                let fullName = country.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if fullName != ""{
                    let key = "\(fullName[fullName.startIndex])"
                    let lower = key.uppercased()
                    
                    if countryDict[lower] == nil {
                        self.firstLetter.append(lower)
                        countryDict[lower] = [country]
                    } else {
                        countryDict[lower]?.append(country)
                    }
                }
            }
            self.allCountriesDict = self.countryDict
            self.firstLetter.sort()
            self.tableView.reloadData()
        }
    }
    @IBAction func cancelButtonTaped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            if searchController.searchBar.text! != "" {
                self.countryDict.removeAll()
                self.firstLetter.removeAll()
                for (countryCode, countryArray) in allCountriesDict {
                    let arr = countryArray.filter( {$0.name.lowercased().components(separatedBy: " ").first!.contains(word: searchController.searchBar.text!.lowercased())})
                    if arr.isEmpty {
                        continue
                    }
                    countryDict[countryCode] = arr
                    self.firstLetter.append(countryCode)
                }
                searchController.searchBar.placeholder = searchController.searchBar.text!
            }
            else {
                searchController.searchBar.placeholder = ""
                generateAlphabetArray(isUpdate: true)
            }
            self.firstLetter.sort()
            self.tableView.reloadData()
        }
    }
    
}

extension String {
    func contains(word : String) -> Bool
    {
        return self.range(of: "\\b\(word)", options: .regularExpression) != nil
    }
}
