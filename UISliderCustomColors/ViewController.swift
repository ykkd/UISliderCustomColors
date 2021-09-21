//
//  ViewController.swift
//  UISliderCustomColors
//
//  Created by okudera on 2021/09/16.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var slider: BufferingSlider! {
        willSet {
            newValue.addTarget(self,
                               action: #selector(sliderValueChanged),
                               for: .valueChanged)
            newValue.configure(
                trackBaseColor: .lightGray,
                progressColor: .red,
                bufferColor: .darkGray,
                thumbImage: UIImage.fillColorCircleImage(color: .blue)
            )
        }
    }
    @IBOutlet private weak var bufferLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fire()
    }
}

extension ViewController {
    private func fire() {
        Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(timerUpdate),
            userInfo: nil,
            repeats: true
        )
    }

    @objc
    private func timerUpdate() {
        // ループさせるために1の場合は初期化する
        slider.bufferEndValue = slider.bufferEndValue == 1
            ? .zero
            : ceil((slider.bufferEndValue + 0.1) * 10) / 10
        bufferLabel.text = "(DarkGray) Buffer:" + String(format: "%1.2f", slider.bufferEndValue)
    }

    @objc
    private func sliderValueChanged() {
        progressLabel.text = "(Red) Progress: " + String(format: "%1.2f", slider.value)
    }
}

// Extensions

extension UIView {

    static func fillColorCircle(length: CGFloat, backgroundColor: UIColor) -> UIView {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: length, height: length)))
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = length / 2
        view.layer.masksToBounds = true
        return view
    }

    func toImage() -> UIImage {
        UIGraphicsImageRenderer(size: bounds.size)
            .image { layer.render(in: $0.cgContext) }
    }
}

extension UIImage {
    static func fillColorCircleImage(color: UIColor) -> UIImage {
        return UIView.fillColorCircle(length: 20, backgroundColor: color).toImage()
    }
}
