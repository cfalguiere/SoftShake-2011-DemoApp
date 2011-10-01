//
//  CurrencyConverterService.h
//  SoftShakeDemo
//
//  Created by Claude FALGUIERE on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyConverterService : NSObject

- (float)convert:(float)input;

- (NSString*)formatValue:(float)input;
- (float)parseValue:(NSString*)input;

@end
