//

import Foundation
import Regex

public struct RecorderLoader {
  let providers: [RecordProvider]

  public init(providers: [RecordProvider]) {
    self.providers = providers
  }

  public func provider(of fileURL: URL) throws -> RecordProvider? {
    let filename = fileURL.lastPathComponent
    return try providers.first {
      try Regex($0.filenamePattern).isMatched(by: filename)
    }
  }

  public func load(from container: URL) throws -> [Record] {
    (try loadFiles(in: container)).reduce([], +).sorted(by: \.date)
  }

  public func loadFiles(in container: URL) throws -> [[Record]] {
    let fileURLs = try FileManager.default.contentsOfDirectory(at: container, includingPropertiesForKeys: [])
    return try fileURLs.compactMap { fileURL in
      guard let provider = try provider(of: fileURL) else {
        return nil
      }
      return try provider.read(contentsOf: fileURL)
    }
  }
}

public extension RecorderLoader {
  static var `default`: RecorderLoader {
    RecorderLoader(providers: [
      FirstradeRecordProvider(),
      SchwabEACRecordProvider(),
      SchwabIndividualRecordProvider(),
    ])
  }
}
