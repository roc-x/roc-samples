## 使用 BottomAppBar 实现底部导航
在我们日常使用的众多app中，底部导航是一种很常见的布局方式。这篇文章将介绍在 Flutter 中如何实现一个底部导航。</br>
在 Flutter 中我们可以使用 Scaffold 的 bottomNavigationBar 属性为应用添加底部导航。其中 bottomNavigationBar 属性常用的类型有 BottomNavigationBar 和 BottomAppBar 两个 Widget。 BottomNavigationBar 即普通的导航，比较中规中矩。BottomAppBar 结合FloatingActionButton 可以实现如缺口的导航等特殊效果。</br>
先来看一下 BottomNavigationBar 和 BottomAppBar 的构造方法。

- BottomNavigationBar

```dart
  BottomNavigationBar({
    Key key,
    @required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.elevation = 8.0,
    BottomNavigationBarType type,
    Color fixedColor,
    this.backgroundColor,
    this.iconSize = 24.0,
    Color selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme = const IconThemeData(),
    this.unselectedIconTheme = const IconThemeData(),
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels = true,
    bool showUnselectedLabels,
  })
```
- BottomAppBar

```dart
  const BottomAppBar({
    Key key,
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior = Clip.none,
    this.notchMargin = 4.0,
    this.child,
  })
```
可以看到 BottomAppBar 构造方法参数要比 BottomNavigationBar 少一些，不过这次我们就尝试用 BottomAppBar 实现一些特殊的效果。
### 常用参数介绍

#### color
color 即 BottomAppBar 的颜色</br>
![](http://p0.qhimg.com/t01033a77bed5c9ee9d.png)

#### elevation
elevation 即 BottomAppBar 的阴影，如果是在底部的话，其实是看不到什么效果的。把它的高度向上移动可以看到阴影效果。如下代码分别设置 elevation = 10 和 20。

```dart
bottomNavigationBar: Transform.translate(
    offset: Offset(0, -80),
    child: BottomAppBar(
      color: Colors.amber,
      elevation: 20,
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, right: 20),
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 20),
            child: IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
            ),
          ),
        ],
      ),
    )),
```
![](http://p0.qhimg.com/t01353d5ba0e0e37d11.png)

#### shape
shape 是缺口的形状，我们设置 CircularNotchedRectangle() 即为圆形缺口，当然也可以自己定义绘制任何形状的缺口。shape 缺口要和 floatingActionButton 和 floatingActionButtonLocation 一起使用才能显示出来。

#### notchMargin
notchMargin 是 FloatingActionButton 和 BottomAppBar 的缺口的距离。
> The margin between the [FloatingActionButton] and the [BottomAppBar]'s notch.

#### child
child 即 BottomAppBar 具体要显示的 tab。

以上就是关于 BottomAppBar 的使用方式，关于自定义 shape 会在接下来的文章中介绍。

### demo地址