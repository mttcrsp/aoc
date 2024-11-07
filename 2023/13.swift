import Foundation

struct Pattern {
  let rows: [[Character]]

  init(rawValue: String) {
    rows = rawValue.components(separatedBy: "\n").map(Array.init)
  }

  var cols: [[Character]] {
    guard let firstRow = rows.first else { return [] }

    var cols: [[Character]] = []
    for rowIndex in firstRow.indices {
      var column: [Character] = []
      for columnIndex in rows.indices {
        column.append(rows[columnIndex][rowIndex])
      }

      cols.append(column)
    }

    return cols
  }
}

func mirrorLocationRequiringSmudge(in elements: [[Character]]) -> Int? {
  for index in elements.indices.dropFirst() {
    var differences = 0
    var lhsIndex = index-1
    var rhsIndex = index
    while elements.indices ~= lhsIndex, elements.indices ~= rhsIndex {
      for (lhs, rhs) in zip(elements[lhsIndex], elements[rhsIndex]) {
        if lhs != rhs {
          differences += 1
        }
      }
      lhsIndex -= 1
      rhsIndex += 1
    }

    if differences == 1 {
      return index
    }
  }

  return nil
}

func mirrorLocation(in elements: [[Character]]) -> Int? {
  for index in elements.indices.dropFirst() {
    var lhsIndex = index-1
    var rhsIndex = index
    while
      elements.indices ~= lhsIndex,
      elements.indices ~= rhsIndex,
      elements[lhsIndex] == elements[rhsIndex]
    {
      lhsIndex -= 1
      rhsIndex += 1
    }
    if !(elements.indices ~= lhsIndex) || !(elements.indices ~= rhsIndex) {
      return index
    }
  }

  return nil
}

let input = try String(contentsOfFile: "13.in", encoding: .utf8)
let patterns = input.components(separatedBy: "\n\n").map(Pattern.init)

var rowsSum = 0
var colsSum = 0
var rowsSumRequiringSmudge = 0
var colsSumRequiringSmudge = 0
for (index, pattern) in patterns.enumerated() {
  if let location = mirrorLocation(in: pattern.rows) {
    rowsSum += location
  } else if let location = mirrorLocation(in: pattern.cols) {
    colsSum += location
  } else {
    fatalError("no mirror found in pattern at \(index)")
  }

  if let location = mirrorLocationRequiringSmudge(in: pattern.rows) {
    rowsSumRequiringSmudge += location
  } else if let location = mirrorLocationRequiringSmudge(in: pattern.cols) {
    colsSumRequiringSmudge += location
  } else {
    fatalError("no mirror found in pattern at \(index)")
  }
}

print((rowsSum*100)+colsSum)
print((rowsSumRequiringSmudge*100)+colsSumRequiringSmudge)
