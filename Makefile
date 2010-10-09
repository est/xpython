top_builddir = .
include Makefile.common

CWD:=$(shell pwd)

all: xpython$(E)

#PYMODS=Python/Modules/timemodule.o Python/Modules/socketmodule.o \
#       Python/Modules/operator.o Python/Modules/cPickle.o \
#       Python/Modules/mathmodule.o Python/Modules/binascii.o \
#       Python/Modules/_randommodule.o Python/Modules/selectmodule.o \
#       Python/Modules/fcntlmodule.o Python/Modules/cStringIO.o Python/Modules/_struct.o \
#       Python/Modules/md5module.o Python/Modules/md5.o Python/Modules/shamodule.o \
#       Python/Modules/sha256module.o Python/Modules/sha512module.o \
#       Python/Modules/pyexpat.o Python/Modules/expat/xmltok.o \
#       Python/Modules/expat/xmlparse.o Python/Modules/expat/xmlrole.o 	

#MAINSCRIPT=helloworld_wx.py
MAINSCRIPT=runathana.py
#MAINSCRIPT=pdf2swf.py

CONFIGVARS=CXX="$(CXX)" \
	CPP="$(CPP)" \
	CC="$(CC)" \
	CPPFLAGS="$(CPPFLAGS) -DPy_BUILD_CORE -I$(CWD)/zlib -I$(CWD)/freetype/include -I$(CWD)/jpeg-6b -I ./include/msvc/wx/ -IPython" \
	LDFLAGS="$(LDFLAGS) -L$(CWD)/zlib -L$(CWD)/freetype -L$(CWD)/jpeg-6b" \
	AR="$(AR)" \
	RANLIB="$(RANLIB)" \
	STRIP="$(STRIP)" \
	WINDRES="$(WINDRES)" \
	NM="$(NM)"

MAGPYMODS=magpy/python/mgquery.o magpy/python/mgindexer.o magpy/python/intSet.o magpy/mgindexer.a magpy/mgquery.a

# ====================== Depack statements ============================

ifeq ($(EXEEXT),.exe)
Python/pyconfig.h.in: libs/Python-2.5.tgz
	rm -rf Python2.5 Python
	@echo Depacking Python-2.5.tgz
	tar -zxf libs/Python-2.5.tgz
	@echo Creating Symlinks
	mv Python-2.5 Python-windows
	rm -f freeze Modules python Lib
	ln -s Python-windows Python
	@echo Applying patches
	patch -p0 < patches/python-mingw.patch
	test "$(EXEEXT)" = .exe && sed -i s/posix/nt/g Python/Modules/Setup.dist || true
	cp Python/Modules/posixmodule.c Python/Modules/ntmodule.c
	cp Python/PC/errmap.h Python/
	test "$(EXEEXT)" = .exe && cp Python/PC/pyconfig.h Python/ || true
	touch -c Python/pyconfig.h.in
else
Python/pyconfig.h.in: Python-linux/pyconfig.h.in
	ln -s Python-linux Python
endif

Python-linux/pyconfig.h.in: libs/Python-2.5.tgz
	rm -rf Python-linux
	@echo Depacking Python-2.5.tgz
	tar -zxf libs/Python-2.5.tgz
	@echo Creating Symlinks
	mv Python-2.5 Python-linux
	ln -s Python-linux/Tools/freeze/ freeze
	@echo Appying patches
	patch -p0 < patches/python-distutils.patch
	touch -c Python-linux/pyconfig.h.in
	rm -rf Python-linux/PC

magpy/Makefile.in: libs/magpy-0.3.1.tar.gz
	rm -rf magpy-0.3.1 magpy
	@echo Depacking Magpy
	tar -zxf libs/magpy-0.3.1.tar.gz
	@echo Creating Symlinks
	ln -s magpy-0.3.1 magpy
	touch -c magpy/Makefile.in

sqlite/Makefile.in: libs/sqlite-3.5.3.tar.gz
	rm -rf sqlite-3.5.3 sqlite
	@echo Depacking sqlite
	tar -zxf libs/sqlite-3.5.3.tar.gz
	@echo Creating Symlinks
	ln -s sqlite-3.5.3 sqlite
	@echo Applying Patches
	echo 'config_BUILD_CC="gcc -g -O2"' > sqlite/hints.txt
	echo 'config_TARGET_READLINE_INC="-L/i/dont/know"' >> sqlite/hints.txt
	echo 'config_TARGET_CC="$(C)"' >> sqlite/hints.txt
	touch -c sqlite/Makefile.in
	cd sqlite;patch -p0 < ../patches/sqlite-fts3.patch

Imaging/setup.py: libs/Imaging-1.1.6.tar.gz
	rm -rf Imaging-1.1.6 Imaging
	@echo Depacking Imaging
	tar -zxf libs/Imaging-1.1.6.tar.gz
	@echo Creating Symlinks
	ln -s Imaging-1.1.6 Imaging
	@echo Applying Patches
	patch -p0 < patches/Imaging-setup.patch
	touch -c Imaging/setup.py

wxPython/Makefile.in: libs/wxPython-src-2.6.3.3.tar.bz2
	rm -rf wxPython-src-2.6.3.3 wxPython wxpythonmods
	@echo Depacking wxPython
	tar -jxf libs/wxPython-src-2.6.3.3.tar.bz2
	@echo Creating Symlinks
	ln -s wxPython-src-2.6.3.3 wxPython
	ln -s wxPython/wxPython wxpythonmods
	touch -c wxPython/Makefile.in

freetype/configure: libs/freetype-2.3.2.tar.bz2
	rm -rf freetype-2.3.2 freetype
	@echo Depacking freetype
	tar -jxf libs/freetype-2.3.2.tar.bz2
	@echo Creating Symlinks
	ln -s freetype-2.3.2 freetype
	touch -c freetype/configure

zlib/configure: libs/zlib-1.2.3.tar.bz2
	rm -rf zlib-1.2.3 zlib
	@echo Depacking zlib
	tar -jxf libs/zlib-1.2.3.tar.bz2
	@echo Creating Symlinks
	ln -s zlib-1.2.3 zlib
	touch -c zlib/configure

swftools/configure: libs/swftools-dev.tar.gz
	rm -rf swftools swftools-*
	@echo Depacking swftools 
	tar -zxf libs/swftools-dev.tar.gz
	@echo Creating Symlinks
	ln -s swftools-* swftools
	touch -c swftools/configure

jpeg-6b/configure: libs/jpegsrc.v6b.tar.gz
	rm -rf jpeg-6b
	@echo Depacking jpeglib
	tar -zxf libs/jpegsrc.v6b.tar.gz
	@echo Creating Symlinks
	touch -c jpeg-6b/configure

reportlab_2_0/MANIFEST.txt: libs/ReportLab_2_0.tgz
	rm -rf reportlab_2_0
	@echo Depacking reportlab
	tar -zxf libs/ReportLab_2_0.tgz
	touch reportlab_2_0/MANIFEST.txt

# ====================== Configure statements ==========================

Python/pyconfig.h: Python/pyconfig.h.in
	#-DHAVE_GETPEERNAME
ifeq ($(EXEEXT),.exe)
	cd Python;$(CONFIGVARS) ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=yes CPPFLAGS="-IModules/expat/ -DMS_WINDOWS -DMS_WIN32 -DPy_WIN_WIDE_FILENAMES -DUSE_PYEXPAT_CAPI -DHAVE_EXPAT_CONFIG_H" ./configure --with-threads --disable-shared --host=i686-pc-linux-gnu --build=$(HOST) && touch -c pyconfig.h
else
	cd Python;$(CONFIGVARS) CPPFLAGS="-IModules/expat/ -DUSE_PYEXPAT_CAPI -DHAVE_EXPAT_CONFIG_H" ./configure --with-threads --disable-shared --host=i686-pc-linux-gnu --build=$(HOST) && touch -c pyconfig.h
endif
	test "$(EXEEXT)" = .exe && sed -i 's/^THREADOBJ=\s*$$/THREADOBJ=Python\/thread.o Modules\/threadmodule.o/' Python/Makefile  || true
	test "$(EXEEXT)" = .exe && sed -i 's/dynload_stub/dynload_win/' Python/Makefile || true
	cp Python/pyconfig.h Python/pyconfig.h.configure
	test "$(EXEEXT)" = .exe && cp Python/PC/pyconfig.h Python/ || true

Python-linux/pyconfig.h: Python-linux/pyconfig.h.in
	cd Python-linux;./configure --disable-shared && touch -c pyconfig.h

magpy/Makefile: magpy/Makefile.in
	cd magpy;PYTHON_LIB=../Python/libpython2.5.a PYTHON_INCLUDES="-I../Python/Include -I../Python" $(CONFIGVARS) ./configure --host=$(HOST) && touch -c Makefile

ifeq ($(EXEEXT),.exe)
sqlite/Makefile: sqlite/Makefile.in
	cd sqlite;$(CONFIGVARS) config_TARGET_EXEEXT=.exe ./configure --with-hints=`pwd`/hints.txt --disable-tcl --disable-shared --enable-static --without-x --host=i686-pc-linux-gnu --build=$(HOST) && touch -c sqlite/Makefile
else
sqlite/Makefile: sqlite/Makefile.in
	cd sqlite;$(CONFIGVARS) ./configure --with-hints=`pwd`/hints.txt --disable-tcl --disable-shared --enable-static --without-x --host=i686-pc-linux-gnu --build=$(HOST) && touch -c sqlite/Makefile
endif

wxPython/Makefile: wxPython/Makefile.in
	cd wxPython;$(CONFIGVARS) ./configure --disable-shared --host=$(HOST) && touch -c wxPython/Makefile

freetype/config.status: freetype/configure
	cd freetype;$(CONFIGVARS) ./configure --disable-shared --enable-static --host=$(HOST)
	touch freetype/config.status

swftools/config.status: swftools/configure zlib/libz.a Python/libpython2.5.a Python/modules.a Python/extramodules.a Imaging/modules.a jpeg-6b/libjpeg.a freetype/libfreetype.a
	sed -i 's/Py_Main(0, 0)/0/' swftools/configure
	cd swftools;$(CONFIGVARS) PYTHON_LIB="$(CWD)/Python/modules.a $(CWD)/Python/libpython2.5.a $(CWD)/Python/extramodules.a" PYTHON_INCLUDES="-I$(CWD)/Python -I$(CWD)/Python/Include/ -I$(CWD)/Imaging/libImaging/" ./configure --disable-lame --host=$(HOST)
	echo all install uninstall clean: > swftools/avi2swf/Makefile || true
	touch -c swftools/config.status

jpeg-6b/config.status: jpeg-6b/configure
	cd jpeg-6b;$(CONFIGVARS) ./configure --disable-shared --enable-static --host=$(SHOST)
jpeg-6b/libtool: jpeg-6b/config.status
	cd jpeg-6b;$(CONFIGVARS) ./ltconfig --disable-shared ltmain.sh $(HOST)
	sed -i 's/^O = lo$$/O = o/' jpeg-6b/Makefile

zlib/config.status: zlib/configure
	cd zlib;$(CONFIGVARS) ./configure
	touch zlib/config.status

# ====================== External makes ==========================

jpeg-6b/libjpeg.a: jpeg-6b/libtool
	cd jpeg-6b;make libjpeg.a
	$(RANLIB) jpeg-6b/libjpeg.a

freetype/libfreetype.a: freetype/config.status
	cd freetype;$(MAKE)
	cp freetype/objs/.libs/libfreetype.a freetype/libfreetype.a
	$(RANLIB) freetype/libfreetype.a

swftools/lib/python/gfx.a: swftools/config.status
	cd swftools;touch --date "Dec 30 2037" lib/python/SWF.dll lib/python/gfx.dll;$(MAKE);cd lib/python;$(MAKE)
	cd swftools/lib/python;for file in *.lib;do mv $$file $${file%lib}a;done
	#mkdir -p swftools-tmp;cd swftools-tmp;ar x ../swftools/lib/python/gfx$(A);for a in *$(A);do $(AR) x $$a;done || true
	#rm -f swftools/lib/python/gfx.a
	#$(AR) cru swftools/lib/python/gfx.a swftools-tmp/*.$(O)
	#$(RANLIB) swftools/lib/python/gfx.a
	#rm -rf swftools-tmp

zlib/libz.a: zlib/config.status
	cd zlib;$(MAKE) adler32.o compress.o crc32.o gzio.o uncompr.o deflate.o trees.o zutil.o inflate.o infback.o inftrees.o inffast.o
	cd zlib;$(AR) cru libz.a adler32.o compress.o crc32.o gzio.o uncompr.o deflate.o trees.o zutil.o inflate.o infback.o inftrees.o inffast.o
	cd zlib;$(RANLIB) libz.a

$(MAGPYMODS): magpy/Makefile
	cd magpy;$(MAKE)
	cd magpy;$(MAKE) python/mgquery.o
	cd magpy;$(MAKE) python/mgindexer.o
	cd magpy;$(MAKE) python/intSet.o

Imaging/modules.a imagingmods: Imaging/setup.py Python-linux/python
	cd Imaging;../Python-linux/python setup.py build_ext $(CPPFLAGS) -DPy_BUILD_CORE $(LDFLAGS) $(SETUPOPTIONS)
	cd Imaging;ar cru modules.a `find build -name "*.o"`
	$(RANLIB) Imaging/modules.a
	rm -f imagingmods
	ln -s Imaging/build/lib.* imagingmods
	    
sqlite/.libs/libsqlite3.a: sqlite/Makefile
	rm -f .libs/libsqlite3.a
	cd sqlite;make || test -f .libs/libsqlite3.a
	@echo OK

Python-linux/python: Python-linux/pyconfig.h
	cd Python-linux;$(MAKE)
	cd Python-linux;$(MAKE) python

wxlibs=wxPython/lib/libwx_msw_adv-2.6-$(HOST).a \
	wxPython/lib/libwx_msw_html-2.6-$(HOST).a \
	wxPython/lib/libwx_msw_media-2.6-$(HOST).a \
	wxPython/lib/libwx_msw_qa-2.6-$(HOST).a \
	wxPython/lib/libwx_msw_xrc-2.6-$(HOST).a \
	wxPython/lib/libwx_msw_core-2.6-$(HOST).a \
	wxPython/lib/libwx_base_net-2.6-$(HOST).a \
	wxPython/lib/libwx_base_xml-2.6-$(HOST).a \
	wxPython/lib/libwx_base-2.6-$(HOST).a \
	wxPython/lib/libwxexpat-2.6-$(HOST).a \
	wxPython/lib/libwxjpeg-2.6-$(HOST).a \
	wxPython/lib/libwxpng-2.6-$(HOST).a \
	wxPython/lib/libwxregex-2.6-$(HOST).a \
	wxPython/lib/libwxtiff-2.6-$(HOST).a
	#wxPython/lib/libwxzlib-2.6-$(HOST).a

$(wxlibs): wxPython/Makefile
	cd wxPython;$(MAKE)
 
WXPYTHON_SWIG_MODULES=wxPython/wxPython/src/helpers.wxobj wxPython/wxPython/src/drawlist.wxobj \
	wxPython/wxPython/src/helpers.wxobj wxPython/wxPython/src/msw/calendar_wrap.wxobj \
	wxPython/wxPython/src/msw/_controls_wrap.wxobj wxPython/wxPython/src/msw/_core_wrap.wxobj \
	wxPython/wxPython/src/msw/_gdi_wrap.wxobj wxPython/wxPython/src/msw/grid_wrap.wxobj \
	wxPython/wxPython/src/msw/html_wrap.wxobj wxPython/wxPython/src/msw/media_wrap.wxobj \
	wxPython/wxPython/src/msw/_misc_wrap.wxobj wxPython/wxPython/src/msw/webkit_wrap.wxobj \
	wxPython/wxPython/src/msw/_windows_wrap.wxobj wxPython/wxPython/src/msw/wizard_wrap.wxobj \
	wxPython/wxPython/src/msw/xrc_wrap.wxobj 

ifeq ($(EXEEXT),.exe)
WXPYTHONINCLUDE=./wxPython/lib/wx/include/$(HOST)-msw-ansi-release-static-2.6/ 
else
WXPYTHONINCLUDE=./wxPython/lib/wx/include/gtk2-ansi-release-static-2.6/ #-D__WXGTK__=1
endif

%.wxobj: %.cpp wxPython/Makefile
	$(CX) -c -DwxTestFontEncoding=mywxTestFontEncoding -DDllMain=WxDllMain -DPy_BUILD_CORE -I Python/Include/ -I Python/ -I wxPython/include/ -IwxPython/wxPython/include -I $(WXPYTHONINCLUDE) $< -o $@
	
wxPython/wxPython/wx/__init__.py: wxPython/Makefile
	sed -i 's/WXPORT=".*"/WXPORT="msw"/' wxPython/wxPython/build_options.py
	cd wxPython/wxPython;../../Python-linux/python setup.py build_py
	cp wxPython/wxPython/src/msw/*.py wxPython/wxPython/wx/
	touch -c wxPython/wxPython/wx/__init__.py

wxPython/modules.a: wxPython/Makefile $(wxlibs) $(WXPYTHON_SWIG_MODULES)
	#cd wxPython/wxPython;../../Python-linux/python setup.py build_ext --compiler=xmingw32 -I../include -I../../Python/ -D__WXMSW__
	$(AR) cru wxPython/modules.a $(WXPYTHON_SWIG_MODULES)
	$(RANLIB) wxPython/modules.a

COMMON_PYMODS=Python/Modules/md5module.obj Python/Modules/md5.obj Python/Modules/shamodule.obj Python/Modules/operator.obj Python/Modules/mathmodule.obj \
	Python/Modules/binascii.obj Python/Modules/_randommodule.obj Python/Modules/cStringIO.obj Python/Modules/_struct.obj  \
	Python/Modules/pyexpat.obj Python/Modules/expat/xmlparse.obj Python/Modules/expat/xmlrole.obj Python/Modules/expat/xmltok.obj \
	Python/Modules/cPickle.obj Python/Modules/sha256module.obj Python/Modules/sha512module.obj Python/Modules/datetimemodule.obj \
	Python/Modules/arraymodule.obj Python/Modules/timemodule.obj Python/Modules/_localemodule.obj Python/Modules/_heapqmodule.obj \
	Python/Modules/_elementtree.obj Python/Modules/_ctypes/_ctypes_test.obj Python/Modules/mmapmodule.obj Python/Modules/imageop.obj \
	Python/Modules/cmathmodule.obj Python/Modules/cryptmodule.obj Python/Modules/audioop.obj Python/Modules/_weakref.obj \
	Python/Modules/_testcapimodule.obj Python/Modules/socketmodule.obj Python/Modules/selectmodule.obj Python/Modules/stropmodule.obj \
	Python/Modules/rgbimgmodule.obj Python/Modules/_bisectmodule.obj Python/Modules/cjkcodecs/_codecs_tw.obj \
	Python/Modules/cjkcodecs/_codecs_iso2022.obj Python/Modules/cjkcodecs/_codecs_kr.obj Python/Modules/cjkcodecs/_codecs_jp.obj \
	Python/Modules/cjkcodecs/_codecs_hk.obj Python/Modules/cjkcodecs/_codecs_cn.obj \
	Python/Modules/parsermodule.obj Python/Modules/timemodule.obj \
	Python/Modules/_sqlite/module.obj Python/Modules/_sqlite/cursor.obj Python/Modules/_sqlite/connection.obj \
	Python/Modules/_sqlite/microprotocols.obj Python/Modules/_sqlite/prepare_protocol.obj \
	Python/Modules/_sqlite/statement.obj Python/Modules/_sqlite/util.obj Python/Modules/_sqlite/cache.obj \
	Python/Modules/_sqlite/row.obj Python/Modules/posixmodule.obj Python/Modules/unicodedata.obj \
	Python/Modules/zlibmodule.obj

ifeq ($(EXEEXT),.exe)
	PYTHON_MODULES=$(COMMON_PYMODS)
else
	PYTHON_MODULES=$(COMMON_PYMODS) Python/Modules/fcntlmodule.obj
endif


ifeq ($(EXEEXT),.exe)
PYTHON_EXTRA_MODULES=Python/PC/dl_nt.obj Python/PC/import_nt.obj
Python/Modules/posixmodule.obj: Python/Modules/posixmodule.c
	#cp Python/pyconfig.h.configure Python/pyconfig.h ; touch -r Python/Makefile Python/pyconfig.h
	#cp Python/PC/pyconfig.h Python ; touch -r Python/Makefile Python/pyconfig.h
	$(C) -DHAVE_GETCWD -DWITH_THREAD -DPy_WIN_WIDE_FILENAMES  -DHAVE_MEMMOVE -DPy_BUILD_CORE -Isqlite -IPython -IPython/Include -IPython/Python -IPython/Modules/expat/ -DMODULE_NAME=\"`basename $< .c`\" $< -o $@ || true
%.obj: %.c Python/libpython2.5.a sqlite/.libs/libsqlite3.a zlib/libz.a
	$(C) -Izlib/ -DWITH_THREAD -DPy_WIN_WIDE_FILENAMES -DUSE_PYEXPAT_CAPI -DHAVE_EXPAT_CONFIG_H -DHAVE_MEMMOVE -DPy_BUILD_CORE -Isqlite -IPython -IPython/Include -IPython/Python -IPython/Modules/expat/ -DMODULE_NAME=\"`basename $< .c`\" $< -o $@
else
PYTHON_EXTRA_MODULES=
%.obj: %.c Python/libpython2.5.a sqlite/.libs/libsqlite3.a zlib/libz.a
	$(C) -Izlib/ -DWITH_THREAD -DUSE_PYEXPAT_CAPI -DHAVE_EXPAT_CONFIG_H -DHAVE_MEMMOVE -DPy_BUILD_CORE -Isqlite -IPython -IPython/Include -IPython/Python -IPython/Modules/expat/ -DMODULE_NAME=\"`basename $< .c`\" $< -o $@
endif

Python/libpython2.5.a: Python/pyconfig.h Python-linux/python
	test "$(EXEEXT)" = .exe && cp Python/PC/pyconfig.h Python/ || true
	cd Python;$(MAKE) libpython2.5.a

Python/modules.a: Python/libpython2.5.a $(PYTHON_MODULES)
	rm -f Python/modules.a
	$(AR) cru Python/modules.a $(PYTHON_MODULES)
	$(RANLIB) Python/modules.a

Python/extramodules.a: Python/libpython2.5.a $(PYTHON_EXTRA_MODULES)
	rm -f Python/extramodules.a
	$(AR) cru Python/extramodules.a $(PYTHON_EXTRA_MODULES)
	$(RANLIB) Python/extramodules.a


frozen/frozen.c: Python-linux/python $(MAINSCRIPT) additionalmodules.py wxPython/wxPython/wx/__init__.py reportlab_2_0/MANIFEST.txt
	rm -f frozen/*.$(O) frozen/*.o frozen/*.c
	echo running freeze
	@PYTHONPATH="imagingmods:wxpythonmods:Imaging/PIL:Imaging:reportlab_2_0" Python-linux/python freeze/freeze.py -p Python -o frozen $(MAINSCRIPT) additionalmodules.py > freeze.log 2>&1 || echo Errors occured, see freeze.log
	rm -f frozen/Makefile
	mv frozen/config.c frozen/config.c.old || true
	sed -i 's/\bmain\b/frozenmain/' frozen/frozen.c
	sed -i 's/static struct _frozen/struct _frozen/' frozen/frozen.c

frozen/frozen.o: frozen/frozen.c
	for a in frozen/*.c;do $(C) -DPy_BUILD_CORE -c $$a -o $${a%c}o;done
	#cd frozen;if test "x.o" '!=' "x.$(O)";then for a in *.o;do mv $$a $${a%o}$(O);done;fi
	touch -c frozen/frozen.$(O)

config.o: config.c
	$(C) -DPy_BUILD_CORE config.c -o config.o

#Python/modules.a


ifeq ($(EXEEXT),.exe)
WXPYTHON_OBJECTS=wxPython/modules.a $(wxlibs) 
OS_EXTRA_OBJECTS=config.coff -lws2_32 -lgdi32 -lole32 -lcomctl32 -loleaut32 -lcomdlg32 -luuid -lwinmm 
else
WXPYTHON_OBJECTS=
OS_EXTRA_OBJECTS=-lpthread -ldl -lutil
endif

xpython$(E): Python/modules.a Python/extramodules.a Python/libpython2.5.a frozen/frozen.o config.o Python/modules.a sqlite/.libs/libsqlite3.a freetype/libfreetype.a Imaging/modules.a swftools/lib/python/gfx.a zlib/libz.a $(MAGPYMODS) $(WXPYTHON_OBJECTS)
	$(LX) -static config.o frozen/*.o -o xpython$(E) \
	    Python/modules.a \
	    Imaging/modules.a \
	    $(WXPYTHON_OBJECTS) \
	    sqlite/.libs/libsqlite3.a \
	    $(MAGPYMODS) \
	    Python/libpython2.5.a \
	    Python/extramodules.a \
	    freetype/libfreetype.a \
	    swftools/lib/python/gfx.a \
	    zlib/libz.a \
	    jpeg-6b/libjpeg.a \
	    $(OS_EXTRA_OBJECTS) \
            -lstdc++ $(LIBS) 
	$(STRIP) xpython$(E)
	upx -9 --best xpython$(E)

clean:
	rm -rf freetype*
	rm -rf magpy*
	rm -rf swftools*
	rm -rf Python*
	rm -rf Imaging*
	rm -rf jpeg*
	rm -rf sqlite*
	rm -rf reportlab*
	rm -rf wxPython*
	rm -rf wxWidgets*
	rm -rf zlib*
	rm -rf frozen
	rm -f gfxpython.exe xpython.exe
	rm -f wxpythonmods
	rm -f imagingmods
	rm -f freeze config.o


.PHONY: exe

