# /---------------------/
# /   User Settings 1   /
# /    [environment]    /
# /---------------------/

### Directory path where GTK+2 library is installed
GTK_PREFIX ?= /gtk2-static$(MINGW_PREFIX)
#GTK_PREFIX ?= $(MINGW_PREFIX)


### CPU architecture: [i686, x86_64]
CPU_ARCH ?= $(MSYSTEM_CARCH)


### Number of processes: 1, 2, 3, ... or auto
JOBS ?= auto



# /---------------------/
# /   User Settings 2   /
# /       [gerbv]       /
# /---------------------/

GERBV_VERSION ?= 2.10.0
GERBV_VERSION_SUFFIX ?= _240815

GERBV_PKG ?= gerbv-$(GERBV_VERSION).tar.gz
GERBV_SRC_DIR ?= gerbv-$(GERBV_VERSION)
GERBV_PREFIX ?= /gerbv-$(GERBV_VERSION)-$(CPU_ARCH)



# /---------------------/
# /   User Settings 3   /
# /      [dxflib]       /
# /---------------------/

ENABLE_DXF ?= 1   # 1:enable dxf, 0:disable dxf
DXFLIB_VERSION ?= 3.26.4

DXFLIB_PKG ?= dxflib-$(DXFLIB_VERSION)-src.tar.gz
DXFLIB_SRC_DIR ?= dxflib-$(DXFLIB_VERSION)-src





# ============================================================================


.PHONY: all show_settings dxflib extract patch autogen config build install runtime_copy lang_copy del_lib cleanall


# /-----------/
# /   Build   /
# /-----------/

# check gtk+-2.0
GTK_VERSION=$(shell pkg-config --modversion gtk+-2.0 2>/dev/null)



# .mo files
MO_FILES := atk10.mo fontconfig-conf.mo fontconfig.mo gdk-pixbuf.mo gettext-runtime.mo glib20.mo gtk20-properties.mo gtk20.mo

MO_SRCS := $(shell bash -c 'for i in $(MO_FILES); do find $(GTK_PREFIX)/share/locale -name "$$i"; done | sort')

MO_DIRS := $(shell bash -c 'echo "$(dir $(MO_SRCS))" | sed "s/ /\n/g" | uniq')

# check JOBS variable
ifneq ($(strip $(shell expr 0 \< $(JOBS) + 0 2>/dev/null)),1)
  JOBS := $(shell expr `grep physical.id /proc/cpuinfo | sort -u | wc -l` \
          \* `grep cpu.cores /proc/cpuinfo | sort -u | sed 's/.\+://'` + 1 )
  ifeq ($(strip $(JOBS)),)
    JOBS := 1
  endif
endif


# switch prodecure depending on ENABLE_DXF
ifneq ($(strip $(ENABLE_DXF)),0)
  ifeq ("$(wildcard $(DXFLIB_PKG))", "")
    $(error File "$(DXFLIB_PKG)" not found. Please prepare this file, or disable DXF feature (change ENABLE_DXF to 0 in Makefile))
  endif

  ENABLE_DXF_OPTION := --enable-dxf
  DXFLIB_INCLUDE := -I`pwd`/../$(DXFLIB_SRC_DIR)
  DXFLIB_LIB_DIR := -L`pwd`/../$(DXFLIB_SRC_DIR)

  all: show_settings cleanall dxflib extract patch autogen config build install runtime_copy lang_copy del_lib

else
  DXFLIB_VERSION := 
  DXFLIB_PKG := 
  DXFLIB_SRC_DIR := 
  ENABLE_DXF_OPTION := 
  DXFLIB_INCLUDE := 
  DXFLIB_LIB_DIR := 

  all: show_settings cleanall extract patch autogen config build install runtime_copy lang_copy del_lib

endif


show_settings:
	@echo "" 1>&2
ifeq ($(GTK_VERSION),)
	@echo "error: GTK+2 library not found" 1>&2
	@echo "" 1>&2
	@exit 1
endif
	@echo "------------------- Settings -------------------" 1>&2
	@echo "System:" 1>&2
	@echo "  GTK version       = $(GTK_VERSION)" 1>&2
	@echo "  GTK_PREFIX        = $(GTK_PREFIX)" 1>&2
	@echo "  CPU_ARCH          = $(CPU_ARCH)" 1>&2
	@echo "  JOBS              = $(JOBS)" 1>&2
	@echo "  MO_FILES          = $(MO_FILES)" 1>&2
	@echo "" 1>&2
	@echo "gerbv:" 1>&2
	@echo "  GERBV_VERSION     = $(GERBV_VERSION)" 1>&2
	@echo "  GERBV_PKG         = $(GERBV_PKG)" 1>&2
	@echo "  GERBV_SRC_DIR     = $(GERBV_SRC_DIR)" 1>&2
	@echo "  GERBV_PREFIX      = $(GERBV_PREFIX)" 1>&2
	@echo "" 1>&2
	@echo "dxflib:" 1>&2
	@echo "  ENABLE_DXF        = $(ENABLE_DXF)" 1>&2
	@echo "  DXFLIB_VERSION    = $(DXFLIB_VERSION)" 1>&2
	@echo "  DXFLIB_PKG        = $(DXFLIB_PKG)" 1>&2
	@echo "  DXFLIB_SRC_DIR    = $(DXFLIB_SRC_DIR)" 1>&2
	@echo "  ENABLE_DXF_OPTION = $(ENABLE_DXF_OPTION)" 1>&2
	@echo "  DXFLIB_INCLUDE    = $(DXFLIB_INCLUDE)" 1>&2
	@echo "  DXFLIB_LIB_DIR    = $(DXFLIB_LIB_DIR)" 1>&2
	@echo "" 1>&2


dxflib:
	@echo "" 1>&2
	@echo "------- [dxflib] version $(DXFLIB_VERSION) -------" 1>&2
	tar xf $(DXFLIB_PKG)
	cp -f ./dxflib_build_tools/Makefile $(DXFLIB_SRC_DIR)
	cp -rf ./dxflib_build_tools/src $(DXFLIB_SRC_DIR)
	cd $(DXFLIB_SRC_DIR) && \
	$(MAKE) distclean && \
	$(MAKE) CC=$(CPU_ARCH)-w64-mingw32-gcc


extract: 
	@echo "" 1>&2
	@echo "------- [gerbv] extract $(GERBV_PKG) -------" 1>&2
	tar xf $(GERBV_PKG)


patch: 
	@echo "" 1>&2
	@echo "------- [gerbv] patch : $(GERBV_SRC_DIR) -------" 1>&2
	@find ./patch -maxdepth 1 -name "*.patch" | sort | xargs -i bash -c 'echo "patch -p1 -d $(GERBV_SRC_DIR) < {}" && patch -p1 -d $(GERBV_SRC_DIR) < {}'
	@echo "#!/bin/bash" > $(GERBV_SRC_DIR)/utils/git-version-gen.sh
	@echo "set -e" >> $(GERBV_SRC_DIR)/utils/git-version-gen.sh
	@echo 'PREFIX="$${1}"' >> $(GERBV_SRC_DIR)/utils/git-version-gen.sh
	@echo 'echo -n "$${PREFIX}${GERBV_VERSION_SUFFIX}"' >> $(GERBV_SRC_DIR)/utils/git-version-gen.sh


autogen: 
	@echo "" 1>&2
	@echo "------- [gerbv] autogen -------" 1>&2
	cd $(GERBV_SRC_DIR) && \
	./autogen.sh


config: 
	@echo "" 1>&2
	@echo "------- [gerbv] configure -------" 1>&2
	cd $(GERBV_SRC_DIR) && \
	./configure --prefix=$(GERBV_PREFIX) --host=$(CPU_ARCH)-w64-mingw32 $(ENABLE_DXF_OPTION) --disable-rpath --enable-nls --disable-update-desktop-database --enable-dependency-tracking --enable-static=yes --disable-shared CFLAGS="-O2 $(DXFLIB_INCLUDE) -static" CXXFLAGS="-O2 $(DXFLIB_INCLUDE) -static" LDFLAGS="$(DXFLIB_LIB_DIR) -s -static -static-libgcc -static-libstdc++ -Wl,-Bstatic -pthread" LIBS="-lstdc++ -lshell32 -lole32" PKG_CONFIG="pkg-config --static"


build: 
	@echo "" 1>&2
	@echo "------- [gerbv] build -------" 1>&2
	cd $(GERBV_SRC_DIR) && \
	LANG=C $(MAKE) -j$(JOBS)


install:
	@echo "" 1>&2
	@echo "------- [gerbv] install gerbv to $(GERBV_PREFIX) -------" 1>&2
	cd $(GERBV_SRC_DIR) && \
	$(MAKE) install && \
	cd ..


runtime_copy:
	@echo "" 1>&2
	@echo "------- [gerbv] copy dlls to $(GERBV_PREFIX)/bin -------" 1>&2
	mkdir -p $(GERBV_PREFIX)/lib
	cd $(GTK_PREFIX)/lib && \
	cp -r gtk-2.0 $(GERBV_PREFIX)/lib
	mkdir -p $(GERBV_PREFIX)/share
	cd $(GTK_PREFIX)/share && \
	cp -r themes $(GERBV_PREFIX)/share
	@./utils/cpyruntime.sh $(GERBV_PREFIX)/bin/gerbv.exe $(GERBV_PREFIX)/bin


lang_copy:
	@echo "" 1>&2
	@echo "------- [gerbv] copy lang files to $(GERBV_PREFIX)/share/locale -------" 1>&2
	@for i in $(MO_DIRS); do \
		j=`echo $$i | sed 's|^$(GTK_PREFIX)/|$(GERBV_PREFIX)/|'` && \
		echo "mkdir -p $$j" && \
		mkdir -p $$j ; \
	done
	@for i in $(MO_SRCS); do \
		j=`echo $$i | sed 's|^$(GTK_PREFIX)/|$(GERBV_PREFIX)/|'` && \
		echo "cp $$i $$j" &&  \
		cp $$i $$j ;  \
	done


del_lib:
	@echo "" 1>&2
	@echo "------- [gerbv] delete library files in $(GERBV_PREFIX) -------" 1>&2
	rm -rf $(GERBV_PREFIX)/include
	rm -rf $(GERBV_PREFIX)/lib/gtk-2.0/include
	rm -rf $(GERBV_PREFIX)/lib/pkgconfig
	@find $(GERBV_PREFIX) -name "*.a" | xargs -i bash -c 'rm -f {} && echo {}'
	@find $(GERBV_PREFIX) -name "*.la" | xargs -i bash -c 'rm -f {} && echo {}'

# ============================================================================

# /-----------/
# /   Clean   /
# /-----------/

cleanall:
	@echo "" 1>&2
	@echo "------- clean all -------" 1>&2
	rm -rf $(GERBV_SRC_DIR)
	rm -rf $(DXFLIB_SRC_DIR)
