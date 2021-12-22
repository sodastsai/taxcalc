//

import ArgumentParser
import Foundation

extension URL: ExpressibleByArgument {
  public init?(argument: String) {
    self = URL(fileURLWithPath: argument)
  }

  var isDirectiory: Bool {
    var result: ObjCBool = false
    return isFileURL && FileManager.default.fileExists(atPath: path, isDirectory: &result) && result.boolValue
  }
}
