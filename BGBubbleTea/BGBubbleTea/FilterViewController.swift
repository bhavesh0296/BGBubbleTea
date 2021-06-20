
import UIKit
import CoreData

class FilterViewController: UITableViewController {

    @IBOutlet weak var firstPriceCategoryLabel: UILabel!
    @IBOutlet weak var secondPriceCategoryLabel: UILabel!
    @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
    @IBOutlet weak var numDealsLabel: UILabel!

    // MARK: - Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!

    // MARK: - Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    @IBOutlet weak var userTipsCell: UITableViewCell!

    // MARK: - Sort section
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var nameZASortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!

    // MARK: - Properties
    var coreDataStack: CoreDataStack!

    lazy var cheapVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K=%@", #keyPath(Venue.priceInfo.priceCategory), "$")
    }()

    lazy var moderateVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K=%@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    }()

    lazy var expensiveVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K=%@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
    }()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateCheapVenueCountLabel()
        populateModerateVenueCountLabel()
        populateExpensiveVenueCountLabel()
    }

    @IBAction func cancelBarButtonClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func searchBarButtonClicked(_ sender: UIBarButtonItem) {


    }


}


// MARK - UITableViewDelegate
extension FilterViewController {

    fileprivate func populateCheapVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = cheapVenuePredicate
        do {
            let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
            if let count = countResult.first?.intValue {
                let pluralized = count == 1 ? "place" : "places"
                firstPriceCategoryLabel.text = "\(count) Bubble tea \(pluralized)"
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    fileprivate func populateModerateVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = moderateVenuePredicate
        do {
            let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
            if let count = countResult.first?.intValue {
                let pluralized = count == 1 ? "place" : "places"
                secondPriceCategoryLabel.text = "\(count) Bubble tea \(pluralized)"
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    fileprivate func populateExpensiveVenueCountLabel() {
        let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest.predicate = expensiveVenuePredicate
        do {
            let count = try coreDataStack.managedContext.count(for: fetchRequest)
            let pluralized = count == 1 ? "place" : "places"
            thirdPriceCategoryLabel.text = "\(count) Bubble tea \(pluralized)"
        }catch {
            print(error.localizedDescription)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
