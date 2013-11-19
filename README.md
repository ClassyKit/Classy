#Classy [![Build Status](https://travis-ci.org/cloudkite/Classy.png?branch=master)](https://travis-ci.org/cloudkite/Classy) [![Coverage Status](https://coveralls.io/repos/cloudkite/Classy/badge.png)](https://coveralls.io/r/cloudkite/Classy)

Not CSS. Instead of trying to force UIKit to fit CSS syntax, properties, conventions and constructs. Classy is a stylesheet system built from the ground up to work in harmony with UIKit. It borrows the best ideas from CSS and introduces new syntax, conventions and constructs where appropriate.

For detailed usage docs go to [http://classy.as/](http://classy.as/)

##Example Stylesheets

This is a valid stylesheet

```
$main-color = #e1e1e1;

MYCustomView {
  background-color: $main-color;
  title-insets: 5, 10, 5, 10;
  > UIProgressView.tinted {
    progress-tint-color: black;
    track-tint-color: yellow;
  }
}

^UIButton.warning, UIView.warning ^UIButton {
  title-color[state:highlighted]: #e3e3e3;
}
```

This is also a valid stylesheet

```
$main-color = #e1e1e1

MYCustomView 
  background-color $main-color
  title-insets 5, 10, 5, 10
  > UIProgressView.tinted 
    progress-tint-color black
    track-tint-color yellow

^UIButton.warning, UIView.warning ^UIButton 
  title-color[state:highlighted] #e3e3e3
```

## Inspiration
- Syntax inspired by [stylus](http://learnboost.github.io/stylus/)
- Property reflection [Mantle](https://github.com/github/mantle)


