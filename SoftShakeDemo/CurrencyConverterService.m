//
//  CurrencyConverterService.m
//  SoftShakeDemo
//
//  Created by Claude FALGUIERE on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CurrencyConverterService.h"

@implementation CurrencyConverterService

float kCHFRate = 1.22f;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (float)convert:(float)input {
    return input*kCHFRate;
}

@end
