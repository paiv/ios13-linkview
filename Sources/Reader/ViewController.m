#import "LinkTableViewController.h"
#import "ViewController.h"


@interface ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField* textField;
@property (weak, nonatomic) LinkTableViewController* tableController;

@end


@implementation ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedtable"]) {
        self.tableController = segue.destinationViewController;
    }
}

- (UIView *)inputAccessoryView {
    return self.textField;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)appendUrlPreview {
    [self.view endEditing:YES];
    NSString* inputString = self.textField.text;
    if (![inputString containsString:@"://"]) {
        inputString = [NSString stringWithFormat:@"https://%@", inputString];
    }
    NSURL* url = [NSURL URLWithString:inputString];
    if (!url) { return; }
    
    [self.tableController appendPreviewOfUrl:url];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField* textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.returnKeyType = UIReturnKeyGo;
    textField.textContentType = UITextContentTypeURL;
    textField.text = @"apple.com/iphone";
    [textField sizeToFit];
    textField.delegate = self;
    self.textField = textField;
    
    [self reloadInputViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self appendUrlPreview];
    return YES;
}

@end
