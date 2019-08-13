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
        Logger.warn('Before init')
        super().__init__(**kwargs)
        Logger.warn('After init')

    def _get_gl_size(self):
        w, h = self.system_size
        Logger.warn('system size, {}, {}'.format(w, h))
        return self._density * w, self._density * h

    def initialize_gl(self):
        Logger.warn('Before gl')
        from kivy.graphics.cgl_backend.cgl_pyodide import set_pyodide_gl
        self._pyodide_gl = context = self._pyodide_canvas.getContext("webgl2")
        Logger.warn('After gl')

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

        Logger.warn('Before setting gl')
        set_pyodide_gl(self._pyodide_gl)
        Logger.warn('After setting gl')
        super().initialize_gl()

    def create_window(self):
        if self.initialized:
            Logger.warn('Before reinit')
            w, h = self.system_size
            self._pyodide_canvas.setAttribute('width', w)
            self._pyodide_canvas.setAttribute('height', h)
            Logger.warn('After reinit')
            super(WindowPyodide, self).create_window()
            return

        Logger.warn('Before canvas')
        self._pyodide_canvas = canvas = iodide.output.element('canvas')
        Logger.warn('After canvas')

        def ignore(event):
            event.preventDefault()
            return False
        js_window.addEventListener('contextmenu', ignore)

        Logger.warn('Setting size')
        w, h = self.system_size
        canvas.setAttribute('width', w)
        canvas.setAttribute('height', h)
        Logger.warn('Set size')

        # self._focus = True

        super(WindowPyodide, self).create_window()

    def _get_window_pos(self):
        return 0, 0

    def close(self):
        # self._win.teardown_window()
        Logger.warn('Before close')
        from kivy.graphics.cgl_backend.cgl_pyodide import clear_pyodide_gl
        super().close()
        self._pyodide_canvas = None
        self._pyodide_gl = None
        self.initialized = False
        clear_pyodide_gl()
        Logger.warn('After close')

    def flip(self):
        pass
