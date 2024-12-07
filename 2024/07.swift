import Foundation

guard let input = try? String(contentsOfFile: "07.in", encoding: .utf8)
else { fatalError("input not found") }

struct Equation: Hashable {
  var result: Int
  var numbers: [Int]

  func canBeSolved(supportingConcatenation: Bool = false, index: Int = 0, result: Int? = nil) -> Bool {
    if index == numbers.count {
      return result == self.result
    }

    return
      canBeSolved(
        supportingConcatenation: supportingConcatenation,
        index: index+1,
        result: (result ?? 0)+numbers[index]
      ) ||
      canBeSolved(
        supportingConcatenation: supportingConcatenation,
        index: index+1,
        result: (result ?? 1)*numbers[index]
      ) ||
      (supportingConcatenation && canBeSolved(
        supportingConcatenation: supportingConcatenation,
        index: index+1,
        result: Int("\(result.flatMap(String.init) ?? "")\(numbers[index])")
      ))
  }
}

var part1 = 0
var part2 = 0
for line in input.components(separatedBy: "\n") {
  let components = line.components(separatedBy: ":")
  let result = Int(components[0])!
  let numbers = components[1].components(separatedBy: " ").compactMap(Int.init)
  let equation = Equation(result: result, numbers: numbers)
  if equation.canBeSolved() { part1 += equation.result }
  if equation.canBeSolved(supportingConcatenation: true) { part2 += equation.result }
}

print(part1)
print(part2)
