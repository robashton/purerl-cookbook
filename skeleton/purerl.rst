Purerl 
#######

The Purerl code is relatively easy to follow coming from any sort of JS environment, in essence it boils down to a single folder of code with a manifest describing the package and its dependencies. The compiler will take all of the Purescript and compile both it and the modules to the output directory and then it's up to us to copy that to somewhere the Erlang compiler can find so it can be further compiled into the beam format.

server/packages.dhall

server/spago.dhall

server/Makefile

