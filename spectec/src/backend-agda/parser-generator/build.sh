
#!/bin/bash
# A sample Bash script, by Ryan

rm -rf ./output-bnfc/**  && \
bnfc --agda -o ./output-bnfc -p SpecTec -d -m example.cf