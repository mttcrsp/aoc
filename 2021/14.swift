import Foundation

guard let file = FileHandle(forReadingAtPath: "14.in")
else { fatalError("input not found") }

var lines: [String] = []
for try await line in file.bytes.lines {
  lines.append(line)
}

var template = Array(lines.removeFirst())
var rules: [[Character]: Character] = [:]
for line in lines {
  let components = line.components(separatedBy: " -> ")
  let src = Array(components[0])
  let dst = components[1].first!
  rules[src] = dst
}

var pairs: [[Character]: Int] = [:]
for i in template.indices.dropLast() {
  let pair = [template[i], template[i+1]]
  pairs[pair, default: 0] += 1
}

for i in 1 ... 40 {
  var newPairs: [[Character]: Int] = [:]
  for (pair, count) in pairs {
    let char1 = pair.first!
    let char2 = pair.last!
    let next = rules[pair]!
    newPairs[[char1, next], default: 0] += count
    newPairs[[next, char2], default: 0] += count
  }

  pairs = newPairs

  if i == 10 || i == 40 {
    var counts: [Character: Int] = [:]
    for (pair, count) in pairs {
      for character in pair {
        counts[character, default: 0] += count
      }
    }

    for (character, count) in counts {
      counts[character, default: 0] = (count+1)/2
    }

    let sortedCounts = counts.sorted { $0.value < $1.value }
    print(sortedCounts.last!.value-sortedCounts.first!.value)
  }
}
