#!/bin/sh
rsync --dry-run -avz --delete --exclude=".git" --exclude="sync.sh" ./ ~/.vim/bundle/grails-vim/
