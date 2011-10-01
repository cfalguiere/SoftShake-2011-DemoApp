//
//  CurrencyConverterServiceTest.m
//  SoftShakeDemo
//
//  Created by Claude FALGUIERE on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrencyConverterServiceTest.h"
#import "CurrencyConverterService.h"

@implementation CurrencyConverterServiceTest


- (void)testConvert {
    CurrencyConverterService *converter = [[CurrencyConverterService alloc] init];
    float inputValue = 1; // EUR
    float expectedOutputValue = 1.22; // CHF
    float outputValue = [converter convert:inputValue];
    STAssertEquals(outputValue, expectedOutputValue, nil);    
}

- (void)testConvert10 {
    CurrencyConverterService *converter = [[CurrencyConverterService alloc] init];
    float inputValue = 10; // EUR
    float expectedOutputValue = 12.2; // CHF
    float outputValue = [converter convert:inputValue];
    STAssertEqualsWithAccuracy(outputValue, expectedOutputValue, 2, nil);    
}

@end
