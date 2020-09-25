//
//  LaunchViewController.swift
//  Kait
//
//  Created by Apple on 31/08/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit
import AVKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideNavigationBar()
        playVideo()
        //self.view.backgroundColor = UIColor.black
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func playVideo() {
        
        guard let path = Bundle.main.path(forResource: "kaitintro", ofType:"mov") else {
            debugPrint("Intro.mov not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: false)
        
    }

}
