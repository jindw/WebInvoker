//
//  XIdeaWebInterface.h
//  Test
//
//  Created by jindw on 14-8-16.
//  Copyright (c) 2014年 jindw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XIdeaWebInterface : NSObject

+ (XIdeaWebInterface*) instance;
-(void) registor : (NSString* )objectName object: (id) object;
-(void) unregistor : (NSString* )objectName;

-(NSData*) invoke:(NSString*) objectName methodName: (NSString*) methodName arguments: (NSString*) argsJSON;
@end
