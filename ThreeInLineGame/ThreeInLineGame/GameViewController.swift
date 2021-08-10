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
	
	var target: UILabel!
	var moves: UILabel!
	var scores: UILabel!
	var targetLabel: UILabel!
	var movesLabel: UILabel!
	var scoreLabel: UILabel!
	var gameOverPanel: UIImageView!
	var tapGestureRecognizer: UITapGestureRecognizer!
	var shuffleButton: UIButton!
	var currentLevelNumber = 0
	
	var score: Int!
	var movesLeft: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLabeles()
        
        if let view = self.view as! SKView? {

			let targetVStack = UIStackView(arrangedSubviews: [target, targetLabel])
			targetVStack.axis = .vertical
			targetVStack.distribution = .equalCentering
			targetVStack.spacing = 4
			
			let movesVStack = UIStackView(arrangedSubviews: [moves, movesLabel])
			movesVStack.axis = .vertical
			movesVStack.distribution = .equalCentering
			movesVStack.spacing = 4
			
			let scoreVStack = UIStackView(arrangedSubviews: [scores, scoreLabel])
			scoreVStack.axis = .vertical
			scoreVStack.distribution = .equalCentering
			scoreVStack.spacing = 4
			
			let horizontalStack = UIStackView(arrangedSubviews: [targetVStack, movesVStack, scoreVStack])
			horizontalStack.axis = .horizontal
			horizontalStack.distribution = .fillEqually
			horizontalStack.spacing = 4
			horizontalStack.translatesAutoresizingMaskIntoConstraints = false
			
			view.addSubview(horizontalStack)

				
			horizontalStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
			horizontalStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
			horizontalStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
			
			shuffleButton = UIButton()
			shuffleButton.backgroundColor = .systemGray3

			shuffleButton.setTitle("Shuffle", for: .normal)
			shuffleButton.setTitleColor(.black, for: .normal)
			shuffleButton.setTitleColor(.white, for: .highlighted)
			shuffleButton.layer.cornerRadius = 10
			shuffleButton.addTarget(self, action: #selector(shuffleButtonPressed), for: .touchDown)

			shuffleButton.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(shuffleButton)

			shuffleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
			shuffleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			shuffleButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
			
			
			gameOverPanel = UIImageView(frame: CGRect(x: 0, y: view.frame.midY - 25, width: view.frame.width, height: 50))
			gameOverPanel.backgroundColor = .brown
			
			view.addSubview(gameOverPanel)
			
			setupLevel(number: currentLevelNumber)
	
//            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
			
        }
    }
	
	func setupLevel(number levelNumber: Int) {
		let skView = view as! SKView
		skView.isMultipleTouchEnabled = false
		
		
		let size = CGSize(width: view.frame.width + 60, height: view.frame.width + 60)
		
		scene = GameScene(size: size)
		scene.scaleMode = .aspectFit
		scene.backgroundColor = .systemTeal
		
		level = Level(filename: "Level_\(levelNumber)")
		scene.level = level
		
		scene.addTiles()
		scene.swipeHandler = handleSwipe
		
		gameOverPanel.isHidden = true
		shuffleButton.isHidden = true
		
		skView.presentScene(scene)
		
		beginGame()
	}
	
	@objc func shuffleButtonPressed(_ sender: UIButton) {
		shuffle()
		decrementMoves()
	}
	
	func beginGame() {
		movesLeft = level.maximumMovies
		score = 0
		updateLabels()
		level.resetComboMultiplier()
		scene.animateBeginGame {
			self.shuffleButton.isHidden = false
		}
		shuffle()
	}
	
	func shuffle() {
		scene.removeAllFigureSprites()
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
			for chain in chains {
				self.score += chain.score
			}
			self.updateLabels()
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
		decrementMoves()
		level.resetComboMultiplier()
		level.detectPossibleSwaps()
		view.isUserInteractionEnabled = true
	}
	
	func decrementMoves() {
		
		movesLeft -= 1
		updateLabels()
		
		if score >= level.targetScore {
//			gameOverPanel.image = UIImage(named: "LevelComplete")
			currentLevelNumber = currentLevelNumber < numLevels ? currentLevelNumber + 1 : 0
			print("CURR LN: \(currentLevelNumber)")
			showGameOver()
		} else if movesLeft == 0 {
//			gameOverPanel.image = UIImage(named: "GameOver")
			showGameOver()
		}
	}
	
	func setupLabeles() {
		target = UILabel()
		target.text = "Target:"
		target.textAlignment = .center
		target.backgroundColor = .red
		
		targetLabel = UILabel()
		targetLabel.textAlignment = .center
		targetLabel.text = "0"
		targetLabel.backgroundColor = .red
		
		
		moves = UILabel()
		moves.text = "Moves:"
		moves.textAlignment = .center
		moves.backgroundColor = .green
		
		movesLabel = UILabel()
		movesLabel.textAlignment = .center
		movesLabel.text = "0"
		movesLabel.backgroundColor = .green
		
		
		scores = UILabel()
		scores.text = "Score:"
		scores.textAlignment = .center
		scores.backgroundColor = .blue
		
		scoreLabel = UILabel()
		scoreLabel.textAlignment = .center
		scoreLabel.text = "0"
		scoreLabel.backgroundColor = .blue
	}

	func updateLabels() {
		targetLabel.text = String(format: "%ld", level.targetScore)
		movesLabel.text = String(format: "%ld", movesLeft)
		scoreLabel.text = String(format: "%ld", score)
	}
	
	func showGameOver() {
		shuffleButton.isHidden = true
		gameOverPanel.isHidden = false
		scene.isUserInteractionEnabled = false
		
		scene.animateGameOver {
			self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
			self.view.addGestureRecognizer(self.tapGestureRecognizer)
		}
	}
	
	@objc func hideGameOver() {
		view.removeGestureRecognizer(tapGestureRecognizer)
		tapGestureRecognizer = nil
		
		gameOverPanel.isHidden = true
		scene.isUserInteractionEnabled = true
		
		setupLevel(number: currentLevelNumber)
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
