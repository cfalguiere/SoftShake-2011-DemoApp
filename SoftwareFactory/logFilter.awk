# logFilter.awk was written by Claude Falguiere
#
# Description
# filter out some of the xcode tools outputs and repetitive outputs
# used by rakefile.rb

BEGIN { 
	emptyLines = 0 
	memStep = ""
	currentAction = ""
	
	nrCompileC = 0
	nrCompileXIB = 0
	nrAnalyze = 0
	nrCopyPlistFile = 0
	nrCopyStringsFile = 0
	nrCpResource = 0
	nrCopyPNGFile = 0
	
	testStatus = ""
}

# ----------------------------
# remove command line feedback
# ----------------------------
/^    cd / { next }
/^    setenv / { next }
/^    \/usr\/bin\/codesign / { next }
/^    [^ ]*\/usr\/bin\/Validation / { next }
/^    "[^ ]*\/Xcode\/PrivatePlugIns\/[^ ]* .* [^ ]*\/copypng" / { next }
/^    builtin-productPackagingUtility / { next }
/^    \/usr\/bin\/touch / { next }
/^    builtin-copy / { next }
/^    builtin-copyStrings / { next }
/^    builtin-copyPlist / { next }
/^    [^ ]*\/usr\/bin\/dsymutil / { next }
/^    [^ ]*\/usr\/bin\/clang / { next } 
/^    [^ ]*\/usr\/bin\/llvm-gcc-4.2 / { next }
/^    [^ ]*\/usr\/bin\/momc / { next }
/^    builtin-infoPlistUtility / { next }
/^    [^ ]*\/usr\/bin\/ibtool / { next }

# -------------------------
# remove repetitive logs
# comment out next to display
# -------------------------

/^CompileC / { 
	currentAction = $0
	nrCompileC += 1
	next 
}

/^CompileXIB / {
	currentAction = $0
	nrCompileXIB += 1
	next
}

/^Analyze / {
	currentAction = $0
	nrAnalyze += 1
	next 
}

/^CopyPlistFile / { 
	nrCopyPlistFile += 1
	next 
}

/^CopyStringsFile / { 
	nrCopyStringsFile += 1
	next 
} 

/^CpResource / {
	nrCpResource += 1
	next 
}

/^CopyPNGFile / { 
	currentAction = $0
	nrCopyPNGFile += 1
	next 
}

# handle Compile warnings
/^cc1obj: warnings /{
	print currentAction 
}

# TODO Analyze warning

# handle CopyPNGFile warnings
/^libpng warning: / {
	print currentAction 
}


# ------------------------------
# suppress redundant empty lines
# ------------------------------
/^$/ { 
	if (emptyLines == 0) print $0 
 	emptyLines += 1
	next
}

/.+/ { 
	emptyLines = 0
}

# ----------------
# collect test status
# ----------------
/^Executed [0-9]+ tests/ {
		testStatus = $0;
}

# -----------------
# print other lines
# -----------------
/.+/ { emptyLines = 0 }
/.*/ { print $0 }

END {
	nr = nrCompileC + nrAnalyze + nrCopyPlistFile + nrCopyStringsFile + nrCpResource + nrCopyPNGFile + nrCompileXIB;
	if (nr > 0) print "\nBUILD SUMMARY"
	if (nrCompileC > 0) printf "  CompileC : %d files \n", nrCompileC
	if (nrCompileXIB > 0) printf "  CompileXIB : %d files \n", nrCompileXIB
	if (nrAnalyze > 0) printf "  Analyze : %d files \n", nrAnalyze
	if (nrCopyPlistFile > 0) printf "  CopyPlistFile : %d files \n", nrCopyPlistFile
	if (nrCopyStringsFile > 0) printf "  CopyStringsFile : %d files \n", nrCopyStringsFile
	if (nrCpResource > 0) printf "  CpResource : %d files \n", nrCpResource
	if (nrCopyPNGFile > 0) printf "  CopyPNGFile : %d files \n", nrCopyPNGFile
		
	if (length(testStatus)>0) {
		print "\nTEST SUMMARY"
		print testStatus
		print " "
	}
	
}
