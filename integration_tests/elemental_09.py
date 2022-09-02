from ltypes import i32, f64, f32
from numpy import empty, arcsinh, arccosh, reshape, float64, sinh, sqrt

def verify1d_arcsinh(array: f32[:], result: f32[:], size: i32):
    i: i32
    eps: f32
    eps = 1e-6

    for i in range(size):
        assert abs(arcsinh(arcsinh(array[i])) - result[i]) <= eps

def verifynd_arcsinh(array: f64[:, :, :], result: f64[:, :, :], size1: i32, size2: i32, size3: i32):
    i: i32
    j: i32
    k: i32
    eps: f64
    eps = 1e-12

    for i in range(size1):
        for j in range(size2):
            for k in range(size3):
                assert abs(arcsinh(array[i, j, k])**(-1) - result[i, j, k]) <= eps


def elemental_arcsinh():
    i: i32
    j: i32
    k: i32

    array1d: f32[256] = empty(256)
    arcsinh1d: f32[256] = empty(256)

    for i in range(256):
        array1d[i] = float(i)

    arcsinh1d = arcsinh(arcsinh(array1d))
    verify1d_arcsinh(array1d, arcsinh1d, 256)

    arraynd: f64[256, 64, 16] = empty((256, 64, 16))
    arcsinhnd: f64[256, 64, 16] = empty((256, 64, 16))

    for i in range(256):
        for j in range(64):
            for k in range(16):
                arraynd[i, j, k] = float(i + j + k)

    arcsinhnd = arcsinh(arraynd)**(-1)
    verifynd_arcsinh(arraynd, arcsinhnd, 256, 64, 16)

def verify2d_arccosh(array: f64[:, :], result: f64[:, :], size1: i32, size2: i32):
    i: i32
    j: i32
    eps: f64
    eps = 1e-12

    for i in range(size1):
        for j in range(size2):
            assert abs(arccosh(array[i, j])**2 - result[i, j]) <= eps

def verifynd_arccosh(array: f64[:, :, :], result: f64[:, :, :], size1: i32, size2: i32, size3: i32, size4: i32):
    i: i32
    j: i32
    k: i32
    l: i32
    eps: f64
    eps = 1e-12

    for i in range(size1):
        for j in range(size2):
            for k in range(size3):
                for l in range(size4):
                    assert abs( sqrt(arccosh(array[i, j, k, l]))**3 - result[i, j, k, l]) <= eps

def elemental_arccosh():
    i: i32
    j: i32

    array2d: f64[256, 64] = empty((256, 64))
    arccosh2d: f64[256, 64] = empty((256, 64))

    for i in range(256):
        for j in range(64):
                array2d[i, j] = float(i + j * 2)

    arccosh2d = arccosh(array2d)**2

    verify2d_arccosh(array2d, arccosh2d, 256, 64)

    arraynd: f64[256, 64, 16, 4] = empty((256, 64, 16, 4))
    arccoshnd: f64[256, 64, 16, 4] = empty((256, 64, 16, 4))

    for i in range(256):
        for j in range(64):
            for k in range(16):
                for l in range(16):
                    arraynd[i, j, k] = float(i / 4 + j / 3 + k / 2 + l)

    arccoshnd = sqrt(arccosh(arraynd))**3
    verifynd_arccosh(arraynd, arccoshnd, 256, 64, 16, 4)

def elemental_trig_identity():
    i: i32; j: i32; k: i32; l: i32
    eps: f64 = 1e-12

    arraynd: f64[10, 5, 2, 4] = empty((10, 5, 2, 4), dtype=float64)

    identity1: f64[10, 5, 2, 4] = empty((10, 5, 2, 4), dtype=float64)
    identity2: f64[10, 5, 2, 4] = empty((10, 5, 2, 4), dtype=float64)
    identity3: f64[10, 5, 2, 4] = empty((10, 5, 2, 4), dtype=float64)
    identity4: f64[10, 5, 2, 4] = empty((10, 5, 2, 4), dtype=float64)

    observed1d_1: f64[400] = empty(400, dtype=float64)
    observed1d_2: f64[400] = empty(400, dtype=float64)
    observed1d_3: f64[400] = empty(400, dtype=float64)
    observed1d_4: f64[400] = empty(400, dtype=float64)

    for i in range(10):
        for j in range(5):
            for k in range(2):
                for l in range(4):
                    arraynd[i, j, k, l] = sin(float(i + j + k + l))

    identity1 = 2 * arccosh(arraynd) - arccosh((arraynd**2)*2 - 1)
    identity2 =  sinh(arccosh(arraynd)) - sqrt((arraynd**2) - 1)
    identity3 =  2 * arcsinh(arraynd) - arccosh((arraynd**2)*2 + 1)
    identity4 =  cosh(arccosh(arraynd)) - sqrt((arraynd**2) + 1)

    newshape: i32[1] = empty(1, dtype=int)
    newshape[0] = 400

    observed1d_1 = reshape(identity1, newshape)
    observed1d_2 = reshape(identity2, newshape)
    observed1d_3 = reshape(identity3, newshape)
    observed1d_4 = reshape(identity4, newshape)

    for i in range(400):
        assert abs(observed1d_1[i] - 0.0) <= eps
        assert abs(observed1d_2[i] - 0.0) <= eps
        assert abs(observed1d_3[i] - 0.0) <= eps
        assert abs(observed1d_4[i] - 0.0) <= eps

elemental_arcsinh()
elemental_arccosh()
elemental_trig_identity()
