//
//  ViewController.swift
//  Shape Target
//
//  Created by Trevor Stevenson on 4/27/15.
//  Copyright (c) 2015 NCUnited. All rights reserved.
//

import UIKit
import iAd
import GameKit

class ViewController: UIViewController, GKGameCenterControllerDelegate, ADBannerViewDelegate {

    var isGameRunning: Bool = false
    var timer = Timer()
    var adTimer = Timer()
    var score = 0
    var time = 0.55
    
    var localPlayer = GKLocalPlayer()
    var gameCenterEnabled: Bool = false
    var leaderBoardIdentifier: String = "highScore3"
    
    var targetShape = ""
    var shapes: [UIBezierPath] = []
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var freePointsButton: UIButton!

    var shapeFrame: CGRect = CGRect.zero
    var centerShape: Shape = Shape(Cframe: CGRect.zero, pShape: "trevor", shapePath: UIBezierPath(), color: "trevor")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var side: CGFloat = 200
        
        if (self.view.bounds.size.height == 480)
        {
            side = 150
        }
        
        let size = self.view.frame.size
        shapeFrame = CGRect(x: size.width/2 - side/2, y: size.height/2 - side/2, width: side, height: side)
        
        let square = UIBezierPath(rect: CGRect(x: 0, y: 0, width: shapeFrame.width, height: shapeFrame.height))
        let circle = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: shapeFrame.width, height: shapeFrame.height))
        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: 0, y: shapeFrame.height))
        triangle.addLine(to: CGPoint(x: shapeFrame.size.width/2, y: 0))
        triangle.addLine(to: CGPoint(x: shapeFrame.size.width, y: shapeFrame.height))
        triangle.addLine(to: CGPoint(x: 0, y: shapeFrame.height))
        triangle.close()
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: shapeFrame.size.width/2, y: 0))
        diamond.addLine(to: CGPoint(x: 0, y: shapeFrame.size.height/2))
        diamond.addLine(to: CGPoint(x: shapeFrame.size.width/2, y: shapeFrame.size.height))
        diamond.addLine(to: CGPoint(x: shapeFrame.size.width, y: shapeFrame.size.height/2))
        diamond.addLine(to: CGPoint(x: shapeFrame.size.width/2, y: 0))
        diamond.close()
        let rectangle = UIBezierPath(rect: CGRect(x: shapeFrame.size.width/4, y: 0, width: shapeFrame.size.width/2, height: shapeFrame.size.height))
        let trapezoid = UIBezierPath()
        trapezoid.move(to: CGPoint(x: 0, y: shapeFrame.height))
        trapezoid.addLine(to: CGPoint(x: shapeFrame.size.width/4, y: 0))
        trapezoid.addLine(to: CGPoint(x: 3 * (shapeFrame.size.width/4), y: 0))
        trapezoid.addLine(to: CGPoint(x: shapeFrame.size.width, y: shapeFrame.height))
        trapezoid.addLine(to: CGPoint(x: 0, y: shapeFrame.size.height))
        trapezoid.close()
        
        shapes = [square, circle, triangle, diamond, rectangle, trapezoid]
        
        let indx = arc4random_uniform(UInt32(shapes.count))
        
        let rand = shapes[Int(indx)]
        
        centerShape = Shape(Cframe: shapeFrame, pShape: "trevor", shapePath: rand, color: "trevor")
        
        centerShape.shapeName = giveShapeName(Int(indx))
        
        self.view.addSubview(centerShape)
        
        scoreLabel.text = "Score: " + String(score)
        
        targetLabel.text = "Tap to begin"
        
        highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScore"))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        freePointsButton.isHidden = true
        
        adTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.isAdAvailable), userInfo: nil, repeats: true)
        
        authenticateLocalPlayer()
        
        if (UserDefaults.standard.bool(forKey: "addPoints"))
        {
            score += 2
            UserDefaults.standard.set(false, forKey: "addPoints")
            UserDefaults.standard.synchronize()
        }
        
        scoreLabel.text = "Score: " + String(score)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        adTimer.invalidate()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        
        UIView.beginAnimations(nil, context: nil)
        
        UIView.setAnimationDuration(1.0)
        
        banner.alpha = 1.0
        
        UIView.commitAnimations()
        
        
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        
        UIView.beginAnimations(nil, context: nil)
        
        UIView.setAnimationDuration(1.0)
        
        banner.alpha = 0.0
        
        UIView.commitAnimations()
        
    }
    
    func isAdAvailable()
    {
        if (AdColony.isVirtualCurrencyRewardAvailable(forZone: "vz73520002517646db89"))
        {
            freePointsButton.isHidden = false
        }
        else
        {
            freePointsButton.isHidden = true
        }
    }
    
    func authenticateLocalPlayer()
    {
        localPlayer.authenticateHandler = {(viewController: UIViewController?, error: Error?) in
            
            if (viewController != nil)
            {
                self.present(viewController!, animated: true, completion: nil)
            }
            else
            {
                if (GKLocalPlayer.localPlayer().isAuthenticated)
                {
                    self.gameCenterEnabled = true
                    
                    GKLocalPlayer.localPlayer().loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier:String?, error: Error?) -> Void in
                        
                        if let e = error
                        {
                            print(e.localizedDescription)
                        }
                        else
                        {
                            self.leaderBoardIdentifier = leaderboardIdentifier!
                            
                            GKNotificationBanner.show(withTitle: "Welcome", message: "Get a high score!", completionHandler: { () -> Void in
                                
                            })
                        }
                        
                    })
                    
                }
                else
                {
                    self.gameCenterEnabled = false
                }
            }
            
        }
        
    }
    
    func showLeaderboard(_ identifier: NSString)
    {
        let GKVC = GKGameCenterViewController()
        
        GKVC.gameCenterDelegate = self
        
        GKVC.viewState = GKGameCenterViewControllerState.leaderboards
        
        GKVC.leaderboardIdentifier = identifier as String
        
        present(GKVC, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leaderboard(_ sender: AnyObject)
    {
        showLeaderboard(leaderBoardIdentifier as NSString)
    }
    
    func giveShapeName(_ index: Int) -> String
    {
        
        var name = ""
        
        switch index
        {
        case 0:
            name = "Square"
            break
            
        case 1:
            name = "Circle"
            break
            
        case 2:
            name = "Triangle"
            break
            
        case 3:
            name = "Diamond"
            break
            
        case 4:
            name = "Rectangle"
            break
            
        case 5:
            name = "Trapezoid"
            break
            
        default:
            name = ""
            break
        }
        
        return name

    }
    
    func check()
    {
        if (centerShape.shapeName == targetShape)
        {
            score += 1
            
            scoreLabel.text = "Score: " + String(score)
            
            targetLabel.text = "Tap to begin"
            
        }
        else
        {
            targetLabel.text = "Game Over"
            
            time = 0.55
            
            submitScore()
            
            var hScore = UserDefaults.standard.integer(forKey: "highScore")
            
            if (score > hScore)
            {
                hScore = score
                
                UserDefaults.standard.set(hScore, forKey: "highScore")
                
                UserDefaults.standard.synchronize()
            }
            
            highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScore"))
            
            score = 0
            
            scoreLabel.text = "Score: " + String(score)
            
        }
    }
    
    
    func beginCycle()
    {
        let random = arc4random_uniform(UInt32(shapes.count))
        
        targetShape = giveShapeName(Int(random))
        
        targetLabel.text = "Target: " + targetShape
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(time), target: self, selector: #selector(ViewController.changeShape), userInfo: nil, repeats: true)
    }
    
    func endCycle()
    {
        timer.invalidate()
        
        check()
    }
    
    
    
    func changeShape()
    {
        let currentShape  = centerShape.shapeName
        let currentColor = centerShape.fillColor
        
        var side: CGFloat = 200
        
        if (self.view.bounds.size.height == 480)
        {
            side = 150
        }
        
        let size = self.view.frame.size
        shapeFrame = CGRect(x: size.width/2 - side/2, y: size.height/2 - side/2, width: side, height: side)
        
        centerShape.removeFromSuperview()
        
        var random = arc4random_uniform(UInt32(shapes.count))
        
        while (currentShape == giveShapeName(Int(random)))
        {
            random = arc4random_uniform(UInt32(shapes.count))

        }
        
        centerShape = Shape(Cframe: shapeFrame, pShape: currentShape, shapePath: shapes[Int(random)], color: currentColor)
        centerShape.shapeName = giveShapeName(Int(random))
        
        self.view.addSubview(centerShape)
    }
    
    func submitScore()
    {
        let id: String = "highScore3"
        
        let highScore = GKScore(leaderboardIdentifier:id)
        
        highScore.value = Int64(score)
        
        GKScore.report([highScore], withCompletionHandler: { (error: Error?) -> Void in
            
            if let e = error
            {
                print(e.localizedDescription)
            }
        })
        
    }
    
    @IBAction func tapped(_ sender: AnyObject)
    {
        
        if (isGameRunning)
        {
            endCycle()
            
            isGameRunning = false
        }
        else
        {
            beginCycle()
            
            isGameRunning = true
        }
        
    }


}

