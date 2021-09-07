//

import ArgumentParser
import CGTCalcCore
import DataSource
import Foundation

struct TaxCalculator: AsyncParsableCommand {
  @Argument(help: "Directory of Stock & Shares records")
  var recordsContainer: URL

  func run() async throws {
    let records = try RecorderLoader.default.load(from: recordsContainer)
    let (transactions, assetEvents) = try await records.groupedByRecordType()

    let serializedRecords = serialize(transactions: transactions, assetEvents: assetEvents)
    let input = try DefaultParser().calculatorInput(fromData: serializedRecords)
    let logger = BasicLogger()
    logger.level = .Warn
    let calculator = try Calculator(input: input, logger: logger)
    let result = try calculator.process()
    let presenter = TextPresenter(result: result)
    let output = try presenter.process()

    print(output)
  }
}

@main
enum App {
  static func main() async throws {
    try await TaxCalculator.main()
  }
}
