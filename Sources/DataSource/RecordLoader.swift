//

import Foundation

public struct RecorderLoader {
  let providers: [RecordProvider]

  public init(providers: [RecordProvider]) {
    self.providers = providers
  }

  func provider(of fileURL: URL) -> RecordProvider? {
    let filename = fileURL.lastPathComponent
    let fullFilenameRange = filename.startIndex ..< filename.endIndex
    return providers.first {
      filename.range(of: $0.filenamePattern, options: .regularExpression) == fullFilenameRange
    }
  }

  public func load(from container: URL) throws -> [Record] {
    let fileURLs = try FileManager.default.contentsOfDirectory(at: container, includingPropertiesForKeys: [])
    return try fileURLs.compactMap { fileURL in
      guard let provider = provider(of: fileURL) else {
        return nil
      }
      return try provider.read(contentsOf: fileURL)
    }.reduce([], +)
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
