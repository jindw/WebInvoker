WebInvoker
==========
WebView 同步调用IOS 方案。

很多人以为ios 无法在web端同步调用ios native方法，其实不然！
嘴里藏不住秘密，就在这里公布一下吧。

Android方案不多说，很多办法， 我推荐自定义 android prompt 接口的方案。
不要采用 自动注入的java对象，能被webview恶意使用，比如，关掉程序，获取你的联系人信息发给外部网站，等等。



##IOS方案

**原理: 自定义url URLProtocel**

IOS 关键代码：

	@implementation InvokeURLProtocel
	+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest *)req{
	    return req;
	}
	- (void)startLoading
	{
	    NSURL *url = self.request.URL;
	    NSString *object = url.user;
	    NSString *method = url.password;
	    //NSLog(@"%@",url.host);
	    NSString *arguments= url.host;
	    NSData* jsonData = [XIdeaWebInterface.instance invoke:object methodName:method arguments:arguments];
	    //TODO: 调用协议
	    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[self.request URL] MIMEType:@"text/plain" 	expectedContentLength:[jsonData length] textEncodingName:nil];
	   [[self client] URLProtocol: self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	    [[self client] URLProtocol:self didLoadData:jsonData];
	    [[self client] URLProtocolDidFinishLoading:self];
	}
	- (void)stopLoading
	{
	}
	+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
		return [request.URL.scheme  isEqualToString:@"js-invoke"] ;
	}
	@end


**IOS 对应测试代码** 

            function callNativeMethod(objectName,methodName,args){
                var xhr = new  XMLHttpRequest();
                xhr.open("GET", "js-invoke://"+objectName+":"+methodName+"@"+encodeURIComponent(JSON.stringify(args)),false);
                xhr.send("");
                //alert(xhr.responseText)
                var rtv = JSON.parse(xhr.responseText);
                if(rtv.error){
                    alert(rtv.error)
                    throw new Error(rtv.error);
                }else{
                    return rtv.result;
                }
            }
        
            prompt("result:",callNativeMethod("object","method",[1,2,3,"asas中文sds",4]))//rtv 即为 object c 返回的代码


 

##接口风格

既然没有异步的枷锁，我个人更倾向于JavaScript端调用能像native端一样，对象注册之后，方法就可以直接调用方法。


    [XIdeaWebInterface.instance registor:@"jsObject" object:self];
    
##方法参数如何映射
    1. 无参数： 方法名同js端方法名
    2. 一个参数  方法名同js端方法名，第一个参数即js传来的参数
    3. 两个参数  方法名同js端方法名，第二个参数命名为p2
    4. 多个参数  方法名同js端方法名，只有一个参数，接收NSArray数据。

