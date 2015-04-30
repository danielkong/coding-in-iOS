//
//  FirstViewController.m
//  stock
//
//  Created by daniel on 4/23/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "FirstViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"

#import "StockAPIUtil.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@interface FirstViewController () 

@property (nonatomic, strong) UITextField *textField;   // input v0.0
@property (nonatomic, strong) JVFloatLabeledTextField *titleField; // input version 0.1

@property (nonatomic, strong) JVFloatLabeledTextField *priceField;
@property (nonatomic, strong) JVFloatLabeledTextField *changeField;
@property (nonatomic, strong) JVFloatLabeledTextField *volField;
@property (nonatomic, strong) JVFloatLabeledTextField *avgVolField;

@property (nonatomic, strong) JVFloatLabeledTextField *targetPriceField;
@property (nonatomic, strong) JVFloatLabeledTextField *peField;
@property (nonatomic, strong) JVFloatLabeledTextField *pbField;
@property (nonatomic, strong) JVFloatLabeledTextField *epsField;
@property (nonatomic, strong) JVFloatLabeledTextField *shortRatioField;
@property (nonatomic, strong) JVFloatLabeledTextField *mktCapField;



@property (nonatomic, strong) UIImageView *imageView;   // output

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)setupUI {
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    NSLog(@"Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

//  create by own
//    UILabel *symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, rect.size.height, self.view.bounds.size.width/3, 30)];
//    symbolLabel.text = @"Symbol:";
////    symbolLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);
//    [symbolLabel sizeToFit];
//    [self.view addSubview:symbolLabel];
//    
//    _textField = [[UITextField alloc] initWithFrame:CGRectMake(symbolLabel.frame.size.width, rect.size.height, symbolLabel.frame.size.width, symbolLabel.frame.size.height)];
//    _textField.placeholder = @"SPY";
//    [self.view addSubview:_textField];
//    
//    UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(_textField.frame.origin.x + _textField.frame.size.width, rect.size.height, symbolLabel.frame.size.width, 30)];
//    [updateButton setTitle:@"Update" forState:UIControlStateNormal];
//    [updateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [updateButton addTarget:self
//                     action:@selector(buttonClicked:)
//           forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:updateButton];
//
//    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.jpg"]];
//    _imageView.frame = CGRectMake(0, _textField.frame.origin.y + _textField.frame.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - 60);
//    //    [_imageView sizeToFit];
//    [_imageView setContentMode:UIViewContentModeScaleAspectFit];    // if imageView larger than icon, then fit to imageView size.
//    //    [self.view addSubview:_imageView];
//    
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _textField.frame.origin.y + _textField.frame.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
//    [scrollView addSubview:_imageView];
//    scrollView.contentSize = _imageView.frame.size;
//    
//    // Disabling panning/scrolling in the scrollView
//    //    scrollView.scrollEnabled = NO;
//    
//    // For supporting zoom,
//    scrollView.minimumZoomScale = 0.5;
//    scrollView.maximumZoomScale = 2.0;
//    scrollView.delegate=self;
//    [self.view addSubview:scrollView];
//  End: create by own
    
    
    // add some values
    [self addJVFloatLabel];
//    UIColor* grey70 = [UIColor colorWithWhite: 0.70 alpha:1];
//    self.view.backgroundColor = grey70;

    
}


// Implement a single scroll view delegate method
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return _imageView;
}


-(void) buttonClicked:(UIButton*)sender
{
    
    [_titleField resignFirstResponder];
    
    NSLog(@"you clicked on button %ld", (long)sender.tag);
    
    NSString *urlString = [NSString stringWithFormat:@"http://stockcharts.com/c-sc/sc?s=%@&p=D&b=5&g=0&i=p09448260106", _titleField.text];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length]>0 && error == nil) {
            NSString *html = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
//            NSLog(@"HTML = %@", html);
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                _imageView.image = [UIImage imageWithData:data];
            });
        }
        else if ([data length]==0 && error == nil) {
            NSLog(@"Nothing was downloaded.");
        }
        else if (error !=nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
    
    NSString *urlStringFromYQL =
//    @"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20%20%28%22AAPL%22%2C%22GOOG%22%2C%22MSFT%22%29&diagnostics=true&env=http%3A%2F%2Fdatatables.org%2Falltables.env&format=json";//&format=json
    [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select%%20*%%20from%%20yahoo.finance.quotes%%20where%%20symbol%%20in%%20%%20%%28%%22%@%%22%%2C%%22GOOG%%22%%2C%%22MSFT%%22%%29&diagnostics=true&env=http%%3A%%2F%%2Fdatatables.org%%2Falltables.env&format=json", _titleField.text];
    
    __block NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringFromYQL]] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            
            responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseDict];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if ([[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"LastTradePriceOnly"] == [NSNull null]) {
                    NSLog(@"bad symbol. :(");
                } else {
                    _priceField.text = [[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"LastTradePriceOnly"];
                    _changeField.text = [[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"Change_PercentChange"];  // Change
                    NSString *volString = [[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"Volume"];
                    _volField.text = [StockAPIUtil getVolumeString:volString];
                    NSString *avgVolString = [[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"AverageDailyVolume"];
                    _avgVolField.text = [StockAPIUtil getVolumeString:avgVolString];
                    
                    
                    _peField.text = [StockAPIUtil getValidRatio:[[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"OneyrTargetPrice"]];
                    _targetPriceField.text = [StockAPIUtil getValidRatio:[[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"PERatio"]];
                    _pbField.text = [StockAPIUtil getValidRatio:[[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"PriceBook"]];
                    _epsField.text = [StockAPIUtil getValidRatio:[[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"EarningsShare"]];
                    _shortRatioField.text = [StockAPIUtil getValidRatio:[[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"ShortRatio"]];
                    _mktCapField.text = [StockAPIUtil getValidRatio:[[[[[dict objectForKey:@"query"] objectForKey:@"results"] objectForKey:@"quote"] objectAtIndex:0] objectForKey:@"MarketCapitalization"]];
                }
            });
            
        } else if ([data length] == 0 && error == nil) {
            NSLog(@"Nothing was downloaded.");
        } else if (error != nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
}

- (void)addJVFloatLabel {
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    UIView *statusBarView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:statusBarView];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    UIColor *floatingLabelColor = [UIColor brownColor];
    
    _titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _titleField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Title", @"")
                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _titleField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _titleField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _titleField.floatingLabelTextColor = floatingLabelColor;
    _titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_titleField];
    _titleField.translatesAutoresizingMaskIntoConstraints = NO;
    _titleField.keepBaseline = 1;
    
    UIView *divTitleAndUpdate = [UIView new];
    divTitleAndUpdate.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:divTitleAndUpdate];
    divTitleAndUpdate.translatesAutoresizingMaskIntoConstraints = NO;

    
    UIView *div1 = [UIView new];
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    div1.translatesAutoresizingMaskIntoConstraints = NO;
    
    _priceField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _priceField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Price", @"")
                                                                       attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _priceField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _priceField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _priceField.floatingLabelTextColor = floatingLabelColor;
    [_priceField setUserInteractionEnabled:NO];
    [self.view addSubview:_priceField];
    _priceField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *div2 = [UIView new];
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div2];
    div2.translatesAutoresizingMaskIntoConstraints = NO;
    
    _changeField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _changeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Change", @"")
                                                                          attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _changeField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _changeField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _changeField.floatingLabelTextColor = floatingLabelColor;
    [_changeField setUserInteractionEnabled:NO];
    [self.view addSubview:_changeField];
    _changeField.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *div22 = [UIView new];
    div22.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div22];
    div22.translatesAutoresizingMaskIntoConstraints = NO;
    
    _volField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _volField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Volume", @"")
                                                                         attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _volField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _volField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _volField.floatingLabelTextColor = floatingLabelColor;
    [_volField setUserInteractionEnabled:NO];
    [self.view addSubview:_volField];
    _volField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *div23 = [UIView new];
    div23.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div23];
    div23.translatesAutoresizingMaskIntoConstraints = NO;
    
    _avgVolField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _avgVolField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Avg Vol", @"")
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _avgVolField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _avgVolField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _avgVolField.floatingLabelTextColor = floatingLabelColor;
    [_avgVolField setUserInteractionEnabled:NO];
    [self.view addSubview:_avgVolField];
    _avgVolField.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *div3 = [UIView new];
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div3];
    div3.translatesAutoresizingMaskIntoConstraints = NO;
    
//    JVFloatLabeledTextField *descriptionField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
//    descriptionField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Avg Vol", @"")
//                                                                         attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
////    descriptionField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
//    descriptionField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
//    descriptionField.floatingLabelTextColor = floatingLabelColor;
//    [descriptionField setUserInteractionEnabled:NO];
//    [self.view addSubview:descriptionField];
//    descriptionField.translatesAutoresizingMaskIntoConstraints = NO;
//
//    UIView *div5 = [UIView new];
//    div5.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
//    [self.view addSubview:div5];
//    div5.translatesAutoresizingMaskIntoConstraints = NO;
    
    _peField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _peField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"1YrTarget", @"")    // P/E
                                                                        attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _peField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _peField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _peField.floatingLabelTextColor = floatingLabelColor;
    [_peField setUserInteractionEnabled:NO];
    [self.view addSubview:_peField];
    _peField.translatesAutoresizingMaskIntoConstraints = NO;
    
    _targetPriceField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _targetPriceField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"P/E", @"")
                                                                     attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _targetPriceField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _targetPriceField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _targetPriceField.floatingLabelTextColor = floatingLabelColor;
    [_targetPriceField setUserInteractionEnabled:NO];
    [self.view addSubview:_targetPriceField];
    _targetPriceField.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *div41 = [UIView new];
    div41.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div41];
    div41.translatesAutoresizingMaskIntoConstraints = NO;
    
    _pbField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _pbField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"P/B", @"")
                                                                         attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _pbField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _pbField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _pbField.floatingLabelTextColor = floatingLabelColor;
    [_pbField setUserInteractionEnabled:NO];
    [self.view addSubview:_pbField];
    _pbField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *div42 = [UIView new];
    div42.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div42];
    div42.translatesAutoresizingMaskIntoConstraints = NO;
    
    _epsField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _epsField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"EPS", @"")
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _epsField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _epsField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _epsField.floatingLabelTextColor = floatingLabelColor;
    [_epsField setUserInteractionEnabled:NO];
    [self.view addSubview:_epsField];
    _epsField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *div43 = [UIView new];
    div43.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div43];
    div43.translatesAutoresizingMaskIntoConstraints = NO;
    
    _shortRatioField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _shortRatioField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"short%", @"")
                                                                         attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _shortRatioField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _shortRatioField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _shortRatioField.floatingLabelTextColor = floatingLabelColor;
    [_shortRatioField setUserInteractionEnabled:NO];
    [self.view addSubview:_shortRatioField];
    _shortRatioField.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *div44 = [UIView new];
    div44.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div44];
    div44.translatesAutoresizingMaskIntoConstraints = NO;

    _mktCapField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    _mktCapField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MKT", @"")
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    _mktCapField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    _mktCapField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    _mktCapField.floatingLabelTextColor = floatingLabelColor;
    [_mktCapField setUserInteractionEnabled:NO];
    [self.view addSubview:_mktCapField];
    _mktCapField.translatesAutoresizingMaskIntoConstraints = NO;


    UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, kJVFieldHeight)];
    [updateButton setTitle:@"Update" forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [updateButton addTarget:self
                     action:@selector(buttonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    updateButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:updateButton];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.jpg"]];
    _imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 260);
    //    [_imageView sizeToFit];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];    // if imageView larger than icon, then fit to imageView size.
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 190, self.view.bounds.size.width, self.view.bounds.size.height - 160)];
    [scrollView addSubview:_imageView];
    scrollView.contentSize = _imageView.frame.size;
    
    // Disabling panning/scrolling in the scrollView
    scrollView.scrollEnabled = YES;
    
    // For supporting zoom,
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 2.0;
    scrollView.delegate=self;
    [self.view addSubview:scrollView];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[_titleField]-(xMargin)-|" options:0 metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(_titleField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div1]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div1)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[_priceField]-(xMargin)-[div2(1)]-(xMargin)-[_changeField]-(xMargin)-[div22(1)]-(xMargin)-[_volField]-(xMargin)-[div23(1)]-(xMargin)-[_avgVolField]-(xMargin)-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(_priceField, div2, _changeField, div22, _volField, div23, _avgVolField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div3]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div3)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[descriptionField]-(xMargin)-|" options:0 metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(descriptionField)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div5]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div5)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[updateButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(updateButton)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[_peField]-[_targetPriceField]-(xMargin)-[div41(1)]-(xMargin)-[_pbField]-(xMargin)-[div42(1)]-(xMargin)-[_epsField]-(xMargin)-[div43(1)]-[_shortRatioField]-[div44(1)]-(xMargin)-[_mktCapField]-(xMargin)-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(_peField, _targetPriceField, div41, _pbField, div42, _epsField, div43, _shortRatioField, div44, _mktCapField)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBarView][_titleField(==minHeight)][div1(1)][_priceField(==minHeight)][div3(1)][_peField(==minHeight)][updateButton(>=minHeight)][scrollView(>=minHeight)]|" options:0 metrics:@{@"minHeight": @(kJVFieldHeight)} views:NSDictionaryOfVariableBindings(statusBarView, _titleField, div1, _priceField, div3, _peField, updateButton, scrollView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBarView][_titleField(>=minHeight)][div1(1)][_priceField(>=minHeight)][div3(1)][descriptionField(>=minHeight)][div5(1)][_peField(>=minHeight)]|" options:0 metrics:@{@"minHeight": @(kJVFieldHeight)} views:NSDictionaryOfVariableBindings(statusBarView, _titleField, div1, _priceField, div3, descriptionField, div5, _peField)]];
    
    // div2
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_priceField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div2 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_priceField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_changeField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_changeField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div22 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_changeField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_volField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_volField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div23 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_volField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_avgVolField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    // div4
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_peField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div41 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_peField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_pbField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pbField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div42 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pbField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_epsField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_epsField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div43 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_epsField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_shortRatioField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_shortRatioField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div44 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_shortRatioField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_mktCapField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [_titleField becomeFirstResponder];

}

@end
