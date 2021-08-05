//
//  Swap.swift
//  ThreeInLineGame
//
//  Created by Сергей on 05.08.2021.
//

struct Swap: CustomStringConvertible, Hashable {
	let figureA: Figure
	let figureB: Figure
	
	private var hashCompute: Int {
		return figureA.hashValue ^ figureB.hashValue
	}
	
	init(figureA: Figure, figureB: Figure) {
		self.figureA = figureA
		self.figureB = figureB
	}
	
	static func ==(lhs: Swap, rhs: Swap) -> Bool {
		return (lhs.figureA == rhs.figureA && lhs.figureB == rhs.figureB) ||
			(lhs.figureB == rhs.figureA && lhs.figureA == rhs.figureB)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(hashCompute)
	}
	
	var description: String {
		return "swap \(figureA) with \(figureB)"
	}
}
