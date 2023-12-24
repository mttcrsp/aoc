import Foundation

struct Coordinate {
  var x: Int
  var y: Int
  var z: Int
  init(rawValue: String) {
    let components = rawValue.components(separatedBy: ",")
    guard
      components.count == 3,
      let x = Int(components[0]),
      let y = Int(components[1]),
      let z = Int(components[2])
    else { fatalError("malformed coordinate '\(rawValue)'") }
    self.x = x
    self.y = y
    self.z = z
  }
}

struct Brick {
  let id = UUID()
  var coordinate1: Coordinate
  var coordinate2: Coordinate

  init(rawValue: String) {
    let components = rawValue.components(separatedBy: "~")
    guard components.count == 2
    else { fatalError("malformed brick '\(rawValue)'") }
    coordinate1 = Coordinate(rawValue: components[0])
    coordinate2 = Coordinate(rawValue: components[1])
  }

  var minZ: Int { min(coordinate1.z, coordinate2.z) }
  var maxZ: Int { max(coordinate1.z, coordinate2.z) }

  var points: Set<Point> {
    var points: Set<Point> = []
    for x in min(coordinate1.x, coordinate2.x) ... max(coordinate1.x, coordinate2.x) {
      for y in min(coordinate1.y, coordinate2.y) ... max(coordinate1.y, coordinate2.y) {
        points.insert(.init(x: x, y: y))
      }
    }
    return points
  }
}

struct Point: Hashable {
  let x: Int
  let y: Int
}

guard let file = FileHandle(forReadingAtPath: "22.in")
else { fatalError("input not found") }

var bricks: [Brick] = []
for try await line in file.bytes.lines {
  let brick = Brick(rawValue: line)
  bricks.append(brick)
}

bricks.sort { $0.minZ < $1.minZ }

var topMost: [Point: Brick] = [:]
var supporter: [UUID: Set<UUID>] = [:]
var supported: [UUID: Set<UUID>] = [:]
for i in bricks.indices {
  var maxZ = 0
  for point in bricks[i].points {
    maxZ = max(maxZ, topMost[point]?.maxZ ?? 0)
  }

  let distance = bricks[i].minZ-(maxZ+1)
  bricks[i].coordinate1.z -= distance
  bricks[i].coordinate2.z -= distance

  for point in bricks[i].points {
    if let supportee = topMost[point], supportee.maxZ == maxZ {
      supporter[bricks[i].id, default: []].insert(supportee.id)
      supported[supportee.id, default: []].insert(bricks[i].id)
    }
  }

  for point in bricks[i].points {
    topMost[point] = bricks[i]
  }
}

var necessary: Set<UUID> = []
for (_, bricks) in supporter {
  if let id = bricks.first, bricks.count == 1 {
    necessary.insert(id)
  }
}

var sum = 0
for id in necessary {
  var destroyed: Set<UUID> = []
  var queue: Set<UUID> = [id]
  while let id = queue.popFirst() {
    destroyed.insert(id)
    for supportedID in supported[id, default: []] {
      if supporter[supportedID, default: []].isSubset(of: destroyed) {
        queue.insert(supportedID)
      }
    }
  }
  sum += destroyed.count-1
}

print(bricks.count-necessary.count)
print(sum)
