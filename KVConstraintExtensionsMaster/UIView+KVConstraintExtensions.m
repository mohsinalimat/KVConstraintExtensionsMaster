//
//  UIView+KVConstraintExtensions.m
//  https://github.com/keshavvishwkarma/KVConstraintExtensionsMaster.git
//
//  Distributed under the MIT License.
//
//  Copyright (c) 2015 Keshav Vishwkarma
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "KVConstraintExtensionsMaster.h"

@implementation UIView (KVConstraintExtensions)

#pragma mark - Initializer Methods

+ (instancetype)prepareNewViewForAutoLayout {
    UIView *preparedView = [self new];
    [preparedView prepareViewForAutoLayout];
    return preparedView;
}

- (void)prepareViewForAutoLayout {
    if (self.translatesAutoresizingMaskIntoConstraints) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

#pragma mark - private constraint methods for views

+ (NSLayoutConstraint *)prepareConstraintForView:(UIView*)firstView  attribute:(NSLayoutAttribute)attribute1 secondView:(UIView*)secondView attribute:(NSLayoutAttribute)attribute2 relation:(NSLayoutRelation)relation multiplier:(CGFloat)multiplier
{
    NSAssert((firstView||secondView), @"both firstView & secondView must not be nil.");
    NSAssert(multiplier!=INFINITY, @"Multiplier/Ratio of view must not be INFINITY.");
    
    return [NSLayoutConstraint constraintWithItem:firstView attribute:attribute1 relatedBy:relation toItem:secondView attribute:attribute2 multiplier:multiplier constant:defualtConstant];
}

- (NSLayoutConstraint *)prepareSelfConstraint:(NSLayoutAttribute)attribute constant:(CGFloat)constant
{
    NSLayoutConstraint *prepareSelfConstraint = [self.class prepareConstraintForView:self attribute:attribute secondView:nil attribute:NSLayoutAttributeNotAnAttribute relation:defualtRelation multiplier:defualtMultiplier];
    [prepareSelfConstraint setConstant:constant];
    return prepareSelfConstraint;
}

#pragma mark - Generalized public constraint methods for views

- (NSLayoutConstraint *)prepareConstraintToSuperviewAttribute:(NSLayoutAttribute)attribute1 attribute:(NSLayoutAttribute)attribute2 relation:(NSLayoutRelation)relation
{
    return [self.class prepareConstraintForView:self attribute:attribute1 secondView:[self superview] attribute:attribute2 relation:relation multiplier:defualtMultiplier];
}

- (NSLayoutConstraint *)prepareEqualRelationPinConstraintToSuperview:(NSLayoutAttribute)attribute constant:(CGFloat)constant
{
    NSLayoutConstraint *preparePinConstraint = [self prepareConstraintToSuperviewAttribute:attribute attribute:attribute relation:defualtRelation];
    [preparePinConstraint setConstant:constant];
    return preparePinConstraint;
}

- (NSLayoutConstraint *)prepareEqualRelationPinRatioConstraintToSuperview:(NSLayoutAttribute)attribute multiplier:(CGFloat)multiplier
{
    NSAssert(multiplier!=INFINITY, @"Multiplier/Ratio of view must not be INFINITY.");
    
    // note if ratio is equal to zero then its ratio prefered 1.0 that is defualtMultiplier
    NSLayoutConstraint *preparedPinRatioConstraint = [self.class prepareConstraintForView:self attribute:attribute secondView:[self superview] attribute:attribute relation:defualtRelation multiplier:multiplier?multiplier:defualtMultiplier];
    return preparedPinRatioConstraint;
}

#pragma mark - Prepare constraint of one sibling view to other sibling view and add it into its superview view.

- (NSLayoutConstraint *)prepareConstraintFromSiblingViewAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView relation:(NSLayoutRelation)relation {
//    NSSet * set = [NSSet setWithArray:@[self.superview,otherSiblingView.superview]];
    NSAssert(([NSSet setWithArray:@[self.superview,otherSiblingView.superview]].count == 1), @"All the sibling views must belong to same superview");
    
    return [self.class prepareConstraintForView:self attribute:attribute secondView:otherSiblingView attribute:toAttribute relation:relation multiplier:defualtMultiplier];
}

- (NSLayoutConstraint *)prepareConstraintFromSiblingViewAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView multiplier:(CGFloat)multiplier {
    NSAssert(multiplier!=INFINITY, @"ratio of spacing between sybings view must not be INFINITY.");
//    NSSet * set = [NSSet setWithArray:@[self.superview,otherSiblingView.superview]];
    NSAssert(([NSSet setWithArray:@[self.superview,otherSiblingView.superview]].count == 1), @"All the sibling views must belong to same superview");
    
    return [self.class prepareConstraintForView:self attribute:attribute secondView:otherSiblingView attribute:toAttribute relation:defualtRelation multiplier:multiplier];
}

#pragma mark - Add constraints cumulative

/** This is the common methods two add cumulative constraint in a view
 * for this you need to call it according to view (self or Superview)
 */
- (void)applyPreparedConstraintInView:(NSLayoutConstraint *)constraint {
    NSLayoutConstraint *appliedConstraint = [self.constraints containsAppliedConstraint:constraint];
    // if this constraint is already added then it update the constraint values else added new constraint
    if (appliedConstraint) {
        [appliedConstraint setConstant:constraint.constant];
    } else {
        if (constraint) {
            [self addConstraint:constraint];
        }
    }
}

#pragma mark - Remove Constraints From a specific View

- (void)removeAppliedConstraintFromSupreview {
    UIView *superview = self.superview;
    [self removeFromSuperview];
    [superview addSubview:self];
}

- (void)removeAllAppliedConstraints {
    [self removeAppliedConstraintFromSupreview];
    if (self.constraints.count) {
        [self removeConstraints:self.constraints];
    }
}

#pragma mark - Modify constraint of a UIView

- (void)changeAppliedConstraintPriority:(UILayoutPriority)priority forAttribute:(NSLayoutAttribute)attribute {
    [[self accessAppliedConstraintByAttribute:attribute] setPriority:priority];
}

- (void)replaceAppliedConstraintInView:(NSLayoutConstraint *)appliedConstraint replaceBy:(NSLayoutConstraint *)constraint {
    NSAssert(constraint!=nil, @" modifiedConstraint must not be nil");
    
    if ([appliedConstraint isEqualToConstraint:constraint]){
        [self removeConstraint:appliedConstraint];
        [self addConstraint:constraint];
    }else{
        KVLog(@"appliedConstraint does not contain caller view = %@ \n appliedConstraint = %@",self,appliedConstraint);
    }
}

- (void)updateModifyConstraints {
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)updateModifyConstraintsWithAnimation:(void (^)(BOOL finished))completion {
    UIView *referenceView = self.superview ? self.superview : self;
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [referenceView updateModifyConstraints];
    } completion:completion];
}

- (void)updateAppliedConstraintConstantValueForIpadByAttribute:(NSLayoutAttribute)attribute{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self updateAppliedConstraintConstantValueByAttribute:attribute withConstantRatio:defualt_iPadRatio];
    }
}

- (void)updateAppliedConstraintConstantValueByAttribute:(NSLayoutAttribute)attribute withConstantRatio:(CGFloat)constantRatio{
    [self accessAppliedConstraintByAttribute:attribute].constant *= constantRatio;
}

#pragma mark - Access Applied Constraint By Attributes From a specific View

- (NSLayoutConstraint*)accessAppliedConstraintByAttribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint appliedConstraintForView:self attribute:attribute];
}

- (NSLayoutConstraint*)accessAppliedConstraintFromSiblingViewByAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView {
   
    NSAssert(self!=otherSiblingView, @"both view must be sibling not same.");

    NSLayoutConstraint *appliedConstraint = nil;
    
    BOOL isSelfConstraintAttributes = (([NSLayoutConstraint isSelfConstraintAttribute:attribute])||([NSLayoutConstraint isSelfConstraintAttribute:toAttribute]));
    if (isSelfConstraintAttributes && ( attribute != toAttribute )) {
        KVLog(@"You should have provided valid sibling atributes of constraints.");
    }
    else
    {
        NSLayoutConstraint *prepareConstraintForSiblingView =  [self prepareConstraintFromSiblingViewAttribute:attribute toAttribute:toAttribute ofView:otherSiblingView multiplier:defualtMultiplier];
        
        appliedConstraint = [self.superview.constraints containsAppliedConstraint:prepareConstraintForSiblingView];
        
        if (!appliedConstraint) {
            appliedConstraint = [self.superview.constraints containsAppliedConstraint:[prepareConstraintForSiblingView swapConstraintItems]];
        }
    }
    
    return appliedConstraint;
}


- (void)accessAppliedConstraintByAttribute:(NSLayoutAttribute)attribute completion:(void (^)(NSLayoutConstraint *appliedConstraint))completion
{
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self accessAppliedConstraintByAttribute:attribute]);
        });
    }
}

#pragma mark - Pin Edges to Superview
// adding or updating the constraint
- (void)applyPreparedEqualRelationPinConstraintToSuperview:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    NSAssert(self.superview, @"You should have addSubView %@ on any other its called's Superview ", self);
    NSAssert(constant!=INFINITY, @"Constant must not be INFINITY.");
    [self.superview applyPreparedConstraintInView:[self prepareEqualRelationPinConstraintToSuperview:attribute constant:constant]];
}

- (void)applyLeftPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeLeft constant:padding];
}
- (void)applyRightPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeRight constant:-padding];
}
- (void)applyTopPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeTop constant:padding];
}
- (void)applyBottomPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeBottom constant:-padding];
}
- (void)applyLeadingPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeLeading constant:padding];
}
- (void)applyTrailingPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeTrailing constant:-padding];
}
- (void)applyCenterXPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeCenterX constant:padding];
}
- (void)applyCenterYPinConstraintToSuperviewWithPadding:(CGFloat)padding {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeCenterY constant:padding];
}
- (void)applyLeadingAndTrailingPinConstraintToSuperviewWithPadding:(CGFloat)padding{
    [self applyLeadingPinConstraintToSuperviewWithPadding:padding];
    [self applyTrailingPinConstraintToSuperviewWithPadding:padding];
}
- (void)applyTopAndBottomPinConstraintToSuperviewWithPadding:(CGFloat)padding{
    [self applyTopPinConstraintToSuperviewWithPadding:padding];
    [self applyBottomPinConstraintToSuperviewWithPadding:padding];
}
- (void)applyEqualWidthPinConstrainToSuperview {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeWidth constant:defualtConstant];
}
- (void)applyEqualHeightPinConstrainToSuperview {
    [self applyPreparedEqualRelationPinConstraintToSuperview:NSLayoutAttributeHeight constant:defualtConstant];
}

- (void)applyEqualHeightRatioPinConstrainToSuperview:(CGFloat)ratio {
    [self applyEqualRatioPinConstrainToSuperview:NSLayoutAttributeHeight ratio:ratio padding:defualtConstant];
}

- (void)applyEqualWidthRatioPinConstrainToSuperview:(CGFloat)ratio {
    [self applyEqualRatioPinConstrainToSuperview:NSLayoutAttributeWidth ratio:ratio padding:defualtConstant];
}

- (void)applyCenterXRatioPinConstrainToSuperview:(CGFloat)ratio padding:(CGFloat)padding {
    [self applyEqualRatioPinConstrainToSuperview:NSLayoutAttributeCenterX ratio:ratio padding:padding];
}

- (void)applyCenterYRatioPinConstrainToSuperview:(CGFloat)ratio padding:(CGFloat)padding {
    [self applyEqualRatioPinConstrainToSuperview:NSLayoutAttributeCenterY ratio:ratio padding:padding];
}

- (void)applyEqualRatioPinConstrainToSuperview:(NSLayoutAttribute)attribute ratio:(CGFloat)ratio padding:(CGFloat)padding{
    // first method to get equal Ratio constraint
    NSAssert(self.superview, @" Superview of this view must not be nil.\n For View: %@", self);
    NSAssert(ratio!=INFINITY, @" Ratio must not be INFINITY.");
    
    NSLayoutConstraint *relationRatioPinConstraint = [self prepareEqualRelationPinRatioConstraintToSuperview:attribute multiplier:ratio];
    if (relationRatioPinConstraint) {
        [relationRatioPinConstraint setConstant:padding];
        [self.superview applyPreparedConstraintInView:relationRatioPinConstraint];
    }
}

/**  Center horizontally and Vertically  */
- (void)applyConstraintForCenterInSuperview {
    [self applyCenterXPinConstraintToSuperviewWithPadding:defualtConstant];
    [self applyCenterYPinConstraintToSuperviewWithPadding:defualtConstant];
}

- (void)applyConstraintForVerticallyCenterInSuperview {
    [self applyCenterYPinConstraintToSuperviewWithPadding:defualtConstant];
}

- (void)applyConstraintForHorizontallyCenterInSuperview {
    [self applyCenterXPinConstraintToSuperviewWithPadding:defualtConstant];
}

- (void)applyConstraintFitToSuperview {
    // First way
    [self applyConstraintFitToSuperviewContentInset:UIEdgeInsetsZero];
    
    // OR Second way to do the same thing
    /** [self applyEqualHeightPinConstrainToSuperview];
     [self applyEqualWidthPinConstrainToSuperview];
     [self applyConstraintForCenterInSuperview];
     */
}

- (void)applyConstraintFitToSuperviewHorizontally{
    [self applyRightPinConstraintToSuperviewWithPadding:defualtConstant];
    [self applyLeftPinConstraintToSuperviewWithPadding:defualtConstant];
}
- (void)applyConstraintFitToSuperviewVertically{
    //    INFINITY/HUGE_VALF is used to exclude the constraint from the view
    [self applyConstraintFitToSuperviewContentInset:UIEdgeInsetsMake(0, INFINITY, 0, HUGE_VALF)];
}

- (void)applyConstraintFitToSuperviewContentInset:(UIEdgeInsets)Insets {
    if (Insets.top!=INFINITY) {
        [self applyTopPinConstraintToSuperviewWithPadding:Insets.top];
    }
    if (Insets.left!=INFINITY) {
        [self applyLeftPinConstraintToSuperviewWithPadding:Insets.left];
    }
    if (Insets.bottom!=INFINITY) {
        [self applyBottomPinConstraintToSuperviewWithPadding:Insets.bottom];
    }
    if (Insets.right!=INFINITY) {
        [self applyRightPinConstraintToSuperviewWithPadding:Insets.right];
    }
}

#pragma mark - Apply self constraints
- (void)applyAspectRatioConstrain {
    [self applyPreparedConstraintInView:[self.class prepareConstraintForView:self attribute:NSLayoutAttributeWidth secondView:self attribute:NSLayoutAttributeHeight relation:defualtRelation multiplier:defualtMultiplier]];
}
- (void)applyWidthConstraint:(CGFloat)width {
    if (width!=INFINITY) {
        [self applyPreparedConstraintInView:[self prepareSelfConstraint:NSLayoutAttributeWidth constant:width]];
    }else {
        KVLog(@"Width of the view con not be INFINITY");
    }
}
- (void)applyHeightConstraint:(CGFloat) height {
    if (height!=INFINITY) {
        [self applyPreparedConstraintInView:[self prepareSelfConstraint:NSLayoutAttributeHeight constant:height]];
    } else {
        KVLog(@"Height of the view con not be INFINITY");
    }
}

#pragma mark - Apply Constraint between sibling views

- (void)applyConstraintFromSiblingViewAttribute:(NSLayoutAttribute)attribute toAttribute:(NSLayoutAttribute)toAttribute ofView:(UIView *)otherSiblingView spacing:(CGFloat)spacing {
    NSAssert(spacing!=INFINITY, @"spacing between sybings view must not be INFINITY.");
    
    NSLayoutConstraint *prepareConstraintForSiblingView =  [self prepareConstraintFromSiblingViewAttribute:attribute toAttribute:toAttribute ofView:otherSiblingView multiplier:defualtMultiplier];
    [prepareConstraintForSiblingView setConstant:spacing];
    
    if ([NSLayoutConstraint recognizedDirectionByAttribute:attribute toAttribute:toAttribute]) {
        [self.superview applyPreparedConstraintInView:[prepareConstraintForSiblingView swapConstraintItems]];
    }else {
        [self.superview applyPreparedConstraintInView:prepareConstraintForSiblingView];
    }
}

@end
