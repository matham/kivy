from kivy._event cimport EventDispatcher
from kivy.properties cimport PropertyStorage


cdef class WidgetBase(EventDispatcher):

    cdef PropertyStorage _x
    cdef PropertyStorage _y
    cdef PropertyStorage _width
    cdef PropertyStorage _height
    cdef PropertyStorage _right
    cdef PropertyStorage _top
    cdef PropertyStorage _center_x
    cdef PropertyStorage _center_y
    cdef PropertyStorage _size_hint_x
    cdef PropertyStorage _size_hint_y
