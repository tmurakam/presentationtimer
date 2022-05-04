/*
  Presentation Timer for iOS

  Copyright (c) 2008-2022, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

protocol TimePickerViewDelegate: AnyObject {
    func timePickerViewSetTime(_ seconds: Int)
    func timePickerViewSetCountdownTarget()
}

class TimePickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    //@IBOutlet weak var mPicker: UIDatePicker?
    @IBOutlet weak var mPickerView: UIPickerView?
    @IBOutlet weak var mCdtButton: UIButton?

    var seconds: Int = 0

    weak var delegate: TimePickerViewDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: "TimePickerViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //picker.datePickerMode = UIDatePickerModeCountDownTimer;

        self.title = "Set Time"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                action: #selector(TimePickerViewController.onCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                action: #selector(TimePickerViewController.onDone))

        let title = NSLocalizedString("Use as presentation end time", comment: "")
        mCdtButton?.setTitle(title, for: .normal)
        mCdtButton?.setTitle(title, for: .highlighted)
    }

    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(animated)
        setupLabel(mPickerView!)
    }

    func setupLabel(_ picker: UIPickerView) {
        let titles = ["hour", "min", "sec"]
        let size = picker.frame.size

        for i in 0..<3 {
            let rect = CGRect(x: CGFloat(42 + (Double(size.width) / 3) * Double(i)), y: CGFloat(Double(size.height) / 2 - 15), width: 75, height: 30)
            let label = UILabel(frame: rect)
            label.text = titles[i];
            label.textColor = UIColor.white
            picker.addSubview(label)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)

        //TODO:
        //mPicker.countDownDuration = (double)mSeconds;

        let hour = self.seconds / 3600
        let min = (self.seconds / 60) % 60
        let sec = self.seconds % 60

        mPickerView?.selectRow(hour, inComponent: 0, animated: false)
        mPickerView?.selectRow(min, inComponent: 1, animated: false)
        mPickerView?.selectRow(sec, inComponent: 2, animated: false)
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (component) {
        case 0:
            return 10  // up to 10 hours
        default:
            return 60  // up to 59 min, 59 sec
        }
    }

    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let columnView = UILabel(frame: CGRect(x: 35, y: 0, width: self.view.frame.size.width / 3 - 35, height: 30))
        columnView.text = "\(row)"
        columnView.textColor = .white
        columnView.textAlignment = .left
        return columnView;
    }

    /*
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch (component) {
        case 0:
            return "hour";
        case 1:
            return "min";
        case 2:
            return "sec"
        default:
            return "?";
        }
    }
    */

    @IBAction func onDone(_ sender: Any) {
        let hour = mPickerView!.selectedRow(inComponent: 0)
        let min = mPickerView!.selectedRow(inComponent: 1)
        let sec = mPickerView!.selectedRow(inComponent: 2)

        self.seconds = hour * 3600 + min * 60 + sec
        delegate?.timePickerViewSetTime(self.seconds)
        dismiss(animated: true)
    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onSetCountdownTarget(_ sender: Any) {
        delegate?.timePickerViewSetCountdownTarget()
    }

    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
