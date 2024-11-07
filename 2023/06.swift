import Foundation

extension [Race] {
  init(rawValue: String) {
    self.init()

    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .whitespacesAndNewlines

    _ = scanner.scanString("Time:")
    var times: [Int] = []
    while let time = scanner.scanInt() {
      times.append(time)
    }

    _ = scanner.scanString("Distance:")
    var distances: [Int] = []
    while let distance = scanner.scanInt() {
      distances.append(distance)
    }

    for (time, distance) in zip(times, distances) {
      append(Race(time: time, distance: distance))
    }
  }
}

extension Race {
  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = .whitespacesAndNewlines

    _ = scanner.scanString("Time:")
    var rawTime = ""
    while let component = scanner.scanCharacters(from: .decimalDigits) {
      rawTime += component
    }

    _ = scanner.scanString("Distance:")
    var rawDistance = ""
    while let component = scanner.scanCharacters(from: .decimalDigits) {
      rawDistance += component
    }

    guard let time = Int(rawTime), let distance = Int(rawDistance)
    else { fatalError("failed to convert '\(rawTime)' or '\(rawDistance)' to Int") }
    self.time = time
    self.distance = distance
  }
}

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

let string = try String(contentsOfFile: "06.in", encoding: .utf8)
let races = [Race](rawValue: string)
print(races.map { $0.sufficientHoldingTimesCount() }.reduce(1, *))

let race = Race(rawValue: string)
print(race.sufficientHoldingTimesCount())
