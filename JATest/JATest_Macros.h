//
//  JATest_Macros.h
//  JATest
//
//  Created by Simon Hall on 24/02/2013.
//  Copyright (c) 2013 Simon Hall. All rights reserved.
//

#ifndef JATest_JATest_Macros_h
#define JATest_JATest_Macros_h

#define SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#endif
