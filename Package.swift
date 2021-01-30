// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "cgtcalc",
  platforms: [
    .macOS(.v11),
  ],
  products: [
    .executable(name: "cgtcalc", targets: ["cgtcalc"]),
  ],
  dependencies: [
    .package(url: "https://github.com/sodastsai/hmrc-fx.git", from: "0.4.0"),
  ],
  targets: [
    .target(name: "cgtcalc",
            dependencies: [
              .target(name: "DataFormat"),
            ]),
    .target(name: "DataFormat",
            dependencies: [
              .product(name: "HMRCExchangeRate", package: "hmrc-fx"),
            ]),
    .testTarget(name: "DataFormatTests",
                dependencies: [
                  .target(name: "DataFormat"),
                ]),
  ],
  swiftLanguageVersions: [.v5]
)
