#!/bin/bash

for p in procedural object functional; do
    text-vimcolor --format html --full-page --output examples/$p.{html,pl}
done
