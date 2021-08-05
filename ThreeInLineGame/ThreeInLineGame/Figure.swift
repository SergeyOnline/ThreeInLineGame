//
//  Figure.swift
//  ThreeInLineGame
//
//  Created by Сергей on 05.08.2021.
//

import SpriteKit

enum FigureType: Int {
	
	var figureName: String {
		let figureNames = [
			"blue",
			"green",
			"lightBlue",
			"pink",
			"red",
			"yellow"]
		
		return figureNames[rawValue - 1]
	}
	
	var highlitedFigureName: String {
		return figureName + "-highlited"
	}
	
	case unknown = 0
	case blue
	case green
	case lightBlue
	case pink
	case red
	case yellow
	
	static func random() -> FigureType {
		return FigureType(rawValue: Int(arc4random_uniform(6)) + 1)!
	}
}

class Figure: CustomStringConvertible, Hashable {

	var column: Int
	var row: Int
	let figureType: FigureType
	var sprite: SKSpriteNode?
	
	static func ==(lhs: Figure, rhs: Figure) -> Bool {
		return lhs.column == rhs.column && lhs.row == rhs.row
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(column)
		hasher.combine(row)
	}
	
	var description: String {
		return "type:\(figureType) square:(\(column),\(row))"
	}
	
	init(column: Int, row: Int, figureType: FigureType) {
		self.column = column
		self.row = row
		self.figureType = figureType
	}
}
