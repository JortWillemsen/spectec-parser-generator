# Agda backend generator for Wasm SpecTec

A backend translating a Wasm specification from wsl into Agda through LBNF transpilation and compilation.

## Module structure

- `Lbnf` - AST of our LBNF representation
- `Gen` - functions exposing the backend outside
- `Print` - writing out `LBNF` representation into actual `.cp` file
- `Translate` - translating from the internal language `Il` into the `LBNF`

## General plan

- [] Create AST representation of SpecTec we can transpile to LBNF
- [] Print and generate LBNF specification
- [] Compile LBNF to Agda/other
- [] Proof correntness of translation
