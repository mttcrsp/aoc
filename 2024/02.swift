import Foundation

guard let input = try? String(contentsOfFile: "02.in", encoding: .utf8)
else { fatalError("input not found") }

let lines = input.components(separatedBy: "\n")

func isSafe(_ report: [Int]) -> Bool {
  let isIncreasing = report[0] < report[1]
  for index in report.indices.dropFirst() {
    guard abs(report[index]-report[index-1]) <= 3 else { return false }

    if isIncreasing, report[index] <= report[index-1] {
      return false
    } else if !isIncreasing, report[index] >= report[index-1] {
      return false
    }
  }

  return true
}

func isAlmostSafe(_ report: [Int]) -> Bool {
  var isAlmostSafe = false
  for index in report.indices {
    var copy = report
    copy.remove(at: index)
    if isSafe(copy) {
      isAlmostSafe = true
      break
    }
  }

  return isAlmostSafe
}

var safeReports = 0
var almostSafeReports = 0
for line in lines {
  let report = line.components(separatedBy: " ").compactMap(Int.init)
  if isSafe(report) {
    safeReports += 1
    almostSafeReports += 1
  } else if isAlmostSafe(report) {
    almostSafeReports += 1
  }
}

print(safeReports)
print(almostSafeReports)
