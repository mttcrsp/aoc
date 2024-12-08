import Foundation

guard let input = try? String(contentsOfFile: "08.in", encoding: .utf8)
else { fatalError("input not found") }

let grid = input.components(separatedBy: "\n").map(Array.init)
let rows = grid.count
let cols = grid[0].count

typealias Grid = [[Character]]

extension Grid {
  subscript(_ point: Point) -> Character {
    self[point.row][point.col]
  }

  func contains(_ point: Point) -> Bool {
    point.row >= 0 && point.row < rows &&
      point.col >= 0 && point.col < cols
  }
}

struct Point: Hashable {
  var row, col: Int
  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
  }
}

var antennas: [Character: [Point]] = [:]
for row in 0 ..< rows {
  for col in 0 ..< cols {
    let character = grid[row][col]
    guard character != "." else { continue }
    let point = Point(row, col)
    antennas[character, default: []].append(point)
  }
}

var antinodes: Set<Point> = []
func generateAntinodes(from pointI: Point, _ pointJ: Point) {
  var antinodeI = pointI
  antinodeI.row += (pointJ.row-pointI.row)*2
  antinodeI.col += (pointJ.col-pointI.col)*2
  if grid.contains(antinodeI) {
    antinodes.insert(antinodeI)
  }

  var antinodeJ = pointJ
  antinodeJ.row += (pointI.row-pointJ.row)*2
  antinodeJ.col += (pointI.col-pointJ.col)*2
  if grid.contains(antinodeJ) {
    antinodes.insert(antinodeJ)
  }
}

var antinodesWithResonance: Set<Point> = []
func generateAntinodesWithResonance(from pointI: Point, _ pointJ: Point) {
  var antinodeI = pointI
  let deltaIRow = pointJ.row-pointI.row
  let deltaICol = pointJ.col-pointI.col
  repeat {
    antinodeI.row += deltaIRow
    antinodeI.col += deltaICol
    guard grid.contains(antinodeI) else { break }
    antinodesWithResonance.insert(antinodeI)
  } while
    true

  var antinodeJ = pointJ
  let deltaJRow = pointI.row-pointJ.row
  let deltaJCol = pointI.col-pointJ.col
  repeat {
    antinodeJ.row += deltaJRow
    antinodeJ.col += deltaJCol
    guard grid.contains(antinodeJ) else { break }
    antinodesWithResonance.insert(antinodeJ)
  } while
    true
}

for (_, points) in antennas {
  for i in points.indices.dropLast() {
    for j in i+1 ..< points.count {
      let pointI = points[i]
      let pointJ = points[j]
      generateAntinodes(from: pointI, pointJ)
      generateAntinodesWithResonance(from: pointI, pointJ)
    }
  }
}

print(antinodes.count)
print(antinodesWithResonance.count)
