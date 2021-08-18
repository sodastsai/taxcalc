//

import CGTCalcCore

public protocol Record {
  var transaction: Transaction? { get }
  var assetEvent: AssetEvent? { get }
}
