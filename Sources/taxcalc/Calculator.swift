//

import ArgumentParser
import CGTCalcCore
import Foundation

struct Calculator: ParsableCommand {
  static var configuration
    = CommandConfiguration(commandName: "calc", abstract: "Calculate tax based on CGTCalc format records")

  @Argument(help: "The output directory for storing the CGTCalc record")
  var outputDirectory: URL

  func run() throws {
    let logger = BasicLogger()
    logger.level = .Warn
    let input = try getInput()
    let calculator = try CGTCalcCore.Calculator(input: input, logger: logger)
    let result = try calculator.process()
    let presenter = TextPresenter(result: result)
    let output = try presenter.process()

    print(output)
  }

  func getAllRecords() throws -> String {
    try FileManager.default.contentsOfDirectory(at: outputDirectory, includingPropertiesForKeys: nil)
      .filter(\.isCGTCalcRecordURL).map { try String(contentsOf: $0) }.reduce("") {
        $0 + "\n" + $1
      }
  }

  func getInput() throws -> CalculatorInput {
    let records = try getAllRecords()
    let rawInput = try DefaultParser().calculatorInput(fromData: records)
    return CalculatorInput(
      transactions: rawInput.transactions.sorted(by: \.date),
      assetEvents: rawInput.assetEvents.sorted(by: \.date)
    )
  }
}

extension URL {
  var isCGTCalcRecordURL: Bool {
    pathExtension == "txt" && deletingPathExtension().pathExtension == "cgtcalc"
  }
}
