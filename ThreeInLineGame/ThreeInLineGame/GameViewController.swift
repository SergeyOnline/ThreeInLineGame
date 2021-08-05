//
//  GameViewController.swift
//  ThreeInLineGame
//
//  Created by Сергей on 04.08.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
	
	var level: Level!
	var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
			let size = CGSize(width: view.frame.width + 60, height: view.frame.width + 60)
			
			scene = GameScene(size: size)
			scene.scaleMode = .aspectFit
			scene.backgroundColor = .systemTeal
			
			view.presentScene(scene)
	
//            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
			
			level = Level(filename: "Level_1")
			scene.level = level
			scene.addTiles()
			scene.swipeHandler = handleSwipe
			
			beginGame()
			
        }
    }
	
	func beginGame() {
		shuffle()
	}
	
	func shuffle() {
		let newFigures = level.shuffle()
		scene.addSprites(for: newFigures)
	}
	
	func handleSwipe(_ swap: Swap) {
		
		view.isUserInteractionEnabled = false
		
		if level.isPossibleSwap(swap) {
			level.performSwap(swap)
			scene.animate(swap, completion: handleMatches)
		} else {
			scene.animateInvalidSwap(swap) {
				self.view.isUserInteractionEnabled = true
			}
		}
	}
	
	func handleMatches() {
		let chains = level.removeMatches()
		if chains.count == 0 {
			beginNextTurn()
			return
		}
		scene.animateMatchedFigures(for: chains) {
			let columns = self.level.fillHoles()
			self.scene.animateFallingFigures(in: columns) {
				let columns = self.level.topUpFigures()
				self.scene.animateNewFigure(in: columns) {
					self.handleMatches()
				}
			}
		}
	}
	
	func beginNextTurn() {
		level.detectPossibleSwaps()
		view.isUserInteractionEnabled = true
	}


//    override var shouldAutorotate: Bool {
//        return true
//    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
}
