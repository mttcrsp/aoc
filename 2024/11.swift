import Foundation

guard let input = try? String(contentsOfFile: "11.in", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")
let numbers = lines[0].components(separatedBy: " ").compactMap(Int.init)

var memo: [[Int]: Int] = [:]
func stones(from stone: Int, after blinks: Int) -> Int {
  if let memo = memo[[stone, blinks]] {
    return memo
  } else if blinks == 0 {
    return 1
  }

  let result: Int
  if stone == 0 {
    result = stones(from: 1, after: blinks-1)
  } else if !String(stone).count.isMultiple(of: 2) {
    result = stones(from: stone*2024, after: blinks-1)
  } else {
    let digits = Array(String(stone))
    let lhs = Int(String(digits[0 ..< digits.count/2]))!
    let rhs = Int(String(digits[(digits.count/2) ..< digits.count]))!
    result = stones(from: lhs, after: blinks-1)+stones(from: rhs, after: blinks-1)
  }

  memo[[stone, blinks]] = result
  return result
}

var part1 = 0
var part2 = 0
for number in numbers {
  part2 += stones(from: number, after: 75)
  part1 += stones(from: number, after: 25)
}

print(part1)
print(part2)
