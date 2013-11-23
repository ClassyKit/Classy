Next Version
===========

* Added support for images from documents/caches folder as well as from bundle. ([flippinjoe21](https://github.com/flippinjoe21))
* Style views as soon as they move to window. Fixes [issue #16](https://github.com/cloudkite/Classy/issues/16)

v0.1.0
=======

* Added ability to seperate stylesheets into multiple files and `@import` them

```
@import "variables.cas"

UITableView UILabel {
  text-color $main-color
}
```

* Added UIView tintColor ([glancashire](https://github.com/glancashire))


v0.0.3
=======

* Added ability to use rgb, rgba, hsl and hsla colors ([avalanched](https://github.com/avalanched))

```
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

```
MYHomeViewController > UIButton.main { 
  background-color black
}
```
