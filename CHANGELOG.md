v0.2.6
======

* Updated list of UIAppearance-setters in tests
* Fixed misnamed @param name in code docs
* Support for iOS 10 font weights
* Reduced warnings caused by missing void in method input declaration

v0.2.5
======

* Styling per window
* Caching to binary plist
* Load on demand
* System font support

v0.2.4
======

* Fixed memory leak
* Added ability to inject variables into stylesheets
* Added various UIKit properties. Thanks awesome contributors

v0.2.3
======

* Live reload, ensure imported stylesheet files are not watched more than once.
* Subtract less precedence points for subclass matching [issue #30](https://github.com/cloudkite/Classy/issues/30)

v0.2.2
======

* Call `cas_updateStyling` on live reload
* Added support for `[UIButton setImage:forState:]` ([skeeet](https://github.com/skeeet))
* Only wrap variable values in brackets if variable has more than one value

v0.2.1
======

* Fixed crash when using media queries [issue #24](https://github.com/cloudkite/Classy/issues/24)
* Added UILabel textAlignment
* Fixed error with style selector nesting
* Removed delay in style updates in didMoveToWindow

v0.2.0
======

* Added @media/@device queries

```Scala
UIView.widget {
  /* default background color */
  background-color red
  
  /* background color on iPads running iOS7 and above */
  @media ipad and (version:>=7) {
    background-color blue
  }
}
```

* Added support for images from documents/caches folder as well as from bundle. ([flippinjoe21](https://github.com/flippinjoe21))
* Fixed Scrolling delaying the update of styling. Fixes [issue #16](https://github.com/cloudkite/Classy/issues/16)
* Fixed style selector subclass matching with styleClass. Fixes [issue #18](https://github.com/cloudkite/Classy/issues/18)

v0.1.0
=======

* Added ability to seperate stylesheets into multiple files and `@import` them

```scala
@import "variables.cas"

UITableView UILabel {
  text-color $mainColor
}
```

* Added UIView tintColor ([glancashire](https://github.com/glancashire))


v0.0.3
=======

* Added ability to use rgb, rgba, hsl and hsla colors ([avalanched](https://github.com/avalanched))

```scala
  background-color  rgb(200, 100, 150)
  text-color        rgba(200, 100, 150, 0.5)
  layer @{
    border-color    hsl(200, 60%, 100%)
    shadow-color    hsla(200, 60%, 100%, 0.2)
  }
```

v0.0.2
=======

* Added ability to specify UIViewController class/subclass in style selector hierarchy. eg

```scala
MYHomeViewController > UIButton.main { 
  background-color black
}
```
