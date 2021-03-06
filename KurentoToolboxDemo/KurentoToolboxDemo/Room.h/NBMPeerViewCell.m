// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

#import "NBMPeerViewCell.h"

#import "DGActivityIndicatorView.h"
#import "Masonry.h"

@interface NBMPeerViewCell ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *peerLabel;
@property (nonatomic, weak) IBOutlet UIView *labelBkgView;
@property (nonatomic, weak) UIView *spinnerView;
@property (nonatomic, strong) UIButton *switchCameraBtn;

@end

//static NSTimeInterval NBMPeerViewCellAnimationTime = 0.3;
//static CGFloat NBMPeerViewCellDampingRatio = 0.85;
//static CGFloat NBMPeerViewCellSpringVelocity = 0.25;

@implementation NBMPeerViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    self.peerLabel.text = @"Peer";
    self.labelBkgView.layer.cornerRadius = self.labelBkgView.bounds.size.height / 2;
}

- (void)setPeerName:(NSString *)peer {
    self.peerLabel.text = peer;
}

- (void)setVideoView:(UIView *)videoView {
    if (!videoView) {
        [self hideCellSubview:self.videoView];
        return;
    }
    if (_videoView != videoView) {
        [_videoView removeFromSuperview];
        _videoView = videoView;
        [self.containerView insertSubview:_videoView aboveSubview:_peerLabel];
        [self showCellSubview:_videoView];
        
//        [self setNeedsLayout];
    }
}

- (void)showSpinner {
    if (_spinnerView.superview) {
        return;
    }
    DGActivityIndicatorView *spinner = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScaleParty tintColor:[UIColor whiteColor]];
    self.spinnerView = spinner;
    [spinner startAnimating];
    
    [self.containerView insertSubview:self.spinnerView aboveSubview:_videoView];
    
    [self showCellSubview:self.spinnerView];
}

- (void)hideSpinner {
    if (!_spinnerView) {
        return;
    }
    [self hideCellSubview:self.spinnerView];
}

- (void)enableVideo:(BOOL)enabled {
    if (enabled) {
        [self removeBlur:YES];
    } else {
        [self addBlur:YES];
    }
}

- (void)addBlur:(BOOL)animated {
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.alpha = 0.0f;
    blurView.tag = 1;
    [_containerView addSubview:blurView];
    [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_containerView);
    }];

    NSTimeInterval duration = animated ? 0.3 : 0;
    [UIView animateWithDuration:duration
                     animations:^{
                         blurView.alpha = 1.0f;
                     }];
}

- (void)removeBlur:(BOOL)animated {
    NSTimeInterval duration = animated ? 0.3 : 0;
    [UIView transitionWithView:_containerView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        UIView *blurView = [_containerView viewWithTag:1];
        [blurView removeFromSuperview];
    } completion:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //    if (CGRectEqualToRect(_videoView.bounds, self.bounds)) {
    //        return;
    //    }
    _spinnerView.center = self.containerView.center;

    _videoView.frame = self.bounds;
    
    CGSize buttonSize = CGSizeMake(72 / 2.5, 54 / 2.5);
    _switchCameraBtn.frame = CGRectMake(self.bounds.size.width - buttonSize.width -5,
                                            self.bounds.size.height - buttonSize.height - 30,
                                            buttonSize.width,
                                            buttonSize.height);
}

- (void)addSwitchCamerButton {
    if (self.switchCameraBtn.superview) {
        return;
    }
    
    UIImage *image = [UIImage imageNamed:@"switchCamera"];
    
    UIButton *switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchCameraBtn = switchCameraBtn;
    self.switchCameraBtn.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
    [self.switchCameraBtn setImage:image
                          forState:UIControlStateNormal];
    
    [self.switchCameraBtn addTarget:self
                             action:@selector(didPressSwitchCamera:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.contentView addSubview:self.switchCameraBtn];
    [self showCellSubview:self.switchCameraBtn];
    
    //[self setNeedsLayout];
}

- (void)removeSwitchCameraButton {
    [self hideCellSubview:self.switchCameraBtn];
}

- (void)didPressSwitchCamera:(UIButton *)sender {
    [self.delegate cell:self pressedSwitchButton:sender];
}

- (void)showCellSubview:(UIView *)subView {
    subView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        subView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)hideCellSubview:(UIView *)subView {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        subView.transform = CGAffineTransformMakeScale(0.01, 0.01);;
    } completion:^(BOOL finished) {
        [subView removeFromSuperview];
    }];
    
//    CGAffineTransform finalTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.01, 0.01), subView.transform);
//    [UIView animateWithDuration:NBMPeerViewCellAnimationTime delay:0 usingSpringWithDamping:NBMPeerViewCellDampingRatio initialSpringVelocity:NBMPeerViewCellSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        subView.transform = finalTransform;
//    } completion:^(BOOL finished) {
//        [subView removeFromSuperview];
//    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_videoView removeFromSuperview];
    _videoView = nil;
    [_spinnerView removeFromSuperview];
    _spinnerView = nil;
    [_switchCameraBtn removeFromSuperview];
    _switchCameraBtn = nil;
    
    for (UIView *subview in self.containerView.subviews) {
        [subview removeFromSuperview];
    }
}

@end
