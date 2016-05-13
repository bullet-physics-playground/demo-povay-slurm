all: cancel clean asy1 sphere clock

asy1:
	./run.sh -s asy1 -f 300

clock:
	./run.sh -s clock -f 9500

sphere:
	./run.sh -s sphere

cancel:
	scancel -u ${USER}

clean:
	./clean.sh
