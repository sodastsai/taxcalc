import CodableCSV
import DataFormat
import Foundation

public struct SchwabEACRecord {
  public enum Action: String {
    case lapse = "Lapse"
  }

  public let date: Date
  public let action: Action
  public let symbol: String
  public let description: String
  public let quantity: Int
  public let feesAndCommissions: Currency
  public let disbursementElection: Currency
  public let amount: Currency
  public let awardDate: Date
  public let awardId: String
  public let fairMarketValue: Currency
  public let salePrice: Currency
  public let sharesSoldOrWithheldForTaxes: Int
  public let netSharesDeposited: Int
  public let totalTaxes: Currency

  public init(
    date: Date,
    action: Action,
    symbol: String,
    description: String,
    quantity: Int,
    feesAndCommissions: Currency,
    disbursementElection: Currency,
    amount: Currency,
    awardDate: Date,
    awardId: String,
    fairMarketValue: Currency,
    salePrice: Currency,
    sharesSoldOrWithheldForTaxes: Int,
    netSharesDeposited: Int,
    totalTaxes: Currency
  ) {
    self.date = date
    self.action = action
    self.symbol = symbol
    self.description = description
    self.quantity = quantity
    self.feesAndCommissions = feesAndCommissions
    self.disbursementElection = disbursementElection
    self.amount = amount
    self.awardDate = awardDate
    self.awardId = awardId
    self.fairMarketValue = fairMarketValue
    self.salePrice = salePrice
    self.sharesSoldOrWithheldForTaxes = sharesSoldOrWithheldForTaxes
    self.netSharesDeposited = netSharesDeposited
    self.totalTaxes = totalTaxes
  }
}

extension SchwabEACRecord: CustomStringConvertible, Equatable {}

extension SchwabEACRecord.Action: Decodable {}

extension SchwabEACRecord: Decodable {
  public enum DecodingError: Error {
    case invalidFileFormat
    case invalidDateFormat(String)
    case invalidDecimalFormat(String)
  }

  private enum CodingKey: String, Swift.CodingKey {
    case date = "Date"
    case action = "Action"
    case symbol = "Symbol"
    case description = "Description"
    case quantity = "Quantity"
    case feesAndCommissions = "Fees & Commissions"
    case disbursementElection = "Disbursement Election"
    case amount = "Amount"
    case awardDate = "Award Date"
    case awardId = "Award ID"
    case fairMarketValue = "Fair Market Value"
    case salePrice = "Sale Price"
    case sharesSoldOrWithheldForTaxes = "Shares Sold/Withheld for Taxes"
    case netSharesDeposited = "Net Shares Deposited"
    case totalTaxes = "Total Taxes"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    date = try container.decode(Date.self, forKey: .date)
    action = try container.decode(Action.self, forKey: .action)
    symbol = try container.decode(String.self, forKey: .symbol)
    description = try container.decode(String.self, forKey: .description)
    quantity = try container.decode(Int.self, forKey: .quantity)
    feesAndCommissions = try container.decode(Currency.self, forKey: .feesAndCommissions, at: date)
    disbursementElection = try container.decode(Currency.self, forKey: .disbursementElection, at: date)
    amount = try container.decode(Currency.self, forKey: .amount, at: date)
    awardDate = try container.decode(Date.self, forKey: .awardDate)
    awardId = try container.decode(String.self, forKey: .awardId)
    fairMarketValue = try container.decode(Currency.self, forKey: .fairMarketValue, at: date)
    salePrice = try container.decode(Currency.self, forKey: .salePrice, at: date)
    sharesSoldOrWithheldForTaxes = try container.decode(Int.self, forKey: .sharesSoldOrWithheldForTaxes)
    netSharesDeposited = try container.decode(Int.self, forKey: .netSharesDeposited)
    totalTaxes = try container.decode(Currency.self, forKey: .totalTaxes, at: date)
  }
}

public extension SchwabEACRecord {
  static func from(contentsOf url: URL) throws -> [Self] {
    let fileContent = try String(contentsOf: url, encoding: .utf8)
    let csvContent = try normalizeCSVLines(fileContent)
    let decoder = CSVDecoder {
      $0.headerStrategy = .firstLine
      $0.dateStrategy = .custom(parseDate(from:))
      $0.decimalStrategy = .custom(parseDecimal(from:))
      $0.trimStrategy = .whitespaces
    }
    return try decoder.decode([Self].self, from: csvContent)
  }
}

private extension KeyedDecodingContainer {
  func decode(_: Currency.Type, forKey key: Key, at date: Date) throws -> Currency {
    let decimal = try decode(Decimal.self, forKey: key)
    return Currency(amount: decimal, unit: .USD, time: date)
  }
}

private func normalizeCSVLines(_ originalContent: String) throws -> String {
  let csvLines = originalContent.split(separator: "\r\n")
  guard csvLines.count > 4 else {
    throw SchwabEACRecord.DecodingError.invalidFileFormat
  }
  let fullHeader = join(firstRow: 1, secondRow: 3, in: csvLines)
  var normalizedCSVLines = [String]()
  let consumedLines = {
    // 2 for file head line and the original title line
    // 3 for first content line, additional header line, and second content line
    2 + normalizedCSVLines.count * 3
  }
  while consumedLines() < csvLines.count {
    let normalizedEntryIndex = normalizedCSVLines.count + 1
    let firstRowIndex = normalizedEntryIndex * 3 - 1
    let secondRowIndex = firstRowIndex + 2
    guard
      firstRowIndex < csvLines.count,
      secondRowIndex < csvLines.count
    else {
      throw SchwabEACRecord.DecodingError.invalidFileFormat
    }
    normalizedCSVLines.append(join(firstRow: firstRowIndex, secondRow: secondRowIndex, in: csvLines))
  }
  guard consumedLines() == csvLines.count else {
    throw SchwabEACRecord.DecodingError.invalidFileFormat
  }
  normalizedCSVLines.insert(fullHeader, at: 0)
  return normalizedCSVLines.joined(separator: "\n")
}

private func join(firstRow: Int, secondRow: Int, in csvLines: [String.SubSequence]) -> String {
  "\(csvLines[firstRow])\(csvLines[secondRow].dropFirst(2))"
}

private let dateFormatters: [DateFormatter] = [
  {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
  }(),
  {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter
  }(),
]

private func parseDate(from decoder: Decoder) throws -> Date {
  let string = try String(from: decoder)
  for dateFormatter in dateFormatters {
    if let date = dateFormatter.date(from: string) {
      return date
    }
  }
  throw SchwabEACRecord.DecodingError.invalidDateFormat(string)
}

private func parseDecimal(from decoder: Decoder) throws -> Decimal {
  let string = try String(from: decoder)
  let decimalString = string.replacingOccurrences(of: "$", with: "")
  if decimalString.isEmpty {
    return 0
  }
  guard let decimal = Decimal(string: decimalString) else {
    throw SchwabEACRecord.DecodingError.invalidDecimalFormat(string)
  }
  return decimal
}
