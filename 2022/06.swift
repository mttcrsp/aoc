import Foundation

func endIndexForMarker(ofLength length: Int, in string: String) -> Int {
  for index in string.indices.dropFirst(length-1) {
    let lowerBound = string.index(index, offsetBy: -(length-1))
    let upperBound = index
    let characterSet = Set(string[lowerBound ... upperBound])
    if characterSet.count == length {
      return string.distance(from: string.startIndex, to: index)+1
    }
  }
  fatalError("marker not found")
}

func part1() throws -> Int {
  let string = try String(contentsOfFile: "06.in")
  return endIndexForMarker(ofLength: 4, in: string)
}

func part2() throws -> Int {
  let string = try String(contentsOfFile: "06.in")
  return endIndexForMarker(ofLength: 14, in: string)
}

try print(part1())
try print(part2())
