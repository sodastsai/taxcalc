//

import ArgumentParser
import CollectionConcurrencyKit
import DataSource
import Foundation

struct RecordConverter: AsyncParsableCommand {
  enum Error: Swift.Error {
    case noProvider
  }

  static var configuration
    = CommandConfiguration(commandName: "convert", abstract: "Convert records to CGTCalc format")

  @Argument(help: "The record file from brokers")
  var inputFile: URL

  @Argument(help: "The output directory for storing the CGTCalc record")
  var outputDirectory: URL

  private var inputFiles: [URL] {
    if inputFile.isDirectiory {
      guard let filePaths = try? FileManager.default.contentsOfDirectory(atPath: inputFile.path) else {
        return []
      }
      return filePaths.map {
        return inputFile.appendingPathComponent($0)
      }
    } else {
      return [inputFile]
    }
  }

  func run() async throws {
    try await inputFiles.concurrentForEach { fileURL in
      do {
        try await run(withFile: fileURL)
      } catch Error.noProvider {
        // Skip this file
      }
    }
  }

  private func run(withFile inputFile: URL) async throws {
    guard let provider = try RecorderLoader.default.provider(of: inputFile) else {
      throw Error.noProvider
    }

    let records = try provider.read(contentsOf: inputFile).sorted(by: \.date)
    let (transactions, assetEvents) = try await records.groupedByRecordType()
    let serializedRecords = serialize(transactions: transactions, assetEvents: assetEvents)

    let inputFileName = inputFile.deletingPathExtension().lastPathComponent
    let outputFile = outputDirectory.appendingPathComponent(inputFileName).appendingPathExtension("cgtcalc.txt")
    try serializedRecords.write(to: outputFile, atomically: true, encoding: .utf8)
    print("Converted records is saved at \(outputFile.isFileURL ? outputFile.path : String(describing: outputFile))")
  }
}
