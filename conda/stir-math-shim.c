/*
 * conda-forge STIR is static-only and built with -ffast-math (gcc Release), so
 * gcc references glibc's errno-free math symbols (__exp_finite, __log_finite,
 * ...). On glibc>=2.35 those are no longer resolvable in a static link, so the
 * final link of STIR into _pystir.so fails. Each __<fn>_finite(x) is just the
 * public <fn>(x) minus errno handling (which STIR does not use), so thin
 * wrappers satisfy the references.
 *
 * Covers exactly the 15 __*_finite symbols referenced by conda-forge STIR 6.4.0
 * (verified via `nm -u` on the .a archives). Wired in through the SIRF CMake
 * hook `-DSTIR_MATH_SHIM=<this .a>` (SIRF/src/CMakeLists.txt).
 */
#include <math.h>

double __exp_finite(double x)                    { return exp(x); }
float  __expf_finite(float x)                    { return expf(x); }
double __exp2_finite(double x)                   { return exp2(x); }
double __log_finite(double x)                    { return log(x); }
float  __logf_finite(float x)                    { return logf(x); }
double __log2_finite(double x)                   { return log2(x); }
double __pow_finite(double a, double b)          { return pow(a, b); }
float  __powf_finite(float a, float b)           { return powf(a, b); }
long double __powl_finite(long double a, long double b) { return powl(a, b); }
double __atan2_finite(double y, double x)        { return atan2(y, x); }
float  __atan2f_finite(float y, float x)         { return atan2f(y, x); }
float  __asinf_finite(float x)                   { return asinf(x); }
float  __acosf_finite(float x)                   { return acosf(x); }
double __cosh_finite(double x)                   { return cosh(x); }
double __sinh_finite(double x)                   { return sinh(x); }
