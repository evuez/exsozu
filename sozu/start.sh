#!/bin/sh

python3 -m http.server 8000 &
python3 -m http.server 8001 &

/sozu start -c config.toml
