import Foundation

guard let string = try? String(contentsOf: URL(filePath: "06.in"), encoding: .utf8)
else { fatalError("input not found") }

let initialState = string
  .components(separatedBy: ",")
  .compactMap { Int($0) }

var counts: [Int: Int] = [:]
for remainingDays in initialState {
  counts[remainingDays, default: 0] += 1
}

for days in 1 ... 256 {
  var nextCounts: [Int: Int] = [:]
  for (remainingDays, count) in counts {
    if remainingDays == 0 {
      nextCounts[6, default: 0] += count
      nextCounts[8, default: 0] += count
    } else {
      nextCounts[remainingDays-1, default: 0] += count
    }
  }

  counts = nextCounts
  if days == 80 || days == 256 {
    print(counts.values.reduce(0, +))
  }
}
