
import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startedBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var blackBgView: UIView!

    // NEW outlets: connect these to the labels inside blackBgView
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    private let gradientLayer = CAGradientLayer()
    private var slideImageViews: [UIImageView] = []
    private let pillControl = PillPageControl()

    var slideArray: [SlideStruct] = [
        SlideStruct(
            image: "onboard1",
            badge: "STONE-DECK OVEN",
            title: "Freshly Baked Pizza\nStraight to Your Door 🍕",
            desc: "Savor piping hot, artisanal hand-tossed pizzas baked at 800° perfection within minutes."
        ),
        SlideStruct(
            image: "onboard2",
            badge: "INSTANT PERKS • 100 PTS ON SIGNUP",
            title: "Earn Loyalty, Gifts\n& Vouchers On Every Order 🎁",
            desc: "Collect pizza reward stamps, enjoy exclusive discounts, free toppings, and redeem treats with every bite!"
        ),
        SlideStruct(
            image: "onboard3",
            badge: "UNLIMITED TOPPINGS • 1 PRICE",
            title: "Customize It Exactly\nTo Your Preference 👨‍🍳",
            desc: "Choose your favorite crust, sauces, fresh cheeses, and unlimited meats & veggies with zero extra cost."
        )
    ]

    var currentPage = 0
    private var builtWidth: CGFloat = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlackBackground()
        configureScrollView()
        configurePageControl()
        titleLabel.numberOfLines = 0
        descLabel.numberOfLines = 0
        updateContent(for: 0, animated: false)
        configureBtn()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = blackBgView.bounds
        startedBtn.layer.cornerRadius = startedBtn.frame.height / 2
        buildSlidesIfNeeded()
    }

    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Setup
    private func configureBlackBackground() {
        blackBgView.backgroundColor = .clear

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.65).cgColor,
            UIColor.black.withAlphaComponent(0.95).cgColor
        ]
        gradientLayer.locations = [0.0, 0.4, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        blackBgView.layer.insertSublayer(gradientLayer, at: 0)

        view.bringSubviewToFront(blackBgView)
    }
    
    private func configureBtn() {
        startedBtn.semanticContentAttribute = .forceRightToLeft
       var configuration = startedBtn.configuration
            ?? UIButton.Configuration.plain()
        
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .white
        configuration.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attributes in
                
                var updatedAttributes = attributes
                updatedAttributes.font =
                    AppFonts.jakartaMedium.withSize(16)
                
                return updatedAttributes
            }
        
        startedBtn.configuration = configuration
    }

    private func configureScrollView() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never   // image goes under the status bar
    }

    private func configurePageControl() {
        pageControl.alpha = 0            // invisible, but still takes space in the stack
        pageControl.isUserInteractionEnabled = false

        pillControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pillControl)

        NSLayoutConstraint.activate([
            pillControl.centerXAnchor.constraint(equalTo: pageControl.centerXAnchor),
            pillControl.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor),
            pillControl.heightAnchor.constraint(equalToConstant: 20)
        ])

        pillControl.numberOfPages = slideArray.count
        pillControl.setProgress(0)
        pillControl.onPageSelected = { [weak self] page in
            self?.goToPage(page)
        }
    }

    // Build the image views once the scroll view has its real size
    private func buildSlidesIfNeeded() {
        let size = scrollView.bounds.size
        guard size.width > 0, builtWidth != size.width else { return }
        builtWidth = size.width

        // remove only the image views created by this method
        slideImageViews.forEach { $0.removeFromSuperview() }
        slideImageViews.removeAll()

        for (index, slide) in slideArray.enumerated() {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * size.width,
                                                      y: 0,
                                                      width: size.width,
                                                      height: size.height))
            imageView.image = UIImage(named: slide.image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
            slideImageViews.append(imageView)
        }

        scrollView.contentSize = CGSize(width: size.width * CGFloat(slideArray.count),
                                        height: size.height)
        scrollView.setContentOffset(CGPoint(x: size.width * CGFloat(currentPage), y: 0), animated: false)
    }

    // MARK: - Content
    private func updateContent(for page: Int, animated: Bool = true) {
        guard slideArray.indices.contains(page) else { return }
        let slide = slideArray[page]

        let changes = {
            self.badgeLabel.text = "  \(slide.badge)  "
            self.titleLabel.text = slide.title
            self.descLabel.text  = slide.desc
        }

        if animated {
            UIView.transition(with: blackBgView, duration: 0.25,
                              options: [.transitionCrossDissolve, .allowUserInteraction],
                              animations: changes)
        } else {
            changes()
        }
        // Button title is intentionally NOT changed
    }

    private func goToPage(_ page: Int, animated: Bool = true) {
        let x = scrollView.bounds.width * CGFloat(page)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }

   
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0 else { return }

        pillControl.setProgress(scrollView.contentOffset.x / width)

        let page = Int(round(scrollView.contentOffset.x / width))
        guard page != currentPage, slideArray.indices.contains(page) else { return }
        currentPage = page
        updateContent(for: page)
    }
}

struct SlideStruct {
    let image: String
    let badge: String
    let title: String
    let desc: String
}
