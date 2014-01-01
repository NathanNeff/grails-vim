" Check if filename ends in 'Controller'
let thisFile = expand("%:r")
if match(thisFile, 'Controller$') != -1
    call grails#GrailsControllerMarks(1)
endif

if !exists("g:grails_folding")
  let g:grails_folding = 0
endif

if g:grails_folding
  " Create nice folding methods for Groovy / Grails filez
  " Example:
  " class Foo {
  "     def method() {
  "     def method2() {
  "     def method3() {

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
endif

" Set tabstop = 4 (convention for groovy files)
setlocal tabstop=4

" Run groovy script with F5
if mapcheck("<F5>") == ""
    map <unique> <F5> :w<bar>:!groovy %<CR>
    imap <unique> <F5> <C-O>:w<bar>:!groovy %<CR>
endif

map <S-F5> :w<bar>:r! groovy %<CR>
imap <S-F5> <C-O>:w<bar>:r! groovy %<CR>
