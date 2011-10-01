//
//  main.m
//  SoftShakeDemo
//
//  Created by Claude FALGUIERE on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SoftShakeDemoAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([SoftShakeDemoAppDelegate class]));
    }
    return retVal;
}
