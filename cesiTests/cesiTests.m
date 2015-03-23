//
//  cesiTests.m
//  cesiTests
//
//  Created by T.Y on 15-2-24.
//  Copyright (c) 2015年 GL_RunMan. All rights reserved.
//   \n QQ：2018338874

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface cesiTests : XCTestCase

@end

@implementation cesiTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
