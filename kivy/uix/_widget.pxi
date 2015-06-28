
from kivy.properties cimport (
    NumericProperty, StringProperty, AliasProperty, ReferenceListProperty,
    ObjectProperty, ListProperty, DictProperty, BooleanProperty)

cdef class WidgetNumericProperty(NumericProperty):

    cdef init_storage(self, EventDispatcher obj, PropertyStorage storage):
        NumericProperty.init_storage(self, obj, storage)
        if storage.value is not None:
            storage.fvalue = storage.value

    cdef compare_value(self, a, b):
        if a is None or b is None:
            return a == b
        return <float>a == <float>b

    cpdef set(self, EventDispatcher obj, value):
        cdef PropertyStorage ps = self.get_storage(obj)
        value = self.convert(obj, value)
        realvalue = ps.value
        if not self.force_dispatch and self.compare_value(realvalue, value):
            return False

        try:
            self.check(obj, value)
        except ValueError as e:
            if self.errorvalue_set == 1:
                value = self.errorvalue
                self.check(obj, value)
            elif self.errorhandler is not None:
                value = self.errorhandler(value)
                self.check(obj, value)
            else:
                raise e

        ps.value = value
        if ps.value is not None:
            ps.fvalue = ps.value
        self.dispatch(obj)
        return True


cdef class WidgetAliasProperty(AliasProperty):

    cdef init_storage(self, EventDispatcher obj, PropertyStorage storage):
        AliasProperty.init_storage(self, obj, storage)
        if storage.value is not None:
            storage.fvalue = storage.value

    cpdef trigger_change(self, EventDispatcher obj, value):
        cdef PropertyStorage ps = self.get_storage(obj)
        cdef float dvalue = self.alias_get(obj)
        if ps.fvalue != dvalue:
            ps.fvalue = ps.value = dvalue
            ps.alias_initial = 0
            self.dispatch(obj)

    cpdef get(self, EventDispatcher obj):
        cdef PropertyStorage ps = self.get_storage(obj)
        if self.use_cache:
            if ps.alias_initial:
                ps.fvalue = ps.value = self.alias_get(obj)
                ps.alias_initial = 0
            return ps.value
        return self.alias_get(obj)

    cpdef set(self, EventDispatcher obj, value):
        cdef PropertyStorage ps = self.get_storage(obj)
        if self.alias_set(obj, value):
            ps.fvalue = ps.value = self.alias_get(obj)
            self.dispatch(obj)

    cdef float alias_get(self, EventDispatcher obj):
        return 0.

    cdef int alias_set(self, EventDispatcher obj, float value):
        return 0


cdef class WidgetNumericPropertyX(WidgetNumericProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase><object>obj)._x

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetNumericProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._x = storage

cdef class WidgetNumericPropertyY(WidgetNumericProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._y

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetNumericProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._y = storage

cdef class WidgetNumericPropertyWidth(WidgetNumericProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._width

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetNumericProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._width = storage

cdef class WidgetNumericPropertyHeight(WidgetNumericProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._height

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetNumericProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._height = storage

cdef class WidgetNumericPropertySizeHintX(WidgetNumericProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._size_hint_x

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetNumericProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._size_hint_x = storage

cdef class WidgetNumericPropertySizeHintY(WidgetNumericProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._size_hint_y

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetNumericProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._size_hint_y = storage


cdef class WidgetAliasPropertyRight(WidgetAliasProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._right

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetAliasProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._right = storage

    cdef float alias_get(self, EventDispatcher obj):
        return (<WidgetBase>obj)._x.fvalue + (<WidgetBase>obj)._width.fvalue

    cdef int alias_set(self, EventDispatcher obj, float value):
        obj.x = value - (<WidgetBase>obj)._width.fvalue
        return 0

cdef class WidgetAliasPropertyTop(WidgetAliasProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._top

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetAliasProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._top = storage

    cdef float alias_get(self, EventDispatcher obj):
        return (<WidgetBase>obj)._y.fvalue + (<WidgetBase>obj)._height.fvalue

    cdef int alias_set(self, EventDispatcher obj, float value):
        obj.y = value - (<WidgetBase>obj)._height.fvalue
        return 0

cdef class WidgetAliasPropertyCenterX(WidgetAliasProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._center_x

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetAliasProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._center_x = storage

    cdef float alias_get(self, EventDispatcher obj):
        return (<WidgetBase>obj)._x.fvalue + (<WidgetBase>obj)._width.fvalue / 2.

    cdef int alias_set(self, EventDispatcher obj, float value):
        obj.x = value - (<WidgetBase>obj)._width.fvalue / 2.
        return 0

cdef class WidgetAliasPropertyCenterY(WidgetAliasProperty):

    cdef PropertyStorage get_storage(self, EventDispatcher obj):
        return (<WidgetBase>obj)._center_y

    cdef void set_storage(self, EventDispatcher obj, PropertyStorage storage):
        WidgetAliasProperty.set_storage(self, obj, storage)
        (<WidgetBase>obj)._center_y = storage

    cdef float alias_get(self, EventDispatcher obj):
        return (<WidgetBase>obj)._y.fvalue + (<WidgetBase>obj)._height.fvalue / 2.

    cdef int alias_set(self, EventDispatcher obj, float value):
        obj.y = value - (<WidgetBase>obj)._height.fvalue / 2.
        return 0
