
include "_widget.pxi"


cdef class WidgetBase(EventDispatcher):

    def __cinit__(self, *largs, **kwargs):
        self.is_initialized = 1
        self._x = None
        self._y = None
        self._width = None
        self._height = None
        self._right = None
        self._top = None
        self._center_x = None
        self._center_y = None
        self._size_hint_x = None
        self._size_hint_y = None
        self._init()

    def _init(self):
        if self.is_initialized:
            EventDispatcher._init(self)

    x = WidgetNumericPropertyX(0)
    '''X position of the widget.

    :attr:`x` is a :class:`~kivy.properties.NumericProperty` and defaults to 0.
    '''

    y = WidgetNumericPropertyY(0)
    '''Y position of the widget.

    :attr:`y` is a :class:`~kivy.properties.NumericProperty` and defaults to 0.
    '''

    width = WidgetNumericPropertyWidth(100)
    '''Width of the widget.

    :attr:`width` is a :class:`~kivy.properties.NumericProperty` and defaults
    to 100.

    .. warning::
        Keep in mind that the `width` property is subject to layout logic and
        that this has not yet happened at the time of the widget's `__init__`
        method.
    '''

    height = WidgetNumericPropertyHeight(100)
    '''Height of the widget.

    :attr:`height` is a :class:`~kivy.properties.NumericProperty` and defaults
    to 100.

    .. warning::
        Keep in mind that the `height` property is subject to layout logic and
        that this has not yet happened at the time of the widget's `__init__`
        method.
    '''

    pos = ReferenceListProperty(x, y)
    '''Position of the widget.

    :attr:`pos` is a :class:`~kivy.properties.ReferenceListProperty` of
    (:attr:`x`, :attr:`y`) properties.
    '''

    size = ReferenceListProperty(width, height)
    '''Size of the widget.

    :attr:`size` is a :class:`~kivy.properties.ReferenceListProperty` of
    (:attr:`width`, :attr:`height`) properties.
    '''

    right = WidgetAliasPropertyRight(None, None, bind=('x', 'width'))
    '''Right position of the widget.

    :attr:`right` is an :class:`~kivy.properties.AliasProperty` of
    (:attr:`x` + :attr:`width`).
    '''

    top = WidgetAliasPropertyTop(None, None, bind=('y', 'height'))
    '''Top position of the widget.

    :attr:`top` is an :class:`~kivy.properties.AliasProperty` of
    (:attr:`y` + :attr:`height`).
    '''

    center_x = WidgetAliasPropertyCenterX(None, None, bind=('x', 'width'))
    '''X center position of the widget.

    :attr:`center_x` is an :class:`~kivy.properties.AliasProperty` of
    (:attr:`x` + :attr:`width` / 2.).
    '''

    center_y = WidgetAliasPropertyCenterY(None, None, bind=('y', 'height'))
    '''Y center position of the widget.

    :attr:`center_y` is an :class:`~kivy.properties.AliasProperty` of
    (:attr:`y` + :attr:`height` / 2.).
    '''

    center = ReferenceListProperty(center_x, center_y)
    '''Center position of the widget.

    :attr:`center` is a :class:`~kivy.properties.ReferenceListProperty` of
    (:attr:`center_x`, :attr:`center_y`) properties.
    '''

    size_hint_x = WidgetNumericPropertySizeHintX(1, allownone=True)
    '''X size hint. Represents how much space the widget should use in the
    direction of the X axis relative to its parent's width.
    Only the :class:`~kivy.uix.layout.Layout` and
    :class:`~kivy.core.window.Window` classes make use of the hint.

    The size_hint is used by layouts for two purposes:

    - When the layout considers widgets on their own rather than in
      relation to its other children, the size_hint_x is a direct proportion
      of the parent width, normally between 0.0 and 1.0. For instance, a
      widget with ``size_hint_x=0.5`` in
      a vertical BoxLayout will take up half the BoxLayout's width, or
      a widget in a FloatLayout with ``size_hint_x=0.2`` will take up 20%
      of the FloatLayout width. If the size_hint is greater than 1, the
      widget will be wider than the parent.
    - When multiple widgets can share a row of a layout, such as in a
      horizontal BoxLayout, their widths will be their size_hint_x as a
      fraction of the sum of widget size_hints. For instance, if the
      size_hint_xs are (0.5, 1.0, 0.5), the first widget will have a
      width of 25% of the parent width.

    :attr:`size_hint_x` is a :class:`~kivy.properties.NumericProperty` and
    defaults to 1.
    '''

    size_hint_y = WidgetNumericPropertySizeHintY(1, allownone=True)
    '''Y size hint.

    :attr:`size_hint_y` is a :class:`~kivy.properties.NumericProperty` and
    defaults to 1.

    See :attr:`size_hint_x` for more information, but with widths and heights
    swapped.
    '''

    size_hint = ReferenceListProperty(size_hint_x, size_hint_y)
    '''Size hint.

    :attr:`size_hint` is a :class:`~kivy.properties.ReferenceListProperty` of
    (:attr:`size_hint_x`, :attr:`size_hint_y`) properties.

    See :attr:`size_hint_x` for more information.
    '''
