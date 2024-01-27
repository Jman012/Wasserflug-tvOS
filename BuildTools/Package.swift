// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "BuildTools",
	platforms: [.macOS(.v10_11)],
	dependencies: [
		.package(url: "https://github.com/nicklockwood/SwiftFormat", "0.51.12"..."0.51.12"),
	],
	targets: [.target(name: "BuildTools", path: "")]
)
