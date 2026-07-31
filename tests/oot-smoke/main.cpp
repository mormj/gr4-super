#include <gnuradio-4.0/Block.hpp>
#include <gnuradio-4.0/algorithm/rng/Xoshiro256pp.hpp>
#include <gnuradio-4.0/math/Rotator.hpp>

#include <complex>

int main() {
    gr::rng::Xoshiro256pp first(42);
    gr::rng::Xoshiro256pp second(42);

    using Rotator = gr::blocks::math::Rotator<std::complex<float>>;
    static_assert(gr::BlockLike<Rotator>);

    return first() == second() ? 0 : 1;
}
