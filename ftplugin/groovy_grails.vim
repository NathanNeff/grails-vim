" Check if filename ends in 'Controller'
let thisFile = expand("%:r")
if match(thisFile, 'Controller$') != -1
    call grails#GrailsControllerMarks(1)
endif

" Spring STS and friends like to use tabs, not spaces
set tabstop=4
