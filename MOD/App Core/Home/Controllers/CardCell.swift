//
//  CardCell.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import UIKit

class CardCell: UITableViewCell {
    
    // MARK: - Interface Builder Outlets
    
    /// Top left badge label (pill)
    @IBOutlet weak var badgeLabel: UILabel!
    
    /// Title label for member perks
    @IBOutlet weak var memberPerkLabel: UILabel!
    
    /// Right-aligned label indicating "Free to Join"
    @IBOutlet weak var freeToJoinLabel: UILabel!
    
    /// Main bold welcome title label
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    
    /// Subtitle text label below welcome title
    @IBOutlet weak var welcomeSubtitleLabel: UILabel!
    
    /// Pill label displaying "$20 Off 1st Order"
    @IBOutlet weak var pill1Label: UILabel!
    
    /// Pill label displaying "Free Breadsticks"
    @IBOutlet weak var pill2Label: UILabel!
    
    /// Pill label displaying "Zero Delivery Fee"
    @IBOutlet weak var pill3Label: UILabel!
    
    /// Left bottom large claim button
    @IBOutlet weak var claimButton: UIButton!
    
    /// Right bottom browse as guest button
    @IBOutlet weak var browseAsGuestButton: UIButton!
    
    /// Background container view for card
    @IBOutlet weak var bgView: UIView!
    
    
    static let identifier = String(describing: CardCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupCardUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Apply styling to the card view and its components
    private func setupCardUI() {
        // Style bgView with red background and rounded corners
        bgView.backgroundColor = UIColor.red
        bgView.layer.cornerRadius = 12
        bgView.layer.masksToBounds = true
        
        // Style badgeLabel as a pill (rounded corners, background color)
        badgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        badgeLabel.textColor = .white
        badgeLabel.layer.cornerRadius = badgeLabel.frame.height / 2
        badgeLabel.layer.masksToBounds = true
        // badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium) // customize font here
        
        // Style memberPerkLabel
        memberPerkLabel.textColor = .white
        // memberPerkLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        // Style freeToJoinLabel
        freeToJoinLabel.textColor = .white
        freeToJoinLabel.textAlignment = .right
        // freeToJoinLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        
        // Style welcomeTitleLabel (bold)
        welcomeTitleLabel.textColor = .white
        welcomeTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        // Style welcomeSubtitleLabel
        welcomeSubtitleLabel.textColor = .white
        welcomeSubtitleLabel.font = UIFont.systemFont(ofSize: 16)
        
        // Style pill labels with pill background and white text
        let pillLabels = [pill1Label, pill2Label, pill3Label]
        for pill in pillLabels {
            pill?.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            pill?.textColor = .white
            pill?.layer.cornerRadius = pill!.frame.height / 2
            pill?.layer.masksToBounds = true
            pill?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            pill?.textAlignment = .center
        }
        
        // Style claimButton (large left bottom button)
        claimButton.backgroundColor = .white
        claimButton.setTitleColor(.red, for: .normal)
        claimButton.layer.cornerRadius = 8
        claimButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Style browseAsGuestButton (right bottom button)
        browseAsGuestButton.setTitleColor(.white, for: .normal)
        browseAsGuestButton.backgroundColor = UIColor.clear
        browseAsGuestButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
}
