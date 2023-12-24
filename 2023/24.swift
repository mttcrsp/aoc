import Accelerate
import Foundation

struct Point {
  var x: Double
  var y: Double
  var z: Double

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .init(charactersIn: " ,")

    var components: [Double] = []
    while let component = scanner.scanDouble() {
      components.append(component)
    }

    guard components.count == 3
    else { fatalError("malformed position or velocity '\(rawValue)'") }
    x = components[0]
    y = components[1]
    z = components[2]
  }

  var point2D: Point2D {
    .init(x: x, y: y)
  }
}

struct Hailstone {
  var position: Point
  var velocity: Point

  init(rawValue: String) {
    let components = rawValue.components(separatedBy: " @ ")
    guard components.count == 2
    else { fatalError("malformed hailstone '\(rawValue)'") }
    position = Point(rawValue: components[0])
    velocity = Point(rawValue: components[1])
  }

  var nextPosition: Point {
    var position = position
    position.x += velocity.x
    position.y += velocity.y
    position.z += velocity.z
    return position
  }

  var nextSegment: Segment {
    .init(start: position.point2D, end: nextPosition.point2D)
  }

  func intercepts(_ point: Point2D) -> Bool {
    (point.x > position.x) == (velocity.x > 0)
  }
}

struct Point2D {
  var x: Double
  var y: Double
}

struct Segment {
  let start: Point2D
  let end: Point2D

  func intersect(_ other: Segment) -> Point2D? {
    func determinant(_ a: Point2D, _ b: Point2D) -> Double {
      a.x*b.y-a.y*b.x
    }

    let deltaX = Point2D(
      x: start.x-end.x,
      y: other.start.x-other.end.x
    )
    let deltaY = Point2D(
      x: start.y-end.y,
      y: other.start.y-other.end.y
    )

    let denominator = determinant(deltaX, deltaY)
    guard denominator != 0 else { return nil }

    let d = Point2D(
      x: determinant(start, end),
      y: determinant(other.start, other.end)
    )
    return Point2D(
      x: determinant(d, deltaX)/denominator,
      y: determinant(d, deltaY)/denominator
    )
  }
}

guard let file = FileHandle(forReadingAtPath: "24.in")
else { fatalError("input not found") }

var hailstones: [Hailstone] = []
for try await line in file.bytes.lines {
  let hailstone = Hailstone(rawValue: line)
  hailstones.append(hailstone)
}

let range: ClosedRange<Double> =
  200_000_000_000_000 ...
  400_000_000_000_000

var count = 0
for i in 0 ..< hailstones.count-1 {
  for j in i+1 ..< hailstones.count {
    let a = hailstones[i]
    let b = hailstones[j]
    if let intersect = a.nextSegment.intersect(b.nextSegment) {
      if range ~= intersect.x, range ~= intersect.y {
        if a.intercepts(intersect) {
          if b.intercepts(intersect) {
            count += 1
          }
        }
      }
    }
  }
}

print(count)

let h1 = hailstones[0]
let h2 = hailstones[1]
let h3 = hailstones[2]
let string = """

Paste this into https://sagecell.sagemath.org/

var('x y z vx vy vz t1 t2 t3 result')
eq1 = x + (vx * t1) == \(Int(h1.position.x)) + (\(Int(h1.velocity.x)) * t1)
eq2 = y + (vy * t1) == \(Int(h1.position.y)) + (\(Int(h1.velocity.y)) * t1)
eq3 = z + (vz * t1) == \(Int(h1.position.z)) + (\(Int(h1.velocity.z)) * t1)
eq4 = x + (vx * t2) == \(Int(h2.position.x)) + (\(Int(h2.velocity.x)) * t2)
eq5 = y + (vy * t2) == \(Int(h2.position.y)) + (\(Int(h2.velocity.y)) * t2)
eq6 = z + (vz * t2) == \(Int(h2.position.z)) + (\(Int(h2.velocity.z)) * t2)
eq7 = x + (vx * t3) == \(Int(h3.position.x)) + (\(Int(h3.velocity.x)) * t3)
eq8 = y + (vy * t3) == \(Int(h3.position.y)) + (\(Int(h3.velocity.y)) * t3)
eq9 = z + (vz * t3) == \(Int(h3.position.z)) + (\(Int(h3.velocity.z)) * t3)
eq10 = result == x + y + z
print(solve([eq1,eq2,eq3,eq4,eq5,eq6,eq7,eq8,eq9,eq10],x,y,z,vx,vy,vz,t1,t2,t3,result))

"""

print(string)
