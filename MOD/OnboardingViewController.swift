import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startedBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    var slideArray: [SlideStruct] = [
        SlideStruct(image: "onboard1"),
        SlideStruct(image: "onboard2"),
        SlideStruct(image: "onboard3")
    ]
    var currentPage = 0
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    
}








struct SlideStruct {
    let image: String
}
