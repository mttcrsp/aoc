import Foundation

enum Turn: CaseIterable {
  case left, right
}

enum Direction: Hashable {
  case up, down, left, right
}

struct Point: Hashable {
  var x: Int
  var y: Int
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }
}

struct VisitedItem: Hashable {
  var position: Point
  var direction: Direction
}

struct HeapItem {
  var totalHeatLoss: Int
  var position: Point
  var direction: Direction
}

class Heap {
  private let heap: CFBinaryHeap?

  init() {
    var callBacks = CFBinaryHeapCallBacks()
    callBacks.compare = { lhsPointer, rhsPointer, _ in
      let lhs = lhsPointer!.load(as: HeapItem.self)
      let rhs = rhsPointer!.load(as: HeapItem.self)
      if lhs.totalHeatLoss < rhs.totalHeatLoss {
        return .compareLessThan
      } else if lhs.totalHeatLoss > rhs.totalHeatLoss {
        return .compareGreaterThan
      } else {
        return .compareEqualTo
      }
    }
    heap = CFBinaryHeapCreate(nil, 0, &callBacks, nil)
  }

  func insert(_ value: HeapItem) {
    let pointer = UnsafeMutablePointer<HeapItem>.allocate(capacity: 1)
    pointer.initialize(to: value)
    CFBinaryHeapAddValue(heap, pointer)
  }

  func extractMin() -> HeapItem? {
    guard let item = CFBinaryHeapGetMinimum(heap)?.load(as: HeapItem.self) else { return nil }
    CFBinaryHeapRemoveMinimumValue(heap)
    return item
  }
}

typealias Grid = [[Int]]

extension Grid {
  subscript(_ point: Point) -> Int {
    self[point.y][point.x]
  }

  func contains(_ point: Point) -> Bool {
    indices.contains(point.y) &&
      self[point.y].indices.contains(point.x)
  }

  var bottomRight: Point? {
    guard let y = indices.last else { return nil }
    guard let x = self[y].indices.last else { return nil }
    return .init(x, y)
  }
}

extension HeapItem {
  var visit: VisitedItem {
    .init(position: position, direction: direction)
  }
}

extension Direction {
  func turn(_ turn: Turn) -> Direction {
    switch (self, turn) {
    case (.up, .left): return .left
    case (.up, .right): return .right
    case (.down, .left): return .right
    case (.down, .right): return .left
    case (.left, .left): return .down
    case (.left, .right): return .up
    case (.right, .left): return .up
    case (.right, .right): return .down
    }
  }
}

extension Point {
  func moved(_ direction: Direction, offset: Int) -> Point {
    switch direction {
    case .up: return .init(x, y-offset)
    case .down: return .init(x, y+offset)
    case .left: return .init(x-offset, y)
    case .right: return .init(x+offset, y)
    }
  }
}

guard let file = FileHandle(forReadingAtPath: "17.in")
else { fatalError("input not found") }

var grid: Grid = []
for try await line in file.bytes.lines {
  grid.append(line.compactMap { Int(String($0)) })
}

func minimumHeatLoss(withAllowedSameDirectionRange sameDirectionRange: ClosedRange<Int>) -> Int {
  var visited = Set<VisitedItem>()
  let heap = Heap()
  heap.insert(.init(totalHeatLoss: 0, position: .init(0, 0), direction: .right))
  heap.insert(.init(totalHeatLoss: 0, position: .init(0, 0), direction: .down))

  while let item = heap.extractMin() {
    if item.position == grid.bottomRight {
      return item.totalHeatLoss
    }

    if visited.contains(item.visit) {
      continue
    }

    visited.insert(item.visit)

    for turn in Turn.allCases {
      for offset in sameDirectionRange {
        let newDirection = item.direction.turn(turn)
        let newPosition = item.position.moved(newDirection, offset: offset)
        if grid.contains(newPosition) {
          let newTotalHeatLoss = (1 ... offset)
            .reduce(item.totalHeatLoss) { totalHeatLoss, offset in
              let position = item.position.moved(newDirection, offset: offset)
              let heatLoss = grid[position]
              return totalHeatLoss+heatLoss
            }
          heap.insert(.init(totalHeatLoss: newTotalHeatLoss, position: newPosition, direction: newDirection))
        }
      }
    }
  }

  fatalError("no path found")
}

print(minimumHeatLoss(withAllowedSameDirectionRange: 1 ... 3))
print(minimumHeatLoss(withAllowedSameDirectionRange: 4 ... 10))
