//

import CGTCalcCore
import Foundation

public enum RecordType {
  case transaction(Transaction)
  case assetEvent(AssetEvent)
}

public protocol Record {
  var date: Date { get }
  var type: RecordType? { get async throws }
}

public extension Sequence where Element == Record {
  func groupedByRecordType() async throws -> ([Transaction], [AssetEvent]) {
    var transactions = [Transaction]()
    var assetEvents = [AssetEvent]()
    for record in self {
      switch try await record.type {
      case .none:
        continue
      case let .some(.transaction(transaction)):
        transactions.append(transaction)
      case let .some(.assetEvent(assetEvent)):
        assetEvents.append(assetEvent)
      }
    }
    return (transactions, assetEvents)
  }
}
