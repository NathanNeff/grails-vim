" Check if filename ends in 'Controller'
let thisFile = expand("%:r")
if match(thisFile, 'Controller$') != -1
    call grails#GrailsControllerMarks(1)
endif

" Set foldmethod to look for standard open/close braces.
setlocal foldmethod=marker foldmarker={,}
" Set foldlevel to 1, which folds up to the top-level methods/actions of
" a Groovy class.
setlocal foldlevel=1
" Avoid showing a bunch of dashes and the number of lines folded:
setlocal fillchars=fold:\  foldtext=getline(v:foldstart)

" Folding can be turned on/off using standard Vim commands:
"    zi  : toggle folding on/off
"    zo  : open fold under cursor
"    zc  : close fold under cursor
"    zm  : fold (m)ore
"    zr  : (r)educe folding
"    See :h folding for more options
