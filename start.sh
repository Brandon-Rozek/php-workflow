#!/bin/bash

trap killgroup SIGINT

SCSSFILE=src/scss/style.scss
TSFILE=src/ts/script.ts

CSSOUTFILE=bin/style.css
JSOUTFILE=bin/script.js

HTTPSPORT=8443
HTTPPORT=8080

DOCKERENABLED=false

#Shutdown all background processes when quitted
killgroup() {
	echo ""
	if $DOCKERENABLED; then
		echo "Shutting down docker image"
		docker stop development
		echo "Removing docker image"
		docker rm development
	fi
	echo "Killing background jobs"
	kill -9 $(jobs -p)
}

installbrowsersync() {
	#If npm is installed then install BrowserSync
	if command -v npm > /dev/null; then
		echo "Installing BrowserSync"
		npm install -g browser-sync
	else
		echo "npm is not installed"
	fi
}

installtypescript() {
	#If npm is installed then install TypeScript
	if command -v npm > /dev/null; then
		echo "Installing TypeScript"
		npm install -g typescript
	else
		echo "npm is not installed"
	fi
}

# Starts BrowserSync to server files in the bin folder and watch for changes in js and css files
startbrowsersync() {
	if command -v browser-sync > /dev/null; then
		if command -v docker > /dev/null; then
			browser-sync start --proxy "https://localhost:$HTTPSPORT" --https --files "bin/*.css" "bin/*.js" 2>> error.log
		else
			browser-sync start --server "bin" --https --files "bin/*.css" "bin/*.js" 2>> error.log
		fi
	else
		echo "BrowserSync is not installed"
	fi
}

# Watches scss files and compiles to css when changed
startsassc() {
	if command -v sassc > /dev/null; then
		./watch.sh --no-clear $SCSSFILE "sassc $SCSSFILE > $CSSOUTFILE" 2>> error.log
	else
		echo "SassC is not installed"
	fi
}

# Watches tts files and compiles to js when changed
starttypescript() {
	if command -v tsc > /dev/null; then
		./watch.sh --no-clear $TSFILE "tsc $TSFILE --outFile \"$JSOUTFILE\"" >> error.log
	else
		echo "TypeScript is not installed"
	fi
}

# Starts up docker instance with apache and php installed (serves the bin folder)
startdocker() {
	if command -v docker > /dev/null; then
		docker run -p $HTTPPORT:80 -p $HTTPSPORT:443 --name development -v "$PWD/"bin/:/var/www/html/ -d eboraas/apache-php 2>> error.log
		DOCKERENABLED=true
	else
		echo "Docker is not installed"
	fi
}

# Download normalize.css if it doesn't exist from the git repo
if [ ! -f src/scss/normalize.scss ]; then
	wget "https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css" -O "src/scss/normalize.scss"
fi

# Install BrowserSync if it doesn't exist
if ! command -v browser-sync > /dev/null; then
	installbrowsersync
fi

# Install TypeScript if it doesn't exist
if ! command -v tsc > /dev/null; then
	installtypescript
fi


startdocker && (startbrowsersync & startsassc & starttypescript &

# Output all future errors
tail -f -n 0 error.log)
