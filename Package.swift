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
  targets: [
    .target(name: "cgtcalc"),
  ],
  swiftLanguageVersions: [.v5]
)
