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

class InfoVC : UIViewController {
    @IBOutlet weak var mNameLabel: UILabel?
    @IBOutlet weak var mVersionLabel: UILabel?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: "InfoView", bundle: nil)
    }

    // Implement viewDidLoad to do additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Info", comment: "");
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InfoVC.doneAction(sender:)))

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        mVersionLabel?.text = "Version \(version ?? "?")"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func doneAction(sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func webButtonTapped() {
        let url = URL(string: NSLocalizedString("HelpURL", comment: "web help url"))
        UIApplication.shared.open(url!, completionHandler: nil)
    }
}
