import Foundation

extension ClosedRange<Int> {
  init(rawValue: String) {
    let components = rawValue.components(separatedBy: "-")
    guard
      let lowerBound = Int(components[0]),
      let upperBound = Int(components[1])
    else { fatalError("malformed range definition '\(rawValue)'") }
    self = lowerBound ... upperBound
  }

  func fullyContains(_ other: Self) -> Bool {
    lowerBound <= other.lowerBound &&
      upperBound >= other.upperBound
  }
}

struct Group {
  let lhs: ClosedRange<Int>
  let rhs: ClosedRange<Int>

  init(rawValue: String) {
    let ranges = rawValue.components(separatedBy: ",")
    guard
      let lhsRawValue = ranges.first,
      let rhsRawValue = ranges.last,
      ranges.count == 2
    else { fatalError("malformed group definition '\(rawValue)'") }
    lhs = .init(rawValue: lhsRawValue)
    rhs = .init(rawValue: rhsRawValue)
  }

  var hasFullContainment: Bool {
    lhs.fullyContains(rhs) || rhs.fullyContains(lhs)
  }

  var hasOverlap: Bool {
    lhs.overlaps(rhs)
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "04.in")
  else { fatalError("input not found") }

  var count = 0
  for try await line in file.bytes.lines {
    let group = Group(rawValue: line)
    if group.hasFullContainment {
      count += 1
    }
  }

  return count
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "04.in")
  else { fatalError("input not found") }

  var count = 0
  for try await line in file.bytes.lines {
    let group = Group(rawValue: line)
    if group.hasOverlap {
      count += 1
    }
  }

  return count
}

try await print(part1())
try await print(part2())
