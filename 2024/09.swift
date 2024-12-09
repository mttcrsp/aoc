import Foundation

guard let input = try? String(contentsOfFile: "09.in", encoding: .utf8)
else { fatalError("input not found") }

let numbers = Array(input).map(String.init).compactMap(Int.init)

struct Block {
  var file: Int
  var free: Int = 0
}

var blocks: [Block] = []
for (index, number) in numbers.enumerated() {
  if index.isMultiple(of: 2) {
    blocks.append(.init(file: number))
  } else {
    blocks[blocks.count-1].free = number
  }
}

var lhs = 0
var rhs = blocks.count-1
var position = 0
var part1 = 0
while lhs < rhs {
  if blocks[lhs].file > 0 {
    part1 += lhs*position
    position += 1
    blocks[lhs].file -= 1
  } else if blocks[lhs].free > 0 {
    part1 += rhs*position
    position += 1
    blocks[rhs].file -= 1
    blocks[lhs].free -= 1
    if blocks[rhs].file == 0 { rhs -= 1 }
    if blocks[lhs].free == 0 { lhs += 1 }
  } else {
    lhs += 1
  }
}

while blocks[lhs].file > 0 {
  part1 += lhs*position
  blocks[lhs].file -= 1
  position += 1
}

print(part1)

struct PositionedBlock {
  var size: Int
  var position: Int
  var id: Int?
}

var files: [PositionedBlock] = []
var frees: [PositionedBlock] = []
var memory: [Int?] = []
for (index, size) in numbers.enumerated() {
  if index.isMultiple(of: 2) {
    files.append(.init(size: size, position: memory.count, id: files.count))
    memory.append(contentsOf: [Int?](repeating: files.count-1, count: size))
  } else {
    frees.append(.init(size: size, position: memory.count))
    memory.append(contentsOf: [Int?](repeating: nil, count: size))
  }
}

nextFile: for fileBlock in files.reversed() {
  for (freeIndex, freeBlock) in frees.enumerated() {
    guard freeBlock.position < fileBlock.position, fileBlock.size <= freeBlock.size else { continue }
    memory.replaceSubrange(fileBlock.position ..< fileBlock.position+fileBlock.size, with: [Int?](repeating: nil, count: fileBlock.size))
    memory.replaceSubrange(freeBlock.position ..< freeBlock.position+fileBlock.size, with: [Int?](repeating: fileBlock.id, count: fileBlock.size))
    frees[freeIndex] = .init(size: freeBlock.size-fileBlock.size, position: freeBlock.position+fileBlock.size)
    continue nextFile
  }
}

var part2 = 0
for (index, number) in memory.enumerated() {
  if let number {
    part2 += index*number
  }
}

print(part2)
