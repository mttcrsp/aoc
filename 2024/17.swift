import Foundation

guard let input = try? String(contentsOfFile: "17.in", encoding: .utf8)
else { fatalError("input not found") }

let components = input.components(separatedBy: "\n\n")
let registers = components[0].components(separatedBy: "\n")
var registerA = Int(registers[0].replacingOccurrences(of: "Register A: ", with: ""))!
var registerB = Int(registers[1].replacingOccurrences(of: "Register B: ", with: ""))!
var registerC = Int(registers[2].replacingOccurrences(of: "Register C: ", with: ""))!
let instructions = components[1]
  .replacingOccurrences(of: "Program: ", with: "")
  .components(separatedBy: ",")
  .compactMap(Int.init)

func execute(
  _ instructions: [Int],
  registerA: Int = registerA,
  registerB: Int = registerB,
  registerC: Int = registerC
)
  -> [Int]
{
  var registerA = registerA
  var registerB = registerB
  var registerC = registerC
  var output: [Int] = []
  var ip = 0

  while ip < instructions.count {
    let operand = instructions[ip+1]
    var comboOperand: Int {
      switch operand {
      case 0, 1, 2, 3: operand
      case 4: registerA
      case 5: registerB
      case 6: registerC
      case let operand: fatalError("unexpect value for combo operand \(operand)")
      }
    }

    switch instructions[ip] {
    case 0: registerA = Int(Double(registerA)/pow(2.0, Double(comboOperand)))
    case 6: registerB = Int(Double(registerA)/pow(2.0, Double(comboOperand)))
    case 7: registerC = Int(Double(registerA)/pow(2.0, Double(comboOperand)))
    case 1: registerB ^= operand
    case 2: registerB = comboOperand%8
    case 3 where registerA == 0: break
    case 3: ip = operand; continue
    case 4: registerB ^= registerC
    case 5: output.append(comboOperand%8)
    case let instruction: fatalError("unexpected instruction \(instruction)")
    }

    ip += 2
  }

  return output
}

// B=A%8
// B=B^3
// C=A/2^B
// B=B^C
// A=A/2^3
// B=B^5
// out B%8
// jump 0

let output = execute(instructions)
print(String(output.map(\.description).joined(separator: ",")))

let lo = 236_555_997_347_838
let hi = 236_555_997_380_608
for i in lo ... hi {
  if execute(instructions, registerA: i) == instructions {
    print(i)
    break
  }
}
