import Foundation

guard var string = try? String(contentsOfFile: "Sources/Resources/in", encoding: .utf8)
else { fatalError("input not found") }

let prefix = "target area: "
guard string.hasPrefix(prefix)
else { fatalError("missing expected prefix") }
string.removeFirst(prefix.count)

let ranges = string.components(separatedBy: ", ")
  .map { $0.dropFirst(2).components(separatedBy: "..").compactMap(Int.init) }

let xRange = ranges[0]
let yRange = ranges[1]

var record = Int.min
for initialValue in 1 ... 500 {
  var maxOffset = 0
  var value = initialValue
  var offset = 0
  var isValid = false
  while offset >= -30 {
    offset += value
    maxOffset = max(maxOffset, offset)
    isValid = isValid || (yRange[0] ... yRange[1]) ~= offset
    value -= 1
  }
  if isValid {
    record = max(record, maxOffset)
  }
}

print(record)

var count = 0
for x in 0 ... 200 {
  loop: for y in -150 ... 1000 {
    var position = [0, 0]
    var velocity = [x, y]
    while position[0] <= xRange.max()!, position[1] >= yRange.min()! {
      position[0] += velocity[0]
      position[1] += velocity[1]
      let xValid = xRange[0] ... xRange[1] ~= position[0]
      let yValid = yRange[0] ... yRange[1] ~= position[1]
      if xValid, yValid { count += 1; continue loop }
      if velocity[0] > 0 {
        velocity[0] -= 1
      } else if velocity[0] < 0 {
        velocity[0] += 1
      }
      velocity[1] -= 1
    }
  }
}

print(count)
