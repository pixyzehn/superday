import UIKit

/**
 Represents the possible categories for any given TimeSlot.
 
 - Friends: For activities with your friends.
 - Work: For any work-related activities.
 - Leisure: For recreation activities.
 - Commute: Used when the app detects the user is traveling.
 - Food: For any work-related activities.
 - Unknown: For app-created activities that are yet to be defined by the user.
 */
enum Category : String
{
    case commute
    case food
    case friends
    case work
    case leisure
    case unknown
    
    // MARK: Properties
    
    /// Get the color associated with the category.
    var color : UIColor
    {
        switch(self)
        {
        case .friends:
            return Color.green
        case .work:
            return Color.yellow
        case .leisure:
            return Color.purple
        case .commute:
            return Color.lightBlue
        case .food:
            return Color.red
        case .unknown:
            return Color.gray
        }
    }
    
    /// Get the AssetInfo for the category.
    var icon : String
    {
        switch(self)
        {
        case .friends:
            return "icFriends"
        case .work:
            return "icWork"
        case .leisure:
            return "icLeisure"
        case .commute:
            return "icCommute"
        case .food:
            return "icFood"
        case .unknown:
            return "icCancel"
        }
    }
}
