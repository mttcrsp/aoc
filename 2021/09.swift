import Foundation

guard let file = try? FileHandle(forReadingAtPath: "09.in")
else { fatalError("input not found") }

var map: [[Int]] = []
for try await line in file.bytes.lines {
  map.append(Array(line.map { Int(String($0))! }))
}

let rows = map.count
let cols = map[0].count

var risksSum = 0
for row in 0 ..< rows {
  for col in 0 ..< cols {
    let heightU = 0 ..< rows ~= row-1 ? map[row-1][col] : Int.max
    let heightD = 0 ..< rows ~= row+1 ? map[row+1][col] : Int.max
    let heightL = 0 ..< cols ~= col-1 ? map[row][col-1] : Int.max
    let heightR = 0 ..< cols ~= col+1 ? map[row][col+1] : Int.max
    let height = map[row][col]
    let isLowPoint = [heightU, heightD, heightL, heightR].allSatisfy { $0 > height }
    guard isLowPoint else { continue }
    let riskLevel = height+1
    risksSum += riskLevel
  }
}

print(risksSum)

let directions: [[Int]] = [[0, 1], [0, -1], [1, 0], [-1, 0]]
var sizes: [Int] = []
for row in 0 ..< rows {
  for col in 0 ..< cols {
    let height = map[row][col]
    guard height < 9 else { continue }

    var size = 0
    var stack: [[Int]] = [[row, col]]
    map[row][col] = 9
    while let position = stack.popLast() {
      size += 1
      for direction in directions {
        var nextPosition = position
        nextPosition[0] += direction[0]
        nextPosition[1] += direction[1]
        guard 
          0 ..< rows ~= nextPosition[0],
          0 ..< cols ~= nextPosition[1],
          map[nextPosition[0]][nextPosition[1]] < 9
        else { continue }
        map[nextPosition[0]][nextPosition[1]] = 9
        stack.append(nextPosition)
      }
    }

    sizes.append(size)
  }
}

print(sizes.sorted().suffix(3).reduce(1, *))
