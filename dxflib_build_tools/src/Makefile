SRC_CXX=$(shell find . -name "*.cpp")
HDRS=$(shell find . -name "*.h")
OBJ_CXX=$(SRC_CXX:.cpp=.o)
CFLAGS=-c -O2 -fPIC

all: $(OBJ_CXX)
	rm -f ../libdxflib.a
	LANG=C ar rvs ../libdxflib.a $(OBJ_CXX)
	ranlib ../libdxflib.a

.cpp.o: Makefile $(SRC_CXX) $(HDRS)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ_CXX)

