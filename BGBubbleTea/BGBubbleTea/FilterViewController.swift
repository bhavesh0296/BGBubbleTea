
import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

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
    weak var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?

    lazy var cheapVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K=%@", #keyPath(Venue.priceInfo.priceCategory), "$")
    }()

    lazy var moderateVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K=%@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    }()

    lazy var expensiveVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K=%@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
    }()

    lazy var offeringDealPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
    }()

    lazy var walkingDistancePredicate: NSPredicate = {
        return NSPredicate(format: "%K < 1000", #keyPath(Venue.location.distance))
    }()

    lazy var hasUserTipPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
    }()

    lazy var nameSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Venue.name), ascending: true, selector: compareSelector)
    }()

    lazy var distanceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Venue.location.distance), ascending: true)
    }()

    lazy var priceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory), ascending: true)
    }()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateCheapVenueCountLabel()
        populateModerateVenueCountLabel()
        populateExpensiveVenueCountLabel()
        populateDealsCounterLabel()
    }

    @IBAction func cancelBarButtonClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func searchBarButtonClicked(_ sender: UIBarButtonItem) {
        delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
        self.navigationController?.popViewController(animated: true)
    }

}

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

    fileprivate func populateDealsCounterLabel() {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: String(describing: Venue.self))
        fetchRequest.resultType = .dictionaryResultType

        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"

        let specialCountExp = NSExpression(format: #keyPath(Venue.specialCount))
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp])
        sumExpressionDesc.expressionResultType = .integer32AttributeType

        fetchRequest.propertiesToFetch = [sumExpressionDesc]

        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            let resultDict = results.first!
            let numDeals = resultDict["sumDeals"] as! Int
            let pluralized = numDeals == 1 ? "deal" : "deals"
            numDealsLabel.text = "\(numDeals) \(pluralized)"
        } catch {
            print(error.localizedDescription)
        }
    }

}

// MARK - UITableViewDelegate
extension FilterViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath)  else {
            return
        }

        switch cell {

        //Price Section
        case cheapVenueCell:
            selectedPredicate = cheapVenuePredicate
        case moderateVenueCell:
            selectedPredicate = moderateVenuePredicate
        case expensiveVenueCell:
            selectedPredicate = expensiveVenuePredicate

        //Most Popular Section
        case offeringDealCell:
            selectedPredicate = offeringDealPredicate
        case walkingDistanceCell:
            selectedPredicate = walkingDistancePredicate
        case userTipsCell:
            selectedPredicate = hasUserTipPredicate

        // Sort By section
        case nameAZSortCell:
            selectedSortDescriptor = nameSortDescriptor
        case nameZASortCell:
            selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
        case distanceSortCell:
            selectedSortDescriptor = distanceSortDescriptor
        case priceSortCell:
            selectedSortDescriptor = priceSortDescriptor

        default: break
        }

        cell.accessoryType = .checkmark
    }
}
