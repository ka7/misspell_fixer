#! /bin/bash

export TEMP=/tmp/misspell_fixer_test/$$
export RUN=". misspell_fixer.sh"
export LC_ALL=C

oneTimeSetUp(){
	mkdir -p $TEMP $TEMP/self/
}

oneTimeTearDown(){
	rm -rf $TEMP
}

# copy code, but remove test-data and dict
setUp(){
	set +f
	cp -a * $TEMP/self/
        rm -R $TEMP/self/dict/*.dict
        rm $TEMP/self/*.sed
        rm -R $TEMP/self/test/expected/
        rm $TEMP/self/test/expected*
        rm -R $TEMP/self/.git
        rm -R $TEMP/self/test/stubs
        rm -R $TEMP/self/X/
        rm -Rf $TEMP/self/shunit2/
	set -f
}

# run over own code, assume zero errors.
testSelf(){
        . misspell_fixer.sh -s -D $TEMP/self/ > $TEMP/self/spelling.txt
        echo "*** those errors found: ***"
        cat $TEMP/self/spelling.txt
	assertEqual "found some spelling-errors. :-( " $(cat $TEMP/self/spelling.txt | grep "^+" | wc -l) 0
}


suite(){
	suite_addTest testSelf
}


# load shunit2
. shunit2/source/2.1/src/shunit2
