//
//  Slider.swift
//  UISliderCustomColors
//
//  Created by okudera on 2021/09/16.
//

import UIKit

final class BufferingSlider: UISlider {

    // MARK: - Properties

    var bufferStartValue: Double = .zero {
        didSet{
            if bufferStartValue < .zero {
                bufferStartValue = .zero
            }
            if bufferStartValue > bufferEndValue {
                bufferStartValue = bufferEndValue
            }
            self.setNeedsDisplay()
        }
    }

    var bufferEndValue: Double = .zero {
        didSet{
            if bufferEndValue > 1.0 {
                bufferEndValue = 1.0
            }
            if bufferEndValue < bufferStartValue {
                bufferEndValue = bufferStartValue
            }
            self.setNeedsDisplay()
        }
    }

    var trackBaseColor: UIColor!

    var bufferColor: UIColor!

    var borderWidth: Double = 0.1 {
        didSet {
            if borderWidth < 0.1 {
                borderWidth = 0.1
            }
            self.setNeedsDisplay()
        }
    }

    var sliderHeight: Double = 8.0 {
        didSet {
            if sliderHeight < 1 {
                sliderHeight = 1
            }
        }
    }

    /// 先端を丸くするかどうか
    ///
    /// FIXME: 現状先端が丸いパターンのみ実装しているが、両方必要な場合は、このフラグで分岐して、addArcかaddLineかpathの描画の処理を分ける必要がありそう。
//    var roundedSlider: Bool = true

    // MARK: - UISlider

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        let heightDiff = CGFloat(sliderHeight) - result.height
        result.origin.y += (heightDiff * 0.5) * -1.0
        result.size.height = CGFloat(sliderHeight)
        return result
    }

    // MARK: - UIView

    override func draw(_ rect: CGRect) {
        let padding = CGFloat(0)
        let rect = trackRect(forBounds: bounds).insetBy(dx: CGFloat(borderWidth) + padding, dy: CGFloat(borderWidth))
        let height = CGFloat(sliderHeight)
        let radius = height/2
        let sliderRect = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.height/2-radius), width: rect.width, height: rect.height)

        let path = UIBezierPath()

        // 後続のストローク/塗りつぶし操作の色を設定
        trackBaseColor.set()
        // 左側の半円を描画
        path.addArc(withCenter: CGPoint(x: sliderRect.minX + radius, y: sliderRect.minY+radius),
                    radius: radius,
                    startAngle: CGFloat(Double.pi) / 2,
                    endAngle: -CGFloat(Double.pi) / 2,
                    clockwise: true)
        // 上側のラインを描画
        path.addLine(to: CGPoint(x: sliderRect.maxX-radius, y: sliderRect.minY))
        // 右側の半円を描画
        path.addArc(withCenter: CGPoint(x: sliderRect.maxX-radius, y: sliderRect.minY+radius),
                    radius: radius,
                    startAngle: -CGFloat(Double.pi) / 2,
                    endAngle: CGFloat(Double.pi) / 2,
                    clockwise: true)
        // 下側のラインを描画
        path.addLine(to: CGPoint(x: sliderRect.minX + radius, y: sliderRect.minY+height))

        // 後続のストローク操作色を設定の色を設定
        trackBaseColor.setStroke()

        // 塗りつぶす
        path.fill()

        path.addClip()

        var fillHeight = sliderRect.size.height - CGFloat(borderWidth)
        if fillHeight < 0 {
            fillHeight = 0
        }

        // buffering部分のFrameを定義
        let fillRect = CGRect(
            x: sliderRect.origin.x + sliderRect.size.width*CGFloat(bufferStartValue),
            y: sliderRect.origin.y + CGFloat(borderWidth) / 2,
            width: sliderRect.size.width * CGFloat(bufferEndValue-bufferStartValue),
            height: fillHeight
        )

        bufferColor.setFill() // 後続の塗りつぶし操作の色を設定
        UIBezierPath(rect: fillRect).fill()
    }
}

extension BufferingSlider {
    func configure(trackBaseColor: UIColor, progressColor: UIColor, bufferColor: UIColor, thumbImage: UIImage?) {
        self.trackBaseColor = trackBaseColor
        self.tintColor = progressColor
        self.bufferColor = bufferColor
        self.setThumbImage(thumbImage, for: .normal)
        self.setThumbImage(thumbImage, for: .highlighted)
        
        if let thumbImage = currentThumbImage,
           sliderHeight > Double(thumbImage.size.height * 0.5)
            {
            sliderHeight = Double(thumbImage.size.height * 0.5)
        }
        bufferStartValue = .zero
        bufferEndValue = .zero
        value = .zero
    }
}
