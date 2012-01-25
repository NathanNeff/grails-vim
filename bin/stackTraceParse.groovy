#!/usr/bin/env groovy
def lastlineFile = 'target/stacktrace_lastline.log'
def lastline = lastlineRead(lastlineFile)
def lines = new File('logs/enrollio.log').readLines()
def dir = new File(".").canonicalPath + "/"

lines = lines[lastline .. lines.size() -1]
lines.each { line ->
    m = line =~ /^Caused by: \S+\s*(.*?)(\S+\d+)$/
    if (m.getCount() == 1) {
        def relPath = m[0][2] - dir
        println relPath + ":" + m[0][1]
    }
    else {
        println "No Errors Found"
    }
}

lastline += lines.size() - 1
saveLastLine(lastlineFile, lastline)

def saveLastLine(lastlineFile, lineNum) {
    def output = """This file is used to track the last line read in stacktrace.log by grails-vim's stackTraceParse.groovy file.
If you're experiencing problems with grails-vim's GrailsReadStackTrace command, try deleting this file.
${lineNum}
"""
    new File(lastlineFile).append(output)
}

def lastlineRead(lastlineFile) {
    def lastline = 0;
    def fh = new File(lastlineFile)

    if ( fh.exists() ) {
        lastline = fh.readLines()[2]
        fh.delete()
    }
    return lastline.toInteger()
}
