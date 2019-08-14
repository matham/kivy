'''
Pyodide window provider.
'''

__all__ = ('WindowPyodide', )

from kivy.logger import Logger
from kivy.core.window import WindowBase
from js import document, iodide, window as js_window


class WindowPyodide(WindowBase):

    _pyodide_canvas = None
    _pyodide_gl = None

    gl_backends_allowed = ['pyodide', ]

    def __init__(self, **kwargs):
        self._win = self
        super().__init__(**kwargs)
        self._mouse_x = self._mouse_y = -1
        self._mouse_buttons_down = set()

    def _get_gl_size(self):
        w, h = self.system_size
        return self._density * w, self._density * h

    def initialize_gl(self):
        from kivy.graphics.cgl_backend.cgl_pyodide import set_pyodide_gl
        self._pyodide_gl = context = self._pyodide_canvas.getContext("webgl2")

        backing_store = (
            getattr(context, 'backingStorePixelRatio', 0) or
            getattr(context, 'webkitBackingStorePixel', 0) or
            getattr(context, 'mozBackingStorePixelRatio', 0) or
            getattr(context, 'msBackingStorePixelRatio', 0) or
            getattr(context, 'oBackingStorePixelRatio', 0) or
            getattr(context, 'backendStorePixelRatio', 0) or
            1
        )
        self._density = (
            getattr(js_window, 'devicePixelRatio', 0) or 1) / backing_store
        self.dpi = self._density * 96.

        set_pyodide_gl(self._pyodide_gl)
        super().initialize_gl()

    def _js_ignore_event(self, event):
        event.preventDefault()
        return False

    def _js_unload_event(self, event):
        from kivy.app import stopTouchApp
        stopTouchApp()
        return True

    def _js_resize_event(self, event):
        # this is not ever actually called on the canvas
        return True

    def _js_convert_mouse(self, event):
        h = self.system_size[1]
        x = event.offsetX
        y = h - event.offsetY
        button = event.button
        # Disable the right-click context menu in some browsers
        if button == 2:
            event.preventDefault()
            event.stopPropagation()
        if button == 0:
            button = 'left'
        elif button == 1:
            button = 'middle'
        elif button == 2:
            button = 'right'
        return x, y, button

    def _js_handle_mouse_down_event(self, event):
        Logger.info(
            f'down: {event}, {event.offsetX}, {event.offsetY}, {event.button}'
        )
        x, y, button = self._js_convert_mouse(event)
        self._mouse_buttons_down.add(button)
        self._mouse_x = x
        self._mouse_y = y
        self.dispatch('on_mouse_down', x, y, button, self.modifiers)
        return False

    def _js_handle_mouse_up_event(self, event):
        Logger.info(
            f'up: {event}, {event.offsetX}, {event.offsetY}, {event.button}'
        )
        x, y, button = self._js_convert_mouse(event)
        if button in self._mouse_buttons_down:
            self._mouse_buttons_down.remove(button)
        self._mouse_x = x
        self._mouse_y = y
        self.dispatch('on_mouse_up', x, y, button, self.modifiers)
        return False

    def _js_handle_mouse_move_event(self, event):
        Logger.info(
            f'move: {event}, {event.offsetX}, {event.offsetY}, {event.button}'
        )
        x, y, button = self._js_convert_mouse(event)
        self._mouse_x = x
        self._mouse_y = y
        # don't dispatch motion if no button are pressed
        if len(self._mouse_buttons_down) == 0:
            return False
        self.dispatch('on_mouse_move', x, y, self.modifiers)
        return False

    def _js_handle_mouse_wheel_event(self, event):
        Logger.info(f'wheel: {event}, {event.deltaX}, {event.deltaY}')
        if event.deltaY:
            button = 'scrolldown'
            if event.deltaY >= 0:
                button = 'scrollup'
            self.dispatch(
                'on_mouse_down', self._mouse_x, self._mouse_y, button,
                self.modifiers)
            self.dispatch(
                'on_mouse_up', self._mouse_x, self._mouse_y, button,
                self.modifiers)

        if event.deltaX:
            button = 'scrollright'
            if event.deltaY < 0:
                button = 'scrollleft'
            self.dispatch(
                'on_mouse_down', self._mouse_x, self._mouse_y, button,
                self.modifiers)
            self.dispatch(
                'on_mouse_up', self._mouse_x, self._mouse_y, button,
                self.modifiers)
        return False

    def create_window(self):
        if self.initialized:
            w, h = self.system_size
            self._pyodide_canvas.setAttribute('width', w)
            self._pyodide_canvas.setAttribute('height', h)
            super(WindowPyodide, self).create_window()
            return

        self._pyodide_canvas = canvas = iodide.output.element('canvas')
        js_window.addEventListener('contextmenu', self._js_ignore_event)
        js_window.addEventListener('unload', self._js_unload_event)
        js_window.addEventListener('resize', self._js_resize_event)
        js_window.addEventListener('mousedown', self._js_handle_mouse_down_event)
        js_window.addEventListener('mouseup', self._js_handle_mouse_up_event)
        js_window.addEventListener('mousemove', self._js_handle_mouse_move_event)
        js_window.addEventListener('wheel', self._js_handle_mouse_wheel_event)

        w, h = self.system_size
        canvas.setAttribute('width', w)
        canvas.setAttribute('height', h)

        # self._focus = True

        super(WindowPyodide, self).create_window()

    def _get_window_pos(self):
        return 0, 0

    def close(self):
        super().close()

    def flip(self):
        pass
