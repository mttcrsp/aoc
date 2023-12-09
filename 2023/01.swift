import Foundation

func part1() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "01.in")
  else { fatalError("input not found") }

  var calibrationValue = 0
  for try await line in file.bytes.lines {
    guard
      let firstDigit = line.first(where: \.isNumber),
      let lastDigit = line.last(where: \.isNumber),
      let first = Int(String(firstDigit)),
      let last = Int(String(lastDigit))
    else { fatalError("no digit found in '\(line)'") }

    calibrationValue += first*10
    calibrationValue += last
  }

  return calibrationValue
}

func part2() async throws -> Int {
  guard let file = FileHandle(forReadingAtPath: "01.in")
  else { fatalError("input not found") }

  let mapping: [String: Int] = [
    "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
    "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
  ]

  func firstDigit(in string: String) -> Int {
    for index in string.indices {
      for (digit, value) in mapping {
        if string[index...].hasPrefix(digit) {
          return value
        }
      }
    }
    fatalError("not match found in '\(string)'")
  }

  func lastDigit(in string: String) -> Int {
    for index in string.indices.reversed() {
      for (digit, value) in mapping {
        if string[index...].hasPrefix(digit) {
          return value
        }
      }
    }
    fatalError("not match found in '\(string)'")
  }

  var calibrationValue = 0
  for try await line in file.bytes.lines {
    let first = firstDigit(in: line)
    let last = lastDigit(in: line)
    calibrationValue += (first*10)+last
  }

  return calibrationValue
}

try await print(part1())
try await print(part2())
