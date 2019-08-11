'''
Pyodide window provider.
'''

__all__ = ('WindowPyodide', )

from kivy.logger import Logger
from kivy.core.window import WindowBase
from kivy.base import EventLoop, ExceptionManager, stopTouchApp
from os import environ
import js
from js import document, iodide
from js import window as js_window


class WindowPyodide(WindowBase):

    _pyodide_canvas = None
    _pyodide_gl = None

    gl_backends_allowed = ['pyodide', ]

    def __init__(self, **kwargs):
        self._win = self
        super().__init__(**kwargs)

    def _get_gl_size(self):
        w, h = self.system_size
        return self._density * w, self._density * h

    def initialize_gl(self):
        from kivy.graphics.cgl_backend.cgl_pyodide import set_pyodide_gl
        self._pyodide_gl = self._pyodide_canvas.getContext("webgl2")
        set_pyodide_gl(self._pyodide_gl)
        super().initialize_gl()

    def create_window(self):
        if self.initialized:
            w, h = self.system_size
            self._pyodide_canvas.setAttribute('width', w)
            self._pyodide_canvas.setAttribute('height', h)
            super(WindowPyodide, self).create_window()
            return

        self._pyodide_canvas = canvas = iodide.output.element('canvas')

        def ignore(event):
            event.preventDefault()
            return False
        js_window.addEventListener('contextmenu', ignore)

        w, h = self.system_size
        canvas.setAttribute('width', w)
        canvas.setAttribute('height', h)
        
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
            getattr(window, 'devicePixelRatio', 0) or 1) / backing_store
        self.dpi = self._density * 96.

        # self._focus = True

        super(WindowPyodide, self).create_window()

    def _get_window_pos(self):
        return 0, 0

    def close(self):
        # self._win.teardown_window()
        from kivy.graphics.cgl_backend.cgl_pyodide import clear_pyodide_gl
        super().close()
        self._pyodide_canvas = None
        self._pyodide_gl = None
        self.initialized = False
        clear_pyodide_gl()

    def flip(self):
        pass
