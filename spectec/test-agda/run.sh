#!/usr/bin/env bash


# Run SpecTec agda generator to create LBNF
# ../watsup --generate-agda test.watsup -o test-bnfc/aaaa.cf
# ../watsup --generate-agda  ../spec/wasm-3.0/*.watsup -o test-bnfc/aaaa.cf
../watsup --generate-agda  minispec/*.watsup -o test-bnfc/aaaa.cf

# Move to /test-bnfc
cd test-bnfc

# Generate Agda/Haskell code
bnfc --agda -m -d aaaa.cf 

# Build Agda executable
make

# Return to parent dir
cd .. 