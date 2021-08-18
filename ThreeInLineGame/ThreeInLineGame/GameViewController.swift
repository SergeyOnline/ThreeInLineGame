//
//  GameViewController.swift
//  ThreeInLineGame
//
//  Created by Сергей on 04.08.2021.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

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
	
	lazy var backgroundMusic: AVAudioPlayer? = {
		guard let url = Bundle.main.url(forResource: "Background", withExtension: "mp3") else { print("FILE NOT FOUND"); return nil }
		do {
			let player = try AVAudioPlayer(contentsOf: url)
			player.numberOfLoops = -1
			player.volume = 0.2
			return player
		} catch {
			return nil
		}
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupLabeles()
		
        if let view = self.view as! SKView? {

			let targetVStack = UIStackView(withAxis: .vertical, distribution: .equalCentering, arrangedSubviews: [target, targetLabel])
			
			let movesVStack = UIStackView(withAxis: .vertical, distribution: .equalCentering, arrangedSubviews: [moves, movesLabel])
			
			let scoreVStack = UIStackView(withAxis: .vertical, distribution: .equalCentering, arrangedSubviews: [scores, scoreLabel])
			
			let horizontalStack = UIStackView(withAxis: .horizontal, distribution: .fillEqually, arrangedSubviews: [targetVStack, movesVStack, scoreVStack])
			
			horizontalStack.translatesAutoresizingMaskIntoConstraints = false
			
			view.addSubview(horizontalStack)

				
			horizontalStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
			horizontalStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
			horizontalStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
			
			
			setupShaffleButton()
			shuffleButton.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(shuffleButton)

			shuffleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
			shuffleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			shuffleButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
			
			
			gameOverPanel = UIImageView(frame: CGRect(x: 0, y: view.frame.midY - 25, width: view.frame.width, height: 50))
			gameOverPanel.backgroundColor = .brown
			
			view.addSubview(gameOverPanel)
			
			setupLevel(number: currentLevelNumber)
	
//            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
			
			backgroundMusic?.play()
			
        }
    }
	
	func setupLevel(number levelNumber: Int) {
		let skView = view as! SKView
		skView.isMultipleTouchEnabled = false
		
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .aspectFill
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
			//FIXME: - delete label
			let label = UILabel(withTitleLabel: "Level comlete")
			label.translatesAutoresizingMaskIntoConstraints = false
			gameOverPanel.addSubview(label)
			label.centerXAnchor.constraint(equalTo: gameOverPanel.centerXAnchor).isActive = true
			label.centerYAnchor.constraint(equalTo: gameOverPanel.centerYAnchor).isActive = true
//			gameOverPanel.image = UIImage(named: "LevelComplete")
			currentLevelNumber = currentLevelNumber < numLevels ? currentLevelNumber + 1 : 0
			showGameOver()
		} else if movesLeft == 0 {
			//FIXME: - delete label
			let label = UILabel(withTitleLabel: "Game over")
			label.translatesAutoresizingMaskIntoConstraints = false
			gameOverPanel.addSubview(label)
			label.centerXAnchor.constraint(equalTo: gameOverPanel.centerXAnchor).isActive = true
			label.centerYAnchor.constraint(equalTo: gameOverPanel.centerYAnchor).isActive = true
//			gameOverPanel.image = UIImage(named: "GameOver")
			showGameOver()
		}
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
		
		//FIXME: - delete label
		for view in gameOverPanel.subviews {
			view.removeFromSuperview()
		}
		
		setupLevel(number: currentLevelNumber)
	}
	
	//MARK: - Setup components
	
	func setupShaffleButton() {
		shuffleButton = UIButton()
		shuffleButton.backgroundColor = .systemTeal

		shuffleButton.setTitle("Shuffle", for: .normal)
		shuffleButton.setTitleColor(.black, for: .normal)
		shuffleButton.setTitleColor(.white, for: .highlighted)
		shuffleButton.layer.cornerRadius = 10
		shuffleButton.addTarget(self, action: #selector(shuffleButtonPressed), for: .touchDown)
	}
	
	func setupLabeles() {
		target = UILabel(withTitleLabel: "Target:")
		targetLabel = UILabel(withTitleLabel: "0")
		
		moves = UILabel(withTitleLabel: "Moves:")
		movesLabel = UILabel(withTitleLabel: "0")
		
		scores = UILabel(withTitleLabel: "Score:")
		scoreLabel = UILabel(withTitleLabel: "0")
	}
	
	
}

extension UILabel {
	convenience init(withTitleLabel text: String) {
		self.init()
		self.text = text
		self.textColor = .black
		self.textAlignment = .center
		self.backgroundColor = .systemTeal
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 5
	}
}

extension UIStackView {
	convenience init(withAxis axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, arrangedSubviews: [UIView]) {
		self.init(arrangedSubviews: arrangedSubviews)
		self.axis = axis
		self.distribution = distribution
		self.spacing = 4
	}
}
