import UIKit


@IBDesignable final class CustomButton: UIButton {
    @IBInspectable override var backgroundColor: UIColor? {
        get {
            _backgroundColor
        }
        set(x) {
            _backgroundColor = x
        }
    }

    @IBInspectable var cornerRadius: Float = 0.0

    private var _backgroundColor: UIColor?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initParam()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initParam()
    }

    private func initParam() {
        backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        cornerRadius = 7.5
    }

    override func draw(_ rect: CGRect) {
        layer.backgroundColor = (_backgroundColor ?? UIColor.white).cgColor
        layer.cornerRadius = CGFloat(cornerRadius)
        super.draw(rect)
    }
}
