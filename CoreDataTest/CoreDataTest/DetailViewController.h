//
//  DetailViewController.h
//  CoreDataTest
//
//  Created by Anatoliy Goodz on 11/3/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

