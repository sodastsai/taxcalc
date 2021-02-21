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
    let calculator = try Calculator(input: input, logger: BasicLogger())
    let result = try calculator.process()
    let presenter = TextPresenter(result: result)
    let output = try presenter.process()
    print(output)
  }
}

TaxCalculator.main()
