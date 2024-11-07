import Foundation

extension String {
  var customHashValue: Int {
    var hashValue = 0
    for character in self {
      guard let asciiCode = character.asciiValue
      else { fatalError("could not get ASCII code for character \(character)") }
      hashValue += Int(asciiCode)
      hashValue *= 17
      hashValue %= 256
    }
    return hashValue
  }
}

struct InsertStep {
  let label: String
  let focalLength: Int

  init?(rawValue: String) {
    let components = rawValue.components(separatedBy: "=")
    guard components.count == 2, let focalLength = Int(components[1])
    else { return nil }
    label = components[0]
    self.focalLength = focalLength
  }
}

struct RemoveStep {
  let label: String

  init?(rawValue: String) {
    guard rawValue.hasSuffix("-") else { return nil }
    label = String(rawValue.dropLast())
  }
}

struct Slot {
  var label: String
  var focalLength: Int
}

let string = try String(contentsOfFile: "15.in", encoding: .utf8)
let steps = string.components(separatedBy: ",")
var sum = 0
var boxes: [Int: [Slot]] = [:]
for step in steps {
  sum += step.customHashValue
  if let step = InsertStep(rawValue: step) {
    let slots = boxes[step.label.customHashValue]
    if let slots, let slotIndex = slots.firstIndex(where: { $0.label == step.label }) {
      boxes[step.label.customHashValue]?[slotIndex]
        .focalLength = step.focalLength
    } else {
      boxes[step.label.customHashValue, default: []].append(
        .init(label: step.label, focalLength: step.focalLength)
      )
    }
  } else if let step = RemoveStep(rawValue: step) {
    boxes[step.label.customHashValue]?.removeAll { $0.label == step.label }
  } else {
    fatalError("unrecognized step \(step)")
  }
}

var focusingPower = 0
for (boxIndex, box) in boxes {
  for (slotIndex, slot) in box.enumerated() {
    let value = (boxIndex+1)*(slotIndex+1)*slot.focalLength
    focusingPower += value
  }
}

print(sum)
print(focusingPower)
