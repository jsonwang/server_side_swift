//
//  login.swift
//  service_swift
//
//  Created by AK on 2018/9/13.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL
import PerfectLib
import PerfectMustache
import PerfectSysInfo

class serverManager: NSObject {
    
    fileprivate var server: HTTPServer = HTTPServer.init()

    override init() {
        super.init()
    }
    //MARK: 初始化服务器
    internal convenience init(root: String, uri:String, address:String, port: UInt16) {
        self.init()
        
        //创建HTTPServer服务器
        var routes = Routes.init(baseUri: uri)              //创建路由器
        configure(routes: &routes)                          //注册路由
        server.serverAddress = address                      //服务器地址
        server.addRoutes(routes)                            //路由添加进服务
        server.serverPort = port                            //端口
        server.documentRoot = root                          //根目录
        server.setResponseFilters([(Filter404(), .high)])   //404过滤
       
        
    }
    //MARK: 开启服务
    open func startServer() {
        
        do {
            print("服务器启动使用url http://127.0.0.1:8181/v1/say?name=AK&age=18")
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("网络出现错误：\(err) \(msg)")
        } catch {
            print("网络未知错误")
        }
        
    }
 
    //MARK: 404过滤
    struct Filter404: HTTPResponseFilter {
        
        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }
        
        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            if case .notFound = response.status {
                response.setHeader(.contentType, value: "text/html;charset=utf-8")
                response.setBody(string: "404 地址不存在:\(response.request.path)")
                response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
                callback(.done)
                
            } else {
                callback(.continue)
            }
        }
        
    }
    
    //MARK: 通用返回格式
    func baseResponseBodyJSONData(status: Int, message: String, data: Any!) -> String {
        
        var result = Dictionary<String, Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        if (data != nil) {
            result.updateValue(data, forKey: "data")
        }else{
            result.updateValue("", forKey: "data")
        }
        guard let jsonString = try? result.jsonEncodedString() else {
            return ""
        }
        return jsonString
        
    }
 
    //MARK: 注册路由
    fileprivate func configure(routes: inout Routes) {
     
        //1返回一句话
        routes.add(method: .get, uri: "/say") { request, response in

            // 请求的参数 e.g http://127.0.0.1:8181/?name=wc&age=18 有人访问了! [("name", "wc"), ("age", "18")]
            // 获取 get参数
            print("parsms\(request.queryParams)")
            var commingName = ""
            var age = ""
            request.queryParams.forEach { param in
                print(param)
                if param.0 == "name" {
                    commingName = param.1
                }
                if param.0 == "age" {
                    age = param.1
                }
            }
            print(commingName + "来访问了!")

            // 返回输出内容
            let say = commingName + "你好!!!" + "  你永远" + age + "岁."
            // 注意设置编码集
            response.setHeader(.contentType, value: "text/html;charset=utf-8")
            response.appendBody(string: say)
                .completed()
            
            self.fetchData()
        }

        
        // 2返回 json 数据
        routes.add(method: .get, uri: "/json") { _, response in

            // 返回输出内容
            let jsonDic: [String: Any] = ["第一名": 300, "第二名": 230.45, "第三名": 150]

            // 注意设置编码集
            response.setHeader(.contentType, value: "text/html;charset=utf-8")
            
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "成功", data: jsonDic)
            response.appendBody(string: jsonString)
            
            response.completed()
 
        }
        
        //3,上传文件到服务器
        let uploadHandler = {
            (request: HTTPRequest, response: HTTPResponse) in

            let webRoot = request.documentRoot
            print("web root:" + webRoot + "\n" + Dir.workingDir.path)
            
            mustacheRequest(request: request, response: response, handler: UploadHandler(), templatePath: webRoot + "/response.mustache")
        }


        // 上传文件
        routes.add(method: .post, uri: "/upload" ,handler:uploadHandler)
 
        //4,返回当前系统信息
        routes.add(method: .get, uri: "/systeminfo") { _, response in
            
            print(SysInfo.CPU)
            // 返回输出内容
            let jsonDic: [String: Any] = ["第一名": 300, "第二名": 230.45, "第三名": 150]
            
            // 注意设置编码集
            response.setHeader(.contentType, value: "text/html;charset=utf-8")
            
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "成功", data: SysInfo.CPU)
            response.appendBody(string: jsonString)
            
            response.completed()
            
        }
     
    }
    
    func fetchData() {
        
        print("数据库连接")
        let testHost = "服务器地址"
        let testUser = "登录用户名"
        let testPassword = "登录密码"
        let testDB = "数据库名"
        
        let dataMysql = MySQL() // 创建一个MySQL连接实例
        let connected = dataMysql.connect(host: testHost, user: testUser, password: testPassword)
        guard connected else {
            // 验证一下连接是否成功
            print(dataMysql.errorMessage())
            return
        }
        
        defer {
            dataMysql.close() //这个延后操作能够保证在程序结束时无论什么结果都会自动关闭数据库连接
        }
        
        // 选择具体的数据Schema
        guard dataMysql.selectDatabase(named: testDB) else {
            Log.info(message: "数据库选择失败。错误代码：\(dataMysql.errorCode()) 错误解释：\(dataMysql.errorMessage())")
            
            return
            }
        
        
        // 运行查询（比如返回在options数据表中的所有数据行）
        let querySuccess = dataMysql.query(statement: "SELECT mobile ,nickname FROM cgq.user")
        
        // 确保查询完成
        guard querySuccess else {
            return
        }
        
        // 在当前会话过程中保存查询结果
        let results = dataMysql.storeResults()! //因为上一步已经验证查询是成功的，因此这里我们认为结果记录集可以强制转换为期望的数据结果。当然您如果需要也可以用if-let来调整这一段代码。
        
//        var ary = [[String:Any]]() //创建一个字典数组用于存储结果
    
        results.forEachRow { row in
            let optionName =  row[0] as! String//保存选!项表的Name名称字段，应该是所在行的第一列，所以是row[0].
            let optionValue = row[1] as! String //保存选项表!Value字段
//            ary.append("\(optionName)":optionValue]) //保存到字典内
            
            print(optionName+"      name :"+optionValue)

        }
    }
}
