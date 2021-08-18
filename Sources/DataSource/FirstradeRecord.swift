//

import CGTCalcCore
import CodableCSV
import DataFormat
import Foundation

public struct FirstradeRecord {
  public enum Action: String {
    case buy = "BUY"
    case sell = "SELL"
    case dividend = "Dividend"
    case interest = "Interest"
    case other = "Other"
  }

  public enum RecordType: String {
    case financial = "Financial"
    case trade = "Trade"
  }

  public let symbol: String?
  public let quantity: Decimal
  public let price: Currency
  public let action: Action
  public let description: String
  public let tradeDate: Date
  public let settledDate: Date
  public let interest: Currency
  public let amount: Currency
  public let commission: Currency
  public let fee: Currency
  public let cusip: String?
  public let recordType: RecordType

  init(symbol: String?,
       quantity: Decimal,
       price: Currency,
       action: Action,
       description: String,
       tradeDate: Date,
       settledDate: Date,
       interest: Currency,
       amount: Currency,
       commission: Currency,
       fee: Currency,
       cusip: String?,
       recordType: RecordType) {
    self.symbol = symbol
    self.quantity = quantity
    self.price = price
    self.action = action
    self.description = description
    self.tradeDate = tradeDate
    self.settledDate = settledDate
    self.interest = interest
    self.amount = amount
    self.commission = commission
    self.fee = fee
    self.cusip = cusip
    self.recordType = recordType
  }
}

extension FirstradeRecord: CustomStringConvertible, Equatable {}

extension FirstradeRecord.Action: Decodable {}

extension FirstradeRecord.RecordType: Decodable {}

extension FirstradeRecord: Decodable {
  private enum CodingKey: String, Swift.CodingKey {
    case symbol = "Symbol"
    case quantity = "Quantity"
    case price = "Price"
    case action = "Action"
    case description = "Description"
    case tradeDate = "TradeDate"
    case settledDate = "SettledDate"
    case interest = "Interest"
    case amount = "Amount"
    case commission = "Commission"
    case fee = "Fee"
    case cusip = "CUSIP"
    case recordType = "RecordType"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    symbol = try container.decode(String.self, forKey: .symbol, option: .emptyAsNil)
    quantity = try container.decode(Decimal.self, forKey: .quantity)
    action = try container.decode(Action.self, forKey: .action)
    description = try container.decode(String.self, forKey: .description)
    tradeDate = try container.decode(Date.self, forKey: .tradeDate)
    settledDate = try container.decode(Date.self, forKey: .settledDate)
    cusip = try container.decode(String.self, forKey: .cusip, option: .emptyAsNil)
    recordType = try container.decode(RecordType.self, forKey: .recordType)
    price = try container.decode(Currency.self, forKey: .price, at: tradeDate)
    interest = try container.decode(Currency.self, forKey: .interest, at: tradeDate)
    amount = try container.decode(Currency.self, forKey: .amount, at: tradeDate)
    commission = try container.decode(Currency.self, forKey: .commission, at: tradeDate)
    fee = try container.decode(Currency.self, forKey: .fee, at: tradeDate)
  }
}

extension FirstradeRecord: Record {
  public var transaction: Transaction? { nil }
  public var assetEvent: AssetEvent? { nil }
}

public struct FirstradeRecordProvider: RecordProvider {
  public var filenamePattern: String {
    #"Firstrade_\d{8}_\d{4}.csv"#
  }

  public func read(contentsOf url: URL) throws -> [Record] {
    let decoder = CSVDecoder {
      $0.headerStrategy = .firstLine
      $0.dateStrategy = .by(formats: "yyyy-MM-dd")
      $0.decimalStrategy = .with(options: .emptyAsZero)
      $0.trimStrategy = .whitespaces
    }
    return try decoder.decode([FirstradeRecord].self, from: url)
  }
}
