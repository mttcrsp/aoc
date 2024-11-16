import Foundation

guard let file = FileHandle(forReadingAtPath: "13.in")
else { fatalError("input not found") }

struct Instruction {
  static let prefix = "fold along "

  let axis: String, offset: Int
  init?(line: String) {
    var line = line
    if line.starts(with: Self.prefix) {
      line.removeFirst(Self.prefix.count)
    } else {
      return nil
    }

    let components = line.components(separatedBy: "=")
    guard components.count == 2, let offset = Int(components[1])
    else { return nil }
    axis = components[0]
    self.offset = offset
  }
}

struct Point: Hashable {
  let x: Int, y: Int
}

extension Point {
  init?(line: String) {
    let components = line.components(separatedBy: ",")
    guard
      components.count == 2,
      let x = Int(components[0]),
      let y = Int(components[1])
    else { return nil }
    self.x = x
    self.y = y
  }
}

var points: Set<Point> = []
var instructions: [Instruction] = []
for try await line in file.bytes.lines {
  if let point = Point(line: line) {
    points.insert(point)
  } else if let instruction = Instruction(line: line) {
    instructions.append(instruction)
  }
}

extension Point {
  func applying(_ instruction: Instruction) -> Point {
    if instruction.axis == "x", x > instruction.offset {
      let distance = x-instruction.offset
      return Point(x: instruction.offset-distance, y: y)
    } else if instruction.axis == "y", y > instruction.offset {
      let distance = y-instruction.offset
      return Point(x: x, y: instruction.offset-distance)
    } else {
      return self
    }
  }
}

extension Set where Element == Point {
  var tableDescription: String {
    var maxX = 0
    var maxY = 0
    for point in self {
      maxX = Swift.max(maxX, point.x)
      maxY = Swift.max(maxY, point.y)
    }

    let tableRow = [Character](repeating: ".", count: maxX+1)
    var table = [[Character]](repeating: tableRow, count: maxY+1)
    for point in self {
      table[point.y][point.x] = "#"
    }

    var rows: [String] = []
    for row in table {
      rows.append(String(row))
    }
    return rows.joined(separator: "\n")
  }
}

for (index, instruction) in instructions.enumerated() {
  var newPoints: Set<Point> = []
  for point in points {
    let newPoint = point.applying(instruction)
    newPoints.insert(newPoint)
  }

  points = newPoints
  if index == 0 {
    print(points.count)
  }
}

print(points.tableDescription)
