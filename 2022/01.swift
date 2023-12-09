import Foundation

func part1() throws -> Int {
  let url = URL(fileURLWithPath: "01.in")
  let string = try String(contentsOf: url)
  let lines = string.components(separatedBy: "\n")

  var maxCalories = 0
  var currentElfCalories = 0
  for line in lines {
    if line.isEmpty {
      maxCalories = Swift.max(currentElfCalories, maxCalories)
      currentElfCalories = 0
    } else if let calories = Int(line) {
      currentElfCalories += calories
    } else {
      fatalError("malformed line '\(line)'")
    }
  }

  return maxCalories
}

func part2() throws -> Int {
  let url = URL(fileURLWithPath: "01.in")
  let string = try String(contentsOf: url)
  let lines = string.components(separatedBy: "\n")

  var top3CaloriesElves: [Int] = [0, 0, 0]
  var currentElfCalories = 0
  for line in lines {
    if line.isEmpty {
      top3CaloriesElves.append(currentElfCalories)
      top3CaloriesElves.sort(by: >)
      top3CaloriesElves.removeLast()
      currentElfCalories = 0
    } else if let calories = Int(line) {
      currentElfCalories += calories
    } else {
      fatalError("malformed line '\(line)'")
    }
  }
  return top3CaloriesElves.reduce(0, +)
}

try print(part1())
try print(part2())
