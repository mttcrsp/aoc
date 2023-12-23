import Foundation

enum Pulse {
  case high, low
}

enum ModuleType {
  case broadcaster
  case conjunction
  case flipFlop
}

class Module {
  var moduleType: ModuleType
  var id: String
  var destinationIDs: [String] = []
  var isOn = false
  var memory: [String: Pulse] = [:]

  init(rawValue: String) {
    let scanner = Scanner(string: rawValue)
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: " ,")

    if rawValue.starts(with: "broadcaster") {
      moduleType = .broadcaster
    } else if let _ = scanner.scanString("&") {
      moduleType = .conjunction
    } else if let _ = scanner.scanString("%") {
      moduleType = .flipFlop
    } else {
      fatalError("unknown module type in '\(rawValue)'")
    }

    guard let id = scanner.scanCharacters(from: .letters)
    else { fatalError("id not found in module '\(rawValue)'") }
    self.id = id

    guard let _ = scanner.scanString("->")
    else { fatalError("destinations not found in module '\(rawValue)'") }
    while let id = scanner.scanCharacters(from: .letters) {
      destinationIDs.append(id)
    }
  }

  func process(_ pulse: Pulse, from previousID: String) -> Pulse? {
    switch moduleType {
    case .flipFlop:
      switch pulse {
      case .high:
        return nil
      case .low:
        defer { isOn.toggle() }
        return isOn ? .low : .high
      }
    case .conjunction:
      memory[previousID] = pulse
      return memory.values.allSatisfy { $0 == .high } ? .low : .high
    case .broadcaster:
      return pulse
    }
  }
}

guard let file = FileHandle(forReadingAtPath: "20.in")
else { fatalError("input not found") }

var modules: [String: Module] = [:]
for try await line in file.bytes.lines {
  let module = Module(rawValue: line)
  modules[module.id] = module
}

for (sourceID, module) in modules {
  for destinationID in module.destinationIDs {
    if case .conjunction = modules[destinationID]?.moduleType {
      module.memory[sourceID] = .low
    }
  }
}

var highCount = 0
var lowCount = 0
for _ in 1 ... 1000 {
  var queue: [(String, String, Pulse)] = [("button", "broadcaster", .low)]
  while !queue.isEmpty {
    let (previousID, id, pulse) = queue.removeFirst()

    switch pulse {
    case .high: highCount += 1
    case .low: lowCount += 1
    }

    if let module = modules[id] {
      if let pulse = module.process(pulse, from: previousID) {
        for destinationID in module.destinationIDs {
          queue.append((id, destinationID, pulse))
        }
      }
    }
  }
}

let result = highCount*lowCount
print(result)
