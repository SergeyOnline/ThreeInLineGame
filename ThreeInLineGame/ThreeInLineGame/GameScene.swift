//
//  GameScene.swift
//  ThreeInLineGame
//
//  Created by Сергей on 04.08.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	var level: Level!
	let tileWidth: CGFloat = 36.0
	let tileHeight: CGFloat = 36.0
	let tilesLayer = SKNode()
	let cropLayer = SKCropNode()
	let maskLayer = SKNode()
	var swipeHandler: ((Swap) -> Void)?
	
	private var swipeFromColumn: Int?
	private var swipeFromRow: Int?
	private var selectionSprite = SKSpriteNode()
	
	let gameLayer = SKNode()
	let figuresLayer = SKNode()
	
	override init(size: CGSize) {
		super.init(size: size)
		
		addChild(gameLayer)
		
		let layerPosition = CGPoint(
			x: size.width / 2 - tileWidth * CGFloat(numColumns) / 2,
			y: size.height / 2 - tileHeight * CGFloat(numRows) / 2)
		
		tilesLayer.position = layerPosition
		maskLayer.position = layerPosition
		cropLayer.maskNode = maskLayer
		
		figuresLayer.position = layerPosition
		
		gameLayer.addChild(tilesLayer)
		gameLayer.addChild(cropLayer)
		cropLayer.addChild(figuresLayer)
	}
	
	func showSelectionIndicator(of figure: Figure) {
		if selectionSprite.parent != nil {
			selectionSprite.removeFromParent()
		}
		
		if let sprite = figure.sprite {
			let texture = SKTexture(imageNamed: figure.figureType.highlitedFigureName)
			selectionSprite.size = CGSize(width: tileWidth, height: tileHeight)
			selectionSprite.run(SKAction.setTexture(texture))
			
			sprite.addChild(selectionSprite)
			selectionSprite.alpha = 1.0
		}
	}
	
	func hideSelectionIndicator() {
		selectionSprite.run(SKAction.sequence([
												SKAction.fadeOut(withDuration: 0.3),
												SKAction.removeFromParent()]))
	}
	
	func addSprites(for figures: Set<Figure>) {
		for figure in figures {
			let sprite = SKSpriteNode(imageNamed: figure.figureType.figureName)
			sprite.size = CGSize(width: tileWidth, height: tileHeight)
			sprite.position = pointFor(column: figure.column, row: figure.row)
			figuresLayer.addChild(sprite)
			figure.sprite = sprite
		}
	}
	
	func addTiles() {
		for row in 0..<numRows {
			for column in 0..<numColumns {
				if level.tileAt(column: column, row: row) != nil {
					let tileNode = SKSpriteNode(imageNamed: "MaskTile")
					tileNode.size = CGSize(width: tileWidth, height: tileHeight)
					tileNode.position = pointFor(column: column, row: row)
					maskLayer.addChild(tileNode)
				}
			}
		}
		
		for row in 0...numRows {
			for column in 0...numColumns {
				let topLeft = ((column > 0) && (row < numRows) && level.tileAt(column: column - 1, row: row) != nil) ? 1 : 0
				let bottomLeft = ((column > 0) && (row > 0) && level.tileAt(column: column - 1, row: row - 1) != nil) ? 1 : 0
				let topRight = ((column < numColumns) && (row < numRows) && level.tileAt(column: column, row: row) != nil) ? 1 : 0
				let bottomRight = ((column < numColumns) && (row > 0) && level.tileAt(column: column, row: row - 1) != nil) ? 1: 0
				
				
				
				var value = topLeft
				
				value = value | topRight << 1
				value = value | bottomLeft << 2
				value = value | bottomRight << 3
				
				if value != 0 && value != 6 && value != 9 {
					let name = String(format: "Tile_%ld", value)
					let tileNode = SKSpriteNode(imageNamed: name)
					tileNode.alpha = 0.5
					tileNode.size = CGSize(width: tileWidth, height: tileHeight)
					var point = pointFor(column: column, row: row)
					point.x -= tileWidth / 2
					point.y -= tileHeight / 2
					tileNode.position = point
					tilesLayer.addChild(tileNode)
				}
			}
		}
	}
	
	private func pointFor(column: Int, row: Int) -> CGPoint {
		return CGPoint(
			x: CGFloat(column) * tileWidth + tileWidth / 2,
			y: CGFloat(row) * tileHeight + tileHeight / 2)
	}
	
	private func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
		if point.x >= 0 && point.x < CGFloat(numColumns) * tileWidth &&
			point.y >= 0 && point.y < CGFloat(numRows) * tileHeight {
			return (true, Int(point.x / tileWidth), Int(point.y / tileHeight))
		} else {
			return (false, 0, 0)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: figuresLayer)
		
		let (success, column, row) = convertPoint(location)
		if success {
			if let figure = level.figure(atColumn: column, row: row) {
				showSelectionIndicator(of: figure)
				swipeFromColumn = column
				swipeFromRow = row
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard swipeFromColumn != nil else { return }
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: figuresLayer)
		
		let (success, column, row) = convertPoint(location)
		if success {
			
			var horizontalDelta = 0, verticalDelta = 0
			if column < swipeFromColumn! {
				horizontalDelta = -1
			} else if column > swipeFromColumn! {
				horizontalDelta = 1
			} else if row < swipeFromRow! {
				verticalDelta = -1
			} else if row > swipeFromRow! {
				verticalDelta = 1
			}
			
			
			if horizontalDelta != 0 || verticalDelta != 0 {
				trySwap(horizontalDelta: horizontalDelta, verticalDelta: verticalDelta)

				hideSelectionIndicator()
				swipeFromColumn = nil
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if selectionSprite.parent != nil && swipeFromColumn != nil {
			hideSelectionIndicator()
		}
		swipeFromColumn = nil
		swipeFromRow = nil
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		touchesEnded(touches, with: event)
	}
	
	private func trySwap(horizontalDelta: Int, verticalDelta: Int) {
		
		let toColumn = swipeFromColumn! + horizontalDelta
		let toRow = swipeFromRow! + verticalDelta
		
		guard toColumn >= 0 && toColumn < numColumns else { return }
		guard toRow >= 0 && toRow < numRows else { return }
		
		if let toFigure = level.figure(atColumn: toColumn, row: toRow),
		   let fromFigure = level.figure(atColumn: swipeFromColumn!, row: swipeFromRow!) {
			
			print("*** swapping \(fromFigure) with \(toFigure)")
			if let handler = swipeHandler {
				let swap = Swap(figureA: fromFigure, figureB: toFigure)
				handler(swap)
			}
		}
	}
	
	func animate(_ swap: Swap, completion: @escaping () -> Void) {
		let spriteA = swap.figureA.sprite!
		let spriteB = swap.figureB.sprite!
		
		spriteA.zPosition = 100
		spriteB.zPosition = 90
		
		let duration: TimeInterval = 0.3
		
		let moveA = SKAction.move(to: spriteB.position, duration: duration)
		moveA.timingMode = .easeOut
		spriteA.run(moveA, completion: completion)
		
		let moveB = SKAction.move(to: spriteA.position, duration: duration)
		moveB.timingMode = .easeOut
		spriteB.run(moveB)
	}
	
	func animateMatchedFigures(for chains: Set<Chain>, completion: @escaping () -> Void) {
		for chain in chains {
			for figure in chain.figures {
				if let sprite = figure.sprite {
					if sprite.action(forKey: "removing") == nil {
						let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
						scaleAction.timingMode = .easeOut
						sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey: "removing")
					}
				}
			}
		}
		
		run(SKAction.wait(forDuration: 0.3), completion: completion)
	}
	
	func animateFallingFigures(in columns: [[Figure]], completion: @escaping () -> Void) {
		var longestDuration: TimeInterval = 0
		for array in columns {
			for (index, figure) in array.enumerated() {
				let newPosition = pointFor(column: figure.column, row: figure.row)
				
				let delay = 0.05 + 0.15 * TimeInterval(index)
				
				let sprite = figure.sprite!
				
				let duration = TimeInterval(((sprite.position.y - newPosition.y) / tileHeight) * 0.1)
				
				longestDuration = max(longestDuration, duration + delay)
				
				let moveAction = SKAction.move(to: newPosition, duration: duration)
				moveAction.timingMode = .easeOut
				sprite.run(SKAction.sequence([
												SKAction.wait(forDuration: delay),
												SKAction.group([moveAction])]))
				
			}
		}
		
		run(SKAction.wait(forDuration: 0.3), completion: completion)
	}
	
	func animateNewFigure(in columns: [[Figure]], completion: @escaping () -> Void) {
		var longestDuration: TimeInterval = 0
		
		for array in columns {
			let startRow = array[0].row + 1
			
			for (index, figure) in array.enumerated() {
				
				let sprite = SKSpriteNode(imageNamed: figure.figureType.figureName)
				sprite.size = CGSize(width: tileWidth, height: tileHeight)
				sprite.position = pointFor(column: figure.column, row: startRow)
				figuresLayer.addChild(sprite)
				figure.sprite = sprite
				
				let delay = 0.1 * 0.2 * TimeInterval(array.count - index - 1)
				
				let duration = TimeInterval(startRow - figure.row) * 0.1
				longestDuration = max(longestDuration, duration + delay)
				
				let newPosition = pointFor(column: figure.column, row: figure.row)
				
				let moveAction = SKAction.move(to: newPosition, duration: duration)
				moveAction.timingMode = .easeOut
				sprite.alpha = 0
				sprite.run(SKAction.sequence([
												SKAction.wait(forDuration: delay),
												SKAction.group([
																SKAction.fadeIn(withDuration: 0.05),
																moveAction])]))
			}
		}
		run(SKAction.wait(forDuration: longestDuration), completion: completion)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func animateInvalidSwap(_ swap: Swap, complition: @escaping () -> Void) {
		let spriteA = swap.figureA.sprite!
		let spriteB = swap.figureB.sprite!
		
		spriteA.zPosition = 100
		spriteB.zPosition = 90
		
		let duration: TimeInterval = 0.2
		
		let moveA = SKAction.move(to: spriteB.position, duration: duration)
		moveA.timingMode = .easeOut
		
		let moveB = SKAction.move(to: spriteA.position, duration: duration)
		moveB.timingMode = .easeOut
		
		spriteA.run(SKAction.sequence([moveA, moveB]), completion: complition)
		spriteB.run(SKAction.sequence([moveB, moveA]))
	}
    
}
