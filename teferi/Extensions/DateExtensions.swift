import Foundation

extension Date
{
    // MARK: Properties
    
    ///Returns the day before the current date
    var yesterday : Date
    {
        return self.add(days: -1)
    }
    
    ///Returns the day after the current date
    var tomorrow : Date
    {
        return self.add(days: 1)
    }
    
    // MARK: Methods
    
    /**
     Add (or subtract, if the value is negative) days to this date.
     
     - Parameter daysToAdd: Days to be added to the date.
     
     - Returns: A new date that is `daysToAdd` ahead of this one.
     */
    func add(days daysToAdd: Int) -> Date
    {
        var dayComponent = DateComponents()
        dayComponent.day = daysToAdd
        
        let calendar = Calendar.current
        let nextDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: self, options: NSCalendar.Options())!
        return nextDate
    }
    
    /**
     Ignores the time portion of the Date.
     
     - Returns: A new date whose time is always midnight.
     */
    func ignoreTimeComponents() -> Date
    {
        let units : NSCalendar.Unit = [ .year, .month, .day];
        let calendar = Calendar.current;
        return calendar.date(from: (calendar as NSCalendar).components(units, from: self))!
    }
    
    func differenceInDays(toDate date: Date) -> Int
    {
        let calendar = Calendar.current
        let units = Set<Calendar.Component>([ .day]);
        
        let components = calendar.dateComponents(units, from: self.ignoreTimeComponents(), to: date.ignoreTimeComponents())

        return components.day!
    }
}
