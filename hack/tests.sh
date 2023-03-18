#!/usr/bin/env bash

this=$(git rev-parse --show-toplevel)

bats --timing --pretty --recursive --verbose-run "${this}"/tests
