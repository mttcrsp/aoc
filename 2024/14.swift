import Foundation

guard let input = try? String(contentsOfFile: "14.in", encoding: .utf8)
else { fatalError("input not found") }

let size = (width: 101, height: 103)
let lines = input.components(separatedBy: "\n")

struct Point: Hashable {
  var x, y: Int
}

struct Robot {
  var point, velocity: Point

  mutating func move(times seconds: Int) {
    point.x = (point.x+velocity.x*seconds)%size.width
    point.y = (point.y+velocity.y*seconds)%size.height
    point.x = (point.x+size.width)%size.width
    point.y = (point.y+size.height)%size.height
  }
}

var robots: [Robot] = []
for line in lines {
  let components = line.components(separatedBy: " ")
  let pointComponents = components[0].dropFirst(2).components(separatedBy: ",").compactMap(Int.init)
  let point = Point(x: pointComponents[0], y: pointComponents[1])
  let velocityComponents = components[1].dropFirst(2).components(separatedBy: ",").compactMap(Int.init)
  let velocity = Point(x: velocityComponents[0], y: velocityComponents[1])
  robots.append(.init(point: point, velocity: velocity))
}

let quadrantSeparator = Point(x: size.width/2, y: size.height/2)
var quadrants: [Point: Int] = [:]
for var robot in robots {
  robot.move(times: 100)
  guard 
    robot.point.x != quadrantSeparator.x,
    robot.point.y != quadrantSeparator.y
  else { continue }

  let quadrantX = robot.point.x < quadrantSeparator.x ? 0 : 1
  let quadrantY = robot.point.y < quadrantSeparator.y ? 0 : 1
  let quadrant = Point(x: quadrantX, y: quadrantY)
  quadrants[quadrant, default: 0] += 1
}

print(quadrants.values.reduce(1, *))

for iteration in 0 ..< 10000 {
  var yCount: [Int: Int] = [:]
  var xCount: [Int: Int] = [:]
  for i in robots.indices {
    robots[i].move(times: 1)
    xCount[robots[i].point.x, default: 0] += 1
    yCount[robots[i].point.y, default: 0] += 1
  }

  guard 
    let x = xCount.values.max(),
    let y = yCount.values.max(),
    x >= 31, y >= 32
  else { continue }

  print(iteration+1)
  break
}
