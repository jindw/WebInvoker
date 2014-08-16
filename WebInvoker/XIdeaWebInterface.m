//
//  XIdeaWebInterface.m
//  Test
//
//  Created by jindw on 14-8-16.
//  Copyright (c) 2014年 jindw. All rights reserved.
//

#import "XIdeaWebInterface.h"



@interface InvokeURLProtocel : NSURLProtocol{
}
@end
@implementation InvokeURLProtocel{
}
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
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[self.request URL] MIMEType:@"text/plain" expectedContentLength:[jsonData length] textEncodingName:nil];
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



static XIdeaWebInterface *sharedInstance = nil;
char* chars = "p1: p2: p3";

@implementation XIdeaWebInterface{
    NSDictionary *interfaceObject;
}
+ (XIdeaWebInterface*) instance
{
    @synchronized (self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[self alloc] init];
            [NSURLProtocol registerClass:[InvokeURLProtocel class]];
        }
    }
    return sharedInstance;
}
-(id)init
{
    if(self=[super init])
    {
        interfaceObject = [NSMutableDictionary dictionary];
    }
    return self;
}
-(NSData*) invoke:(NSString*) objectName methodName: (NSString*) methodName arguments: (NSString*) argsJSON{
    id object = [interfaceObject valueForKey:objectName];
    NSArray * arguments = [NSJSONSerialization JSONObjectWithData:[argsJSON dataUsingEncoding:NSUTF8StringEncoding ] options:NSJSONReadingMutableContainers error:nil];
    int len = [arguments count];
    
    NSMutableString* sels = [NSMutableString stringWithString:methodName];
    switch(len){
        case 0:
            break;
        case 1:
            [sels appendString:@":"];
            break;
        case 2:
            [sels appendString:@":p1:"];
            break;
        default:
            [sels appendString:@":"];
            break;
        
    }
    SEL sel = NSSelectorFromString(sels);
    if([object respondsToSelector:sel]){
        id result;
        switch (len) {
            case 0:
                result =[object performSelector:sel];
                break;
            case 1:
                result =[object performSelector:sel withObject:arguments [0]];
                break;
            case 2:
                result =[object performSelector:sel withObject:arguments [0] withObject:arguments[1]];
                break;
            default:
                result =[object performSelector:sel withObject:arguments];
                //return [NSString stringWithFormat:@"{\"error\":\"too many arguments\"}"];
        }
        
        
        NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:result,@"result",nil];
        //convert object to data
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:data
                                                          options:NSJSONWritingPrettyPrinted error:nil];
        return jsonData;
    }
    return [[NSString stringWithFormat:@"{\"error\":\"method not found:%@.%@\"}",objectName,methodName] dataUsingEncoding:NSUTF8StringEncoding];
}
-(void) registor : (NSString* )objectName object: (id) object{
    [interfaceObject setValue:object forKey:objectName];
}
-(void) unregistor : (NSString* )objectName{
    [interfaceObject setNilValueForKey:objectName];
}


@end
