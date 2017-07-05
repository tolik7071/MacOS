/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  CaseInsensitivePredicateTemplate is a subclass of 
   NSPredicateEditorRowTemplate that will generate case insensitive 
   comparison predicates; it can be used as the custom subclass of an 
   NSPredicateEditorRowTemplate in Interface Builder. 
 */

#import "CaseInsensitivePredicateTemplate.h"

@implementation CaseInsensitivePredicateTemplate

- (NSPredicate *)predicateWithSubpredicates:(NSArray *)subpredicates {
    
    // we only make NSComparisonPredicates
    NSComparisonPredicate *predicate = (NSComparisonPredicate *)[super predicateWithSubpredicates:subpredicates];
    
    // construct an identical predicate, but add the NSCaseInsensitivePredicateOption flag
    return [NSComparisonPredicate predicateWithLeftExpression:predicate.leftExpression
                                              rightExpression:predicate.rightExpression
                                                     modifier:predicate.comparisonPredicateModifier
                                                         type:predicate.predicateOperatorType
                                                      options:predicate.options | NSCaseInsensitivePredicateOption];
}

@end

