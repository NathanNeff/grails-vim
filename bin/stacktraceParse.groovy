#!/usr/bin/env groovy
def lines = new File('target/stacktrace.log').readLines()
lines.each { line ->
    m = line =~ /^Caused by: \S+\s*(.*?)(\S+\d+)$/
    if (m.getCount() == 1) {
        println m[0][2] + ":" + m[0][1]
    }
}
