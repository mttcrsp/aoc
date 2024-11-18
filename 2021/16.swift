import Foundation

guard let string = try? String(contentsOfFile: "16.in", encoding: .utf8)
else { fatalError("input not found") }

let mapping: [Character: String] = [
  "0": "0000", "1": "0001",
  "2": "0010", "3": "0011",
  "4": "0100", "5": "0101",
  "6": "0110", "7": "0111",
  "8": "1000", "9": "1001",
  "A": "1010", "B": "1011",
  "C": "1100", "D": "1101",
  "E": "1110", "F": "1111",
]

enum Packet {
  case literal(LiteralPacket)
  case `operator`(OperatorPacket)
}

extension Packet {
  var versionSum: Int {
    switch self {
    case let .literal(packet):
      return packet.version
    case let .operator(packet):
      var sum = packet.version
      for subpacket in packet.subpackets {
        sum += subpacket.versionSum
      }
      return sum
    }
  }
}

extension Packet {
  var value: Int {
    switch self {
    case let .literal(packet):
      return packet.value
    case let .operator(packet):
      var values: [Int] = []
      for subpacket in packet.subpackets {
        values.append(subpacket.value)
      }
      return packet.operator(values)
    }
  }
}

struct LiteralPacket {
  var version: Int
  var type: Int
  var value: Int
}

struct OperatorPacket {
  var version: Int
  var type: Int
  var subpackets: [Packet]
}

extension OperatorPacket {
  var `operator`: ([Int]) -> Int {
    switch type {
    case 0: { values in values.reduce(0, +) }
    case 1: { values in values.reduce(1, *) }
    case 2: { values in values.min()! }
    case 3: { values in values.max()! }
    case 5: { values in values[0] > values[1] ? 1 : 0 }
    case 6: { values in values[0] < values[1] ? 1 : 0 }
    case 7: { values in values[0] == values[1] ? 1 : 0 }
    case _: preconditionFailure("unexpected type \(type)")
    }
  }
}

func parseLiteral(from string: String, at index: String.Index) -> (LiteralPacket, String.Index)? {
  let vvv = string[string.index(index, offsetBy: 0) ... string.index(index, offsetBy: 2)]
  let ttt = string[string.index(index, offsetBy: 3) ... string.index(index, offsetBy: 5)]
  let version = Int(vvv, radix: 2)!
  let type = Int(ttt, radix: 2)!
  guard type == 4 else { return nil }

  var blockIndex = string.index(index, offsetBy: 6)
  var digits = ""
  while true {
    let isLast = string[blockIndex] == "0"
    let lhs = string.index(blockIndex, offsetBy: 1)
    let rhs = string.index(blockIndex, offsetBy: 4)
    digits.append(contentsOf: string[lhs ... rhs])
    blockIndex = string.index(blockIndex, offsetBy: 5)
    if isLast { break }
  }

  let value = Int(digits, radix: 2)!
  return (LiteralPacket(version: version, type: type, value: value), blockIndex)
}

func parseOperator(from string: String, at index: String.Index) -> (OperatorPacket, String.Index)? {
  let vvv = string[string.index(index, offsetBy: 0) ... string.index(index, offsetBy: 2)]
  let ttt = string[string.index(index, offsetBy: 3) ... string.index(index, offsetBy: 5)]
  let version = Int(vvv, radix: 2)!
  let type = Int(ttt, radix: 2)!
  guard type != 4 else { return nil }

  let i = string[string.index(index, offsetBy: 6)]
  let lllEndIndex = string.index(index, offsetBy: i == "0" ? 6+15 : 6+11)
  let lll = string[string.index(index, offsetBy: 7) ... lllEndIndex]
  let l = Int(lll, radix: 2)!

  var subpackets: [Packet] = []
  var index = string.index(after: lllEndIndex)

  func predicate() -> Bool {
    if i == "0" {
      string.distance(from: lllEndIndex, to: index) < l
    } else {
      subpackets.count < l
    }
  }

  while predicate() {
    if let (subpacket, nextIndex) = parse(from: string, at: index) {
      subpackets.append(subpacket)
      index = nextIndex
    }
  }

  return (OperatorPacket(version: version, type: type, subpackets: subpackets), index)
}

func parse(from string: String, at index: String.Index) -> (Packet, String.Index)? {
  if let (`operator`, index) = parseOperator(from: string, at: index) {
    return (Packet.operator(`operator`), index)
  } else if let (literal, index) = parseLiteral(from: string, at: index) {
    return (Packet.literal(literal), index)
  } else {
    return nil
  }
}

var binaryString = ""
for character in string {
  binaryString.append(contentsOf: mapping[character]!)
}

let (packet, _) = parse(from: binaryString, at: binaryString.startIndex)!
print(packet.versionSum)
print(packet.value)
