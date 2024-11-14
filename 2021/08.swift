import Foundation

guard let file = FileHandle(forReadingAtPath: "08.in")
else { fatalError("input not found") }

typealias Line = (inputs: [String], outputs: [String])

var lines: [Line] = []
for try await line in file.bytes.lines {
  let components = line.components(separatedBy: " | ")
  let inputs = components[0].components(separatedBy: " ")
  let outputs = components[1].components(separatedBy: " ")
  lines.append((inputs, outputs))
}

let uniqueCounts: Set<Int> = [2, 3, 4, 7]

var count = 0
for (_, outputs) in lines {
  for output in outputs {
    if uniqueCounts.contains(output.count) {
      count += 1
    }
  }
}

print(count)

var sum = 0
for line in lines {
  let values = (line.inputs+line.outputs).map(Set.init)
  var byLength: [Int: Set<Set<Character>>] = [:]
  var reverseMapping = [Set<Character>?](repeating: nil, count: 10)
  for value in values {
    let segments = Set(value)
    byLength[value.count, default: []].insert(segments)
    switch value.count {
    case 2: reverseMapping[1] = segments
    case 3: reverseMapping[7] = segments
    case 4: reverseMapping[4] = segments
    case 7: reverseMapping[8] = segments
    default: continue
    }
  }

  var charactersCounts: [Character: Int] = [:]
  for value in Set(values) {
    for character in value {
      charactersCounts[character, default: 0] += 1
    }
  }

  let segmentF = charactersCounts.first { $1 == 9 }!.key
  reverseMapping[2] = byLength[5]!.first { !$0.contains(segmentF) }!

  let segmentC = reverseMapping[1]!.subtracting([segmentF]).first!
  reverseMapping[5] = byLength[5]!.first { !$0.contains(segmentC) }!
  reverseMapping[6] = byLength[6]!.first { !$0.contains(segmentC) }!

  let segmentE = reverseMapping[6]!.subtracting(reverseMapping[5]!).first!
  reverseMapping[9] = byLength[6]!.first { !$0.contains(segmentE) && $0 != reverseMapping[6] }!
  reverseMapping[0] = byLength[6]!.first { $0 != reverseMapping[6] && $0 != reverseMapping[9] }!
  reverseMapping[3] = byLength[5]!.first { $0 != reverseMapping[2] && $0 != reverseMapping[5] }!

  var mapping: [Set<Character>: Int] = [:]
  for (index, value) in reverseMapping.enumerated() {
    mapping[value!] = index
  }

  var number = 0
  for output in line.outputs {
    if let value = mapping[Set(output)] {
      number = (number*10)+value
    }
  }

  sum += number
}

print(sum)
