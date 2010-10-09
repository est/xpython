/* main.c - should be named config.c */

#include "Python.h"

#ifdef WIN32
#define WITH_WX
#endif
#define WITH_IMAGING
#define WITH_MAGPY
#define WITH_SQLITE
#define WITH_SWFTOOLS

extern int Py_FrozenMain(int, char **);
extern void initutils(void);
extern void init_codecs(void);
extern void init_sre(void);
extern void initerrno(void);
extern void initimp(void);
extern void initthread(void);
extern void PyMarshal_Init(void);
extern void initimp(void);
extern void initgc(void);
extern void inittime(void);
extern void init_socket(void);
extern void initoperator(void);
extern void initmath(void);
extern void initbinascii(void);
extern void init_random(void);
extern void initselect(void);
extern void initcStringIO(void);
extern void initcPickle(void);
extern void init_struct(void);
extern void init_md5(void);
extern void init_sha(void);
extern void init_sha256(void);
extern void init_sha512(void);
extern void initmgquery(void);
extern void initmgindexer(void);
extern void initpyexpat(void);
extern void init_sqlite3(void);
extern void initdatetime(void);
extern void initarray(void);
extern void init_imaging(void);
extern void init_imagingmath(void);
extern void init_imagingft(void);
extern void initunicodedata(void);
extern void initzlib(void);

#ifndef WIN32
extern void initposix(void);
extern void initfcntl(void);
#else
extern void initnt(void);
#endif

#ifdef WITH_WX
extern void init_core_(void);
extern void init_gdi_(void);
extern void init_windows_(void);
extern void init_controls_(void);
extern void init_misc_(void);
#endif

#ifdef WITH_SWFTOOLS
extern void initgfx(void);
#endif

/* built in modules */
struct _inittab _PyImport_Inittab[] = {
        {"_codecs", init_codecs},
        {"_sre", init_sre},
        {"errno", initerrno},
        {"imp", initimp},
        {"marshal", PyMarshal_Init},
        {"imp", initimp},
        {"gc", initgc},
#ifndef WIN32
        {"posix", initposix},
        {"fcntl", initfcntl},
#else
        {"nt", initnt},
#endif
        {"time", inittime},
        {"_socket", init_socket},
        {"operator", initoperator},
        {"math", initmath},
        {"binascii", initbinascii},
        {"_random", init_random},
        {"select", initselect},
        {"thread", initthread},
        {"cStringIO", initcStringIO},
        {"_struct", init_struct},
        {"_md5", init_md5},
        {"_sha", init_sha},
        {"_sha256", init_sha256},
        {"_sha512", init_sha512},
        {"unicodedata", initunicodedata},
        {"pyexpat", initpyexpat},
        {"datetime", initdatetime},
        {"array", initarray},
#ifdef WITH_SQLITE
        {"_sqlite3", init_sqlite3},
#endif
#ifdef WITH_MAGPY
        {"mgindexer", initmgindexer},
        {"mgquery", initmgquery},
#endif
#ifdef WITH_IMAGING
        {"_imaging", init_imaging},
        {"_imagingmath", init_imagingmath},
        {"_imagingft", init_imagingft},
#endif
#ifdef WITH_WX
        {"_core_", init_core_},
        {"_gdi_", init_gdi_},
        {"_windows_", init_windows_},
        {"_controls_", init_controls_},
        {"_misc_", init_misc_},
#endif
#ifdef WITH_SWFTOOLS
        {"gfx", initgfx},
#endif
        
        {"zlib",  initzlib},
        {"cPickle", initcPickle},

        /* These entries are here for sys.builtin_module_names */
        {"__main__", NULL},
        {"__builtin__", NULL},
        {"sys", NULL},
        {"exceptions", NULL},
        /* Sentinel */
        {0, 0}
};

#ifdef WIN32 
int PyWinFreeze_ExeInit() {return 0;}
int PyWinFreeze_ExeTerm() {return 0;}
#endif

int PyInitFrozenExtensions()
{
    return 0;
}

extern struct _frozen _PyImport_FrozenModules[];
PyAPI_DATA(struct _frozen *) PyImport_FrozenModules;

int main(int argc, char **argv)
{
#ifdef WIN32
    /* getpath.c won't look into the current directory for 
       the executable, if the executable name doesn't contain
       any path, so we just put a .\ in front of the name */
    char filename[256];
    if(!strchr(argv[0], '\\')) {
        sprintf(filename, ".\\%s", argv[0]);
        argv[0] = filename;
    }
#endif

    if(argc <= 1) {
        extern int Py_FrozenMain(int, char **);
        Py_NoSiteFlag = 1;
        Py_FrozenFlag = 1; /* Suppress errors from getpath.c */
        PyImport_FrozenModules = _PyImport_FrozenModules;
        return Py_FrozenMain(argc, argv);
    } else {
        void* dummy = malloc(4096);
        Py_NoSiteFlag = 1;
        Py_FrozenFlag = 1; /* Suppress errors from getpath.c */
        PyInitFrozenExtensions();
        PyImport_FrozenModules = _PyImport_FrozenModules;
        int ret = Py_Main(argc, argv);
        Py_Finalize();
        return ret;
    }
}
