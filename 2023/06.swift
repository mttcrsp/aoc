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

guard let file = FileHandle(forReadingAtPath: "06.in")
else { fatalError("input not found") }

var times: [Int] = []
var rawTime = ""
var distances: [Int] = []
var rawDistance = ""
for try await line in file.bytes.lines {
  let scanner = Scanner(string: line)
  if let _ = scanner.scanString("Time: ") {
    while let component = scanner.scanCharacters(from: .decimalDigits) {
      rawTime += component
      guard let time = Int(component)
      else { fatalError("malformed time component '\(component)'") }
      times.append(time)
    }
  } else if let _ = scanner.scanString("Distance: ") {
    while let component = scanner.scanCharacters(from: .decimalDigits) {
      rawDistance += component
      guard let distance = Int(component)
      else { fatalError("malformed distance component '\(component)'") }
      distances.append(distance)
    }
  } else {
    fatalError("unexpected line '\(line)'")
  }
}

var part1 = 1
for (time, distance) in zip(times, distances) {
  let race = Race(time: time, distance: distance)
  part1 *= race.sufficientHoldingTimesCount()
}

guard let time = Int(rawTime), let distance = Int(rawDistance)
else { fatalError("malformed time '\(rawTime)' or distance '\(rawDistance)' found") }
let race = Race(time: time, distance: distance)
let part2 = race.sufficientHoldingTimesCount()

print(part1)
print(part2)
