#Classy [![Build Status](https://travis-ci.org/cloudkite/Classy.png?branch=master)](https://travis-ci.org/cloudkite/Classy) [![Coverage Status](https://coveralls.io/repos/cloudkite/Classy/badge.png)](https://coveralls.io/r/cloudkite/Classy)

Not CSS. Instead of trying to force UIKit to fit CSS syntax, properties, conventions and constructs. Classy is a stylesheet system built from the ground up to work in harmony with UIKit. It borrows the best ideas from CSS and introduces new syntax, conventions and constructs where appropriate.

Plays nice with Interface Builder and views created in code.

For detailed usage docs visit [classy.as](http://classy.as/)

##Supports UIAppearance
Classy supports all [UIAppearance properties and methods](https://github.com/cloudkite/Classy/blob/master/Tests/UIAppearance-setters.md) and much more. But instead of being limited to `+appearanceWhenContainedIn:` and `+appearance`,
Classy gives you much greater control over which views are styled and with what values.

##Example Stylesheets

Classy features a very flexible, nestable syntax. 
Classy makes `{`   `}`   `:`   `;` all optional so you can choose a style that suits you. It also saves you from worrying about small syntax mistakes like accidentally forgetting to end a line with a `;`

You can use `{`   `}`   `:`   `;` to delimit your stylesheets

```Scala
@import "other_stylesheet.cas";

$mainColor = #e1e1e1;

// Supports your custom UIView subclasses
MYCustomView {
  background-color: $mainColor;
  title-insets: 5, 10, 5, 10;
  > UIProgressView.tinted {
    progress-tint-color: rgb(200, 155, 110, 0.6);
    track-tint-color: yellow;
  }
}

/*
 * Supports Single or Multi-line comments
 */
^UIButton.warning, UIView.warning ^UIButton {
  title-color[state:highlighted]: #e3e3e3;
}
```

**OR** you can use whitespace to delimit your sytlesheets

```Scala
@import "other_stylesheet.cas"

$mainColor = #e1e1e1

// Supports your custom UIView subclasses
MYCustomView 
  background-color $mainColor
  title-insets 5, 10, 5, 10
  > UIProgressView.tinted 
    progress-tint-color rgb(200, 155, 110, 0.6)
    track-tint-color yellow

/*
 * Supports Single or Multi-line comments
 */
^UIButton.warning, UIView.warning ^UIButton 
  title-color[state:highlighted] #e3e3e3
```

## Live Reload
Live reload can dramatically speed up your development time, with live reload enabled you can instantenously see your stylesheet changes. Without having to rebuild and navigate back to the same spot within your app.

For more details about these features and more visit [classy.as](http://classy.as/)

## Inspiration
- Syntax inspired by [stylus](http://learnboost.github.io/stylus/)
- Property reflection [Mantle](https://github.com/github/mantle)

