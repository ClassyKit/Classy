v0.0.3
=======

* Ability to use rgb, rgba, hsl and hsla colors ([avalanched](https://github.com/avalanched))

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

* Ability to specify UIViewController class/subclass in style selector hierarchy. eg

```
MYHomeViewController > UIButton.main { 
  background-color black
}
```
