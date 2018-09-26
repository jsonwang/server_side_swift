
#### Perfect框架 简介

Perfect-Github地址：https://github.com/PerfectlySoft/Perfect）
Perfect的官网地址：https://www.perfect.org/
开发文档地址：https://www.perfect.org/docs/index_zh_CN.html

Perfect 目前支持 swift 4.0 如果低于4.0版本则Perfect是无法成功编译的。

#### 目录结构说明
- Perfect——该代码资源库包含了PerfectLib库核心，也是整个软件框架的核心内容
- PerfectTemplate——项目模板，一个使用Swift Package Manager软件包管理器编译的、可以单独执行的HTTP服务器。该项目模板非常适合开发基于Perfect的服务器项目
- PerfectDocs——包含了所有API参考资料
- PerfectExamples——所有Perfect项目典型示例和文档
- Perfect-Redis——Redis数据库连接工具
- Perfect-SQLite——SQLite3数据库连接工具
- Perfect-PostgreSQL——PostgreSQL数据库连接工具
- Perfect-MySQL——MySQL数据库连接工具
- Perfect-MongoDB——MongoDB数据库连接工具
- Perfect-FastCGI-Apache2.4——Apache 2.4 FastCGI模块；对于Perfect FastCGI服务器应用是必须安装的内容

可以从[Swift.org](https://swift.org/getting-started/)完成Swift 4.0 toolchain工具集安装之后，并在终端并输入命令 swift --version查看当前版本

#### 开始创建hello world project

```
- mkdir service_swift
- cd service_swift
- swift package init --type=executable
- swift build 编译( swift build -c release, swift build --clean, swift build --clean=dist)
- 最后一行会显示PAHT 运行  ./.build/x86_64-apple-macosx10.10/debug/service_swift
- 在浏览器中 查看http://127.0.0.1:8181
```

生成 xcode 工程
```
swift package generate-xcodeproj
```
ps 查看占用端口的PID
```
lsof -nP -iTCP:8181 |grep LISTEN|awk '{print $2}'

```

#### 取参数

```
//获取 get参数
 let params = request.queryParams
 //获取 post参数
let port_params = request.postParams
```
#### 联接 mysql 数据库
2018年09月21日 Perfect-MySQL 只支持mysql@5.7 否则编译报错. [Perfect-MySQL 代码地址]https://github.com/PerfectlySoft/Perfect-MySQL

#### Perfect文件上传例子 [Demo](https://github.com/iamjono/perfect-file-uploads)
