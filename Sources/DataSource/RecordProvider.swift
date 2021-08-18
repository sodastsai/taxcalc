//

import Foundation

public protocol RecordProvider {
  var filenamePattern: String { get }
  func read(contentsOf url: URL) throws -> [Record]
}
