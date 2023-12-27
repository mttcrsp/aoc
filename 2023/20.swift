import Foundation

enum Pulse {
  case hi, lo
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
      case .hi:
        return nil
      case .lo:
        defer { isOn.toggle() }
        return isOn ? .lo : .hi
      }
    case .conjunction:
      memory[previousID] = pulse
      return memory.values.allSatisfy { $0 == .hi } ? .lo : .hi
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

for (sourceID, sourceModule) in modules {
  for destinationID in sourceModule.destinationIDs {
    if let destinationModule = modules[destinationID] {
      if case .conjunction = destinationModule.moduleType {
        destinationModule.memory[sourceID] = .lo
      }
    }
  }
}

var rxConjunction: Module?
for (_, sourceModule) in modules {
  for destinationID in sourceModule.destinationIDs {
    if destinationID == "rx", case .conjunction = sourceModule.moduleType {
      rxConjunction = sourceModule
    }
  }
}

guard let rxConjunction
else { fatalError("rx source conjunction module not found") }

var hiCount = 0
var loCount = 0
var rxSourcesActivations: [String: Int] = [:]
var buttonPressesCount = 0
while true {
  if buttonPressesCount == 1000 {
    print(hiCount*loCount)
  } else if rxSourcesActivations.count == rxConjunction.memory.count {
    print(rxSourcesActivations.values.reduce(1, *))
    break
  }

  buttonPressesCount += 1

  var queue: [(String, String, Pulse)] = [("button", "broadcaster", .lo)]
  while !queue.isEmpty {
    let (previousID, id, pulse) = queue.removeFirst()

    switch pulse {
    case .hi: hiCount += 1
    case .lo: loCount += 1
    }

    if let module = modules[id] {
      if let pulse = module.process(pulse, from: previousID) {
        for destinationID in module.destinationIDs {
          queue.append((id, destinationID, pulse))
        }
      }

      if module === rxConjunction {
        for (id, pulse) in module.memory where pulse == .hi {
          rxSourcesActivations[id] = buttonPressesCount
        }
      }
    }
  }
}
