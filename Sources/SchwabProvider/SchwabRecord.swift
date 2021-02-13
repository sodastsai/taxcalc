import CodableCSV
import DataFormat
import Foundation

public struct SchwabRecord {
  public enum Action: String, Decodable {
    case reinvestShares = "Reinvest Shares"
    case dividendReinvested = "Qual Div Reinvest"
    case dividend = "Qualified Dividend"
    case dividendNRATax = "NRA Tax Adj"
    case cashDividend = "Cash Dividend"
    case incomingWire = "Wire Funds Received"
    case outgoingWire = "Wire Funds"
    case miscCashEntry = "Misc Cash Entry"
    case serviceFee = "Service Fee"
    case sell = "Sell"
    case stockPlanActivity = "Stock Plan Activity"
    case reorganizedIssue = "Reorganized Issue"
    case stockSplit = "Stock Split"
    case autoS1Debit = "Auto S1 Debit"
    case autoS1Credit = "Auto S1 Credit"
    case buy = "Buy"
    case creditInterest = "Credit Interest"
    case cancelBuy = "Cancel Buy"
    case journal = "Journal"
    case moneyLinkDeposit = "MoneyLink Deposit"
  }

  public let action: Action
  public let symbol: String?
  public let description: String
  public let tradeDate: Date
  public let settledDate: Date
  public let quantity: Decimal?
  public let price: Currency?
  public let feesAndComm: Currency?
  public let amount: Currency?

  public init(action: Action,
              symbol: String?,
              description: String,
              tradeDate: Date,
              settledDate: Date,
              quantity: Decimal?,
              price: Currency?,
              feesAndComm: Currency?,
              amount: Currency?) {
    self.action = action
    self.symbol = symbol
    self.description = description
    self.tradeDate = tradeDate
    self.settledDate = settledDate
    self.quantity = quantity
    self.price = price
    self.feesAndComm = feesAndComm
    self.amount = amount
  }
}

extension SchwabRecord: CustomStringConvertible, Equatable {}

extension SchwabRecord: Decodable {
  public enum DecodingError: Error {
    case invalidFileFormat
    case invalidDateFormat
    case nonDecimalString(String)
  }

  fileprivate enum CodingKeys: String, CodingKey {
    case date = "Date"
    case action = "Action"
    case symbol = "Symbol"
    case description = "Description"
    case quantity = "Quantity"
    case price = "Price"
    case feesAndComm = "Fees & Comm"
    case amount = "Amount"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    action = try container.decode(Action.self, forKey: .action)
    symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
    description = try container.decode(String.self, forKey: .description)
    (tradeDate, settledDate) = try decodeDate(from: container)
    quantity = try container.decodeIfPresent(Decimal.self, forKey: .quantity)
    price = try decodeCurrency(from: container, for: .price, at: tradeDate)
    feesAndComm = try decodeCurrency(from: container, for: .feesAndComm, at: tradeDate)
    amount = try decodeCurrency(from: container, for: .amount, at: tradeDate)
  }
}

public extension SchwabRecord {
  static func from(contentsOf url: URL) throws -> [Self] {
    let fileContent = try String(contentsOf: url, encoding: .utf8)
    // skipping first title line
    guard let csvString = fileContent.split(separator: "\r\n", maxSplits: 1).last else {
      throw DecodingError.invalidFileFormat
    }
    let decoder = CSVDecoder {
      $0.headerStrategy = .firstLine
      $0.trimStrategy = .whitespaces
      $0.decimalStrategy = .custom(parse(decimal:))
    }
    return try decoder.decode([Self].self, from: String(csvString))
  }
}

private func decodeDate(from container: KeyedDecodingContainer<SchwabRecord.CodingKeys>) throws -> (Date, Date) {
  let string = try container.decode(String.self, forKey: .date)
  let pattern = try NSRegularExpression(pattern: #"(\d{2}/\d{2}/\d{4})"#)
  let matches = pattern.matches(in: string, range: string.fullStringRange)
  if matches.count == 1 {
    guard
      let dateString = string.matchedSubstring(of: matches[0]),
      let date = dateFormatter.date(from: String(dateString))
    else {
      throw SchwabRecord.DecodingError.invalidDateFormat
    }
    return (date, date)
  } else if matches.count == 2 {
    guard
      let settledDateString = string.matchedSubstring(of: matches[0]),
      let settledDate = dateFormatter.date(from: String(settledDateString)),
      let tradeDateString = string.matchedSubstring(of: matches[1]),
      let tradeDate = dateFormatter.date(from: String(tradeDateString))
    else {
      throw SchwabRecord.DecodingError.invalidDateFormat
    }
    return (tradeDate, settledDate)
  } else {
    throw SchwabRecord.DecodingError.invalidDateFormat
  }
}

private func decodeCurrency(
  from container: KeyedDecodingContainer<SchwabRecord.CodingKeys>,
  for key: SchwabRecord.CodingKeys,
  at tradeDate: Date
) throws -> Currency? {
  guard let decimal = try container.decodeIfPresent(Decimal.self, forKey: key) else {
    return nil
  }
  return Currency(amount: decimal, unit: .USD, time: tradeDate)
}

private extension String {
  var fullStringRange: NSRange {
    NSRange(startIndex ..< endIndex, in: self)
  }

  func matchedSubstring(of result: NSTextCheckingResult) -> Substring? {
    guard let range = Range(result.range, in: self) else {
      return nil
    }
    return self[range]
  }
}

private func parse(decimal decoder: Decoder) throws -> Decimal {
  let string = try String(from: decoder)
  let numberString = string.replacingOccurrences(of: "$", with: "")
  guard let decimal = Decimal(string: numberString) else {
    throw SchwabRecord.DecodingError.nonDecimalString(numberString)
  }
  return decimal
}

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MM/dd/yyyy"
  return formatter
}()
