import Collections
import Foundation

guard let file = FileHandle(forReadingAtPath: "15.in")
else { fatalError("input not found") }

var grid: [[Int]] = []
for try await line in file.bytes.lines {
  grid.append(line.map { Int(String($0))! })
}

let rows = grid.count
let cols = grid[0].count
let directions: [(x: Int, y: Int)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]

struct Element: Comparable {
  var row: Int
  var col: Int
  var distance: Int
  static func < (_ lhs: Self, _ rhs: Self) -> Bool {
    guard lhs.row == rhs.row else { return lhs.row < rhs.row }
    guard lhs.col == rhs.col else { return lhs.col < rhs.col }
    return lhs.distance < rhs.distance
  }
}

@MainActor func minimumRisk(tiles: Int = 1) -> Int {
  let costsRow = [Int?](repeating: nil, count: tiles*cols)
  var costs = [[Int?]](repeating: costsRow, count: tiles*rows)
  var heap: Heap<Element> = [.init(row: 0, col: 0, distance: 0)]
  while let element = heap.popMin() {
    let row = element.row
    let col = element.col
    guard 
      row >= 0, row < rows*tiles,
      col >= 0, col < cols*tiles
    else { continue }

    var value = grid[row%rows][col%cols]+row/rows+col/cols
    while value > 9 {
      value -= 9
    }

    let cost = element.distance+value
    guard costs[row][col] == nil || cost < costs[row][col]! else { continue }
    costs[row][col] = cost

    if row == (tiles*rows)-1, col == (tiles*cols)-1 {
      break
    }

    for direction in directions {
      heap.insert(.init(row: row+direction.x, col: col+direction.y, distance: cost))
    }
  }

  return costs[(tiles*rows)-1][(tiles*cols)-1]!-grid[0][0]
}

print(minimumRisk())
print(minimumRisk(tiles: 5))
