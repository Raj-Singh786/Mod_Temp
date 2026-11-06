//
//  CustomPageController.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//

import UIKit

final class PillPageControl: UIView {

    var numberOfPages = 0 { didSet { rebuild() } }
    var dotSize: CGFloat = 8 { didSet { invalidateIntrinsicContentSize() } }
    var activeWidth: CGFloat = 26 { didSet { invalidateIntrinsicContentSize() } }
    var spacing: CGFloat = 6 { didSet { invalidateIntrinsicContentSize() } }
    var activeColor: UIColor = .white
    var inactiveAlpha: CGFloat = 0.4

    /// Called when the user taps a dot
    var onPageSelected: ((Int) -> Void)?

    private var dots: [UIView] = []
    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }

    private func rebuild() {
        dots.forEach { $0.removeFromSuperview() }
        dots = (0..<numberOfPages).map { _ in
            let v = UIView()
            v.layer.cornerRadius = dotSize / 2
            addSubview(v)
            return v
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    /// progress = scrollView.contentOffset.x / scrollView.bounds.width
    func setProgress(_ value: CGFloat) {
        progress = min(max(value, 0), CGFloat(max(numberOfPages - 1, 0)))
        layoutDots()
    }

    /// Jump to a page with a smooth animation (for tap or programmatic use)
    func setPage(_ page: Int, animated: Bool) {
        let target = CGFloat(page)
        guard animated else { setProgress(target); return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.progress = target
            self.layoutDots()
        }
    }

    override var intrinsicContentSize: CGSize {
        guard numberOfPages > 0 else { return CGSize(width: 0, height: dotSize) }
        let w = CGFloat(numberOfPages - 1) * dotSize + activeWidth + CGFloat(numberOfPages - 1) * spacing
        return CGSize(width: w, height: dotSize)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDots()
    }

    private func layoutDots() {
        guard !dots.isEmpty else { return }
        var x = (bounds.width - intrinsicContentSize.width) / 2
        let y = (bounds.height - dotSize) / 2

        for (i, dot) in dots.enumerated() {
            let t = max(0, 1 - abs(progress - CGFloat(i)))   // 1 = fully active, 0 = inactive
            let w = dotSize + (activeWidth - dotSize) * t
            dot.frame = CGRect(x: x, y: y, width: w, height: dotSize)
            dot.layer.cornerRadius = dotSize / 2
            dot.backgroundColor = activeColor.withAlphaComponent(inactiveAlpha + (1 - inactiveAlpha) * t)
            x += w + spacing
        }
    }

    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: self)
        if let index = dots.firstIndex(where: { $0.frame.insetBy(dx: -spacing / 2, dy: -10).contains(point) }) {
            onPageSelected?(index)
        }
    }
}
