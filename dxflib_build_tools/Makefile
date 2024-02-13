SRCS=$(shell find src -name "*.cpp")
HDRS=$(shell find src -name "*.h")

lib: libdxflib.a Makefile
	mkdir -p dxflib
	cp -f src/*.h dxflib

libdxflib.a: src/Makefile $(SRCS) $(HDRS)
	rm -f ./libdxflib.a
	cd src ; $(MAKE)

clean:
	cd src ; $(MAKE) clean

distclean: clean
	rm -rf ./libdxflib.a ./dxflib
