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

class PresentationTimerViewController : UIViewController, TimePickerViewDelegate, TimerModelDelegate {
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var bell1Button: UIButton?
    @IBOutlet weak var bell2Button: UIButton?
    @IBOutlet weak var bell3Button: UIButton?

    @IBOutlet weak var bellButton: UIButton?
    @IBOutlet weak var startStopButton: UIButton?
    @IBOutlet weak var resetButton: UIButton?

    var mTimer = TimerModel()
    var mIsCountDown = false

    var mColor0 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var mColor1 = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    var mColor2 = UIColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0)
    var mColor3 = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

    var mEditingItem: Int = -1

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: nil)
    }

    /** Initialize */
    override func viewDidLoad() {
        super.viewDidLoad()

        mTimer.delegate = self;

        let start = NSLocalizedString("Start", comment: "")
        startStopButton?.setTitle(start, for: .normal)
        startStopButton?.setTitle(start, for: .highlighted)

        let reset = NSLocalizedString("Reset", comment: "")
        resetButton?.setTitle(reset, for: .normal)
        resetButton?.setTitle(reset, for: .highlighted)
        resetButton?.setTitle(reset, for: .disabled)

        // timeLabel に対するタッチイベントを有効にする。
        // タッチイベントは touchesBegan で取る
        timeLabel?.isUserInteractionEnabled = true
        timeLabel?.tag = 100; // dummy tag

        // timeLabel: フォントサイズを over 300 に設定する
        timeLabel?.font = UIFont(name: "Helvetica", size: 500)

        //[self setButtonBorder:bellButton];
        //[self setButtonBorder:startStopButton];
        //[self setButtonBorder:resetButton];
    }

    /*
    - (void)setButtonBorder:(UIButton *)button {
        //button.layer.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f].CGColor;
        //button.layer.cornerRadius = 7.5f;
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonTitle()
        updateTimeLabel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /**
     Update values of time buttons
     */
    func updateButtonTitle() {
        for i in 0..<3 {
            var button: UIButton?
            switch i {
            case 0:
                button = bell1Button
            case 1:
                button = bell2Button
            case 2:
                button = bell3Button
            default:
                break
            }
            let time = mTimer.bellTime(i)
            let timeText = TimerModel.timeText(time)
            button?.setTitle(timeText, for: .normal)
            button?.setTitle(timeText, for: .highlighted)
        }
    }

    /**
     Start or stop timer (toggle)
     */
    @IBAction func startStopTimer(_ sender: Any) {
        var newTitle = ""
        if (!mTimer.timerRunning) {
            // start timer
            mTimer.startTimer()
            newTitle = NSLocalizedString("Pause", comment: "")
            resetButton?.isEnabled = false
        } else {
            // stop timer
            mTimer.stopTimer()
            newTitle = NSLocalizedString("Start", comment: "");
            resetButton?.isEnabled = true
        }
        startStopButton?.setTitle(newTitle, for: .normal)
        startStopButton?.setTitle(newTitle, for: .highlighted)
    }

    /**
     Reset timer value
     */
    @IBAction func resetTimer(_ sender: Any) {
        mTimer.resetTimer()
        updateTimeLabel()
    }
    
    /**
     Ring bell manually
     */
    @IBAction func manualBell(_ sender: Any) {
        mTimer.manualBell()
    }

    /**
     Called when time buttons are tapped
     */
    @IBAction func bellButtonTapped(_ sender: UIButton) {
        if (sender === bell1Button) {
            mEditingItem = 1;
        } else if (sender === bell2Button) {
            mEditingItem = 2;
        } else {
            mEditingItem = 3;
        }
        let sec = mTimer.bellTime(mEditingItem - 1)

        let vc = TimePickerViewController()
        vc.delegate = self
        vc.seconds = sec

        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .formSheet
        present(nv, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //super.touchesBegan(touches, with: event)
        let touch = event?.allTouches?.first
        if (touch?.view?.tag == timeLabel?.tag) {
            invertCountDown()
        }
    }

    /**
     Toggle count down mode
     */
    func invertCountDown() {
        mIsCountDown = !mIsCountDown;
        updateTimeLabel()
    }

    /**
     Timer handler : called for each 1 second.
     */
    func timerUpdated() {
        updateTimeLabel()
    }

    /**
     Update time label
     */
    func updateTimeLabel() {
        var t = 0
        if (!mIsCountDown) {
            t = mTimer.currentTime;
        } else {
            var cdt = mTimer.countDownTarget;
            if (cdt < 1 || 3 < cdt) {
                cdt = 2;
            }
            t = mTimer.bellTime(cdt - 1) - mTimer.currentTime;
            if (t < 0) {
                t = -t
            }
        }
        timeLabel?.text = TimerModel.timeText(t)

        var col: UIColor?
        if (mTimer.currentTime >= mTimer.bellTime(2)) {
            col = mColor3;
        } else if (mTimer.currentTime >= mTimer.bellTime(1)) {
            col = mColor2;
        } else if (mTimer.currentTime >= mTimer.bellTime(0)) {
            col = mColor1;
        } else {
            col = mColor0;
        }

        timeLabel?.textColor = col
    }

    @IBAction func showHelp(_ sender: Any) {
        let vc = InfoVC()
        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .formSheet
        present(nv, animated: true)
    }

    // MARK: TimePickerViewDelegate

    func timePickerViewSetTime(_ seconds: Int) {
        mTimer.setBellTime(seconds, index: mEditingItem - 1)
        mTimer.saveDefaults()
        updateButtonTitle()
    }

    func timePickerViewSetCountdownTarget() {
        mTimer.countDownTarget = mEditingItem
        mTimer.saveDefaults()
    }

    // MARK: Suspend support

    /// サスペンド移行
    func appSuspended() {
        mTimer.appSuspended()
    }

    /// レジューム処理
    func appResumed() {
        mTimer.appResumed()
        updateTimeLabel()
    }
}
