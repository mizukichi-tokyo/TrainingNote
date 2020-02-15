//
//  CalenderViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit

class CalenderViewController: UIViewController {

    @IBAction func moveToSetting(_ sender: Any) {
        let settingVC = SettingViewController()
        settingVC.modalPresentationStyle = .fullScreen
        present(settingVC, animated: true, completion: nil)
    }

    @IBAction func moveToNote(_ sender: Any) {
        let noteVC = NoteViewController()
        noteVC.modalPresentationStyle = .fullScreen
        present(noteVC, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
