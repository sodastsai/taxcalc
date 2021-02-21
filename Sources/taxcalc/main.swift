import ArgumentParser
import CGTCalcCore
import DataSource
import Foundation

struct TaxCalculator: ParsableCommand {
  @Argument(help: "Directory of Stock & Shares records")
  var recordsContainer: URL

  func run() throws {
    let records = try RecorderLoader.default.load(from: recordsContainer)
    let input = CalculatorInput(
      transactions: records.compactMap(\.transaction),
      assetEvents: records.compactMap(\.assetEvent)
    )
    print(input.transactions.count)
    print(input.assetEvents.count)
  }
}

TaxCalculator.main()
