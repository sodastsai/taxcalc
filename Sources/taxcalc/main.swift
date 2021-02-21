import DataSource
import Foundation

func main(arguments: [String]) throws -> Int32 {
  guard arguments.count >= 2 else {
    print("No container path")
    return 1
  }
  let container = URL(fileURLWithPath: arguments[1])
  do {
    let records = try RecorderLoader.default.load(from: container)
    print(records.count)
  }
  return 0
}

do {
  exit(try main(arguments: ProcessInfo.processInfo.arguments))
} catch {
  print(error)
  exit(1024)
}
