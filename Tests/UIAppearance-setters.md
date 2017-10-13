Extracted using technique described at https://gist.github.com/mattt/5135521

The information below was extracted from the iPhoneOS 11.1 SDK.

### UIActivityIndicatorView

```objective-c
@property (nullable, readwrite, nonatomic, strong) UIColor *color NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

### UIBarButtonItem

```objective-c
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
- (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; 
- (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; 
- (void)setBackButtonBackgroundImage:(nullable UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
- (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
- (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
```

### UIBarItem

```objective-c
- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

### UIButton

```objective-c
@property(nonatomic) UIEdgeInsets contentEdgeInsets UI_APPEARANCE_SELECTOR; // default is UIEdgeInsetsZero. On tvOS 10 or later, default is nonzero except for custom buttons.
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR; // default if nil. use opaque white
- (void)setTitleShadowColor:(nullable UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR; // default is nil. use 50% black
- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state UI_APPEARANCE_SELECTOR; // default is nil
```

### UINavigationBar

```objective-c
@property(nonatomic,assign) UIBarStyle barStyle UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
@property(nonatomic,assign,getter=isTranslucent) BOOL translucent NS_AVAILABLE_IOS(3_0) UI_APPEARANCE_SELECTOR; // Default is NO on iOS 6 and earlier. Always YES if barStyle is set to UIBarStyleBlackTranslucent
@property (nonatomic, readwrite, assign) BOOL prefersLargeTitles UI_APPEARANCE_SELECTOR API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
@property(nullable, nonatomic,strong) UIColor *barTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;  // default is nil
@property(nullable,nonatomic,strong) UIImage *backIndicatorImage NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
@property(nullable,nonatomic,strong) UIImage *backIndicatorTransitionMaskImage NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
@property(nullable, nonatomic,strong) UIImage *shadowImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nullable,nonatomic,copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *largeTitleTextAttributes UI_APPEARANCE_SELECTOR API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setTitleVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

### UIPageControl

```objective-c
@property(nullable, nonatomic,strong) UIColor *pageIndicatorTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic,strong) UIColor *currentPageIndicatorTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
```

### UIProgressView

```objective-c
@property(nonatomic, strong, nullable) UIColor* progressTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong, nullable) UIColor* trackTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong, nullable) UIImage* progressImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong, nullable) UIImage* trackImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

### UIRefreshControl

```objective-c
@property (nullable, nonatomic, strong) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;
```

### UISearchBar

```objective-c
@property(nullable, nonatomic,strong) UIColor *barTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;  // default is nil
@property(nullable, nonatomic,strong) UIImage *backgroundImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic,strong) UIImage *scopeBarBackgroundImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic) UIOffset searchFieldBackgroundPositionAdjustment NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic) UIOffset searchTextPositionAdjustment NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR; // Use UIBarMetricsDefaultPrompt to set a separate backgroundImage for a search bar with a prompt
- (void)setSearchFieldBackgroundImage:(nullable UIImage *)backgroundImage forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setImage:(nullable UIImage *)iconImage forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setScopeBarButtonBackgroundImage:(nullable UIImage *)backgroundImage forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; 
- (void)setScopeBarButtonDividerImage:(nullable UIImage *)dividerImage forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setScopeBarButtonTitleTextAttributes:(nullable NSDictionary<NSString *, id> *)attributes forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setPositionAdjustment:(UIOffset)adjustment forSearchBarIcon:(UISearchBarIcon)icon NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

### UISegmentedControl

```objective-c
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; 
- (void)setDividerImage:(nullable UIImage *)dividerImage forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setTitleTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setContentPositionAdjustment:(UIOffset)adjustment forSegmentType:(UISegmentedControlSegment)leftCenterRightOrAlone barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; 
```

### UISlider

```objective-c
@property(nullable, nonatomic,strong) UIColor *minimumTrackTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic,strong) UIColor *maximumTrackTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic,strong) UIColor *thumbTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
```

### UIStepper

```objective-c
- (void)setBackgroundImage:(nullable UIImage*)image forState:(UIControlState)state NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
- (void)setDividerImage:(nullable UIImage*)image forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
- (void)setIncrementImage:(nullable UIImage *)image forState:(UIControlState)state NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
- (void)setDecrementImage:(nullable UIImage *)image forState:(UIControlState)state NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
```

### UISwitch

```objective-c
@property(nullable, nonatomic, strong) UIColor *onTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIColor *thumbTintColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIImage *onImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIImage *offImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
```

### UITabBar

```objective-c
@property(nullable, nonatomic, strong) UIColor *barTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;  // default is nil
@property (nonatomic, readwrite, copy, nullable) UIColor *unselectedItemTintColor NS_AVAILABLE_IOS(10_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIColor *selectedImageTintColor NS_DEPRECATED_IOS(5_0,8_0,"Use tintColor") UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
@property(nullable, nonatomic, strong) UIImage *backgroundImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIImage *selectionIndicatorImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIImage *shadowImage NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic) UITabBarItemPositioning itemPositioning NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
@property(nonatomic) CGFloat itemWidth NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic) CGFloat itemSpacing NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic) UIBarStyle barStyle NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
```

### UITabBarItem

```objective-c
@property (nonatomic, readwrite, assign) UIOffset titlePositionAdjustment NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, readwrite, copy, nullable) UIColor *badgeColor NS_AVAILABLE_IOS(10_0) UI_APPEARANCE_SELECTOR;
- (void)setBadgeTextAttributes:(nullable NSDictionary<NSString *,id> *)textAttributes forState:(UIControlState)state NS_AVAILABLE_IOS(10_0) UI_APPEARANCE_SELECTOR;
```

### UITableView

```objective-c
@property (nonatomic) UIEdgeInsets separatorInset NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR; // allows customization of the frame of cell separators; see also the separatorInsetReference property. Use UITableViewAutomaticDimension for the automatic inset for that edge.
@property (nonatomic, strong, nullable) UIColor *sectionIndexColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR; // color used for text of the section index
@property (nonatomic, strong, nullable) UIColor *sectionIndexBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR; // the background color of the section index while not being touched
@property (nonatomic, strong, nullable) UIColor *sectionIndexTrackingBackgroundColor NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR; // the background color of the section index while it is being touched
@property (nonatomic, strong, nullable) UIColor *separatorColor UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED; // default is the standard separator gray
@property (nonatomic, copy, nullable) UIVisualEffect *separatorEffect NS_AVAILABLE_IOS(8_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED; // effect to apply to table separators
```

### UITableViewCell

```objective-c
@property (nonatomic) UIEdgeInsets separatorInset NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED; // allows customization of the separator frame
@property (nonatomic) UITableViewCellFocusStyle focusStyle NS_AVAILABLE_IOS(9_0) UI_APPEARANCE_SELECTOR;
```

### UIToolbar

```objective-c
@property(nonatomic) UIBarStyle barStyle UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED; // default is UIBarStyleDefault
@property(nonatomic,assign,getter=isTranslucent) BOOL translucent NS_AVAILABLE_IOS(3_0) UI_APPEARANCE_SELECTOR; // Default is NO on iOS 6 and earlier. Always YES if barStyle is set to UIBarStyleBlackTranslucent
@property(nullable, nonatomic, strong) UIColor *barTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;  // default is nil
- (void)setBackgroundImage:(nullable UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
- (void)setShadowImage:(nullable UIImage *)shadowImage forToolbarPosition:(UIBarPosition)topOrBottom NS_AVAILABLE_IOS(6_0) UI_APPEARANCE_SELECTOR;
```

### UIView

```objective-c
@property(nullable, nonatomic,copy) UIColor *backgroundColor UI_APPEARANCE_SELECTOR; // default is nil. Can be useful with the appearance proxy on custom UIView subclasses.
```