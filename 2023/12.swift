import Foundation

enum SpringState: String {
  case operational = "."
  case damaged = "#"
  case unknown = "?"
}

struct Row {
  var springs: [SpringState]
  var damaged: [Int]
}

extension Row {
  init(rawValue: String) {
    let components = rawValue.components(separatedBy: " ")
    guard components.count == 2 else { fatalError("malformed springs row '\(rawValue)'") }

    let damagedComponents = components[1].components(separatedBy: ",")
    guard damagedComponents.count > 0 else { fatalError("empty damaged groups in '\(rawValue)'") }

    springs = components[0].compactMap { SpringState(rawValue: String($0)) }
    damaged = damagedComponents.compactMap { Int(String($0)) }
  }

  var unfolded: Row {
    .init(
      springs: [[SpringState]](repeating: springs, count: 5)
        .joined(separator: [.unknown])
        .compactMap { $0 },
      damaged: [[Int]](repeating: damaged, count: 5)
        .flatMap { $0 }
    )
  }
}

struct CacheKey: Hashable {
  let springs: ArraySlice<SpringState>
  let damaged: ArraySlice<Int>
  let isTracking: Bool
}

var cache: [CacheKey: Int] = [:]

func arrangementsCount(for springs: ArraySlice<SpringState>, damaged: ArraySlice<Int>, isTracking: Bool = false) -> Int {
  let cacheKey = CacheKey(springs: springs, damaged: damaged, isTracking: isTracking)
  if let cachedValue = cache[cacheKey] {
    return cachedValue
  }

  let value: Int = {
    switch springs.first {
    case nil:
      return damaged == [] || damaged == [0] ? 1 : 0
    case .unknown:
      return arrangementsCount(for: [.operational]+springs.dropFirst(), damaged: damaged, isTracking: isTracking)
        + arrangementsCount(for: [.damaged]+springs.dropFirst(), damaged: damaged, isTracking: isTracking)
    case .damaged:
      if let current = damaged.first, current > 0 {
        return arrangementsCount(for: springs.dropFirst(), damaged: [current-1]+damaged.dropFirst(), isTracking: true)
      } else {
        return 0
      }
    case .operational:
      if !isTracking {
        return arrangementsCount(for: springs.dropFirst(), damaged: damaged)
      } else if damaged.first == 0 {
        return arrangementsCount(for: springs.dropFirst(), damaged: damaged.dropFirst())
      } else {
        return 0
      }
    }
  }()

  cache[cacheKey] = value
  return value
}

guard let file = FileHandle(forReadingAtPath: "12.in")
else { fatalError("input not found") }

var count = 0
var unfoldedCount = 0
for try await line in file.bytes.lines {
  let row = Row(rawValue: line)
  count += arrangementsCount(
    for: row.springs[...],
    damaged: row.damaged[...]
  )
  unfoldedCount += arrangementsCount(
    for: row.unfolded.springs[...],
    damaged: row.unfolded.damaged[...]
  )
}

print(count)
print(unfoldedCount)
