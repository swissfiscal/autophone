#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.


options="hdcU"
function usage()
{
    cat<<EOF
usage: $(basename $0) [-h][-d][-U] logfiles

Process logfiles and produce a report of the errors found.

optional arguments:
  -h  This help message.

  -d  Enable debugging output.
      Do not sort or eliminate duplicates in the output.

  -U  Do not sort and eliminate duplicate messages.

  -c  Prefix the output with the number of occurences of each
      output. If you wish to sort the output by decreasing frequency
      of occurence, pipe the output into sort -nr.

Error lines match the regular expression:
PROCESS-CRASH|TEST-UNEXPECTED|ERROR runtests.py|[IE]/Gecko.*ABORT:|F/MOZ_CRASH|\
   MOZ_Assert.*Assertion failure:

By default, the output is sorted and duplicates eliminated.
The output lines are organized as "records" with a field
delimiter of ";" which facilitates reprocessing the output
using a variety of tools such as awk.

EOF
    exit 0
}

filter="sort -u"
let nshift=0
while getopts $options optname; do
    case $optname in
        h) usage
           ;;
        d) filter=cat
           DEBUG='-v DEBUG=True'
           let nshift=nshift+1
           ;;
        c) filter='sort | uniq -c'
           let nshift=nshift+1
           ;;
        U) filter=cat
           let nshift=nshift+1
           ;;
    esac
done
shift $nshift

here=$(dirname $0)

grep -HE '(PROCESS-CRASH|TEST-UNEXPECTED|ERROR runtests.py|[IE]/Gecko.*ABORT:|F/MOZ_CRASH|MOZ_Assert.*Assertion failure:)' $@ | awk $DEBUG -f ${here}/errors.awk | eval "$filter"
