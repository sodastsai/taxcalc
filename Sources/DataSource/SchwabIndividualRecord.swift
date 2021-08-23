//

import CGTCalcCore
import CodableCSV
import DataFormat
import Foundation

public struct SchwabIndividualRecord {
  public enum Action: String {
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

extension SchwabIndividualRecord: CustomStringConvertible, Equatable {}

extension SchwabIndividualRecord.Action: Decodable {}

extension SchwabIndividualRecord: Decodable {
  private enum CodingKey: String, Swift.CodingKey {
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
    let container = try decoder.container(keyedBy: CodingKey.self)
    let (tradeDate, settledDate) = try container.decodeDates(forKey: .date)
    self = .init(
      action: try container.decode(Action.self, forKey: .action),
      symbol: try container.decodeIfPresent(String.self, forKey: .symbol),
      description: try container.decode(String.self, forKey: .description),
      tradeDate: tradeDate,
      settledDate: settledDate,
      quantity: try container.decodeIfPresent(Decimal.self, forKey: .quantity),
      price: try container.decodeIfPresent(Currency.self, forKey: .price, at: tradeDate),
      feesAndComm: try container.decodeIfPresent(Currency.self, forKey: .feesAndComm, at: tradeDate),
      amount: try container.decodeIfPresent(Currency.self, forKey: .amount, at: tradeDate)
    )
  }
}

extension SchwabIndividualRecord: Record {
  public var date: Date {
    tradeDate
  }

  private var transactionKind: Transaction.Kind? {
    switch action {
    case .buy:
      return .Buy
    case .sell:
      return .Sell
    default:
      return nil
    }
  }

  public var type: RecordType? {
    get async throws {
      if let transactionKind = transactionKind, let symbol = symbol, let price = price {
        return .transaction(Transaction(
          kind: transactionKind,
          date: tradeDate,
          asset: symbol,
          amount: quantity ?? 0,
          price: try await price.converting(to: .GBP).amount,
          expenses: try await feesAndComm?.converting(to: .GBP).amount ?? 0
        ))
      }
      return nil
    }
  }
}

public struct SchwabIndividualRecordProvider: RecordProvider {
  public var filenamePattern: String {
    #"Schwab_\d{8}_\d{4}.csv"#
  }

  public func read(contentsOf url: URL) throws -> [Record] {
    let fileContent = try String(contentsOf: url, encoding: .utf8)
    let csvString = normalizeCSVLines(fileContent)
    let decoder = CSVDecoder {
      $0.headerStrategy = .firstLine
      $0.trimStrategy = .whitespaces
      $0.decimalStrategy = .with(options: .replaceDollarSign)
    }
    return try decoder.decode([SchwabIndividualRecord].self, from: String(csvString))
  }
}

// MARK: - Decoder

// The "date" could be something like "MM/dd/yyyy as of MM/dd/yyyy"
private extension KeyedDecodingContainer {
  func decodeDates(forKey key: Key) throws -> (Date, Date) {
    let string = try decode(String.self, forKey: key)
    let pattern = try NSRegularExpression(pattern: #"(\d{2}/\d{2}/\d{4})"#)
    let matches = pattern.matches(in: string, range: string.rangeOfFullString)
    if matches.count == 1 {
      guard
        let dateString = string.substring(matching: matches[0]),
        let date = dateFormatter.date(from: String(dateString))
      else {
        throw DecodingError.invalidDateString(string)
      }
      return (date, date)
    } else if matches.count == 2 {
      guard
        let settledDateString = string.substring(matching: matches[0]),
        let settledDate = dateFormatter.date(from: String(settledDateString)),
        let tradeDateString = string.substring(matching: matches[1]),
        let tradeDate = dateFormatter.date(from: String(tradeDateString))
      else {
        throw DecodingError.invalidDateString(string)
      }
      return (tradeDate, settledDate)
    } else {
      throw DecodingError.invalidDateString(string)
    }
  }
}

private let dateFormatter = DateFormatter(dateFormat: "MM/dd/yyyy")

private func normalizeCSVLines(_ originalContent: String) -> String {
  // Strip the first title line and the last summary line
  let lines = originalContent.split(separator: "\r\n")
  return lines[1 ..< lines.count - 1].joined(separator: "\r\n")
}
