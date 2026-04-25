#!/bin/bash

# this is a location to list patch files to apply in the repo, nothing
# fancy just a place to hard code "apply this patch to this git subrepo file"

# apply patches as needed
patch -d ./tmux/.tmux/plugins/tmux-fzf < ./tmux/.tmux/plugins/tmux-fzf.patch
