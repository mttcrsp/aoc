import Foundation

guard let file = try? FileHandle(forReadingAtPath: "11.in")
else { fatalError("input not found") }

var map: [[Int]] = []
for try await line in file.bytes.lines {
  map.append(line.map { Int(String($0))! })
}

let rows = map.count
let cols = map[0].count
let directions = [
  [0, 1], [0, -1], [1, 0], [-1, 0],
  [-1, -1], [1, -1], [1, 1], [-1, 1],
]

var flashes = 0
for i in 1 ... Int.max {
  var flashed: Set<[Int]> = []
  for row in 0 ..< rows {
    for col in 0 ..< cols {
      map[row][col] += 1
      if map[row][col] > 9 {
        flashed.insert([row, col])
      }
    }
  }

  for position in flashed {
    var stack = [position]
    while let position = stack.popLast() {
      map[position[0]][position[1]] = 0
      flashes += 1

      for direction in directions {
        var neighbor = position
        neighbor[0] += direction[0]
        neighbor[1] += direction[1]
        guard
          0 ..< rows ~= neighbor[0],
          0 ..< cols ~= neighbor[1],
          map[neighbor[0]][neighbor[1]] > 0,
          !flashed.contains(neighbor)
        else { continue }
        map[neighbor[0]][neighbor[1]] += 1
        if map[neighbor[0]][neighbor[1]] > 9 {
          stack.append(neighbor)
          flashed.insert(neighbor)
        }
      }
    }
  }

  if i == 100 {
    print(flashes)
  }

  if flashed.count == rows*cols {
    print(i)
    break
  }
}
