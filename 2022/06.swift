import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case markerNotFound
}

func endIndexForMarker(ofLength length: Int, in string: String) throws -> Int {
  for index in string.indices.dropFirst(length-1) {
    let lowerBound = string.index(index, offsetBy: -(length-1))
    let upperBound = index
    let characterSet = Set(string[lowerBound ... upperBound])
    if characterSet.count == length {
      return string.distance(from: string.startIndex, to: index)+1
    }
  }
  throw UnexpectedError.markerNotFound
}

func part1() throws -> Int {
  let string = try String(contentsOfFile: "06.in")
  return try endIndexForMarker(ofLength: 4, in: string)
}

func part2() throws -> Int {
  let string = try String(contentsOfFile: "06.in")
  return try endIndexForMarker(ofLength: 14, in: string)
}

try await print(part1())
try await print(part2())
