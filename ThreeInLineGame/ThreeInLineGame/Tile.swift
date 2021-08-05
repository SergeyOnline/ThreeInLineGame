//
//  Tile.swift
//  ThreeInLineGame
//
//  Created by Сергей on 05.08.2021.
//

import Foundation

struct DataJSON: Decodable {
	var tiles: [[Int]]
	var targetScore: Int
	var moves: Int
}

struct LevelData {
	
	var tiles: [[Int]]?
	var targetScore: Int?
	var moves: Int?
	
	static func loadFrom(file: String) -> LevelData? {
		
		let url = Bundle.main.url(forResource: file, withExtension: "json")!
		do {
			let data = try Data(contentsOf: url)
			let dataJSON = try JSONDecoder().decode(DataJSON.self, from: data)
			let levelData = LevelData(tiles: dataJSON.tiles, targetScore: dataJSON.targetScore, moves: dataJSON.moves)
			return levelData
		} catch {
			print(error)
			return nil
		}
	}
}

class Tile: CustomStringConvertible, Hashable {

	var column: Int
	var row: Int
	
	static func ==(lhs: Tile, rhs: Tile) -> Bool {
		return lhs.column == rhs.column && lhs.row == rhs.row
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(column)
		hasher.combine(row)
	}
	
	var description: String {
		return "square:(\(column),\(row))"
	}
	
	init(column: Int, row: Int) {
		self.column = column
		self.row = row
	}
}

