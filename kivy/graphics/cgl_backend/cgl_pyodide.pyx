"""
CGL/pyodide: GL backend implementation using Pyodide.
"""

include "../common.pxi"

from cpython cimport array
from libc.string cimport memcpy, strcpy, strlen
import array
from kivy.graphics.cgl cimport *
cdef object pyodide_gl = None

__all__ = ('set_pyodide_gl', 'clear_pyodide_gl', 'is_backend_supported')

cpdef is_backend_supported():
    try:
        import js
        return True
    except ImportError:
        return False


def set_pyodide_gl(gl):
    global pyodide_gl
    pyodide_gl = gl


def clear_pyodide_gl():
    global pyodide_gl
    pyodide_gl = None


cdef inline array.array get_float_array(GLsizei count, const GLfloat* v):
    cdef array.array arr = array.array('f', [])
    array.resize(arr, count)
    memcpy(arr.as_floats, v, count * sizeof(GLfloat))
    return arr


cdef inline array.array get_int_array(GLsizei count, const GLint* v):
    cdef array.array arr = array.array('i', [])
    array.resize(arr, count)
    memcpy(arr.as_ints, v, count * sizeof(GLint))
    return arr


cdef inline array.array get_char_array(GLsizei count, const GLchar* v):
    cdef array.array arr = array.array('b', [])
    array.resize(arr, count)
    memcpy(arr.as_chars, v, count * sizeof(GLchar))
    return arr


cdef dict locations = {}
cdef dict programs = {}
cdef dict shaders = {}


cdef void __stdcall pyodideGetActiveAttrib(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name):
    pass
cdef void __stdcall pyodideGetActiveUniform(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name):
    pass
cdef void __stdcall pyodideGetAttachedShaders(GLuint program, GLsizei maxcount, GLsizei* count, GLuint* shaders):
    pass
cdef void __stdcall pyodideGetProgramiv(GLuint program, GLenum pname, GLint* params):
    pass
cdef void __stdcall pyodideGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog):
    pass
# cdef void __stdcall pyodideReleaseShaderCompiler():
#     pass
cdef void __stdcall pyodideShaderBinary(GLsizei n, const GLuint* shaders, GLenum binaryformat, const GLvoid* binary, GLsizei length):
    pass
cdef void __stdcall pyodideTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels):
    pass
cdef void __stdcall pyodideTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels):
    pass


cdef int __stdcall pyodideGetUniformLocation(GLuint program,  const GLchar* name):
    cdef int loc_id
    cdef bytes py_name = name
    loc = pyodide_gl.getUniformLocation(programs[program], py_name)
    loc_id = id(loc)
    assert loc_id not in locations
    locations[loc_id] = loc
    return loc_id


cdef void __stdcall pyodideUniform1f(GLint location, GLfloat x):
    pyodide_gl.uniform1f(locations[location], x)


cdef void __stdcall pyodideUniform1fv(GLint location, GLsizei count, const GLfloat* v):
    pyodide_gl.uniform1fv(locations[location], get_float_array(count, v))


cdef void __stdcall pyodideUniform1i(GLint location, GLint x):
    pyodide_gl.uniform1i(locations[location], x)


cdef void __stdcall pyodideUniform1iv(GLint location, GLsizei count, const GLint* v):
    pyodide_gl.uniform1iv(locations[location], get_int_array(count, v))


cdef void __stdcall pyodideUniform2f(GLint location, GLfloat x, GLfloat y):
    pyodide_gl.uniform2f(locations[location], x, y)


cdef void __stdcall pyodideUniform2fv(GLint location, GLsizei count, const GLfloat* v):
    pyodide_gl.uniform2fv(locations[location], get_float_array(count, v))


cdef void __stdcall pyodideUniform2i(GLint location, GLint x, GLint y):
    pyodide_gl.uniform2i(locations[location], x, y)


cdef void __stdcall pyodideUniform2iv(GLint location, GLsizei count, const GLint* v):
    pyodide_gl.uniform2iv(locations[location], get_int_array(count, v))


cdef void __stdcall pyodideUniform3f(GLint location, GLfloat x, GLfloat y, GLfloat z):
    pyodide_gl.uniform3f(locations[location], x, y, z)


cdef void __stdcall pyodideUniform3fv(GLint location, GLsizei count, const GLfloat* v):
    pyodide_gl.uniform3fv(locations[location], get_float_array(count, v))


cdef void __stdcall pyodideUniform3i(GLint location, GLint x, GLint y, GLint z):
    pyodide_gl.uniform3i(locations[location], x, y, z)


cdef void __stdcall pyodideUniform3iv(GLint location, GLsizei count, const GLint* v):
    pyodide_gl.uniform3iv(locations[location], get_int_array(count, v))


cdef void __stdcall pyodideUniform4f(GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w):
    pyodide_gl.uniform4f(locations[location], x, y, z, w)


cdef void __stdcall pyodideUniform4fv(GLint location, GLsizei count, const GLfloat* v):
    pyodide_gl.uniform4fv(locations[location], get_float_array(count, v))


cdef void __stdcall pyodideUniform4i(GLint location, GLint x, GLint y, GLint z, GLint w):
    pyodide_gl.uniform4i(locations[location], x, y, z, w)


cdef void __stdcall pyodideUniform4iv(GLint location, GLsizei count, const GLint* v):
    pyodide_gl.uniform4iv(locations[location], get_int_array(count, v))


cdef void __stdcall pyodideUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value):
    pyodide_gl.uniformMatrix2fv(locations[location], transpose, get_float_array(count, value))


cdef void __stdcall pyodideUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value):
    pyodide_gl.uniformMatrix3fv(locations[location], transpose, get_float_array(count, value))


cdef void __stdcall pyodideUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value):
    pyodide_gl.uniformMatrix4fv(locations[location], transpose, get_float_array(count, value))


cdef void __stdcall pyodideGetUniformfv(GLuint program, GLint location, GLfloat* params):
    params[0] = pyodide_gl.getUniform(programs[program], locations[location])


cdef void __stdcall pyodideGetUniformiv(GLuint program, GLint location, GLint* params):
    params[0] = pyodide_gl.getUniform(programs[program], locations[location])


cdef void __stdcall pyodideAttachShader(GLuint program, GLuint shader):
    pyodide_gl.attachShader(programs[program], shaders[shader])


cdef int __stdcall pyodideGetAttribLocation(GLuint program, const GLchar* name):
    cdef bytes py_name = name
    return pyodide_gl.getAttribLocation(programs[program], py_name)


cdef void __stdcall pyodideBindAttribLocation(GLuint program, GLuint index, const GLchar* name):
    cdef bytes py_name = name
    pyodide_gl.bindAttribLocation(programs[program], index, py_name)


cdef GLboolean __stdcall pyodideIsProgram(GLuint program):
    return pyodide_gl.isProgram(programs[program])


cdef void __stdcall pyodideDeleteProgram(GLuint program):
    pyodide_gl.deleteProgram(programs[program])
    del programs[program]


cdef GLuint __stdcall pyodideCreateProgram():
    program = pyodide_gl.createProgram()
    cdef GLuint program_id = id(program)
    shaders[program_id] = program
    return program_id


cdef void __stdcall pyodideDetachShader(GLuint program, GLuint shader):
    pyodide_gl.detachShader(programs[program], shaders[shader])


cdef void __stdcall pyodideLinkProgram(GLuint program):
    pyodide_gl.linkProgram(programs[program])


cdef void __stdcall pyodideUseProgram(GLuint program):
    pyodide_gl.useProgram(programs[program])


cdef void __stdcall pyodideValidateProgram(GLuint program):
    pyodide_gl.validateProgram(programs[program])


cdef GLuint __stdcall pyodideCreateShader(GLenum type):
    shader = pyodide_gl.createShader(type)
    cdef GLuint shader_id = id(shader)
    shaders[shader_id] = shader
    return shader_id


cdef void __stdcall pyodideShaderSource(GLuint shader, GLsizei count, const GLchar* const* string, const GLint* length):
    cdef bytes py_source
    if count < 1:
        return

    if length == NULL:
        py_source = string[0]
    else:
        py_source = string[0][:length[0]]
    pyodide_gl.shaderSource(shaders[shader], py_source)


cdef GLboolean __stdcall pyodideIsShader(GLuint shader):
    return pyodide_gl.isShader(shaders[shader])


cdef void __stdcall pyodideCompileShader(GLuint shader):
    pyodide_gl.compileShader(shaders[shader])


cdef void __stdcall pyodideDeleteShader(GLuint shader):
    pyodide_gl.deleteShader(shaders[shader])
    del shaders[shader]


cdef void __stdcall pyodideGetShaderiv(GLuint shader, GLenum pname, GLint* params):
    params[0] = pyodide_gl.getShaderParameter(shaders[shader], pname)


cdef void __stdcall pyodideGetShaderInfoLog(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog):
    cdef bytes py_str = pyodide_gl.getShaderInfoLog(shaders[shader])
    cdef char* c_str = py_str
    if len(py_str) >= bufsize:
        infolog[bufsize - 1] = NULL
        memcpy(infolog, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        strcpy(infolog, c_str)
        length[0] = len(py_str)


cdef void __stdcall pyodideGetShaderPrecisionFormat(GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision):
    res = pyodide_gl.getShaderPrecisionFormat(shadertype, precisiontype)
    range[0] = res.rangeMin
    range[1] = res.rangeMax
    precision[0] = res.precision


cdef void __stdcall pyodideGetShaderSource(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* source):
    cdef bytes py_str = pyodide_gl.getShaderSource(shaders[shader])
    cdef char* c_str = py_str
    if len(py_str) >= bufsize:
        source[bufsize - 1] = NULL
        memcpy(source, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        strcpy(source, c_str)
        length[0] = len(py_str)


cdef void __stdcall pyodideTexImage2DSize(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels, GLint size):
    pyodide_gl.texImage2D(target, level, internalformat, width, height, border, format, type, get_char_array(size, <GLchar*>pixels), 0)


cdef void __stdcall pyodideTexParameterf(GLenum target, GLenum pname, GLfloat param):
    pyodide_gl.texParameterf(target, pname, param)


cdef void __stdcall pyodideTexParameterfv(GLenum target, GLenum pname, GLfloat* params):
    params[0] = pyodide_gl.getTexParameter(target, pname)


cdef void __stdcall pyodideTexParameteri(GLenum target, GLenum pname, GLint param):
    pyodide_gl.texParameteri(target, pname, param)


cdef void __stdcall pyodideTexParameteriv(GLenum target, GLenum pname, GLint* params):
    params[0] = pyodide_gl.getTexParameter(target, pname)


cdef void __stdcall pyodideTexSubImage2DSize(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels, GLint size):
    pyodide_gl.texSubImage2D(target, level, xoffset, yoffset, width, height, format, type, get_char_array(size, <GLchar*>pixels), 0)


cdef void __stdcall pyodideHint(GLenum target, GLenum mode):
    pyodide_gl.hint(target, mode)


cdef void __stdcall pyodideRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height):
    pyodide_gl.renderbufferStorage(target, internalFormat, width, height)


cdef GLenum __stdcall pyodideCheckFramebufferStatus(GLenum target):
    return <GLenum>pyodide_gl.checkFramebufferStatus(target)


cdef void __stdcall pyodideGetBufferParameteriv(GLenum target, GLenum pname, GLint* params):
    params[0] = pyodide_gl.getBufferParameter(target, pname)


cdef void __stdcall pyodideGetFramebufferAttachmentParameteriv(GLenum target, GLenum attachment, GLenum pname, GLint* params):
    params[0] = pyodide_gl.getFramebufferAttachmentParameter(target, attachment, pname)


cdef void __stdcall pyodideGetRenderbufferParameteriv(GLenum target, GLenum pname, GLint* params):
    params[0] = pyodide_gl.getRenderbufferParameter(target, pname)


cdef void __stdcall pyodideGetTexParameterfv(GLenum target, GLenum pname, GLfloat* params):
    params[0] = pyodide_gl.getTexParameter(target, pname)


cdef void __stdcall pyodideGetTexParameteriv(GLenum target, GLenum pname, GLint* params):
    params[0] = pyodide_gl.getTexParameter(target, pname)


cdef void __stdcall pyodideFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer):
    pyodide_gl.framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer)


cdef void __stdcall pyodideFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level):
    pass
cdef void __stdcall pyodideGenerateMipmap(GLenum target):
    pass
cdef void __stdcall pyodideCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid* data):
    pass
cdef void __stdcall pyodideCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid* data):
    pass
cdef void __stdcall pyodideCopyTexImage2D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border):
    pass
cdef void __stdcall pyodideCopyTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height):
    pass
cdef void __stdcall pyodideBufferData(GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage):
    pass
cdef void __stdcall pyodideBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid* data):
    pass
cdef void __stdcall pyodideBindBuffer(GLenum target, GLuint buffer):
    pass
cdef void __stdcall pyodideBindFramebuffer(GLenum target, GLuint framebuffer):
    pass
cdef void __stdcall pyodideBindRenderbuffer(GLenum target, GLuint renderbuffer):
    pass
cdef void __stdcall pyodideBindTexture(GLenum target, GLuint texture):
    pass

cdef const GLubyte* __stdcall pyodideGetString(GLenum name):
    return empty_str


cdef GLenum __stdcall pyodideGetError():
    return GL_NO_ERROR
cdef GLboolean __stdcall pyodideIsBuffer(GLuint buffer):
    return GL_TRUE
cdef GLboolean __stdcall  pyodideIsEnabled(GLenum cap):
    return GL_TRUE
cdef GLboolean __stdcall pyodideIsFramebuffer(GLuint framebuffer):
    return GL_TRUE
cdef GLboolean __stdcall pyodideIsRenderbuffer(GLuint renderbuffer):
    return GL_TRUE
cdef GLboolean __stdcall pyodideIsTexture(GLuint texture):
    return GL_TRUE

cdef void __stdcall pyodideActiveTexture(GLenum texture):
    pass
cdef void __stdcall pyodideBlendColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha):
    pass
cdef void __stdcall pyodideBlendEquation( GLenum mode ):
    pass
cdef void __stdcall pyodideBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha):
    pass
cdef void __stdcall pyodideBlendFunc(GLenum sfactor, GLenum dfactor):
    pass
cdef void __stdcall pyodideBlendFuncSeparate(GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha):
    pass
cdef void __stdcall pyodideClear(GLbitfield mask):
    pass
cdef void __stdcall pyodideClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha):
    pass
# cdef void __stdcall pyodideClearDepthf(GLclampf depth):
#     pass
cdef void __stdcall pyodideClearStencil(GLint s):
    pass
cdef void __stdcall pyodideColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha):
    pass
cdef void __stdcall pyodideCullFace(GLenum mode):
    pass
cdef void __stdcall pyodideDeleteBuffers(GLsizei n, const GLuint* buffers):
    pass
cdef void __stdcall pyodideDeleteFramebuffers(GLsizei n, const GLuint* framebuffers):
    pass
cdef void __stdcall pyodideDeleteRenderbuffers(GLsizei n, const GLuint* renderbuffers):
    pass
cdef void __stdcall pyodideDeleteTextures(GLsizei n, const GLuint* textures):
    pass
cdef void __stdcall pyodideDepthFunc(GLenum func):
    pass
cdef void __stdcall pyodideDepthMask(GLboolean flag):
    pass
# cdef void __stdcall pyodideDepthRangef(GLclampf zNear, GLclampf zFar):
#     pass
cdef void __stdcall pyodideDisable(GLenum cap):
    pass
cdef void __stdcall pyodideDisableVertexAttribArray(GLuint index):
    pass
cdef void __stdcall pyodideDrawArrays(GLenum mode, GLint first, GLsizei count):
    pass
cdef void __stdcall pyodideDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid* indices):
    pass
cdef void __stdcall pyodideEnable(GLenum cap):
    pass
cdef void __stdcall pyodideEnableVertexAttribArray(GLuint index):
    pass
cdef void __stdcall pyodideFinish():
    pass
cdef void __stdcall pyodideFlush():
    pass
cdef void __stdcall pyodideFrontFace(GLenum mode):
    pass
cdef void __stdcall pyodideGenBuffers(GLsizei n, GLuint* buffers):
    pass
cdef void __stdcall pyodideGenFramebuffers(GLsizei n, GLuint* framebuffers):
    pass
cdef void __stdcall pyodideGenRenderbuffers(GLsizei n, GLuint* renderbuffers):
    pass
cdef void __stdcall pyodideGenTextures(GLsizei n, GLuint* textures):
    pass
cdef void __stdcall pyodideGetBooleanv(GLenum pname, GLboolean* params):
    pass
cdef void __stdcall pyodideGetFloatv(GLenum pname, GLfloat* params):
    pass
cdef void __stdcall pyodideGetIntegerv(GLenum pname, GLint* params):
    pass
cdef void __stdcall pyodideGetVertexAttribfv(GLuint index, GLenum pname, GLfloat* params):
    pass
cdef void __stdcall pyodideGetVertexAttribiv(GLuint index, GLenum pname, GLint* params):
    pass
cdef void __stdcall pyodideLineWidth(GLfloat width):
    pass
cdef void __stdcall pyodidePixelStorei(GLenum pname, GLint param):
    pass
cdef void __stdcall pyodidePolygonOffset(GLfloat factor, GLfloat units):
    pass
cdef void __stdcall pyodideReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels):
    pass
cdef void __stdcall pyodideSampleCoverage(GLclampf value, GLboolean invert):
    pass
cdef void __stdcall pyodideScissor(GLint x, GLint y, GLsizei width, GLsizei height):
    pass
cdef void __stdcall pyodideStencilFunc(GLenum func, GLint ref, GLuint mask):
    pass
cdef void __stdcall pyodideStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask):
    pass
cdef void __stdcall pyodideStencilMask(GLuint mask):
    pass
cdef void __stdcall pyodideStencilMaskSeparate(GLenum face, GLuint mask):
    pass
cdef void __stdcall pyodideStencilOp(GLenum fail, GLenum zfail, GLenum zpass):
    pass
cdef void __stdcall pyodideStencilOpSeparate(GLenum face, GLenum fail, GLenum zfail, GLenum zpass):
    pass
cdef void __stdcall pyodideVertexAttrib1f(GLuint indx, GLfloat x):
    pass
# cdef void __stdcall pyodideVertexAttrib1fv(GLuint indx, GLfloat* values):
#     pass
cdef void __stdcall pyodideVertexAttrib2f(GLuint indx, GLfloat x, GLfloat y):
    pass
# cdef void __stdcall pyodideVertexAttrib2fv(GLuint indx, GLfloat* values):
#     pass
cdef void __stdcall pyodideVertexAttrib3f(GLuint indx, GLfloat x, GLfloat y, GLfloat z):
    pass
# cdef void __stdcall pyodideVertexAttrib3fv(GLuint indx, GLfloat* values):
#     pass
cdef void __stdcall pyodideVertexAttrib4f(GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w):
    pass
# cdef void __stdcall pyodideVertexAttrib4fv(GLuint indx, GLfloat* values):
#     pass
cdef void __stdcall pyodideVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr):
    pass
cdef void __stdcall pyodideViewport(GLint x, GLint y, GLsizei width, GLsizei height):
    pass


def init_backend():
    cgl.glActiveTexture = pyodideActiveTexture
    cgl.glAttachShader = pyodideAttachShader
    cgl.glBindAttribLocation = pyodideBindAttribLocation
    cgl.glBindBuffer = pyodideBindBuffer
    cgl.glBindFramebuffer = pyodideBindFramebuffer
    cgl.glBindRenderbuffer = pyodideBindRenderbuffer
    cgl.glBindTexture = pyodideBindTexture
    cgl.glBlendColor = pyodideBlendColor
    cgl.glBlendEquation = pyodideBlendEquation
    cgl.glBlendEquationSeparate = pyodideBlendEquationSeparate
    cgl.glBlendFunc = pyodideBlendFunc
    cgl.glBlendFuncSeparate = pyodideBlendFuncSeparate
    cgl.glBufferData = pyodideBufferData
    cgl.glBufferSubData = pyodideBufferSubData
    cgl.glCheckFramebufferStatus = pyodideCheckFramebufferStatus
    cgl.glClear = pyodideClear
    cgl.glClearColor = pyodideClearColor
    cgl.glClearStencil = pyodideClearStencil
    cgl.glColorMask = pyodideColorMask
    cgl.glCompileShader = pyodideCompileShader
    cgl.glCompressedTexImage2D = pyodideCompressedTexImage2D
    cgl.glCompressedTexSubImage2D = pyodideCompressedTexSubImage2D
    cgl.glCopyTexImage2D = pyodideCopyTexImage2D
    cgl.glCopyTexSubImage2D = pyodideCopyTexSubImage2D
    cgl.glCreateProgram = pyodideCreateProgram
    cgl.glCreateShader = pyodideCreateShader
    cgl.glCullFace = pyodideCullFace
    cgl.glDeleteBuffers = pyodideDeleteBuffers
    cgl.glDeleteFramebuffers = pyodideDeleteFramebuffers
    cgl.glDeleteProgram = pyodideDeleteProgram
    cgl.glDeleteRenderbuffers = pyodideDeleteRenderbuffers
    cgl.glDeleteShader = pyodideDeleteShader
    cgl.glDeleteTextures = pyodideDeleteTextures
    cgl.glDepthFunc = pyodideDepthFunc
    cgl.glDepthMask = pyodideDepthMask
    cgl.glDetachShader = pyodideDetachShader
    cgl.glDisable = pyodideDisable
    cgl.glDisableVertexAttribArray = pyodideDisableVertexAttribArray
    cgl.glDrawArrays = pyodideDrawArrays
    cgl.glDrawElements = pyodideDrawElements
    cgl.glEnable = pyodideEnable
    cgl.glEnableVertexAttribArray = pyodideEnableVertexAttribArray
    cgl.glFinish = pyodideFinish
    cgl.glFlush = pyodideFlush
    cgl.glFramebufferRenderbuffer = pyodideFramebufferRenderbuffer
    cgl.glFramebufferTexture2D = pyodideFramebufferTexture2D
    cgl.glFrontFace = pyodideFrontFace
    cgl.glGenBuffers = pyodideGenBuffers
    cgl.glGenerateMipmap = pyodideGenerateMipmap
    cgl.glGenFramebuffers = pyodideGenFramebuffers
    cgl.glGenRenderbuffers = pyodideGenRenderbuffers
    cgl.glGenTextures = pyodideGenTextures
    cgl.glGetActiveAttrib = pyodideGetActiveAttrib
    cgl.glGetActiveUniform = pyodideGetActiveUniform
    cgl.glGetAttachedShaders = pyodideGetAttachedShaders
    cgl.glGetAttribLocation = pyodideGetAttribLocation
    cgl.glGetBooleanv = pyodideGetBooleanv
    cgl.glGetBufferParameteriv = pyodideGetBufferParameteriv
    cgl.glGetError = pyodideGetError
    cgl.glGetFloatv = pyodideGetFloatv
    cgl.glGetFramebufferAttachmentParameteriv = pyodideGetFramebufferAttachmentParameteriv
    cgl.glGetIntegerv = pyodideGetIntegerv
    cgl.glGetProgramInfoLog = pyodideGetProgramInfoLog
    cgl.glGetProgramiv = pyodideGetProgramiv
    cgl.glGetRenderbufferParameteriv = pyodideGetRenderbufferParameteriv
    cgl.glGetShaderInfoLog = pyodideGetShaderInfoLog
    cgl.glGetShaderiv = pyodideGetShaderiv
    cgl.glGetShaderSource = pyodideGetShaderSource
    cgl.glGetString = pyodideGetString
    cgl.glGetTexParameterfv = pyodideGetTexParameterfv
    cgl.glGetTexParameteriv = pyodideGetTexParameteriv
    cgl.glGetUniformfv = pyodideGetUniformfv
    cgl.glGetUniformiv = pyodideGetUniformiv
    cgl.glGetUniformLocation = pyodideGetUniformLocation
    cgl.glGetVertexAttribfv = pyodideGetVertexAttribfv
    cgl.glGetVertexAttribiv = pyodideGetVertexAttribiv
    cgl.glHint = pyodideHint
    cgl.glIsBuffer = pyodideIsBuffer
    cgl.glIsEnabled = pyodideIsEnabled
    cgl.glIsFramebuffer = pyodideIsFramebuffer
    cgl.glIsProgram = pyodideIsProgram
    cgl.glIsRenderbuffer = pyodideIsRenderbuffer
    cgl.glIsShader = pyodideIsShader
    cgl.glIsTexture = pyodideIsTexture
    cgl.glLineWidth = pyodideLineWidth
    cgl.glLinkProgram = pyodideLinkProgram
    cgl.glPixelStorei = pyodidePixelStorei
    cgl.glPolygonOffset = pyodidePolygonOffset
    cgl.glReadPixels = pyodideReadPixels
    cgl.glRenderbufferStorage = pyodideRenderbufferStorage
    cgl.glSampleCoverage = pyodideSampleCoverage
    cgl.glScissor = pyodideScissor
    cgl.glShaderBinary = pyodideShaderBinary
    cgl.glShaderSource = pyodideShaderSource
    cgl.glStencilFunc = pyodideStencilFunc
    cgl.glStencilFuncSeparate = pyodideStencilFuncSeparate
    cgl.glStencilMask = pyodideStencilMask
    cgl.glStencilMaskSeparate = pyodideStencilMaskSeparate
    cgl.glStencilOp = pyodideStencilOp
    cgl.glStencilOpSeparate = pyodideStencilOpSeparate
    cgl.glTexImage2D = pyodideTexImage2D
    cgl.glTexImage2DSize = pyodideTexImage2DSize
    cgl.glTexParameterf = pyodideTexParameterf
    cgl.glTexParameteri = pyodideTexParameteri
    cgl.glTexSubImage2D = pyodideTexSubImage2D
    cgl.glTexSubImage2DSize = pyodideTexSubImage2DSize
    cgl.glUniform1f = pyodideUniform1f
    cgl.glUniform1fv = pyodideUniform1fv
    cgl.glUniform1i = pyodideUniform1i
    cgl.glUniform1iv = pyodideUniform1iv
    cgl.glUniform2f = pyodideUniform2f
    cgl.glUniform2fv = pyodideUniform2fv
    cgl.glUniform2i = pyodideUniform2i
    cgl.glUniform2iv = pyodideUniform2iv
    cgl.glUniform3f = pyodideUniform3f
    cgl.glUniform3fv = pyodideUniform3fv
    cgl.glUniform3i = pyodideUniform3i
    cgl.glUniform3iv = pyodideUniform3iv
    cgl.glUniform4f = pyodideUniform4f
    cgl.glUniform4fv = pyodideUniform4fv
    cgl.glUniform4i = pyodideUniform4i
    cgl.glUniform4iv = pyodideUniform4iv
    cgl.glUniformMatrix4fv = pyodideUniformMatrix4fv
    cgl.glUseProgram = pyodideUseProgram
    cgl.glValidateProgram = pyodideValidateProgram
    cgl.glVertexAttrib1f = pyodideVertexAttrib1f
    cgl.glVertexAttrib2f = pyodideVertexAttrib2f
    cgl.glVertexAttrib3f = pyodideVertexAttrib3f
    cgl.glVertexAttrib4f = pyodideVertexAttrib4f
    cgl.glVertexAttribPointer = pyodideVertexAttribPointer
    cgl.glViewport = pyodideViewport
