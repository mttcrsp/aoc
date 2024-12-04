import Foundation

guard let input = try? String(contentsOfFile: "04.in", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
let grid = lines.map(Array.init)
let rows = grid.count
let cols = grid[0].count

struct Point {
  var row, col: Int
  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
  }

  func next(in direction: Direction) -> Point {
    .init(row+direction.deltaRow, col+direction.deltaCol)
  }

  var isInsideBounds: Bool {
    row >= 0 && row < rows && col >= 0 && col < cols
  }
}

struct Direction {
  var deltaRow, deltaCol: Int
  init(_ deltaRow: Int, _ deltaCol: Int) {
    self.deltaRow = deltaRow
    self.deltaCol = deltaCol
  }

  static let l = Self(0, -1)
  static let r = Self(0, +1)
  static let t = Self(-1, 0)
  static let b = Self(+1, 0)
  static let tl = Self(-1, -1)
  static let tr = Self(-1, +1)
  static let bl = Self(+1, -1)
  static let br = Self(+1, +1)
}

func search(for word: String, from point: Point, in direction: Direction) -> Bool {
  var current = point
  for target in word {
    guard current.isInsideBounds, grid[current.row][current.col] == target else { return false }
    current = current.next(in: direction)
  }

  return true
}

func isMASCenter(_ point: Point) -> Bool {
  let target = "MAS"
  let tl = point.next(in: .tl), tr = point.next(in: .tr)
  let bl = point.next(in: .bl), br = point.next(in: .br)
  let diag1 = search(for: target, from: tl, in: .br) || search(for: target, from: br, in: .tl)
  let diag2 = search(for: target, from: tr, in: .bl) || search(for: target, from: bl, in: .tr)
  return diag1 && diag2
}

var part1 = 0
var part2 = 0
for row in grid.indices {
  for col in grid[row].indices {
    let point = Point(row, col)
    for direction in [.l, .r, .t, .b, .tl, .tr, .bl, .br] as [Direction] {
      if search(for: "XMAS", from: point, in: direction) {
        part1 += 1
      }
    }

    if isMASCenter(point) {
      part2 += 1
    }
  }
}

print(part1)
print(part2)
