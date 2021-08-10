//
//  Level.swift
//  ThreeInLineGame
//
//  Created by Сергей on 05.08.2021.
//

import Foundation

let numColumns = 9
let numRows = 9
let numLevels = 2

class Level {

	private var possibleSwaps: Set<Swap> = []
	var targetScore = 0
	var maximumMovies = 0
	private var comboMultiplier = 0
	
	private var figures = Array2D<Figure?>(columns: numColumns, rows: numRows, initialValue: Figure(column: 0, row: 0, figureType: FigureType.unknown))
	
	private var tiles = Array2D<Tile?>(columns: numColumns, rows: numRows, initialValue: Tile(column: 0, row: 0))
	
	func tileAt(column: Int, row: Int) -> Tile? {
		precondition(column >= 0 && column < numColumns)
		precondition(row >= 0 && row < numRows)
		return tiles[column, row]
	}
	
	func figure(atColumn column: Int, row: Int) -> Figure? {
		precondition(column >= 0 && column < numColumns)
		precondition(row >= 0 && row < numRows)
		return figures[column, row]
	}
	
	func shuffle() -> Set<Figure> {
		var set: Set<Figure>
		repeat {
			set = createInitialFigures()
			detectPossibleSwaps()
//			print("possible swaps: \(possibleSwaps)")
		} while possibleSwaps.count == 0
		
		return set
	}
	
	private func hasChain(atColumn column: Int, row: Int) -> Bool {
		let figureType = figures[column, row]!.figureType

		var horizontalLenght = 1

		//left
		var i = column - 1
		while i >= 0 && figures[i, row]?.figureType == figureType {
			i -= 1
			horizontalLenght += 1
		}

		//right
		i = column + 1
		while i < numColumns && figures[i, row]?.figureType == figureType {
			i += 1
			horizontalLenght += 1
		}
		if horizontalLenght >= 3 { return true }

		var verticalLenght = 1

		//down
		i = row - 1
		while i >= 0 && figures[column, i]?.figureType == figureType {
			i -= 1
			verticalLenght += 1
		}

		//up
		i = row + 1
		while i < numRows && figures[column, i]?.figureType == figureType {
			i += 1
			verticalLenght += 1
		}
		return verticalLenght >= 3
	}
	
	
	func detectPossibleSwaps() {
		var set: Set<Swap> = []
		
		for row in 0..<numRows {
			for column in 0..<numColumns {
				if let figure = figures[column, row] {
					
					
					if column < numColumns - 1,
					   let other = figures[column + 1, row] {
						figures[column, row] = other
						figures[column + 1, row] = figure
						
						if hasChain(atColumn: column + 1, row: row) ||
							hasChain(atColumn: column, row: row) {
							set.insert(Swap(figureA: figure, figureB: other))
						}
						
						figures[column, row] = figure
						figures[column + 1, row] = other
					}
					
					if row < numRows - 1,
					   let other = figures[column, row + 1] {
						figures[column, row] = other
						figures[column, row + 1] = figure
						
						if hasChain(atColumn: column, row: row + 1) ||
							hasChain(atColumn: column, row: row) {
							set.insert(Swap(figureA: figure, figureB: other))
						}
						
						figures[column, row] = figure
						figures[column, row + 1] = other
					} else if column == numColumns - 1, let figure = figures[column, row] {
						if row < numRows - 1,
						   let other = figures[column, row + 1] {
							figures[column, row] = other
							figures[column, row + 1] = figure
							
							if hasChain(atColumn: column, row: row + 1) ||
								hasChain(atColumn: column, row: row) {
								set.insert(Swap(figureA: figure, figureB: other))
							}
							
							figures[column, row] = figure
							figures[column, row + 1] = other
						}
					}
				}
			}
		}
		
		possibleSwaps = set
	}
	
//	func detectPossibleSwaps() {
//		var set: Set<Swap> = []
//
//		for row in 0..<numRows {
//			for column in 0..<numColumns {
//				if let figure = figures[column, row] {
//					if column < numColumns - 1, let other = figures[column + 1, row] {
//						figures[column, row] = other
//						figures[column + 1, row] = figure
//
//						if hasChain(atColumn: column + 1, row: row) ||
//							hasChain(atColumn: column, row: row) {
//							set.insert(Swap(figureA: figure, figureB: other))
//						}
//
//						figures[column, row] = figure
//						figures[column + 1, row] = other
//					}
//
//					if row < numRows - 1, let other = figures[column, row + 1] {
//						figures[column, row] = other
//						figures[column, row + 1] = figure
//
//						if hasChain(atColumn: column, row: row + 1) ||
//							hasChain(atColumn: column, row: row) {
//							set.insert(Swap(figureA: figure, figureB: other))
//						}
//
//						figures[column, row] = figure
//						figures[column, row + 1] = other
//					}
//				} else if column == numColumns - 1, let figure = figures[column, row] {
//					if row < numRows - 1, let other = figures[column, row + 1] {
//						figures[column, row] = other
//						figures[column, row + 1] = figure
//
//						if hasChain(atColumn: column, row: row + 1) ||
//							hasChain(atColumn: column, row: row) {
//							set.insert(Swap(figureA: figure, figureB: other))
//						}
//
//						figures[column, row] = figure
//						figures[column, row + 1] = other
//					}
//				}
//			}
//		}
//
//		possibleSwaps = set
//	}
	
	func isPossibleSwap(_ swap: Swap) -> Bool {
		return possibleSwaps.contains(swap)
	}
	
	private func createInitialFigures() -> Set<Figure> {
		var set: Set<Figure> = []
		for row in 0..<numRows {
			for column in 0..<numColumns {
				
				var figureType: FigureType
				repeat {
					figureType = FigureType.random()
				} while (column >= 2 &&
							figures[column - 1, row]?.figureType == figureType &&
							figures[column - 2, row]?.figureType == figureType)
					|| (row >= 2 &&
							figures[column, row - 1]?.figureType == figureType &&
							figures[column, row - 2]?.figureType == figureType)

				if tiles[column, row] != nil {
					let figure = Figure(column: column, row: row, figureType: figureType)
					figures[column, row] = figure
					set.insert(figure)
				} else {
					figures[column, row] = nil
				}
			}
		}
		return set
	}
	
	func performSwap(_ swap: Swap) {
		let columnA = swap.figureA.column
		let rowA = swap.figureA.row

		let columnB = swap.figureB.column
		let rowB = swap.figureB.row

		figures[columnA, rowA] = swap.figureB
		swap.figureB.column = columnA
		swap.figureB.row = rowA

		figures[columnB, rowB] = swap.figureA
		swap.figureA.column = columnB
		swap.figureA.row = rowB
	}

	func fillHoles() -> [[Figure]] {
		var columns: [[Figure]] = []

		for column in 0..<numColumns {
			var array: [Figure] = []
			for row in 0..<numRows {
				if tiles[column, row] != nil && figures[column, row] == nil {

					for lookup in (row + 1)..<numRows {
						if let figure = figures[column, lookup] {
							figures[column, lookup] = nil
							figures[column, row] = figure
							figure.row = row

							array.append(figure)
							break
						}
					}
				}
			}
			if !array.isEmpty {
				columns.append(array)
			}
		}
		return columns
	}

	private func detectHorizontalMatches() -> Set<Chain> {
		var set: Set<Chain> = []

		for row in 0..<numRows {
			var column = 0
			while column < numColumns - 2 {
				if let figure = figures[column, row] {
					let matchType = figure.figureType

					if figures[column + 1, row]?.figureType == matchType &&
						figures[column + 2, row]?.figureType == matchType {

						let chain = Chain(chainType: .horizontal)
						repeat {
							chain.add(figure: figures[column, row]!)
							column += 1
						} while column < numColumns && figures[column, row]?.figureType == matchType

						set.insert(chain)
						continue
					}
				}

				column += 1
			}
		}
		return set
	}

	private func detectVerticalMatches() -> Set<Chain> {
		var set: Set<Chain> = []

		for column in 0..<numColumns {
			var row = 0
			while row < numRows - 2 {
				if let figure = figures[column, row] {
					let matchType = figure.figureType

					if figures[column, row + 1]?.figureType == matchType &&
						figures[column, row + 2]?.figureType == matchType {

						let chain = Chain(chainType: .vertical)
						repeat {
							chain.add(figure: figures[column, row]!)
							row += 1
						} while row < numRows && figures[column, row]?.figureType == matchType

						set.insert(chain)
						continue
					}
				}
				row += 1
			}
		}
		return set
	}
	
	func removeMatches() -> Set<Chain> {
		let horizontalChains = detectHorizontalMatches()
		let verticalChains = detectVerticalMatches()

		removeFigures(in: horizontalChains)
		removeFigures(in: verticalChains)
		
		calculateScore(for: horizontalChains)
		calculateScore(for: verticalChains)

		return horizontalChains.union(verticalChains)
	}

	private func removeFigures(in chains: Set<Chain>) {
		for chain in chains {
			for figure in chain.figures {
				figures[figure.column, figure.row] = nil
			}
		}
	}
	
	func topUpFigures() -> [[Figure]] {
		var columns: [[Figure]] = []
		var figureType: FigureType = .unknown
		
		for column in 0..<numColumns {
			var array: [Figure] = []
			
			var row = numRows - 1
			while row >= 0 && figures[column, row] == nil {
				if tiles[column, row] != nil {
					var newFigureType: FigureType
					repeat {
						newFigureType = FigureType.random()
					} while newFigureType == figureType
					figureType = newFigureType
					
					let figure = Figure(column: column, row: row, figureType: figureType)
					figures[column, row] = figure
					array.append(figure)
				}
				
				row -= 1
			}
			
			if !array.isEmpty {
				columns.append(array)
			}
		}
		return columns
	}
	
	private func calculateScore(for chains: Set<Chain>) {
		for chain in chains {
			chain.score = 60 * (chain.lenght - 2) * comboMultiplier
			comboMultiplier += 1
		}
	}
	
	func resetComboMultiplier() {
		comboMultiplier = 1
	}
	
	init(filename: String) {
		guard let levelData = LevelData.loadFrom(file: filename) else { return }

		let tilesArray = levelData.tiles
		targetScore = levelData.targetScore ?? 0
		maximumMovies = levelData.moves ?? 0

		for (row, rowArray) in tilesArray!.enumerated() {
			let titleRow = numRows - row - 1

			for (column, value) in rowArray.enumerated() {
				if value == 1 {
					tiles[column, titleRow] = Tile(column: column, row: titleRow)
				} else {
					tiles[column, titleRow] = nil
				}
			}
		}
	}
	
}
