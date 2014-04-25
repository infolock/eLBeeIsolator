//
//  NSObject+Nametags.m
//  eLBee
//
//  Created by Jonathon Hibbard on 3/12/14.
//  Copyright (c) 2014 Integrated Events. All rights reserved.
//

@import ObjectiveC.runtime;

#import "NSObject+Nametag.h"


@implementation NSObject(Nametag)

-(id)nametag {
    return objc_getAssociatedObject( self, @selector( nametag ) );
}

-(void) setNametag: (NSString *)nametag {
    objc_setAssociatedObject( self, @selector( nametag ), nametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

-(NSString *)objectIdentifier {
    return [NSString stringWithFormat:@"%@:0x%0x", self.description, ( int )self];
}

@end
