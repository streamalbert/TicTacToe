//
//  ViewController.m
//  TicTacToe
//
//  Created by Weichuan Tian on 8/12/15.
//  Copyright (c) 2015 Weichuan Tian. All rights reserved.
//

#import "ViewController.h"
#import "TTTGamePieceCollectionViewCell.h"

#define TTTGamePieceCellReuseIdentifier                    @"TTTGamePieceCellReuseIdentifier"

// Only support 3 by 3 right now
static const NSUInteger TTTGameDimension = 3;

typedef NS_ENUM(NSUInteger, TTTGameBoardOccupationState) {
    TTTGameBoardOccupationStateEmpty = 1,
    TTTGameBoardOccupationStatePlayer,
    TTTGameBoardOccupationStateAI
};

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *gameBoardCollectionView;
@property (nonatomic) NSMutableArray *gameBoardOccupation;
@property (nonatomic) BOOL playerGoesFirst;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.gameBoardCollectionView registerClass:[TTTGamePieceCollectionViewCell class] forCellWithReuseIdentifier:TTTGamePieceCellReuseIdentifier];
    
    self.gameBoardCollectionView.dataSource = self;
    self.gameBoardCollectionView.delegate = self;
    
    self.playerGoesFirst = NO;

    [self initGameBoard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.gameBoardCollectionView.dataSource = nil;
    self.gameBoardCollectionView.delegate = nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return TTTGameDimension * TTTGameDimension;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTTGamePieceCollectionViewCell *gamePieceCell = [self.gameBoardCollectionView dequeueReusableCellWithReuseIdentifier:TTTGamePieceCellReuseIdentifier forIndexPath:indexPath];
    
    TTTGameBoardOccupationState stateForCurrentIndexPath = [self.gameBoardOccupation[indexPath.row / TTTGameDimension][indexPath.row % TTTGameDimension] integerValue];
    switch (stateForCurrentIndexPath) {
        case TTTGameBoardOccupationStateEmpty:
            gamePieceCell.backgroundColor = [UIColor whiteColor];
            break;
        case TTTGameBoardOccupationStatePlayer:
            gamePieceCell.backgroundColor = [UIColor blueColor];
            break;
        case TTTGameBoardOccupationStateAI:
            gamePieceCell.backgroundColor = [UIColor redColor];
            break;
        default:
            break;
    }

    gamePieceCell.layer.borderColor = [UIColor greenColor].CGColor;
    gamePieceCell.layer.borderWidth = 2;
    return  gamePieceCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.gameBoardOccupation[indexPath.row / TTTGameDimension][indexPath.row % TTTGameDimension] = [NSNumber numberWithInteger:TTTGameBoardOccupationStatePlayer];
    [self.gameBoardCollectionView reloadData];
    
    if ([self hasWonWithCurrentIndex:indexPath.row]) {
        self.view.userInteractionEnabled = NO;
        return;
    }

    [self makeAMoveAI];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sizeDimension = CGRectGetWidth(self.view.frame) / TTTGameDimension;
    return CGSizeMake(sizeDimension, sizeDimension);
}

#pragma mark Private Helpers

- (void)initGameBoard
{
    self.gameBoardOccupation = [[NSMutableArray alloc] init];
    for (int i = 0; i < TTTGameDimension; ++i) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < TTTGameDimension; ++j) {
            [tempArray addObject:[NSNumber numberWithInteger:TTTGameBoardOccupationStateEmpty]];
        }
        [self.gameBoardOccupation addObject:tempArray];
    }
    if (!self.playerGoesFirst) {
        [self makeAMoveAI];
    }
}

- (void)clearGameBoard
{
    for (int i = 0; i < TTTGameDimension; ++i) {
        for (int j = 0; j < TTTGameDimension; ++j) {
            self.gameBoardOccupation[i][j] = [NSNumber numberWithInteger:TTTGameBoardOccupationStateEmpty];
        }
    }
    if (!self.playerGoesFirst) {
        [self makeAMoveAI];
    }
}

- (BOOL)hasWonWithCurrentIndex:(NSUInteger)index
{
    NSUInteger row = index / TTTGameDimension;
    NSUInteger col = index % TTTGameDimension;
    NSUInteger currentState = [self.gameBoardOccupation[row][col] integerValue];
    
    BOOL hasWon = YES;
    
    // judge row
    for (int i = 0; i < TTTGameDimension; ++i) {
        if ([self.gameBoardOccupation[row][i] integerValue] != currentState) {
            hasWon = NO;
            break;
        }
    }
    if (hasWon) {
        NSLog(@"%@ won!", currentState == TTTGameBoardOccupationStatePlayer ? @"Player" : @"AI");
        return YES;
    }
    
    hasWon = YES;
    // judge col
    for (int i = 0; i < TTTGameDimension; ++i) {
        if ([self.gameBoardOccupation[i][col] integerValue] != currentState) {
            hasWon = NO;
            break;
        }
    }
    if (hasWon) {
        NSLog(@"%@ won!", currentState == TTTGameBoardOccupationStatePlayer ? @"Player" : @"AI");
        return YES;
    }
    
    
    if (row == col) {
        hasWon = YES;
        // judge diagonal
        for (int i = 0; i < TTTGameDimension; ++i) {
            if ([self.gameBoardOccupation[i][i] integerValue] != currentState) {
                hasWon = NO;
                break;
            }
        }
        if (hasWon) {
            NSLog(@"%@ won!", currentState == TTTGameBoardOccupationStatePlayer ? @"Player" : @"AI");
            return YES;
        }
    }
    
    if (row + col == TTTGameDimension - 1) {
        hasWon = YES;
        // judge diagonal
        int i = 0;
        int j = TTTGameDimension - 1;
        while (i < TTTGameDimension && j >= 0) {
            if ([self.gameBoardOccupation[i][j] integerValue] != currentState) {
                hasWon = NO;
                break;
            }
            ++ i;
            -- j;
        }
        if (hasWon) {
            NSLog(@"%@ won!", currentState == TTTGameBoardOccupationStatePlayer ? @"Player" : @"AI");
            return YES;
        }
    }
    
    return NO;
}

- (void)makeAMoveAI
{
    NSUInteger lowerBound = 0;
    NSUInteger upperBound = TTTGameDimension * TTTGameDimension;
    NSUInteger rndValue;
    
    rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    while ([self.gameBoardOccupation[rndValue / TTTGameDimension][rndValue % TTTGameDimension] integerValue] != TTTGameBoardOccupationStateEmpty) {
        rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    }
    self.gameBoardOccupation[rndValue / TTTGameDimension][rndValue % TTTGameDimension] = [NSNumber numberWithInteger:TTTGameBoardOccupationStateAI];
    
    [self.gameBoardCollectionView reloadData];
    
    if ([self hasWonWithCurrentIndex:rndValue]) {
        self.view.userInteractionEnabled = NO;
    }
}

@end
