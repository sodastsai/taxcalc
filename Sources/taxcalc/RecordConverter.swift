//

import ArgumentParser
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

  func run() async throws {
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
