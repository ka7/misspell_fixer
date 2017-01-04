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
        rm $TEMP/self/*.sed
        rm $TEMP/self/test/expected/
        rm -R $TEMP/self/test/dict/*.dict
        rm -R $TEMP/self/.git
        rm -R $TEMP/self/test/stubs/
        rm $TEMP/self/test/expected*
	set -f
}

# run over own code, assume zero errors.
testSelf(){
        ./misspell-fixer.sh -s -D $TEMP/self/ > $TEMP/self/spelling.txt
        if ( $(wc -l $TEMP/self/spelling.txt) <> 0 )
           cat $TEMP/self/spelling.txt
        fi
	assertTrue $(cat $TEMP/self/spelling.txt | grep "^+" | wc -l) 0
}


suite(){
	suite_addTest testSelf
}


# load shunit2
. shunit2/source/2.1/src/shunit2
