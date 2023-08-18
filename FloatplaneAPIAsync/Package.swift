// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "FloatplaneAPIAsync",
	platforms: [
		.macOS(.v10_15),
		.tvOS(.v13),
	],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "FloatplaneAPIAsync",
			targets: ["FloatplaneAPIAsync"]
		),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "FloatplaneAPIAsync",
			dependencies: [],
			path: "src"
		),
	]
)
