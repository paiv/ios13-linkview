#import <LinkPresentation/LinkPresentation.h>
#import "LinkTableViewController.h"


@interface LinkTableViewController ()

@property (strong, nonatomic) NSArray* urls;
@property (strong, nonatomic) NSMutableDictionary* metadata;

@end


@implementation LinkTableViewController

- (void)appendPreviewOfUrl:(NSURL *)url {
    NSIndexPath* insertion = [NSIndexPath indexPathForRow:self.urls.count inSection:0];
    self.urls = [self.urls arrayByAddingObject:url];
    [self.tableView insertRowsAtIndexPaths:@[insertion] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    [self.tableView scrollToRowAtIndexPath:insertion atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    
    self.urls = [NSArray array];
    self.metadata = [NSMutableDictionary dictionary];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL* url = self.urls[indexPath.row];
    LPLinkMetadata* meta = self.metadata[indexPath];
    
    UITableViewCell* cell = [[UITableViewCell alloc] init];

    LPLinkView* linkView = nil;
    if (meta) {
        linkView = [[LPLinkView alloc] initWithMetadata:meta];
    }
    else {
        linkView = [[LPLinkView alloc] initWithURL:url];
    }
    [cell.contentView addSubview:linkView];
    linkView.frame = cell.contentView.bounds;
    linkView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    if (meta) {
        return cell;
    }
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(tableView) weakView = tableView;
    LPMetadataProvider* provider = [[LPMetadataProvider alloc] init];
    [provider startFetchingMetadataForURL:url completionHandler:^(LPLinkMetadata * _Nullable meta, NSError * _Nullable error) {
        if (!meta) { return; }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakSelf;
            if (!self) { return; }
            self.metadata[indexPath] = meta;
            [weakView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
            [weakView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionMiddle) animated:YES];
        });
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LPLinkMetadata* meta = self.metadata[indexPath];
    if (!meta) {
        return UITableViewAutomaticDimension;
    }
    
    LPLinkView* linkView = [[LPLinkView alloc] initWithMetadata:meta];
    CGSize size = [linkView sizeThatFits:tableView.bounds.size];
    return size.height;
}

@end
