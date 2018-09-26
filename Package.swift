// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//这个文件你可以理解为CocoaPod中的 Podfile

import PackageDescription

let package = Package(
    name: "server_swift",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //在这里可以添加对应的依赖关系库
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        //数据库
        .package(url:"https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
        
        
        //mustache
        .package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", from: "3.0.0"),
        
        //用于系统性能指标监控的函数库
        .package(url: "https://github.com/PerfectlySoft/Perfect-SysInfo.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "server_swift",
            dependencies: ["PerfectHTTPServer","PerfectMySQL","PerfectMustache","PerfectSysInfo"]),
    ]
)
