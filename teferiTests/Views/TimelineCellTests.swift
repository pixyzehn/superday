import Foundation
import XCTest
import Nimble
@testable import teferi

class TimelineCellTests : XCTestCase
{
    // MARK: Fields
    private let timeSlot = TimeSlot(withStartTime: Date(), category: .work, categoryWasSetByUser: false)
    private var view : TimelineCell!
    
    private var imageIcon : UIImageView
    {
        let view = self.view.subviews.filter { v in v is UIImageView  }.first!
        return view as! UIImageView
    }
    
    private var slotDescription : UILabel
    {
        let view = self.view.subviews.filter { v in v is UILabel  }.first!
        return view as! UILabel
    }
    
    private var slotTime : UILabel
    {
        let view = self.view.subviews.filter { v in v is UILabel  }.last!
        return view as! UILabel
    }
    
    private var timeLabel : UILabel
    {
        let labels = self.view.subviews.filter { v in v is UILabel  }
        
        let view = labels[labels.count - 2]
        return view as! UILabel
    }
    
    private var line : UIView
    {
        return  self.view.subviews.first!
    }
    
    override func setUp()
    {
        self.view = Bundle.main.loadNibNamed("TimelineCell", owner: nil, options: nil)?.first! as! TimelineCell
        self.view.bind(toTimeSlot: timeSlot, index: 0, lastInPastDay: false)
    }
    
    override func tearDown()
    {
        self.timeSlot.category = .work
    }
    
    private func editCellSetUp(_ shouldFade: Bool = true, isEditingCategory: Bool = true)
    {
        self.view.bind(toTimeSlot: timeSlot, index: 0, lastInPastDay: false)
    }
    
    func testTheImageChangesAccordingToTheBoundTimeSlot()
    {
        expect(self.imageIcon.image).toNot(beNil())
    }
    
    func testTheDescriptionChangesAccordingToTheBoundTimeSlot()
    {
        expect(self.slotDescription.text).to(equal(timeSlot.category.rawValue.capitalized))
    }
    
    func testTheTimeChangesAccordingToTheBoundTimeSlot()
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: timeSlot.startTime)
        
        expect(self.slotTime.text).to(equal(dateString))
    }
    
    func testTheTimeDescriptionShowsEndDateIfIsLastPastTimeSlot()
    {
        let date = Date().yesterday.ignoreTimeComponents()
        let newTimeSlot = self.createTimeSlot(withStartTime: date)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        newTimeSlot.endTime = date.addingTimeInterval(5000)
        
        self.view.bind(toTimeSlot: newTimeSlot, index: 0, lastInPastDay: true)
        
        let startText = formatter.string(from: newTimeSlot.startTime)
        let endText = formatter.string(from: newTimeSlot.endTime!)
        
        let expectedText = "\(startText) - \(endText)"
        
        expect(self.slotTime.text).to(equal(expectedText))
    }
    
    func testTheDescriptionHasNoTextWhenTheCategoryIsUnknown()
    {
        let unknownTimeSlot = self.createTimeSlot(withStartTime: Date())
        view.bind(toTimeSlot: unknownTimeSlot, index: 0, lastInPastDay: false)
        
        expect(self.slotDescription.text).to(equal(""))
    }
    
    func testTheElapsedTimeLabelShowsOnlyMinutesWhenLessThanAnHourHasPassed()
    {
        let minuteMask = "%02d min"
        let interval = Int(timeSlot.duration)
        let minutes = (interval / 60) % 60
        
        let expectedText = String(format: minuteMask, minutes)
        
        expect(self.timeLabel.text).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelShowsHoursAndMinutesWhenOverAnHourHasPassed()
    {
        let date = Date().yesterday.ignoreTimeComponents()
        let newTimeSlot = self.createTimeSlot(withStartTime: date)
        newTimeSlot.endTime = date.addingTimeInterval(5000)
        self.view.bind(toTimeSlot: newTimeSlot, index: 0, lastInPastDay: false)
        
        let hourMask = "%02d h %02d min"
        let interval = Int(newTimeSlot.duration)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        
        let expectedText = String(format: hourMask, hours, minutes)
        
        expect(self.timeLabel.text).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.work.color
        let actualColor = timeLabel.textColor!
        
        expect(expectedColor).to(equal(actualColor))
    }
    
    func testTheTimelineCellLineHeightChangesAccordingToTheBoundTimeSlot()
    {
        let oldLineHeight = self.line.frame.height
        let date = Date().add(days: -1)
        let newTimeSlot = self.createTimeSlot(withStartTime: date)
        newTimeSlot.endTime = Date()
        self.view.bind(toTimeSlot: newTimeSlot, index: 0, lastInPastDay: false)
        self.view.layoutIfNeeded()
        let newLineHeight = line.frame.height
        
        expect(oldLineHeight).to(beLessThan(newLineHeight))
    }
    
    func testTheLineColorChangesAccordingToTheBoundTimeSlot()
    {
        let expectedColor = Category.work.color
        let actualColor = self.line.backgroundColor!
        
        expect(expectedColor).to(equal(actualColor))
    }
    
    func testRebindingACellAfterEditingRemovesTheExtraViews()
    {
        let numberOfViewsBeforeBinding = view.subviews.count
        self.editCellSetUp()
        self.editCellSetUp(true, isEditingCategory: false)
        
        expect(self.view.subviews.count).to(equal(numberOfViewsBeforeBinding))
    }
    
    private func createTimeSlot(withStartTime time: Date) -> TimeSlot
    {
        return TimeSlot(withStartTime: time, categoryWasSetByUser: false)
    }
}
