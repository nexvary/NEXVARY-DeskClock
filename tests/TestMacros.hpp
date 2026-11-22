#pragma once
// AERO_REQUIRE* macros are NEVER disabled by NDEBUG.
// All failures call std::exit(1) so CTest reports them correctly in Release builds.
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>

#define AERO_REQUIRE(expr)                                                              \
    do {                                                                                \
        if (!(expr)) {                                                                  \
            std::fprintf(stderr, "FAIL [%s]  expr: %s  (%s:%d)\n",                     \
                         __func__, #expr, __FILE__, __LINE__);                          \
            std::exit(1);                                                               \
        }                                                                               \
    } while (0)

#define AERO_REQUIRE_NEAR(a, b, tol)                                                    \
    do {                                                                                \
        const double _va = static_cast<double>(a);                                      \
        const double _vb = static_cast<double>(b);                                      \
        const double _vt = static_cast<double>(tol);                                    \
        if (!std::isfinite(_va) || !std::isfinite(_vb) ||                               \
            std::abs(_va - _vb) > _vt) {                                                \
            std::fprintf(stderr,                                                         \
                "FAIL [%s]  |%s - %s| = %.17g > %.17g  (%s:%d)\n",                     \
                __func__, #a, #b, std::abs(_va - _vb), _vt, __FILE__, __LINE__);        \
            std::exit(1);                                                               \
        }                                                                               \
    } while (0)

#define AERO_REQUIRE_THROWS(exception_type, expr)                                       \
    do {                                                                                \
        bool _threw = false;                                                            \
        try { (expr); }                                                                 \
        catch (const exception_type&) { _threw = true; }                               \
        catch (...) {}                                                                  \
        if (!_threw) {                                                                  \
            std::fprintf(stderr,                                                         \
                "FAIL [%s]  expected " #exception_type " from: %s  (%s:%d)\n",          \
                __func__, #expr, __FILE__, __LINE__);                                   \
            std::exit(1);                                                               \
        }                                                                               \
    } while (0)

// AERO_TEST(name) { ... } — self-registering test via static initialiser.
// Runs at program startup; use with an empty main() that just returns 0.
#define AERO_TEST(name)                                                                 \
    static void aero_test_##name();                                                     \
    [[maybe_unused]] static const bool _aero_reg_##name = ([] {                        \
        std::fprintf(stdout, "[ RUN ] %s\n", #name);                                   \
        aero_test_##name();                                                             \
        std::fprintf(stdout, "[ OK  ] %s\n", #name);                                   \
        return true;                                                                    \
    }(), true);                                                                         \
    static void aero_test_##name()
