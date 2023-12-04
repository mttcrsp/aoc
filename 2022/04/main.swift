import Foundation

enum UnexpectedError: Error {
  case inputNotFound
  case malformedLine
  case malformedRange
}

extension ClosedRange<Int> {
  init(rawValue: String) throws {
    let components = rawValue.components(separatedBy: "-")
    guard
      let lowerBound = Int(components[0]),
      let upperBound = Int(components[1])
    else { throw UnexpectedError.malformedRange }
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

  init(rawValue: String) throws {
    let ranges = rawValue.components(separatedBy: ",")
    guard
      let lhsRawValue = ranges.first,
      let rhsRawValue = ranges.last,
      ranges.count == 2
    else { throw UnexpectedError.malformedLine }
    lhs = try .init(rawValue: lhsRawValue)
    rhs = try .init(rawValue: rhsRawValue)
  }

  var hasFullContainment: Bool {
    lhs.fullyContains(rhs) || rhs.fullyContains(lhs)
  }

  var hasOverlap: Bool {
    lhs.overlaps(rhs)
  }
}

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var count = 0
  for try await line in file.bytes.lines {
    let group = try Group(rawValue: line)
    if group.hasFullContainment {
      count += 1
    }
  }

  return count
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "input.txt")
  else { throw UnexpectedError.inputNotFound }

  var count = 0
  for try await line in file.bytes.lines {
    let group = try Group(rawValue: line)
    if group.hasOverlap {
      count += 1
    }
  }

  return count
}
