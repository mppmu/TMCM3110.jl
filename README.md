# Julia Control Software for the TMCM-3110 v1.11

[![Build Status](https://travis-ci.org/lmh91/TMCM3110.jl.svg?branch=master)](https://travis-ci.org/lmh91/TMCM3110.jl)

[![Coverage Status](https://coveralls.io/repos/lmh91/TMCM3110.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/lmh91/TMCM3110.jl?branch=master)

[![codecov.io](http://codecov.io/github/lmh91/TMCM3110.jl/coverage.svg?branch=master)](http://codecov.io/github/lmh91/TMCM3110.jl?branch=master)



TMCM-3110: https://www.trinamic.com/products/modules/details/tmcm-3110/



# Installation

First install the requirements:

    julia> Pkg.add("BinDeps.jl")
    julia> Pkg.clone("https://github.com/andrewadare/LibSerialPort.jl.git")
    julia> Pkg.build("LibSerialPort")

Then install the package:

    julia> Pkg.clone("https://github.com/lmh91/TMCM3110.jl.git")

# Test

Just connect the controller TMCM-3110 via USB and run the Pkg.test function:

    julia> Pkg.test("TMCM3110")

Now all axis parameters of motor 0 should be listed. See "test/runtests.jl".
