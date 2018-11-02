#! /bin/bash

gittop=$(git rev-parse --show-toplevel)
ln --symbolic $gittop/githooks/pre-commit $gittop/.git/hooks
