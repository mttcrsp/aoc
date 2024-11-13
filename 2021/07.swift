import Foundation

guard let string = try? String(contentsOf: URL(filePath: "07.in"), encoding: .utf8)
else { fatalError("input not found") }

let positions = string
  .components(separatedBy: ",")
  .compactMap { Int($0) }

var minPosition = Int.max
var maxPosition = Int.min
for position in positions {
  minPosition = min(minPosition, position)
  maxPosition = max(maxPosition, position)
}

var minLinearAlignmentCost = Int.max
var minAlignmentCost = Int.max
for destination in minPosition ... maxPosition {
  var linearAlignmentCost = 0
  var alignmentCost = 0
  for position in positions {
    let linearCost = abs(destination-position)
    linearAlignmentCost += linearCost
    alignmentCost += (linearCost*(linearCost+1))/2
  }

  minLinearAlignmentCost = min(minLinearAlignmentCost, linearAlignmentCost)
  minAlignmentCost = min(minAlignmentCost, alignmentCost)
}

print(minLinearAlignmentCost)
print(minAlignmentCost)
