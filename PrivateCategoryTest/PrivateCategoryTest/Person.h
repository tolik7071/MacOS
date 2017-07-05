//
//  Person.h
//  PrivateCategoryTest
//
//  Created by Anatoliy Goodz on 4/27/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

- (void)run;

@end


@interface Person(Protected)

@property (nonatomic) NSString *name;
- (void)someMethod;

@end
