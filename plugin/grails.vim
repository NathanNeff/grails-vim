" grails.vim - Detect a grails application
" Author:       Nathan Neff <nathan.neff@gmail.com>

" Install this file as plugin/grails.vim.
" Run :helptags ~/.vim/doc
" ============================================================================
" Initialization {{{1
" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if &cp || (exists("g:loaded_grails") && g:loaded_grails) 
  finish
endif

let g:loaded_grails = 1

" If we're in a grails directory, then
" perform initialization
function! s:Detect()
    if finddir("grails-app", getcwd()) != ""
        call s:GrailsBufInit()
    endif
endfunction

" Detect whether this file is a Grails file.
" We only look @ the current directory, and try to find a grails-app
" directory.  Therefore, you must run vim from the root directory of a Grails
" app
augroup grailsPluginDetect
  autocmd!
  autocmd BufNewFile,BufRead * call s:Detect()
  autocmd VimEnter * call s:Detect() 
  " autocmd Syntax railslog if s:autoload()|call rails#log_syntax()|endif
augroup END

" This function puts the current directory
" and all files underneath it into the path.
" This makes commands like 'gf' and friends able to open
" files with paths relative to the Grails projects' root directory
function! s:GrailsBufInit()
    let wildcardpath=getcwd() . "/**/"
    exec 'set path+=' . wildcardpath
endfunction

" Exported Functions {{{1
" Opens a netrw window in the view directory
" pertain to the buffer where the cursor was when
" this function was called
function! s:GrailsDisplayViews()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem = s:GrailsGetCurrentItem()
    " Lower-case the first letter
    let currentItem =  tolower(currentItem[0]) . strpart(currentItem, 1)
    let viewsPath = "grails-app/views/" . currentItem
    echo "Exploring viewsPath".viewsPath
    if finddir(viewsPath) != ""
        exe "Explore " . viewsPath
    else
        echo "Sorry, " . viewsPath . " is not found, you idiot."
    endif
endfunction


" Function: s:GrailsDisplayDomainClass
" Shows the domain class that pertains to the active buffer.
" Example:  FooController.groovy -> domain/Foo.groovy
function! s:GrailsDisplayDomainClass()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem = s:GrailsGetCurrentItem() . ".groovy"
    call s:GrailsOpenItem(currentItem)
endfunction

" Function: s:GrailsDisplayController
" Shows the controller that pertains to the active buffer.
" Example:  FooController.groovy -> domain/Foo.groovy
function! s:GrailsDisplayController()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem = s:GrailsGetCurrentItem() . "Controller.groovy"
    call s:GrailsOpenItem(currentItem)
endfunction

" Function: s:GrailsDisplayService
" Shows the service that pertains to the active buffer.
" Example:  Foo.groovy -> FooService.groovy
function! s:GrailsDisplayService()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem = s:GrailsGetCurrentItem() . "Service.groovy"
    call s:GrailsOpenItem(currentItem)
endfunction

" Function: s:GrailsDisplayTests
" Shows the tests that pertain to active buffer
" Example:  Foo.groovy -> FooTests.groovy
" TODO: What if there's unit, and integration tests?
function! s:GrailsDisplayTests()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem =  expand("%:t:r")
    let currentItem = substitute(currentItem, "Tests$", "", "")
    " If we're in a test report, we'll have all kinds of garbage at the front.
    " Remove it.
    let currentItem = substitute(currentItem, "^.*TEST-.*-", "", "")
    let currentItem = currentItem . "Tests.groovy"
    echo "Opening item: " . currentItem
    call s:GrailsOpenItem(currentItem)
endfunction

" Function: s:GrailsDisplayTestReports
" Shows the plain-text tests that pertain to a particular file
" Example:  Foo.groovy -> test/reports/plain/TEST-FooTests.txt
" TODO: What if there's unit, and integration tests?
function! s:GrailsDisplayTestReports()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem =  expand("%:t:r")
    " Zap the TEST-blahblah if we're in a test
    let currentItem = s:GrailsStripTest(currentItem)
    let testGlob = substitute(currentItem, "Tests$", "", "") . "Tests.txt"
    let testGlob =  "**/TEST-*" . testGlob
    " Use glob path to try to find the file.
    " Search in Grails pre 1.2 and 1.2+ paths
    let searchPath = getcwd() . "/test/reports/plain"
    let searchPath = searchPath .  ',' . getcwd() . '/target/test-reports/plain'
    let foundItem = globpath(searchPath, testGlob)
    if foundItem == ""
        echo "Sorry, test report file: " . testGlob . " was not found :-("
    else
        call s:GrailsOpenItem(foundItem)
    endif

endfunction

" Function: s:GrailsDisplayTestXml
" Shows the XML test results that pertain to a particular file
" Example:  Foo.groovy -> test/reports/plain/TEST-FooTests.xml
" TODO: What if there's unit, and integration tests?
function! s:GrailsDisplayTestXml()
    " Get the name of the current file we're on
    " TODO: Maybe we'll prompt someday
    let currentItem =  expand("%:t:r")
    " Zap the TEST-blahblah if we're in a test
    let currentItem = s:GrailsStripTest(currentItem)
    let testGlob = substitute(currentItem, "Tests$", "", "") . "Tests.xml"
    let testGlob =  "**/TEST-*" . testGlob
    " Use glob path to try to find the file.
    " Search in Grails pre 1.2 and 1.2+ paths
    let searchPath = getcwd() . "/test/reports/plain"
    let searchPath = searchPath .  ',' . getcwd() . '/target/test-reports'
    let foundItem = globpath(searchPath, testGlob)
    if foundItem == ""
        echo "Sorry, test report file: " . testGlob . " was not found :-("
    else
        call s:GrailsOpenItem(foundItem)
    endif

endfunction
" }}}1

" Utility functions{{{1
" Function: s:GrailsGetCurrentItem()
" Utility method to detect what grails 'item' we're in now.
" (Domain Class, Controller, Service, View).
" Returns the name of the thing we're in (e.g. 'Song', 'Whatever')
function! s:GrailsGetCurrentItem()
    let extension = expand("%:e") 
    let fileNameBase = expand("%:t:r")
    
    if extension == "gsp"
        " We're in a view.  Get the current thing by looking @ the parent dir.
        let currentItem = expand("%:p:h:t")
        " Capitalize
        let currentItem = toupper(currentItem[0]) . strpart(currentItem, 1)
    else
        let currentItem = substitute(fileNameBase, "\\(FunctionalTests\\|ControllerTests\\|ServiceTests\\|Service\\|Controller\\|Tests\\)$", "", "")
        let currentItem = s:GrailsStripTest(currentItem)
    endif
    
    return currentItem
endfunction

function! s:GrailsStripTest(thisItem)
    " If we're in a TEST-functional-FooTests.txt file, then return Foo
    let thisItem = substitute(a:thisItem, "^.*TEST-.*-", "", "")
    let thisItem = substitute(thisItem, ".*\\.", "", "")
    return thisItem
endfunction

function! s:GrailsOpenItem(thisItem, ...)
    if a:0 > 0
        let startPath = a:1
    else
        let startPath = getcwd()
    endif
    let filePath = findfile(a:thisItem, startPath . "/**")
    if filePath  != ""
        exe "e " . filePath
        return 1
    else
        echo "Sorry, " . a:thisItem . " is not found, you idiot."
        return 0
    endif
endfunction

function! grails#GrailsControllerMarks(silent)
    " Todo: find better way to restore orig. pos.
    exe "ma z"
    exe "silent g/def\ delete\\>/ma\ d"
    exe "silent g/def\ create\\>/ma\ c"
    exe "silent g/def\ edit\\>/ma\ e"
    exe "silent g/def\ index\\>/ma\ i"
    exe "silent g/def\ list\\>/ma\ l"
    exe "silent g/def\ save\\>/ma\ s"
    exe "silent g/def\ show\\>/ma\ h"
    exe "silent g/def\ update\\>/ma\ u"
    exe "normal 'z"
    if !a:silent
        echo "Marks have been set for this controller, meow"
    endif
endfunction

function s:GrailsReadTestOutput()

    let old_efm = &efm
    " format is file:lineNumber:message
    set efm=%f:%l:%m
    cexpr system(s:parseScript)
    botright copen

    let &efm = old_efm
endfunction

"}}}1
" Define Commands{{{1
noremap <unique> <script> <Plug>GrailsReadTestOutput <SID>GrailsReadTestOutput
noremap <SID>GrailsReadTestOutput :call <SID>GrailsReadTestOutput()<CR>

noremap <unique> <script> <Plug>GrailsDisplayViews <SID>GrailsDisplayViews
noremap <SID>GrailsDisplayViews :call <SID>GrailsDisplayViews()<CR>

noremap <unique> <script> <Plug>GrailsDisplayDomainClass <SID>GrailsDisplayDomainClass
noremap <SID>GrailsDisplayDomainClass :call <SID>GrailsDisplayDomainClass()<CR>

noremap <unique> <script> <Plug>GrailsDisplayController <SID>GrailsDisplayController
noremap <SID>GrailsDisplayController :call <SID>GrailsDisplayController()<CR>

noremap <unique> <script> <Plug>GrailsDisplayService <SID>GrailsDisplayService
noremap <SID>GrailsDisplayService :call <SID>GrailsDisplayService()<CR>

noremap <unique> <script> <Plug>GrailsDisplayTests <SID>GrailsDisplayTests
noremap <SID>GrailsDisplayTests :call <SID>GrailsDisplayTests()<CR>

noremap <unique> <script> <Plug>GrailsDisplayTestReports <SID>GrailsDisplayTestReports
noremap <SID>GrailsDisplayTestReports :call <SID>GrailsDisplayTestReports()<CR>

noremap <unique> <script> <Plug>GrailsDisplayTestXml <SID>GrailsDisplayTestXml
noremap <SID>GrailsDisplayTestXml :call <SID>GrailsDisplayTestXml()<CR>

noremap <unique> <script> <Plug>GrailsControllerMarks <SID>GrailsControllerMarks
noremap <SID>GrailsControllerMarks :call grails#GrailsControllerMarks()<CR>

noremap <unique> <script> <Plug>GrailsDisplayUrlMappings <SID>GrailsDisplayUrlMappings
noremap <SID>GrailsDisplayUrlMappings :call <SID>GrailsOpenItem("UrlMappings.groovy")<CR>
" }}}1

let s:parseScript=findfile('bin/testSuitesXmlParse.groovy', &rtp) 

" Mappings {{{1
" Default the Grails-Vim MapPrefix to leader g.
if !exists("g:GrailsMapPrefix")
    let g:GrailsMapPrefix='<Leader>g'
endif


function s:GrailsMap(char, mapping)
    let l:curMap = maparg(g:GrailsMapPrefix . a:char) 
    if l:curMap == ""
        exe "map <unique> <silent> " . g:GrailsMapPrefix . a:char . " " . a:mapping
    else
        echo "Grails-vim:  Won't map " . a:mapping . ".  " . 
                    \ g:GrailsMapPrefix . a:char . " is already mapped to " . l:curMap
    endif

endfunction

call <SID>GrailsMap("c", "<Plug>GrailsDisplayController")
call <SID>GrailsMap("d", "<Plug>GrailsDisplayDomainClass")
call <SID>GrailsMap("g", "<Plug>GrailsReadTestOutput")
call <SID>GrailsMap("m", "<Plug>GrailsControllerMarks")
call <SID>GrailsMap("r", "<Plug>GrailsDisplayTestReports")
call <SID>GrailsMap("s", "<Plug>GrailsDisplayService")
call <SID>GrailsMap("t", "<Plug>GrailsDisplayTests")
call <SID>GrailsMap("u", "<Plug>GrailsDisplayUrlMappings")
call <SID>GrailsMap("v", "<Plug>GrailsDisplayViews")
call <SID>GrailsMap("x", "<Plug>GrailsDisplayTestXml")

" }}}1
" vim: set fdm=marker:
