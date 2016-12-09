import UIKit
import JTAppleCalendar

class CalendarCellView: JTAppleDayCellView
{

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    let fontSize = CGFloat(14.0)
    
    func updateCell(cellState: CellState,
                    startDate: Date,
                    date: Date,
                    selectedDate: Date,
                    categorySlots: [CategorySlot])
    {
        self.resetCell()
        if cellState.dateBelongsTo == .thisMonth
        {
            self.dateLabel.text = cellState.text
            if Calendar.current.compare(date,
                                           to: startDate,
                                           toGranularity: .day) == .orderedAscending
            {// is smaller
                self.activityView.backgroundColor = Color.lightGreyColor
            } else
            {
                self.activityView.backgroundColor = Color.lightGreyColor
                self.updateActivity(categorySlots: categorySlots)
                self.dateLabel.textColor = UIColor.black
            }
        }
        if Calendar.current.isDate(date, inSameDayAs: selectedDate)
        {//is the same
            if cellState.dateBelongsTo == .thisMonth
            {
                self.updateForCurrentDay()
            }
        }
    }

    // updates Activity based on sorted time slots for the day
    func updateActivity(categorySlots: [CategorySlot])
    {
        self.activityView.layoutIfNeeded()
        let timeSpent:TimeInterval = categorySlots.reduce(0.0)
        {
            return $0 + $1.duration
        }
        let fullWidth = self.activityView.bounds.size.width - CGFloat(categorySlots.count) + 1.0
        var prev:UIView?
        if categorySlots.count > 0
        {
            self.isUserInteractionEnabled = true
        }
        for categorySlot in categorySlots
        {
            let timeSlotView = UIView()
            timeSlotView.clipsToBounds = true
            timeSlotView.layer.cornerRadius = 1
            timeSlotView.backgroundColor = categorySlot.category.color
            let timeSlotWidth = Double(fullWidth) * (categorySlot.duration / timeSpent)
            self.activityView.addSubview(timeSlotView)
            timeSlotView.snp.makeConstraints({ (make) in
                make.top.equalTo(self.activityView.snp.top)
                make.bottom.equalTo(self.activityView.snp.bottom)
                if let previous = prev
                {
                    make.left.equalTo(previous.snp.right).offset(1)
                } else
                {
                    make.left.equalTo(self.activityView.snp.left)
                }
                
                // category can occur only once
                if categorySlot.category != categorySlots.last?.category
                {
                    make.width.equalTo(timeSlotWidth)
                }
            })
            prev = timeSlotView
        }
        // last time slot is rounded to fit the end
        if let lastTimeSlot = prev
        {
            lastTimeSlot.snp.makeConstraints(
            {(make) in
                make.right.equalTo(self.activityView.snp.right)
            })
            self.activityView.backgroundColor = UIColor.clear
        }
        self.activityView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    func updateForCurrentDay()
    {
        self.backgroundColor = Color.lightGreyColor
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.dateLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    func resetCell()
    {
        for subView in self.activityView.subviews
        {
            subView.removeFromSuperview()
        }
        self.dateLabel.text = ""
        self.dateLabel.textColor = UIColor.black
        self.backgroundColor = UIColor.white
        self.activityView.backgroundColor = UIColor.white
        self.activityView.clipsToBounds = true
        self.activityView.layer.cornerRadius = 1.0
        self.layer.cornerRadius = 0
        self.clipsToBounds = true
        self.dateLabel.font = UIFont.systemFont(ofSize: fontSize)
        self.isUserInteractionEnabled = false
    }
}