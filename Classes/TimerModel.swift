/*
  Presentation Timer for iPhone

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
import AVFoundation

let NUM_BELLS = 3

protocol TimerModelDelegate {
    func timerUpdated()
}

/**
 * タイマ情報　：ベル時刻およびベル音を管理
 */
class TimerInfo {
    // ベル時刻(秒)
    var bellTime: Int = -1

    // ベル音
    var soundBell: AVAudioPlayer?

    /**
     ベル鳴動
     */
    func playBell() {
        soundBell?.play()
    }

    /**
     ベル鳴動
     - Parameter delay: 遅延時間(秒)
     */
    func playBell(delay: TimeInterval) {
        if let b = soundBell {
            b.play(atTime: b.deviceCurrentTime + delay)
        }
    }

    /**
     ベル停止
     */
    func stopBell() {
        if let b = soundBell {
            if (b.isPlaying) {
                b.stop()
                b.currentTime = 0
            }
        }
    }
}

/**
 Timer business logic
 */
class TimerModel: NSObject {
    var delegate: TimerModelDelegate?

    /** 現在のタイマ時間(経過秒) */
    var currentTime: Int = 0

    /** プレゼン終了時刻タイマのインデックス(1 origin) */
    var countDownTarget: Int = 0

    /** タイマ稼働中? */
    var timerRunning: Bool {
        get {
            isTimerRunning()
        }
    }

    /** Background モードに入っているか？ */
    private var mIsInBackground = false

    /** ベル情報 */
    private var mTimerInfo = [TimerInfo?](repeating: nil, count: NUM_BELLS)

    /** interval timer */
    private var mTimer: Timer? = nil

    /** suspend に入った時刻 */
    private var mSuspendedTime: Date? = nil

    /** 最後に鳴らしたベルのインデックス */
    private var mLastPlayBell: Int = 0

    override init() {
        super.init()

        let defaults = UserDefaults.standard

        for i in 0..<NUM_BELLS {
            let ti = TimerInfo()

            var bellTime = defaults.integer(forKey: "bell\(i + 1)Time")
            if (bellTime == 0) {
                switch i {
                case 0:
                    bellTime = 13 * 60
                case 1:
                    bellTime = 15 * 60
                case 2:
                    bellTime = 20 * 60
                default:
                    break // NEVER
                }
            }
            ti.bellTime = bellTime

            let avp = loadWav(name: "\(i + 1)bell")
            ti.soundBell = avp

            mTimerInfo[i] = ti
        }

        countDownTarget = defaults.integer(forKey: "countDownTarget")
        if (countDownTarget == 0) {
            countDownTarget = 2
        }

        mLastPlayBell = -1
    }

    /** バックグランドで音がなるようにする */
    private func setBackgroundAudioEnable(enable: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            if (enable) {
                try? session.setCategory(.playback)
                try? session.setActive(true)
            } else {
                try? session.setActive(false)
            }
        }
    }

    /**
     Save default values
     */
    func saveDefaults() {
        let defaults = UserDefaults.standard
        for i in 0..<NUM_BELLS {
            defaults.set(mTimerInfo[i]!.bellTime, forKey: "bell\(i + 1)Time")
        }
        defaults.set(countDownTarget, forKey: "countDownTarget")
        defaults.synchronize()
    }

    /**
     get timer value
     - Parameter index:
     - Returns:
     */
    func bellTime(_ index: Int) -> Int {
        mTimerInfo[index]!.bellTime
    }

    func setBellTime(_ time: Int, index: Int) {
        mTimerInfo[index]!.bellTime = time
    }

    /**
     load wav file from resource
     - Parameter name:
     - Returns:
     */
    private func loadWav(name: String) -> AVAudioPlayer? {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "wav")!)
        do {
            let audio = try AVAudioPlayer(contentsOf: url)
            return audio
        } catch {
            NSLog(error.localizedDescription)
            return nil
        }
    }

    /**
     Is timer running?
     - Returns:
     */
    func isTimerRunning() -> Bool {
        mTimer != nil
    }

    /**
     Start or stop timer (toggle)
    */
    func startTimer() {
        if (mTimer != nil) {
            return // do nothing
        }

        mTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)

        // Disable auto lock when timer is running
        UIApplication.shared.isIdleTimerDisabled = true

        setBackgroundAudioEnable(enable: true)
    }

    /**
     Stop timer
     */
    func stopTimer() {
        if (mTimer == nil) {
            return // do nothing
        }
        
        // stop timer
        mTimer?.invalidate()
        mTimer = nil

        // Enable auto lock
        UIApplication.shared.isIdleTimerDisabled = false

        setBackgroundAudioEnable(enable: false)
    }

    /**
     Reset timer
     */
    func resetTimer() {
        currentTime = 0
    }

    /**
     Ring bell manually
     */
    func manualBell() {
        playBell(0)
    }

    /**
     Timer handler: called for each 1 second.
     - Parameter theTimer:
     */
    @objc func timerHandler(theTimer: Timer) {
        // バックグランド中はタイマイベントを無視する
        // TBD: 本来は止めたほうがよい。。。
        if (mIsInBackground) {
            return
        }

        currentTime += 1
        //NSLog("time: \(currentTime)")

        for i in 0..<NUM_BELLS {
            if (currentTime == mTimerInfo[i]!.bellTime) {
                playBell(i)
            }
        }

        delegate?.timerUpdated()
    }

    private func playBell(_ index: Int) {
        if (mLastPlayBell >= 0) {
            mTimerInfo[mLastPlayBell]!.stopBell()
        }
        mTimerInfo[index]!.playBell()
        mLastPlayBell = index
    }

    /**
     秒を時分秒に変換する
     - Parameter seconds: 経過秒
     - Returns:
     */
    static func timeText(_ seconds: Int) -> String {
        let sec: Int = seconds % 60
        let mm = seconds / 60
        let min: Int = mm % 60
        let hour: Int = mm / 60

        if (hour > 0) {
            return String(format: "%d:%02d:%02d", hour, min, sec)
        }
        return String(format: "%02d:%02d", min, sec)
    }

    func appSuspended() {
        mIsInBackground = true
        if (mTimer == nil) {
            return // do nothing
        }

        // timer working. remember current time
        mSuspendedTime = Date()

        // バックグランドで再生を行わせる
        for i in 0..<NUM_BELLS {
            let ti = mTimerInfo[i]!
            let delay = ti.bellTime - currentTime
            if (delay > 0) {
                NSLog("suspend: set timer \(i + 1) at delay \(delay)")
                ti.playBell(delay: Double(delay))
            }
        }
    }

    func appResumed() {
        mIsInBackground = false

        if (mTimer == nil) {
            return // do nothing
        }

        if (mSuspendedTime == nil) {
            return
        }

        let now = Date()

        // modify current time
        let interval = now.timeIntervalSince(mSuspendedTime!)
        NSLog("resumed : suspended \(mSuspendedTime!), now \(now), interval \(interval)")

        currentTime += Int(interval)
        mSuspendedTime = nil

        // stop all bells
        for i in 0..<NUM_BELLS {
            mTimerInfo[i]!.stopBell()
        }
    }
}
