import Foundation

struct Location: Hashable, Comparable {
  let x: Int
  let y: Int

  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  func distance(to other: Location) -> Int {
    abs(other.x-x)+abs(other.y-y)
  }

  public static func < (lhs: Location, rhs: Location) -> Bool {
    lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
  }
}

func distancesSum(withExpansionFactor expansionFactor: Int) async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "11.in")
  else { fatalError("input not found") }

  var original: [[Character]] = []
  for try await line in file.bytes.lines {
    original.append(Array(line))
  }

  var emptyRowsIndices: Set<Int> = []
  for index in original.indices {
    if original[index].allSatisfy({ $0 == "." }) {
      emptyRowsIndices.insert(index)
    }
  }

  var emptyColsIndices: Set<Int> = []
  for i in original.indices {
    var column: [Character] = []
    for j in original[i].indices {
      column.append(original[j][i])
    }
    if column.allSatisfy({ $0 == "." }) {
      emptyColsIndices.insert(i)
    }
  }

  var galaxies: Set<Location> = []
  for row in original.indices {
    for col in original[row].indices {
      if original[row][col] == "#" {
        galaxies.insert(.init(col, row))
      }
    }
  }

  let sortedGalaxies = galaxies.sorted()

  var sum = 0
  for (i, galaxy) in sortedGalaxies.enumerated() {
    for (j, otherGalaxy) in sortedGalaxies.enumerated() {
      if i < j {
        let rowsRange = galaxy.y < otherGalaxy.y
          ? galaxy.y ..< otherGalaxy.y
          : otherGalaxy.y ..< galaxy.y
        let colsRange = galaxy.x < otherGalaxy.x
          ? galaxy.x ..< otherGalaxy.x
          : otherGalaxy.x ..< galaxy.x
        var distance = galaxy.distance(to: otherGalaxy)
        distance += Set(rowsRange).intersection(emptyRowsIndices).count*(expansionFactor-1)
        distance += Set(colsRange).intersection(emptyColsIndices).count*(expansionFactor-1)
        sum += distance
      }
    }
  }

  return sum
}

func part1() async throws -> Int {
  try await distancesSum(withExpansionFactor: 2)
}

func part2() async throws -> Int {
  try await distancesSum(withExpansionFactor: 1_000_000)
}

try await print(part1())
try await print(part2())
