# coding: utf-8
"""Core Treelite library."""
from __future__ import absolute_import as _abs

import ctypes
import os
import sys

from .libpath import TreeliteLibraryNotFound, find_lib_path
from .util import TreeliteError, _log_callback, _warn_callback, py_str


def _load_lib():
    """Load Treelite Library."""
    lib_path = [str(x) for x in find_lib_path()]
    if not lib_path:
        # Building docs
        return None  # type: ignore
    if sys.version_info >= (3, 8) and sys.platform == "win32":
        # pylint: disable=no-member
        os.add_dll_directory(
            os.path.join(os.path.normpath(sys.prefix), "Library", "bin")
        )
    lib = ctypes.cdll.LoadLibrary(lib_path[0])
    lib.TreeliteGetLastError.restype = ctypes.c_char_p
    lib.log_callback = _log_callback
    lib.warn_callback = _warn_callback
    if lib.TreeliteRegisterLogCallback(lib.log_callback) != 0:
        raise TreeliteError(py_str(lib.TreeliteGetLastError()))
    if lib.TreeliteRegisterWarningCallback(lib.warn_callback) != 0:
        raise TreeliteError(py_str(lib.TreeliteGetLastError()))
    return lib


# load the Treelite library globally
# (do not load if called by sphinx)
if "sphinx" in sys.modules:
    try:
        _LIB = _load_lib()
    except TreeliteLibraryNotFound:
        _LIB = None
else:
    _LIB = _load_lib()


def _check_call(ret):
    """Check the return value of C API call

    This function will raise exception when error occurs.
    Wrap every API call with this function

    Parameters
    ----------
    ret : int
        return value from API calls
    """
    if ret != 0:
        raise TreeliteError(_LIB.TreeliteGetLastError().decode("utf-8"))


def c_array(ctype, values):
    """
    Convert a Python byte array to C array

    WARNING
    -------
    DO NOT USE THIS FUNCTION if performance is critical. Instead, use np.array(*)
    with dtype option to explicitly convert type and then use
    ndarray.ctypes.data_as(*) to expose underlying buffer as C pointer.
    """
    return (ctype * len(values))(*values)
