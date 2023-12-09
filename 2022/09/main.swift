import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case malformedInstruction
}

enum Direction: String, CaseIterable {
  case u = "U", d = "D", l = "L", r = "R"
}

extension CharacterSet {
  static let direction: CharacterSet =
    Direction.allCases.reduce(into: CharacterSet()) { set, direction in
      set.formUnion(.init(charactersIn: direction.rawValue))
    }
}

struct Point: Hashable {
  let x: Int
  let y: Int
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  func touches(_ other: Point) -> Bool {
    let distanceX = abs(x-other.x)
    let distanceY = abs(y-other.y)
    return distanceX <= 1 && distanceY <= 1
  }

  func following(_ other: Point) -> Point {
    touches(other) ? self : .init(
      x.following(other.x),
      y.following(other.y)
    )
  }

  func moving(in direction: Direction) -> Point {
    switch direction {
    case .u: .init(x, y+1)
    case .d: .init(x, y-1)
    case .l: .init(x-1, y)
    case .r: .init(x+1, y)
    }
  }

  static let zero = Point(0, 0)
}

extension Int {
  func following(_ other: Int) -> Int {
    guard self != other else { return self }
    return self > other ? self-1 : self+1
  }
}

struct Instruction {
  let direction: Direction
  let amount: Int

  init(rawValue: String) throws {
    let scanner = Scanner(string: rawValue)
    guard
      let directionRawValue = scanner.scanCharacters(from: .direction),
      let direction = Direction(rawValue: directionRawValue),
      let amount = scanner.scanInt()
    else { throw UnexpectedError.malformedInstruction }
    self.direction = direction
    self.amount = amount
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var headLocation: Point = .zero
  var tailLocation: Point = .zero
  var visitedLocations: Set<Point> = [tailLocation]
  for try await line in file.bytes.lines {
    let instruction = try Instruction(rawValue: line)
    for _ in 0 ..< instruction.amount {
      headLocation = headLocation.moving(in: instruction.direction)
      tailLocation = tailLocation.following(headLocation)
      visitedLocations.insert(tailLocation)
    }
  }

  return visitedLocations.count
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var headLocation: Point = .zero
  var knotsLocations = [Point](repeating: .zero, count: 9)
  var visitedLocations: Set<Point> = [knotsLocations.last!]
  for try await line in file.bytes.lines {
    let instruction = try Instruction(rawValue: line)
    for _ in 0 ..< instruction.amount {
      headLocation = headLocation.moving(in: instruction.direction)
      for (index, knotLocation) in knotsLocations.enumerated() {
        let targetLocation = index == 0 ? headLocation : knotsLocations[index-1]
        knotsLocations[index] = knotLocation.following(targetLocation)
        if index == knotsLocations.count-1 {
          visitedLocations.insert(knotsLocations[index])
        }
      }
    }
  }

  return visitedLocations.count
}
