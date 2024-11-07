import Foundation

guard let file = FileHandle(forReadingAtPath: "01.in")
else { fatalError("input not found") }

var depths: [Int] = []
for try await line in file.bytes.lines {
  guard let depth = Int(line)
  else { fatalError("malformed depth '\(line)'") }
  depths.append(depth)
}

var largerMeasurementsCount = 0
for i in depths.indices.dropFirst() {
  if depths[i] > depths[i-1] {
    largerMeasurementsCount += 1
  }
}

var largerWindowsCount = 0
for i in depths.indices.dropFirst(3) {
  let window1 = depths[i-3]+depths[i-2]+depths[i-1]
  let window2 = depths[i-2]+depths[i-1]+depths[i-0]
  if window2 > window1 {
    largerWindowsCount += 1
  }
}

print(largerMeasurementsCount)
print(largerWindowsCount)
