//
//  Chain.swift
//  ThreeInLineGame
//
//  Created by Сергей on 05.08.2021.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
	
	enum ChainType: CustomStringConvertible {
		case horizontal
		case vertical
		
		var description: String {
			switch self {
			case .horizontal: return "Horizontal"
			case .vertical: return "Vertical"
			}
		}
	}
	
	var figures: [Figure] = []
	var score = 0
	var chainType: ChainType
	
	init(chainType: ChainType) {
		self.chainType = chainType
	}
	
	func add(figure: Figure) {
		figures.append(figure)
	}
	
	func firstFigure() -> Figure {
		return figures[0]
	}
	
	func lastFigure() -> Figure {
		return figures[figures.count - 1]
	}
	
	var lenght: Int {
		return figures.count
	}
	
	var description: String {
		return "type:\(chainType) cookies:\(figures)"
	}
	
	static func ==(lhs: Chain, rhs: Chain) -> Bool {
		return lhs.figures == rhs.figures
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(figures)
	}
}

