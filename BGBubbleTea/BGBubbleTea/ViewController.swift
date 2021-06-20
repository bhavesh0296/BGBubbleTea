//
//  ViewController.swift
//  BGBubbleTea
//
//  Created by bhavesh on 20/06/21.
//  Copyright © 2021 Bhavesh. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // MARK: - Properties
    private let venueCellIdentifier = "VenueCell"

    lazy var coreDataStack = CoreDataStack(modelName: "BGBubbleTea")
    var fetchRequest: NSFetchRequest<Venue>?
    var venues: [Venue] = []
    var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>?

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        importJSONSeedDataIfNeeded()


        /*
         // to use the fetch request from the Managed Object Model
        guard let model = coreDataStack.managedContext.persistentStoreCoordinator?.managedObjectModel,
            let fetchRequest = model.fetchRequestTemplate(forName: "FetchRequest") as? NSFetchRequest<Venue> else {
                return
        }
        self.fetchRequest = fetchRequest
        */

        /*
         // to get the fetch request from the Venue NSManagedObject
        self.fetchRequest = Venue.fetchRequest()
        fetchAndReload()
        */

        // example of batch update used when we have thousands of data to update
        batchUpdateMarkFavorite()

        // Asynchronous fetching without blocking the main thread
        let venueFetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest = venueFetchRequest

        asyncFetchRequest = NSAsynchronousFetchRequest<Venue>(fetchRequest: venueFetchRequest, completionBlock: { [unowned self] (result: NSAsynchronousFetchResult) in
            guard let venues = result.finalResult else {
                return
            }
            self.venues = venues
            self.tableView.reloadData()
        })

        do {
            guard let asyncFetchRequest = asyncFetchRequest else {
                return
            }
            try coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }

    @IBAction func filterBarButtonClicked(_ sender: UIBarButtonItem) {
        if let filterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: FilterViewController.self)) as? FilterViewController {
            filterVC.coreDataStack = self.coreDataStack
            filterVC.delegate = self
            self.navigationController?.pushViewController(filterVC, animated: true)
        }
    }

    fileprivate func fetchAndReload() {
        guard let fetchRequest = fetchRequest else { return }
        do {
            venues = try coreDataStack.managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }

    fileprivate func batchUpdateMarkFavorite() {
        let batchUpdate = NSBatchUpdateRequest(entityName: String(describing: Venue.self))
        batchUpdate.propertiesToUpdate = [#keyPath(Venue.favorite): true]

        batchUpdate.affectedStores = coreDataStack.managedContext.persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectsCountResultType

        do {
            let batchResult = try coreDataStack.managedContext.execute(batchUpdate) as! NSBatchUpdateResult
            print("Records Updated \(batchResult.result!)")
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
        let venue = venues[indexPath.row]
        cell.textLabel?.text = venue.name ?? ""
        cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
        return cell
    }
}

// MARK - Data loading
extension ViewController {

    func importJSONSeedDataIfNeeded() {
        let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
        let count = try! coreDataStack.managedContext.count(for: fetchRequest)

        guard count == 0 else { return }

        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            results.forEach { coreDataStack.managedContext.delete($0) }

            coreDataStack.saveContext()
            importJSONSeedData()
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
    }

    func importJSONSeedData() {
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)

        let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: Any]
        let responseDict = jsonDict["response"] as! [String: Any]
        let jsonArray = responseDict["venues"] as! [[String: Any]]

        for jsonDictionary in jsonArray {
            let venueName = jsonDictionary["name"] as? String
            let contactDict = jsonDictionary["contact"] as! [String: String]

            let venuePhone = contactDict["phone"]

            let specialsDict = jsonDictionary["specials"] as! [String: Any]
            let specialCount = specialsDict["count"] as? NSNumber

            let locationDict = jsonDictionary["location"] as! [String: Any]
            let priceDict = jsonDictionary["price"] as! [String: Any]
            let statsDict =  jsonDictionary["stats"] as! [String: Any]

            let location = Location(context: coreDataStack.managedContext)
            location.address = locationDict["address"] as? String
            location.city = locationDict["city"] as? String
            location.state = locationDict["state"] as? String
            location.zipcode = locationDict["postalCode"] as? String
            let distance = locationDict["distance"] as? NSNumber
            location.distance = distance!.floatValue

            let category = Category(context: coreDataStack.managedContext)

            let priceInfo = PriceInfo(context: coreDataStack.managedContext)
            priceInfo.priceCategory = priceDict["currency"] as? String

            let stats = Stats(context: coreDataStack.managedContext)
            let checkins = statsDict["checkinsCount"] as? NSNumber
            stats.checkinsCount = checkins!.int32Value
            let tipCount = statsDict["tipCount"] as? NSNumber
            stats.tipCount = tipCount!.int32Value
            
            let venue = Venue(context: coreDataStack.managedContext)
            venue.name = venueName
            venue.phone = venuePhone
            venue.specialCount = specialCount!.int32Value
            venue.location = location
            venue.category = category
            venue.priceInfo = priceInfo
            venue.stats = stats
        }

        coreDataStack.saveContext()
    }
}

extension ViewController: FilterViewControllerDelegate {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        guard let fetchRequest = fetchRequest else {
            return
        }

        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil

        fetchRequest.predicate = predicate

        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        fetchAndReload()
    }

}
