/*
 * conda-forge STIR is static-only and built with -ffast-math (gcc Release), so
 * gcc references glibc's errno-free math symbols (__exp_finite, __log_finite,
 * ...). On glibc>=2.35 those are no longer resolvable in a static link, so the
 * final link of STIR into _pystir.so fails. Each __<fn>_finite(x) is just the
 * public <fn>(x) minus errno handling (which STIR does not use), so thin
 * wrappers satisfy the references.
 *
 * Covers the __*_finite symbols referenced by conda-forge STIR 6.3.0/6.4.0
 * (verified via `nm -u` on the .a archives). The STIR 6.3.0 CUDA 13 build
 * additionally references the C++ vector-call-ABI variants (_ZGVbN*) of some of
 * these plus cos/sin — glibc exports the plain C symbols from libm but not the
 * mangled vector-call ones, so asm-labelled wrappers provide them.
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

/* STIR 6.3.0 cuda130 (GCC vector-call ABI) references the C++ mangled
   nothrow variants; provide them as aliases (the vector-call ABI is
   compatible with plain const/nothrow functions). */
double __shim_cos(double x)                __asm__("_ZGVbN2v_cos");
double __shim_sin(double x)                __asm__("_ZGVbN2v_sin");
double __shim_exp_finite(double x)         __asm__("_ZGVbN2v___exp_finite");
double __shim_log_finite(double x)         __asm__("_ZGVbN2v___log_finite");
double __shim_pow_finite(double a, double b) __asm__("_ZGVbN2vv___pow_finite");
float  __shim_cosf(float x)                __asm__("_ZGVbN4v_cosf");
float  __shim_sinf(float x)                __asm__("_ZGVbN4v_sinf");
float  __shim_expf_finite(float x)         __asm__("_ZGVbN4v___expf_finite");
float  __shim_powf_finite(float a, float b) __asm__("_ZGVbN4vv___powf_finite");

double __shim_cos(double x)                { return cos(x); }
double __shim_sin(double x)                { return sin(x); }
double __shim_exp_finite(double x)         { return exp(x); }
double __shim_log_finite(double x)         { return log(x); }
double __shim_pow_finite(double a, double b) { return pow(a, b); }
float  __shim_cosf(float x)                { return cosf(x); }
float  __shim_sinf(float x)                { return sinf(x); }
float  __shim_expf_finite(float x)         { return expf(x); }
float  __shim_powf_finite(float a, float b) { return powf(a, b); }
