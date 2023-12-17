import Foundation

enum Direction: Hashable {
  case up, down, left, right
}

struct Point: Hashable {
  var x: Int
  var y: Int
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }
}

struct Beam: Hashable {
  var point: Point
  var direction: Direction
}

extension Beam {
  static let initial =
    Self(point: .init(0, 0), direction: .right)

  mutating func advance() {
    switch direction {
    case .up: point.y -= 1
    case .down: point.y += 1
    case .left: point.x -= 1
    case .right: point.x += 1
    }
  }
}

enum Mirror: Character {
  case backslash = "\\"
  case forwardSlash = "/"
}

enum Splitter: Character {
  case vertical = "|"
  case horizontal = "-"
}

extension Splitter {
  var directions: [Direction] {
    switch self {
    case .vertical: return [.up, .down]
    case .horizontal: return [.left, .right]
    }
  }
}

enum Item {
  case empty
  case mirror(Mirror)
  case splitter(Splitter)
}

extension Item {
  init?(rawValue: Character) {
    if rawValue == "." {
      self = .empty
    } else if let mirror = Mirror(rawValue: rawValue) {
      self = .mirror(mirror)
    } else if let splitter = Splitter(rawValue: rawValue) {
      self = .splitter(splitter)
    } else {
      return nil
    }
  }
}

typealias Grid = [[Item]]

extension Grid {
  func contains(_ beam: Beam) -> Bool {
    indices.contains(beam.point.y) &&
      self[beam.point.y].indices.contains(beam.point.x)
  }

  subscript(_ point: Point) -> Item {
    self[point.y][point.x]
  }

  var edgeBeams: [Beam] {
    guard let first else { return [] }
    var beams: [Beam] = []
    for y in 0 ..< count {
      beams.append(.init(point: .init(0, y), direction: .right))
      beams.append(.init(point: .init(first.count-1, y), direction: .left))
    }
    for x in 0 ..< first.count {
      beams.append(.init(point: .init(x, 0), direction: .down))
      beams.append(.init(point: .init(x, count-1), direction: .up))
    }
    return beams
  }
}

extension Direction {
  func matches(_ splitter: Splitter) -> Bool {
    switch (self, splitter) {
    case (.up, .vertical): true
    case (.down, .vertical): true
    case (.left, .horizontal): true
    case (.right, .horizontal): true
    default: false
    }
  }

  func reflected(by mirror: Mirror) -> Direction {
    switch (mirror, self) {
    case (.backslash, .up): .left
    case (.backslash, .down): .right
    case (.backslash, .left): .up
    case (.backslash, .right): .down
    case (.forwardSlash, .up): .right
    case (.forwardSlash, .down): .left
    case (.forwardSlash, .left): .down
    case (.forwardSlash, .right): .up
    }
  }

  func interact(with item: Item) -> [Direction] {
    switch item {
    case .empty:
      [self]
    case let .splitter(splitter) where matches(splitter):
      [self]
    case let .splitter(splitter):
      splitter.directions
    case let .mirror(mirror):
      [reflected(by: mirror)]
    }
  }
}

guard let file = FileHandle(forReadingAtPath: "16.in")
else { fatalError("input not found") }

var grid: Grid = []
for try await line in file.bytes.lines {
  grid.append(line.compactMap(Item.init))
}

var maxEnergizedTiles = 0

for initialBeam in grid.edgeBeams {
  var energizedTiles: Set<Point> = []
  var inspectedBeams: Set<Beam> = []
  var beams: [Beam] = [initialBeam]
  while !beams.isEmpty {
    var newBeams: [Beam] = []

    for beam in beams where inspectedBeams.insert(beam).inserted {
      energizedTiles.insert(beam.point)
      for direction in beam.direction.interact(with: grid[beam.point]) {
        var newBeam = beam
        newBeam.direction = direction
        newBeam.advance()
        if grid.contains(newBeam) {
          newBeams.append(newBeam)
        }
      }
    }

    beams = newBeams
  }

  if initialBeam == .initial {
    print(energizedTiles.count)
  }

  maxEnergizedTiles = max(maxEnergizedTiles, energizedTiles.count)
}

print(maxEnergizedTiles)
