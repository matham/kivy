"""
CGL/pyodide: GL backend implementation using Pyodide.
"""

include "../common.pxi"

from cpython cimport array as carray
from libc.string cimport memcpy, strcpy, strlen
import array
from kivy.logger import Logger
from kivy.graphics.cgl cimport *
from ..opengl import _GL_GET_SIZE
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


cdef inline carray.array get_float_array(GLsizei count, const GLfloat* v):
    cdef carray.array arr = array.array('f', [])
    carray.resize(arr, count)
    memcpy(arr.data.as_floats, v, count * sizeof(GLfloat))
    return arr


cdef inline carray.array get_int_array(GLsizei count, const GLint* v):
    cdef carray.array arr = array.array('i', [])
    carray.resize(arr, count)
    memcpy(arr.data.as_ints, v, count * sizeof(GLint))
    return arr


cdef inline carray.array get_char_array(GLsizei count, const GLchar* v):
    cdef carray.array arr = array.array('b', [])
    carray.resize(arr, count)
    memcpy(arr.data.as_chars, v, count * sizeof(GLchar))
    return arr


cdef dict locations = {}
cdef dict programs = {}
cdef dict shaders = {}
cdef dict textures = {}
cdef dict buffers = {}
cdef dict render_buffers = {}
cdef dict frame_buffers = {}
# never clear this or delete items from this dict
cdef dict gl_strings = {}


cdef void __stdcall pyodideReleaseShaderCompiler():
    pass
cdef void __stdcall pyodideShaderBinary(GLsizei n, const GLuint* shaders, GLenum binaryformat, const GLvoid* binary, GLsizei length) with gil:
    pass
cdef void __stdcall pyodideGetUniformfv(GLuint program, GLint location, GLfloat* params) with gil:
    Logger.error("glGetUniformfv called. It's not supported by pyodide. Please call glGetUniformfvSize instead")
cdef void __stdcall pyodideGetUniformiv(GLuint program, GLint location, GLint* params) with gil:
    Logger.error("glGetUniformiv called. It's not supported by pyodide. Please call glGetUniformivSize instead")
cdef void __stdcall pyodideTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels) with gil:
    Logger.error("glTexImage2D called. It's not supported by pyodide. Please call glTexImage2DSize instead")
cdef void __stdcall pyodideTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels) with gil:
    Logger.error("pyodideTexSubImage2D called. It's not supported by pyodide. Please call glTexSubImage2DSize instead")
cdef void __stdcall pyodideClearDepthf(GLclampf depth):
    pass
cdef void __stdcall pyodideDepthRangef(GLclampf zNear, GLclampf zFar):
    pass
cdef void __stdcall pyodideVertexAttrib1fv(GLuint indx, GLfloat* values):
    pass
cdef void __stdcall pyodideVertexAttrib2fv(GLuint indx, GLfloat* values):
    pass
cdef void __stdcall pyodideVertexAttrib3fv(GLuint indx, GLfloat* values):
    pass
cdef void __stdcall pyodideVertexAttrib4fv(GLuint indx, GLfloat* values):
    pass


cdef void __stdcall pyodideReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels) with gil:
    cdef carray.array arr = array.array('B', [])
    cdef int size
    assert format in (GL_RGB, GL_RGBA)
    assert type == GL_UNSIGNED_BYTE

    size = width * height * sizeof(GLubyte)
    if format == GL_RGB:
        size *= 3
    else:
        size *= 4

    carray.resize(arr, size)
    pyodide_gl.pixelStorei(GL_PACK_ALIGNMENT, 1)
    pyodide_gl.readPixels(x, y, width, height, format, type, arr)
    memcpy(pixels, arr.data.as_uchars, size)


cdef int __stdcall pyodideGetUniformLocation(GLuint program,  const GLchar* name) with gil:
    Logger.warn('before glGetUniformLocation')
    cdef int loc_id
    cdef bytes py_name = name
    loc = pyodide_gl.getUniformLocation(programs[program], py_name.decode('utf8'))
    loc_id = id(loc)
    locations[loc_id] = loc
    Logger.warn('after glGetUniformLocation')
    return loc_id


cdef void __stdcall pyodideUniform1f(GLint location, GLfloat x) with gil:
    Logger.warn('before glUniform1f')
    pyodide_gl.uniform1f(locations[location], x)
    Logger.warn('after glUniform1f')


cdef void __stdcall pyodideUniform1fv(GLint location, GLsizei count, const GLfloat* v) with gil:
    Logger.warn('before glUniform1fv')
    pyodide_gl.uniform1fv(locations[location], get_float_array(count, v))
    Logger.warn('after glUniform1fv')


cdef void __stdcall pyodideUniform1i(GLint location, GLint x) with gil:
    Logger.warn('before glUniform1i')
    pyodide_gl.uniform1i(locations[location], x)
    Logger.warn('after glUniform1i')


cdef void __stdcall pyodideUniform1iv(GLint location, GLsizei count, const GLint* v) with gil:
    Logger.warn('before glUniform1iv')
    pyodide_gl.uniform1iv(locations[location], get_int_array(count, v))
    Logger.warn('after glUniform1iv')


cdef void __stdcall pyodideUniform2f(GLint location, GLfloat x, GLfloat y) with gil:
    Logger.warn('before glUniform2f')
    pyodide_gl.uniform2f(locations[location], x, y)
    Logger.warn('after glUniform2f')


cdef void __stdcall pyodideUniform2fv(GLint location, GLsizei count, const GLfloat* v) with gil:
    Logger.warn('before glUniform2fv')
    pyodide_gl.uniform2fv(locations[location], get_float_array(count, v))
    Logger.warn('after glUniform2fv')


cdef void __stdcall pyodideUniform2i(GLint location, GLint x, GLint y) with gil:
    Logger.warn('before glUniform2i')
    pyodide_gl.uniform2i(locations[location], x, y)
    Logger.warn('after glUniform2i')


cdef void __stdcall pyodideUniform2iv(GLint location, GLsizei count, const GLint* v) with gil:
    Logger.warn('before glUniform2iv')
    pyodide_gl.uniform2iv(locations[location], get_int_array(count, v))
    Logger.warn('after glUniform2iv')


cdef void __stdcall pyodideUniform3f(GLint location, GLfloat x, GLfloat y, GLfloat z) with gil:
    Logger.warn('before glUniform3f')
    pyodide_gl.uniform3f(locations[location], x, y, z)
    Logger.warn('after glUniform3f')


cdef void __stdcall pyodideUniform3fv(GLint location, GLsizei count, const GLfloat* v) with gil:
    Logger.warn('before glUniform3fv')
    pyodide_gl.uniform3fv(locations[location], get_float_array(count, v))
    Logger.warn('after glUniform3fv')


cdef void __stdcall pyodideUniform3i(GLint location, GLint x, GLint y, GLint z) with gil:
    Logger.warn('before glUniform3i')
    pyodide_gl.uniform3i(locations[location], x, y, z)
    Logger.warn('after glUniform3i')


cdef void __stdcall pyodideUniform3iv(GLint location, GLsizei count, const GLint* v) with gil:
    Logger.warn('before glUniform3iv')
    pyodide_gl.uniform3iv(locations[location], get_int_array(count, v))
    Logger.warn('after glUniform3iv')


cdef void __stdcall pyodideUniform4f(GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w) with gil:
    Logger.warn('before glUniform4f')
    pyodide_gl.uniform4f(locations[location], x, y, z, w)
    Logger.warn('after glUniform4f')


cdef void __stdcall pyodideUniform4fv(GLint location, GLsizei count, const GLfloat* v) with gil:
    Logger.warn('before glUniform4fv')
    pyodide_gl.uniform4fv(locations[location], get_float_array(count, v))
    Logger.warn('after glUniform4fv')


cdef void __stdcall pyodideUniform4i(GLint location, GLint x, GLint y, GLint z, GLint w) with gil:
    Logger.warn('before glUniform4i')
    pyodide_gl.uniform4i(locations[location], x, y, z, w)
    Logger.warn('after glUniform4i')


cdef void __stdcall pyodideUniform4iv(GLint location, GLsizei count, const GLint* v) with gil:
    Logger.warn('before glUniform4iv')
    pyodide_gl.uniform4iv(locations[location], get_int_array(count, v))
    Logger.warn('after glUniform4iv')


cdef void __stdcall pyodideUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value) with gil:
    Logger.warn('before glUniformMatrix2fv')
    pyodide_gl.uniformMatrix2fv(locations[location], transpose, get_float_array(count, value))
    Logger.warn('after glUniformMatrix2fv')


cdef void __stdcall pyodideUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value) with gil:
    Logger.warn('before glUniformMatrix3fv')
    pyodide_gl.uniformMatrix3fv(locations[location], transpose, get_float_array(count, value))
    Logger.warn('after glUniformMatrix3fv')


cdef void __stdcall pyodideUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value) with gil:
    Logger.warn('before glUniformMatrix4fv')
    pyodide_gl.uniformMatrix4fv(locations[location], transpose, get_float_array(count, value))
    Logger.warn('after glUniformMatrix4fv')


cdef void __stdcall pyodideGetUniformfvSize(GLuint program, GLint location, GLfloat* params, GLint size) with gil:
    Logger.warn('before glGetUniformfvSize')
    cdef int i
    cdef GLfloat val
    res = pyodide_gl.getUniform(programs[program], locations[location])

    if size == 1:
        params[0] = res
    else:
        for i, val in enumerate(res):
            params[i] = val
    Logger.warn('after glGetUniformfvSize')


cdef void __stdcall pyodideGetUniformivSize(GLuint program, GLint location, GLint* params, GLint size) with gil:
    Logger.warn('before glGetUniformivSize')
    cdef int i
    cdef GLint val
    res = pyodide_gl.getUniform(programs[program], locations[location])

    if size == 1:
        params[0] = res
    else:
        for i, val in enumerate(res):
            params[i] = val
    Logger.warn('after glGetUniformivSize')


cdef void __stdcall pyodideAttachShader(GLuint program, GLuint shader) with gil:
    Logger.warn('before glAttachShader')
    pyodide_gl.attachShader(programs[program], shaders[shader])
    Logger.warn('after glAttachShader')


cdef int __stdcall pyodideGetAttribLocation(GLuint program, const GLchar* name) with gil:
    Logger.warn('before glGetAttribLocation')
    cdef bytes py_name = name
    res = pyodide_gl.getAttribLocation(programs[program], py_name.decode('utf8'))
    Logger.warn('after glGetAttribLocation')
    return res


cdef void __stdcall pyodideBindAttribLocation(GLuint program, GLuint index, const GLchar* name) with gil:
    Logger.warn('before glBindAttribLocation')
    cdef bytes py_name = name
    pyodide_gl.bindAttribLocation(programs[program], index, py_name.decode('utf8'))
    Logger.warn('after glBindAttribLocation')


cdef GLboolean __stdcall pyodideIsProgram(GLuint program) with gil:
    Logger.warn('before glIsProgram')
    res = pyodide_gl.isProgram(programs[program])
    Logger.warn('after glIsProgram')
    return res


cdef void __stdcall pyodideDeleteProgram(GLuint program) with gil:
    Logger.warn('before glDeleteProgram')
    pyodide_gl.deleteProgram(programs[program])
    del programs[program]
    Logger.warn('after glDeleteProgram')


cdef GLuint __stdcall pyodideCreateProgram() with gil:
    Logger.warn('before glCreateProgram')
    cdef GLuint program_id
    program = pyodide_gl.createProgram()
    program_id = id(program)
    programs[program_id] = program
    res = program_id
    Logger.warn('after glCreateProgram')
    return res


cdef void __stdcall pyodideDetachShader(GLuint program, GLuint shader) with gil:
    Logger.warn('before glDetachShader')
    pyodide_gl.detachShader(programs[program], shaders[shader])
    Logger.warn('after glDetachShader')


cdef void __stdcall pyodideLinkProgram(GLuint program) with gil:
    Logger.warn('before glLinkProgram')
    pyodide_gl.linkProgram(programs[program])
    Logger.warn('after glLinkProgram')


cdef void __stdcall pyodideUseProgram(GLuint program) with gil:
    Logger.warn('before glUseProgram')
    pyodide_gl.useProgram(programs[program])
    Logger.warn('after glUseProgram')


cdef void __stdcall pyodideValidateProgram(GLuint program) with gil:
    Logger.warn('before glValidateProgram')
    pyodide_gl.validateProgram(programs[program])
    Logger.warn('after glValidateProgram')


cdef void __stdcall pyodideGetActiveAttrib(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name) with gil:
    Logger.warn('before glGetActiveAttrib')
    cdef bytes py_str
    cdef char* c_str
    info = pyodide_gl.getActiveAttrib(programs[program], index)
    size[0] = info.size
    type[0] = info.type

    py_str = info.name.encode('utf8')
    c_str = py_str
    if len(py_str) >= bufsize:
        name[bufsize - 1] = 0
        memcpy(name, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        length[0] = len(py_str)
        memcpy(name, c_str, length[0])
        name[length[0]] = 0
    Logger.warn('after glGetActiveAttrib')


cdef void __stdcall pyodideGetActiveUniform(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name) with gil:
    Logger.warn('before glGetActiveUniform')
    cdef bytes py_str
    cdef char* c_str
    info = pyodide_gl.getActiveUniform(programs[program], index)
    size[0] = info.size
    type[0] = info.type

    py_str = info.name.encode('utf8')
    c_str = py_str
    if len(py_str) >= bufsize:
        name[bufsize - 1] = 0
        memcpy(name, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        length[0] = len(py_str)
        memcpy(name, c_str, length[0])
        name[length[0]] = 0
    Logger.warn('after glGetActiveUniform')


cdef void __stdcall pyodideGetAttachedShaders(GLuint program, GLsizei maxcount, GLsizei* count, GLuint* shader_ret_list) with gil:
    Logger.warn('before glGetAttachedShaders')
    shaders_list = pyodide_gl.getAttachedShaders(programs[program])
    count[0] = min(len(shaders_list), maxcount)
    for i in range(count[0]):
        shader = shaders_list[i]
        shader_ret_list[i] = id(shader)

    if len(shaders_list) > maxcount:
        Logger.error('pyodideGetAttachedShaders maxcount is too small to contain all the shaders')
    Logger.warn('after glGetAttachedShaders')


cdef void __stdcall pyodideGetProgramiv(GLuint program, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetProgramiv')
    params[0] = pyodide_gl.getProgramParameter(programs[program], pname)
    Logger.warn('after glGetProgramiv')


cdef void __stdcall pyodideGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog) with gil:
    Logger.warn('before glGetProgramInfoLog')
    cdef bytes py_str
    cdef char* c_str
    py_str = pyodide_gl.getProgramInfoLog(programs[program]).encode('utf8')
    c_str = py_str
    if len(py_str) >= bufsize:
        infolog[bufsize - 1] = 0
        memcpy(infolog, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        length[0] = len(py_str)
        memcpy(infolog, c_str, length[0])
        infolog[length[0]] = 0
    Logger.warn('after glGetProgramInfoLog')


cdef GLuint __stdcall pyodideCreateShader(GLenum type) with gil:
    Logger.warn('before glCreateShader')
    cdef GLuint shader_id
    shader = pyodide_gl.createShader(type)
    shader_id = id(shader)
    shaders[shader_id] = shader
    Logger.warn('after glCreateShader')
    return shader_id


cdef void __stdcall pyodideShaderSource(
        GLuint shader, GLsizei count, const GLchar* const* string,
        const GLint* length) with gil:
    Logger.warn('before glShaderSource')
    cdef bytes py_source
    if count < 1:
        Logger.error('pyodideShaderSource called with an empty array')
        Logger.warn('after glShaderSource')
        return
    elif count > 1:
        Logger.error(
            'pyodideShaderSource called with an array of more than 1 '
            'element, using only first element')

    if length == NULL:
        py_source = string[0]
    else:
        py_source = string[0][:length[0]]
    pyodide_gl.shaderSource(shaders[shader], py_source.decode('utf8'))
    Logger.warn('after glShaderSource')


cdef GLboolean __stdcall pyodideIsShader(GLuint shader) with gil:
    Logger.warn('before glIsShader')
    res = pyodide_gl.isShader(shaders[shader])
    Logger.warn('after glIsShader')
    return res


cdef void __stdcall pyodideCompileShader(GLuint shader) with gil:
    Logger.warn('before glCompileShader')
    pyodide_gl.compileShader(shaders[shader])
    Logger.warn('after glCompileShader')


cdef void __stdcall pyodideDeleteShader(GLuint shader) with gil:
    Logger.warn('before glDeleteShader')
    pyodide_gl.deleteShader(shaders[shader])
    del shaders[shader]
    Logger.warn('after glDeleteShader')


cdef void __stdcall pyodideGetShaderiv(GLuint shader, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetShaderiv')
    params[0] = pyodide_gl.getShaderParameter(shaders[shader], pname)
    Logger.warn('after glGetShaderiv')


cdef void __stdcall pyodideGetShaderInfoLog(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog) with gil:
    Logger.warn('before glGetShaderInfoLog')
    cdef bytes py_str
    cdef char* c_str
    py_str = pyodide_gl.getShaderInfoLog(shaders[shader]).encode('utf8')
    c_str = py_str
    if len(py_str) >= bufsize:
        infolog[bufsize - 1] = 0
        memcpy(infolog, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        length[0] = len(py_str)
        memcpy(infolog, c_str, length[0])
        infolog[length[0]] = 0
    Logger.warn('after glGetShaderInfoLog')


cdef void __stdcall pyodideGetShaderPrecisionFormat(GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision) with gil:
    Logger.warn('before glGetShaderPrecisionFormat')
    res = pyodide_gl.getShaderPrecisionFormat(shadertype, precisiontype)
    range[0] = res.rangeMin
    range[1] = res.rangeMax
    precision[0] = res.precision
    Logger.warn('after glGetShaderPrecisionFormat')


cdef void __stdcall pyodideGetShaderSource(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* source) with gil:
    Logger.warn('before glGetShaderSource')
    cdef bytes py_str
    cdef char* c_str
    py_str = pyodide_gl.getShaderSource(shaders[shader]).encode('utf8')
    c_str = py_str
    if len(py_str) >= bufsize:
        source[bufsize - 1] = 0
        memcpy(source, c_str, bufsize - 1)
        length[0] = bufsize - 1
    else:
        length[0] = len(py_str)
        memcpy(source, c_str, length[0])
        source[length[0]] = 0
    Logger.warn('after glGetShaderSource')


cdef void __stdcall pyodideTexImage2DSize(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels, GLint size) with gil:
    Logger.warn('before glTexImage2DSize')
    pyodide_gl.texImage2D(target, level, internalformat, width, height, border, format, type, get_char_array(size, <GLchar*>pixels), 0)
    Logger.warn('after glTexImage2DSize')


cdef void __stdcall pyodideTexParameterf(GLenum target, GLenum pname, GLfloat param) with gil:
    Logger.warn('before glTexParameterf')
    pyodide_gl.texParameterf(target, pname, param)
    Logger.warn('after glTexParameterf')


cdef void __stdcall pyodideTexParameterfv(GLenum target, GLenum pname, GLfloat* params) with gil:
    Logger.warn('before glTexParameterfv')
    params[0] = pyodide_gl.getTexParameter(target, pname)
    Logger.warn('after glTexParameterfv')


cdef void __stdcall pyodideTexParameteri(GLenum target, GLenum pname, GLint param) with gil:
    Logger.warn('before glTexParameteri')
    pyodide_gl.texParameteri(target, pname, param)
    Logger.warn('after glTexParameteri')


cdef void __stdcall pyodideTexParameteriv(GLenum target, GLenum pname, GLint* params) with gil:
    Logger.warn('before glTexParameteriv')
    params[0] = pyodide_gl.getTexParameter(target, pname)
    Logger.warn('after glTexParameteriv')


cdef void __stdcall pyodideTexSubImage2DSize(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels, GLint size) with gil:
    Logger.warn('before glTexSubImage2DSize')
    pyodide_gl.texSubImage2D(target, level, xoffset, yoffset, width, height, format, type, get_char_array(size, <GLchar*>pixels), 0)
    Logger.warn('after glTexSubImage2DSize')


cdef void __stdcall pyodideHint(GLenum target, GLenum mode) with gil:
    Logger.warn('before glHint')
    pyodide_gl.hint(target, mode)
    Logger.warn('after glHint')


cdef void __stdcall pyodideRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height) with gil:
    Logger.warn('before glRenderbufferStorage')
    pyodide_gl.renderbufferStorage(target, internalformat, width, height)
    Logger.warn('after glRenderbufferStorage')


cdef GLenum __stdcall pyodideCheckFramebufferStatus(GLenum target) with gil:
    Logger.warn('before glCheckFramebufferStatus')
    res = <GLenum>pyodide_gl.checkFramebufferStatus(target)
    Logger.warn('after glCheckFramebufferStatus')
    return res


cdef void __stdcall pyodideGetBufferParameteriv(GLenum target, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetBufferParameteriv')
    params[0] = pyodide_gl.getBufferParameter(target, pname)
    Logger.warn('after glGetBufferParameteriv')


cdef void __stdcall pyodideGetFramebufferAttachmentParameteriv(GLenum target, GLenum attachment, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetFramebufferAttachmentParameteriv')
    if pname == GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME:
        params[0] = id(pyodide_gl.getFramebufferAttachmentParameter(target, attachment, pname))
    else:
        params[0] = pyodide_gl.getFramebufferAttachmentParameter(target, attachment, pname)
    Logger.warn('after glGetFramebufferAttachmentParameteriv')


cdef void __stdcall pyodideGetRenderbufferParameteriv(GLenum target, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetRenderbufferParameteriv')
    params[0] = pyodide_gl.getRenderbufferParameter(target, pname)
    Logger.warn('after glGetRenderbufferParameteriv')


cdef void __stdcall pyodideGetTexParameterfv(GLenum target, GLenum pname, GLfloat* params) with gil:
    Logger.warn('before glGetTexParameterfv')
    params[0] = pyodide_gl.getTexParameter(target, pname)
    Logger.warn('after glGetTexParameterfv')


cdef void __stdcall pyodideGetTexParameteriv(GLenum target, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetTexParameteriv')
    params[0] = pyodide_gl.getTexParameter(target, pname)
    Logger.warn('after glGetTexParameteriv')


cdef void __stdcall pyodideGenerateMipmap(GLenum target) with gil:
    Logger.warn('before glGenerateMipmap')
    pyodide_gl.generateMipmap(target)
    Logger.warn('after glGenerateMipmap')


cdef void __stdcall pyodideCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid* data) with gil:
    Logger.warn('before glCompressedTexImage2D')
    pyodide_gl.compressedTexImage2D(target, level, internalformat, width, height, border, get_char_array(imageSize, <const GLchar*>data))
    Logger.warn('after glCompressedTexImage2D')


cdef void __stdcall pyodideCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid* data) with gil:
    Logger.warn('before glCompressedTexSubImage2D')
    pyodide_gl.compressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, get_char_array(imageSize, <const GLchar*>data))
    Logger.warn('after glCompressedTexSubImage2D')


cdef void __stdcall pyodideCopyTexImage2D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border) with gil:
    Logger.warn('before glCopyTexImage2D')
    pyodide_gl.copyTexImage2D(target, level, internalformat, x, y, width, height, border)
    Logger.warn('after glCopyTexImage2D')


cdef void __stdcall pyodideCopyTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height) with gil:
    Logger.warn('before glCopyTexSubImage2D')
    pyodide_gl.copyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height)
    Logger.warn('after glCopyTexSubImage2D')


cdef void __stdcall pyodideFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer) with gil:
    Logger.warn('before glFramebufferRenderbuffer')
    pyodide_gl.framebufferRenderbuffer(target, attachment, renderbuffertarget, render_buffers[renderbuffer])
    Logger.warn('after glFramebufferRenderbuffer')


cdef void __stdcall pyodideBufferData(GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage) with gil:
    Logger.warn('before glBufferData')
    pyodide_gl.bufferData(target, get_char_array(size, <const GLchar*>data), usage)
    Logger.warn('after glBufferData')


cdef void __stdcall pyodideBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid* data) with gil:
    Logger.warn('before glBufferSubData')
    pyodide_gl.bufferSubData(target, offset, get_char_array(size, <const GLchar*>data))
    Logger.warn('after glBufferSubData')


cdef void __stdcall pyodideBindBuffer(GLenum target, GLuint buffer) with gil:
    Logger.warn('before glBindBuffer')
    pyodide_gl.bindBuffer(target, buffers[buffer])
    Logger.warn('after glBindBuffer')


cdef void __stdcall pyodideBindFramebuffer(GLenum target, GLuint framebuffer) with gil:
    Logger.warn('before glBindFramebuffer')
    pyodide_gl.bindFramebuffer(target, frame_buffers[framebuffer])
    Logger.warn('after glBindFramebuffer')


cdef void __stdcall pyodideBindRenderbuffer(GLenum target, GLuint renderbuffer) with gil:
    Logger.warn('before glBindRenderbuffer')
    pyodide_gl.bindRenderbuffer(target, render_buffers[renderbuffer])
    Logger.warn('after glBindRenderbuffer')


cdef void __stdcall pyodideFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level) with gil:
    Logger.warn('before glFramebufferTexture2D')
    pyodide_gl.framebufferTexture2D(target, attachment, textarget, textures[texture], level)
    Logger.warn('after glFramebufferTexture2D')


cdef void __stdcall pyodideBindTexture(GLenum target, GLuint texture) with gil:
    Logger.warn('before glBindTexture')
    pyodide_gl.bindTexture(target, textures[texture])
    Logger.warn('after glBindTexture')


cdef void __stdcall pyodideGenTextures(GLsizei n, GLuint* texture_list) with gil:
    Logger.warn('before glGenTextures')
    cdef GLuint tex_id
    cdef int i
    for i in range(n):
        tex = pyodide_gl.createTexture()
        tex_id = id(tex)
        texture_list[i] = tex_id
        textures[tex_id] = tex
    Logger.warn('after glGenTextures')


cdef void __stdcall pyodideDeleteTextures(GLsizei n, const GLuint* texture_list) with gil:
    Logger.warn('before glDeleteTextures')
    cdef int i
    for i in range(n):
        pyodide_gl.deleteTexture(textures[texture_list[i]])
        del textures[texture_list[i]]
    Logger.warn('after glDeleteTextures')


cdef GLboolean __stdcall pyodideIsTexture(GLuint texture) with gil:
    Logger.warn('before glIsTexture')
    res = pyodide_gl.isTexture(textures[texture])
    Logger.warn('after glIsTexture')
    return res


cdef void __stdcall pyodideActiveTexture(GLenum texture) with gil:
    Logger.warn('before glActiveTexture')
    pyodide_gl.activeTexture(texture)
    Logger.warn('after glActiveTexture')


cdef GLboolean __stdcall pyodideIsBuffer(GLuint buffer) with gil:
    Logger.warn('before glIsBuffer')
    res = pyodide_gl.isBuffer(buffers[buffer])
    Logger.warn('after glIsBuffer')
    return res


cdef GLboolean __stdcall pyodideIsFramebuffer(GLuint framebuffer) with gil:
    Logger.warn('before glIsFramebuffer')
    return pyodide_gl.isFramebuffer(frame_buffers[framebuffer])
    Logger.warn('after glIsFramebuffer')


cdef GLboolean __stdcall pyodideIsRenderbuffer(GLuint renderbuffer) with gil:
    Logger.warn('before glIsRenderbuffer')
    res = pyodide_gl.isRenderbuffer(render_buffers[renderbuffer])
    Logger.warn('after glIsRenderbuffer')
    return res


cdef void __stdcall pyodideDeleteBuffers(GLsizei n, const GLuint* buffer_list) with gil:
    Logger.warn('before glDeleteBuffers')
    cdef int i
    for i in range(n):
        pyodide_gl.deleteBuffer(buffers[buffer_list[i]])
        del buffers[buffer_list[i]]
    Logger.warn('after glDeleteBuffers')


cdef void __stdcall pyodideDeleteFramebuffers(GLsizei n, const GLuint* framebuffer_list) with gil:
    Logger.warn('before glDeleteFramebuffers')
    cdef int i
    for i in range(n):
        pyodide_gl.deleteFramebuffer(frame_buffers[framebuffer_list[i]])
        del frame_buffers[framebuffer_list[i]]
    Logger.warn('after glDeleteFramebuffers')


cdef void __stdcall pyodideDeleteRenderbuffers(GLsizei n, const GLuint* renderbuffer_list) with gil:
    Logger.warn('before glDeleteRenderbuffers')
    cdef int i
    for i in range(n):
        pyodide_gl.deleteRenderbuffer(render_buffers[renderbuffer_list[i]])
        del render_buffers[renderbuffer_list[i]]
    Logger.warn('after glDeleteRenderbuffers')


cdef void __stdcall pyodideGenBuffers(GLsizei n, GLuint* buffer_list) with gil:
    Logger.warn('before glGenBuffers')
    cdef GLuint buf_id
    cdef int i
    for i in range(n):
        buf = pyodide_gl.createBuffer()
        buf_id = id(buf)
        buffer_list[i] = buf_id
        buffers[buf_id] = buf
    Logger.warn('after glGenBuffers')


cdef void __stdcall pyodideGenFramebuffers(GLsizei n, GLuint* framebuffer_list) with gil:
    Logger.warn('before glGenFramebuffers')
    cdef GLuint buf_id
    cdef int i
    for i in range(n):
        buf = pyodide_gl.createFramebuffer()
        buf_id = id(buf)
        framebuffer_list[i] = buf_id
        frame_buffers[buf_id] = buf
    Logger.warn('after glGenFramebuffers')


cdef void __stdcall pyodideGenRenderbuffers(GLsizei n, GLuint* renderbuffer_list) with gil:
    Logger.warn('before glGenRenderbuffers')
    cdef GLuint buf_id
    cdef int i
    for i in range(n):
        buf = pyodide_gl.createRenderbuffer()
        buf_id = id(buf)
        renderbuffer_list[i] = buf_id
        render_buffers[buf_id] = buf
    Logger.warn('after glGenRenderbuffers')


cdef const GLubyte* __stdcall pyodideGetString(GLenum name) with gil:
    Logger.warn('before glGetString')
    cdef char* val_c
    cdef bytes val = pyodide_gl.getParameter(name).encode('utf8')
    if val in gl_strings:
        # it's the same string, but we have make sure it's the same object so
        # we can share the pointer
        val = gl_strings[val]
    else:
        gl_strings[val] = val

    # pointers are alive for the duration of the object so we can safely return it
    val_c = val
    Logger.warn('after glGetString')
    return <const GLubyte*>val_c


cdef GLenum __stdcall pyodideGetError() with gil:
    Logger.warn('before glGetError')
    res = pyodide_gl.getError()
    Logger.warn('after glGetError')
    return res


cdef GLboolean __stdcall pyodideIsEnabled(GLenum cap) with gil:
    Logger.warn('before glIsEnabled')
    res = pyodide_gl.isEnabled(cap)
    Logger.warn('after glIsEnabled')
    return res


cdef void __stdcall pyodideBlendColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) with gil:
    Logger.warn('before glBlendColor')
    pyodide_gl.blendColor(red, green, blue, alpha)
    Logger.warn('after glBlendColor')


cdef void __stdcall pyodideBlendEquation(GLenum mode) with gil:
    Logger.warn('before glBlendEquation')
    pyodide_gl.blendEquation(mode)
    Logger.warn('after glBlendEquation')


cdef void __stdcall pyodideBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha) with gil:
    Logger.warn('before glBlendEquationSeparate')
    pyodide_gl.blendEquationSeparate(modeRGB, modeAlpha)
    Logger.warn('after glBlendEquationSeparate')


cdef void __stdcall pyodideBlendFunc(GLenum sfactor, GLenum dfactor) with gil:
    Logger.warn('before glBlendFunc')
    pyodide_gl.blendFunc(sfactor, dfactor)
    Logger.warn('after glBlendFunc')


cdef void __stdcall pyodideBlendFuncSeparate(GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha) with gil:
    Logger.warn('before glBlendFuncSeparate')
    pyodide_gl.blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha)
    Logger.warn('after glBlendFuncSeparate')


cdef void __stdcall pyodideClear(GLbitfield mask) with gil:
    Logger.warn('before glClear')
    pyodide_gl.clear(mask)
    Logger.warn('after glClear')


cdef void __stdcall pyodideClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) with gil:
    Logger.warn('before glClearColor')
    pyodide_gl.clearColor(red, green, blue, alpha)
    Logger.warn('after glClearColor')


cdef void __stdcall pyodideClearStencil(GLint s) with gil:
    Logger.warn('before glClearStencil')
    pyodide_gl.clearStencil(s)
    Logger.warn('after glClearStencil')


cdef void __stdcall pyodideColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) with gil:
    Logger.warn('before glColorMask')
    pyodide_gl.colorMask(red, green, blue, alpha)
    Logger.warn('after glColorMask')


cdef void __stdcall pyodideCullFace(GLenum mode) with gil:
    Logger.warn('before glCullFace')
    pyodide_gl.cullFace(mode)
    Logger.warn('after glCullFace')


cdef void __stdcall pyodideDepthFunc(GLenum func) with gil:
    Logger.warn('before glDepthFunc')
    pyodide_gl.depthFunc(func)
    Logger.warn('after glDepthFunc')


cdef void __stdcall pyodideDepthMask(GLboolean flag) with gil:
    Logger.warn('before glDepthMask')
    pyodide_gl.depthMask(flag)
    Logger.warn('after glDepthMask')


cdef void __stdcall pyodideDisable(GLenum cap) with gil:
    Logger.warn('before glDisable')
    pyodide_gl.disable(cap)
    Logger.warn('after glDisable')


cdef void __stdcall pyodideDisableVertexAttribArray(GLuint index) with gil:
    Logger.warn('before glDisableVertexAttribArray')
    pyodide_gl.disableVertexAttribArray(index)
    Logger.warn('after glDisableVertexAttribArray')


cdef void __stdcall pyodideDrawArrays(GLenum mode, GLint first, GLsizei count) with gil:
    Logger.warn('before glDrawArrays')
    pyodide_gl.drawArrays(mode, first, count)
    Logger.warn('after glDrawArrays')


cdef void __stdcall pyodideDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid* indices) with gil:
    Logger.warn('before glDrawElements')
    pyodide_gl.drawElements(mode, count, type, <GLintptr>indices)
    Logger.warn('after glDrawElements')


cdef void __stdcall pyodideEnable(GLenum cap) with gil:
    Logger.warn('before glEnable')
    pyodide_gl.enable(cap)
    Logger.warn('after glEnable')


cdef void __stdcall pyodideEnableVertexAttribArray(GLuint index) with gil:
    Logger.warn('before glEnableVertexAttribArray')
    pyodide_gl.enableVertexAttribArray(index)
    Logger.warn('after glEnableVertexAttribArray')


cdef void __stdcall pyodideFinish() with gil:
    Logger.warn('before glFinish')
    pyodide_gl.finish()
    Logger.warn('after glFinish')


cdef void __stdcall pyodideFlush() with gil:
    Logger.warn('before glFlush')
    pyodide_gl.flush()
    Logger.warn('after glFlush')


cdef void __stdcall pyodideFrontFace(GLenum mode) with gil:
    Logger.warn('before glFrontFace')
    pyodide_gl.frontFace(mode)
    Logger.warn('after glFrontFace')


cdef void __stdcall pyodideGetBooleanv(GLenum pname, GLboolean* params) with gil:
    Logger.warn('before glGetBooleanv')
    cdef GLboolean val
    cdef int i
    if pname in (GL_ARRAY_BUFFER_BINDING, GL_CURRENT_PROGRAM,
            GL_ELEMENT_ARRAY_BUFFER_BINDING, GL_FRAMEBUFFER_BINDING,
            GL_RENDERBUFFER_BINDING, GL_TEXTURE_BINDING_2D,
            GL_TEXTURE_BINDING_CUBE_MAP):
        if _GL_GET_SIZE[pname] != 1:
            raise ValueError
        params[0] = id(pyodide_gl.getParameter(pname))
    else:
        res = pyodide_gl.getParameter(pname)
        if _GL_GET_SIZE[pname] != len(res):
            raise ValueError
        for i, val in enumerate(res):
            params[i] = val
    Logger.warn('after glGetBooleanv')


cdef void __stdcall pyodideGetFloatv(GLenum pname, GLfloat* params) with gil:
    Logger.warn('before glGetFloatv')
    cdef GLfloat val
    cdef int i
    if pname in (GL_ARRAY_BUFFER_BINDING, GL_CURRENT_PROGRAM,
            GL_ELEMENT_ARRAY_BUFFER_BINDING, GL_FRAMEBUFFER_BINDING,
            GL_RENDERBUFFER_BINDING, GL_TEXTURE_BINDING_2D,
            GL_TEXTURE_BINDING_CUBE_MAP):
        if _GL_GET_SIZE[pname] != 1:
            raise ValueError
        params[0] = id(pyodide_gl.getParameter(pname))
    else:
        res = pyodide_gl.getParameter(pname)
        if _GL_GET_SIZE[pname] != len(res):
            raise ValueError
        for i, val in enumerate(res):
            params[i] = val
    Logger.warn('after glGetFloatv')


cdef void __stdcall pyodideGetIntegerv(GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetIntegerv {}'.format(pname))
    cdef GLint val
    cdef int i
    if pname in (GL_ARRAY_BUFFER_BINDING, GL_CURRENT_PROGRAM,
            GL_ELEMENT_ARRAY_BUFFER_BINDING, GL_FRAMEBUFFER_BINDING,
            GL_RENDERBUFFER_BINDING, GL_TEXTURE_BINDING_2D,
            GL_TEXTURE_BINDING_CUBE_MAP):
        if _GL_GET_SIZE[pname] != 1:
            raise ValueError
        params[0] = id(pyodide_gl.getParameter(pname))
    else:
        res = pyodide_gl.getParameter(pname)
        if _GL_GET_SIZE[pname] != len(res):
            raise ValueError
        for i, val in enumerate(res):
            params[i] = val
    Logger.warn('after glGetIntegerv')


cdef void __stdcall pyodideGetVertexAttribfv(GLuint index, GLenum pname, GLfloat* params) with gil:
    Logger.warn('before glGetVertexAttribfv')
    cdef GLfloat fval
    cdef int i
    if pname == GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING:
        params[0] = id(pyodide_gl.getVertexAttrib(index, pname))
    elif pname == GL_CURRENT_VERTEX_ATTRIB:
        for i, fval in enumerate(pyodide_gl.getVertexAttrib(index, pname)):
            params[i] = fval
    else:
        params[0] = pyodide_gl.getVertexAttrib(index, pname)
    Logger.warn('after glGetVertexAttribfv')


cdef void __stdcall pyodideGetVertexAttribiv(GLuint index, GLenum pname, GLint* params) with gil:
    Logger.warn('before glGetVertexAttribiv')
    if pname == GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING:
        params[0] = id(pyodide_gl.getVertexAttrib(index, pname))
    elif pname == GL_CURRENT_VERTEX_ATTRIB:
        raise ValueError('Call glGetVertexAttribfv instead of glGetVertexAttribiv for GL_CURRENT_VERTEX_ATTRIB')
    else:
        params[0] = pyodide_gl.getVertexAttrib(index, pname)
    Logger.warn('after glGetVertexAttribiv')


cdef void __stdcall pyodideLineWidth(GLfloat width) with gil:
    Logger.warn('before glLineWidth')
    pyodide_gl.lineWidth(width)
    Logger.warn('after glLineWidth')


cdef void __stdcall pyodidePixelStorei(GLenum pname, GLint param) with gil:
    Logger.warn('before glPixelStorei')
    pyodide_gl.pixelStorei(pname, param)
    Logger.warn('after glPixelStorei')


cdef void __stdcall pyodidePolygonOffset(GLfloat factor, GLfloat units) with gil:
    Logger.warn('before glPolygonOffset')
    pyodide_gl.polygonOffset(factor, units)
    Logger.warn('after glPolygonOffset')


cdef void __stdcall pyodideSampleCoverage(GLclampf value, GLboolean invert) with gil:
    Logger.warn('before glSampleCoverage')
    pyodide_gl.sampleCoverage(value, invert)
    Logger.warn('after glSampleCoverage')


cdef void __stdcall pyodideScissor(GLint x, GLint y, GLsizei width, GLsizei height) with gil:
    Logger.warn('before glScissor')
    pyodide_gl.scissor(x, y, width, height)
    Logger.warn('after glScissor')


cdef void __stdcall pyodideStencilFunc(GLenum func, GLint ref, GLuint mask) with gil:
    Logger.warn('before glStencilFunc')
    pyodide_gl.stencilFunc(func, ref, mask)
    Logger.warn('after glStencilFunc')


cdef void __stdcall pyodideStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask) with gil:
    Logger.warn('before glStencilFuncSeparate')
    pyodide_gl.stencilFuncSeparate(face, func, ref, mask)
    Logger.warn('after glStencilFuncSeparate')


cdef void __stdcall pyodideStencilMask(GLuint mask) with gil:
    Logger.warn('before glStencilMask')
    pyodide_gl.stencilMask(mask)
    Logger.warn('after glStencilMask')


cdef void __stdcall pyodideStencilMaskSeparate(GLenum face, GLuint mask) with gil:
    Logger.warn('before glStencilMaskSeparate')
    pyodide_gl.stencilMaskSeparate(face, mask)
    Logger.warn('after glStencilMaskSeparate')


cdef void __stdcall pyodideStencilOp(GLenum fail, GLenum zfail, GLenum zpass) with gil:
    Logger.warn('before glStencilOp')
    pyodide_gl.stencilOp(fail, zfail, zpass)
    Logger.warn('after glStencilOp')


cdef void __stdcall pyodideStencilOpSeparate(GLenum face, GLenum fail, GLenum zfail, GLenum zpass) with gil:
    Logger.warn('before glStencilOpSeparate')
    pyodide_gl.stencilOpSeparate(face, fail, zfail, zpass)
    Logger.warn('after glStencilOpSeparate')


cdef void __stdcall pyodideVertexAttrib1f(GLuint indx, GLfloat x) with gil:
    Logger.warn('before glVertexAttrib1f')
    pyodide_gl.vertexAttrib1f(indx, x)
    Logger.warn('after glVertexAttrib1f')


cdef void __stdcall pyodideVertexAttrib2f(GLuint indx, GLfloat x, GLfloat y) with gil:
    Logger.warn('before glVertexAttrib2f')
    pyodide_gl.vertexAttrib2f(indx, x, y)
    Logger.warn('after glVertexAttrib2f')


cdef void __stdcall pyodideVertexAttrib3f(GLuint indx, GLfloat x, GLfloat y, GLfloat z) with gil:
    Logger.warn('before glVertexAttrib3f')
    pyodide_gl.vertexAttrib3f(indx, x, y, z)
    Logger.warn('after glVertexAttrib3f')


cdef void __stdcall pyodideVertexAttrib4f(GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w) with gil:
    Logger.warn('before glVertexAttrib4f')
    pyodide_gl.vertexAttrib4f(indx, x, y, z, w)
    Logger.warn('after glVertexAttrib4f')


cdef void __stdcall pyodideVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr) with gil:
    Logger.warn('before glVertexAttribPointer')
    pyodide_gl.vertexAttribPointer(indx, size, type, normalized, stride, <GLintptr>ptr)
    Logger.warn('after glVertexAttribPointer')


cdef void __stdcall pyodideViewport(GLint x, GLint y, GLsizei width, GLsizei height) with gil:
    Logger.warn('before glViewport')
    pyodide_gl.viewport(x, y, width, height)
    Logger.warn('after glViewport')


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
    cgl.glGetUniformfvSize = pyodideGetUniformfvSize
    cgl.glGetUniformiv = pyodideGetUniformiv
    cgl.glGetUniformivSize = pyodideGetUniformivSize
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
