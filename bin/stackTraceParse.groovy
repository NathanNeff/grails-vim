#!/usr/bin/env groovy
def lastlineFile = 'target/stacktrace_lastline.log'
def lastline = lastlineRead(lastlineFile)
def lines = new File('logs/enrollio.log').readLines()
lines = lines[lastline .. lines.size() -1]
lines.each { line ->
    m = line =~ /^Caused by: \S+\s*(.*?)(\S+\d+)$/
    if (m.getCount() == 1) {
        println m[0][2] + ":" + m[0][1]
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
