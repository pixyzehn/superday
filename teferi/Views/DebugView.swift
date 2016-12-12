import UIKit
import MapKit
import SnapKit
import RxSwift
import Foundation

class DebugView : UIView
{
    //MARK: Fields
    @IBOutlet private var map : MKMapView!
    
    static func attach(toViewController viewController: MainViewController,
                       makeToggleButtonRelativeToView view: UIView,
                       addDisposableTo disposeBag: DisposeBag,
                       editStateService: EditStateService)
    {
        let debugView = Bundle.main.loadNibNamed("DebugView", owner: self, options: nil)!.first as! DebugView
        debugView.listenForEdits(editStateService, disposeBag)
        
        viewController.view.addSubview(debugView)
        
        debugView.snp.makeConstraints { make in
            
            make.bottom.right.equalTo(viewController.view)
            
            make.height.equalTo(UIScreen.main.bounds.height / 1.5)
            make.width.equalTo(UIScreen.main.bounds.width - 80)
        }
        
        let button = UIButton()
        button.setImage(UIImage(named: "icBug"), for: .normal)
        
        view.superview!.addSubview(button)
        
        button.snp.makeConstraints { make in
            
            make.right.equalTo(view.snp.left)
            make.centerY.equalTo(view.snp.centerY)
            make.height.width.equalTo(50)
        }
        
        button
            .rx.tap
            .subscribe(onNext: { debugView.isHidden = !debugView.isHidden })
            .addDisposableTo(disposeBag)
    }
    
    private func listenForEdits(_ editStateService: EditStateService, _ disposeBag: DisposeBag)
    {
        editStateService
            .beganEditingObservable
            .map { return $0.1  }
            .subscribe(onNext: self.onEditingTimeSlot)
            .addDisposableTo(disposeBag)
    }
    
    private func onEditingTimeSlot(timeSlot: TimeSlot)
    {
        guard let location = timeSlot.location else { return }
        
        let annotation = MKPointAnnotation()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        annotation.title = "\(timeSlot.category) @ \(formatter.string(from: timeSlot.startTime))"
        annotation.coordinate = location.coordinate
        
        self.map.addAnnotation(annotation)
    }
}
