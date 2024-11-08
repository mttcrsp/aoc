import Foundation

guard let file = FileHandle(forReadingAtPath: "05.in")
else { fatalError("input not found") }

struct Location {
  var x: Int
  var y: Int
}

extension Location {
  init(rawValue: String) {
    let components = rawValue.components(separatedBy: ",")
    guard
      components.count == 2,
      let x = Int(components[0]),
      let y = Int(components[1])
    else { fatalError("malformed location \(rawValue)") }
    self.init(x: x, y: y)
  }
}

struct Vent {
  var src: Location
  var dst: Location

  init(line: String) {
    let components = line.components(separatedBy: " -> ")
    guard components.count == 2
    else { fatalError("malformed line \(line)") }
    src = Location(rawValue: components[0])
    dst = Location(rawValue: components[1])
  }

  func locations(includingDiagonals: Bool = false) -> [Location] {
    if src.x == dst.x {
      return (min(src.y, dst.y) ... max(src.y, dst.y))
        .map { y in Location(x: src.x, y: y) }
    } else if src.y == dst.y {
      return (min(src.x, dst.x) ... max(src.x, dst.x))
        .map { x in Location(x: x, y: src.y) }
    } else if !includingDiagonals {
      return []
    } else {
      let xs = Array(stride(from: src.x, through: dst.x, by: src.x < dst.x ? 1 : -1))
      let ys = Array(stride(from: src.y, through: dst.y, by: src.y < dst.y ? 1 : -1))
      var locations: [Location] = []
      for index in xs.indices {
        let location = Location(x: xs[index], y: ys[index])
        locations.append(location)
      }
      return locations
    }
  }

  var maxX: Int { max(src.x, dst.x) }
  var maxY: Int { max(src.y, dst.y) }
}

var maxX = 0
var maxY = 0
var vents: [Vent] = []
for try await line in file.bytes.lines {
  let vent = Vent(line: line)
  maxX = max(maxX, vent.maxX)
  maxY = max(maxY, vent.maxY)
  vents.append(vent)
}

let boardRow = [Int](repeating: 0, count: maxX+1)
let board = [[Int]](repeating: boardRow, count: maxY+1)

var mutableBoard = board
for vent in vents {
  for location in vent.locations() {
    mutableBoard[location.y][location.x] += 1
  }
}

var dangerousAreas = 0
for x in 0 ... maxX {
  for y in 0 ... maxY {
    if mutableBoard[y][x] > 1 {
      dangerousAreas += 1
    }
  }
}

print(dangerousAreas)

mutableBoard = board
for vent in vents {
  for location in vent.locations(includingDiagonals: true) {
    mutableBoard[location.y][location.x] += 1
  }
}

dangerousAreas = 0
for x in 0 ... maxX {
  for y in 0 ... maxY {
    if mutableBoard[y][x] > 1 {
      dangerousAreas += 1
    }
  }
}

print(dangerousAreas)
