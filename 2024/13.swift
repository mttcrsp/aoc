import Accelerate
import Foundation

guard let input = try? String(contentsOfFile: "13.in", encoding: .utf8)
else { fatalError("input not found") }

let increment = 10_000_000_000_000
let lines = input.components(separatedBy: "\n")

func solve(_ ax: Int, _ ay: Int, _ bx: Int, _ by: Int, _ prizeX: Int, _ prizeY: Int) -> (Int, Int)? {
  var n = 2, nrhs = 1
  var a = [Double(ax), Double(ay), Double(bx), Double(by)], lda = 2
  var b = [Double(prizeX), Double(prizeY)], ldb = 2
  var ipiv = [Int](repeating: 0, count: b.count)
  var info = 0
  dgesv_(&n, &nrhs, &a, &lda, &ipiv, &b, &ldb, &info)
  assert(info == 0)

  let aPresses = Int(b[0].rounded())
  let bPresses = Int(b[1].rounded())
  return
    aPresses*ax+bPresses*bx == prizeX &&
    aPresses*ay+bPresses*by == prizeY
    ? (aPresses, bPresses) : nil
}

var part1 = 0
var part2 = 0
var i = 0
while i < lines.count {
  defer { i += 4 }

  guard
    let (_, axRaw, ayRaw) = lines[i+0].firstMatch(of: /Button A: X\+(\d+), Y\+(\d+)/)?.output,
    let (_, bxRaw, byRaw) = lines[i+1].firstMatch(of: /Button B: X\+(\d+), Y\+(\d+)/)?.output,
    let (_, prizeXRaw, prizeYRaw) = lines[i+2].firstMatch(of: /Prize: X=(\d+), Y=(\d+)/)?.output,
    let ax = Int(axRaw), let ay = Int(ayRaw),
    let bx = Int(bxRaw), let by = Int(byRaw),
    let prizeX = Int(prizeXRaw), let prizeY = Int(prizeYRaw)
  else { continue }

  if let (a, b) = solve(ax, ay, bx, by, prizeX, prizeY) {
    part1 += a*3+b
  }
  if let (a, b) = solve(ax, ay, bx, by, prizeX+increment, prizeY+increment) {
    part2 += a*3+b
  }
}

print(part1)
print(part2)
