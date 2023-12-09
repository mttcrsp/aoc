import Foundation

struct Race {
  let time: Int
  let distance: Int

  func distanceTravelled(afterHoldingFor holdingTime: Int) -> Int {
    (time-holdingTime)*holdingTime
  }

  func isSufficientHoldingTime(_ holdingTime: Int) -> Bool {
    (time-holdingTime)*holdingTime > distance
  }

  func sufficientHoldingTimesCount() -> Int {
    var holdingTime = 1
    var insufficientHoldingTimesCount = 0
    var sufficientHoldingTimeFound = false
    while !sufficientHoldingTimeFound {
      defer { holdingTime += 1 }
      if isSufficientHoldingTime(holdingTime) {
        sufficientHoldingTimeFound = true
      } else {
        insufficientHoldingTimesCount += 1
      }
    }

    holdingTime = time
    sufficientHoldingTimeFound = false
    while !sufficientHoldingTimeFound {
      defer { holdingTime -= 1 }
      if isSufficientHoldingTime(holdingTime) {
        sufficientHoldingTimeFound = true
      } else {
        insufficientHoldingTimesCount += 1
      }
    }

    return time-insufficientHoldingTimesCount
  }
}

func part1() async throws -> Int {
  guard let fileHandle = FileHandle(forReadingAtPath: "06.in")
  else { fatalError("input not found") }

  var times: [Int] = []
  var distances: [Int] = []
  for try await line in fileHandle.bytes.lines {
    let scanner = Scanner(string: line)
    if let _ = scanner.scanString("Time: ") {
      while let time = scanner.scanInt() {
        times.append(time)
      }
    } else if let _ = scanner.scanString("Distance: ") {
      while let distance = scanner.scanInt() {
        distances.append(distance)
      }
    } else {
      fatalError("unexpected line '\(line)'")
    }
  }

  var result = 1
  for (time, distance) in zip(times, distances) {
    let race = Race(time: time, distance: distance)
    result *= race.sufficientHoldingTimesCount()
  }

  return result
}

func part2() async throws -> Int {
  guard let fileHandle = FileHandle(forReadingAtPath: "06.in")
  else { fatalError("input not found") }

  var rawTime = ""
  var rawDistance = ""
  for try await line in fileHandle.bytes.lines {
    let scanner = Scanner(string: line)
    if let _ = scanner.scanString("Time: ") {
      while let component = scanner.scanCharacters(from: .decimalDigits) {
        rawTime += component
      }
    } else if let _ = scanner.scanString("Distance: ") {
      while let component = scanner.scanCharacters(from: .decimalDigits) {
        rawDistance += component
      }
    } else {
      fatalError("unexpected line '\(line)'")
    }
  }

  guard let time = Int(rawTime), let distance = Int(rawDistance)
  else { fatalError("malformed time '\(rawTime)' or distance '\(rawDistance)' found") }

  let race = Race(time: time, distance: distance)
  return race.sufficientHoldingTimesCount()
}

try await print(part1())
try await print(part2())
