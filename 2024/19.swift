import Foundation

guard let input = try? String(contentsOfFile: "19.in", encoding: .utf8)
else { fatalError("input not found") }

let components = input.components(separatedBy: "\n\n")
let patterns = components[0].components(separatedBy: ", ")
let designs = components[1].components(separatedBy: "\n")

var memo: [Substring: Int] = [:]
func countCombinations(_ target: Substring) -> Int {
  if let memo = memo[target] {
    return memo
  } else if target.isEmpty {
    return 1
  }

  var result = 0
  for pattern in patterns where target.hasPrefix(pattern) {
    let nextIndex = target.index(target.startIndex, offsetBy: pattern.count)
    let nextSubstring = target[nextIndex...]
    result += countCombinations(nextSubstring)
  }

  memo[target] = result
  return result
}

var part1 = 0
var part2 = 0
for design in designs {
  let combinations = countCombinations(Substring(design))
  guard combinations > 0 else { continue }
  part1 += 1
  part2 += combinations
}

print(part1)
print(part2)
