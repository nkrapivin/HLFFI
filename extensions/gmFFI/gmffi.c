/* gmffi begin */
#ifndef _GMFFI_C_
#define _GMFFI_C_ 1

/*

    Place me into libffi/include/
    Open libffi/src/closure.c
    Add #include <gmffi.c>
    at the end.
    
    Try to build it.
    Open gmffi_raw_abi and comment out the ABIs it complains about.
    Rebuild.
    Enjoy.

*/

FFI_API double gmffi_raw_sizeof_ptr() {
    return ( (double)(sizeof(char*)) );
}

enum HLFFIType {
    TError   = 0 << 0,
    TVoid    = 1 << 0,
    TInt8    = 1 << 1,
    TUInt8   = 1 << 2,
    TInt16   = 1 << 3,
    TUInt16  = 1 << 4,
    TInt32   = 1 << 5,
    TUInt32  = 1 << 6,
    TInt64   = 1 << 7,
    TUInt64  = 1 << 8,
    TFloat   = 1 << 9,
    TDouble  = 1 << 10,
    TPointer = 1 << 11,
    Last     = 1 << 12 /* reserved for potential bitflags... */
};

/* that should be more than enough... */
static char gmffi_tmpbuff[32];
static char gmffi_tmpbuff2[32];
static char gmffi_tmpbuff4[32];

#ifdef GMFFI_WIN32
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
static WCHAR gmffi_tmpbuff3[65536];
#else
#include <dlfcn.h>
#endif

#include <stdio.h>

FFI_API const char* gmffi_raw_library_load(const char* slibpath) {
    void* libhandle;
    int libok;
    
    if (!slibpath || (*slibpath) == '\0') {
        return "";
    }
    
    libhandle = NULL;
    libok = 0;
    
#ifdef GMFFI_WIN32
    memset(gmffi_tmpbuff3, 0, sizeof(gmffi_tmpbuff3));
    MultiByteToWideChar(CP_UTF8, 0, slibpath, -1, gmffi_tmpbuff3, sizeof(gmffi_tmpbuff3) / sizeof(gmffi_tmpbuff3[0]));
    libhandle = (void*)(LoadLibraryW(gmffi_tmpbuff3));
#else
    libhandle = (void*)(dlopen(slibpath, 0));
#endif
    
    libok = libhandle != NULL;
    if (!libok) {
        return "";
    }
    else {
        memset(gmffi_tmpbuff, 0, sizeof(gmffi_tmpbuff));
        snprintf(gmffi_tmpbuff, sizeof(gmffi_tmpbuff) - 1, "%p", libhandle);
        return gmffi_tmpbuff;
    }
}

FFI_API const char* gmffi_raw_library_resolve(const char* slibhandle, const char* sfuncname) {
    void* libhandle;
    void* funcaddr;
    int funcok;
    
    if (!slibhandle || (*slibhandle) == '\0' || !sfuncname || (*sfuncname) == '\0') {
        return "";
    }
    
    funcaddr = NULL;
    funcok = 0;
    libhandle = NULL;
    sscanf(slibhandle, "%p", &libhandle);

#ifdef GMFFI_WIN32
    funcaddr = (void*)(GetProcAddress((HMODULE)(libhandle), sfuncname));
#else
    funcaddr = (void*)(dlsym(libhandle, sfuncname));
#endif
    
    funcok = funcaddr != NULL;
    if (!funcok) {
        return "";
    }
    else {
        memset(gmffi_tmpbuff2, 0, sizeof(gmffi_tmpbuff2));
        snprintf(gmffi_tmpbuff2, sizeof(gmffi_tmpbuff2) - 1, "%p", funcaddr);
        return gmffi_tmpbuff2;
    }
}

FFI_API const char* gmffi_raw_type_ptr(double dtypeid) {
    void* typeptr;
    int typeok;
    int rawtype;
    
    typeptr = NULL;
    typeok = 0;
    rawtype = ((int)(dtypeid));
    if (rawtype & TVoid)    typeptr = (void*)(&ffi_type_void);    
    if (rawtype & TInt8)    typeptr = (void*)(&ffi_type_sint8);   
    if (rawtype & TUInt8)   typeptr = (void*)(&ffi_type_uint8);   
    if (rawtype & TInt16)   typeptr = (void*)(&ffi_type_sint16);  
    if (rawtype & TUInt16)  typeptr = (void*)(&ffi_type_uint16);  
    if (rawtype & TInt32)   typeptr = (void*)(&ffi_type_sint32);  
    if (rawtype & TUInt32)  typeptr = (void*)(&ffi_type_uint32);  
    if (rawtype & TInt64)   typeptr = (void*)(&ffi_type_sint64);  
    if (rawtype & TUInt64)  typeptr = (void*)(&ffi_type_uint64);  
    if (rawtype & TFloat)   typeptr = (void*)(&ffi_type_float);   
    if (rawtype & TDouble)  typeptr = (void*)(&ffi_type_double);  
    if (rawtype & TPointer) typeptr = (void*)(&ffi_type_pointer); 
    
    typeok = typeptr != NULL;
    if (!typeok) {
        return "";
    }
    else {
        memset(gmffi_tmpbuff4, 0, sizeof(gmffi_tmpbuff4));
        snprintf(gmffi_tmpbuff4, sizeof(gmffi_tmpbuff4) - 1, "%p", typeptr);
        return gmffi_tmpbuff4;
    }
}

struct GMFFIData {
    void*        pfunction;
    ffi_type*    prettype;
    ffi_type**   ptypes;
    void*        pretmem;
    void**       pargsmem;
    unsigned int unargs;
    unsigned int unvarargs;
    unsigned int unffiabi;
    unsigned int ureserved;
};

FFI_API double gmffi_raw_library_function_call(struct GMFFIData* pgmffidata) {
    ffi_cif fcif;
    ffi_status fstatus;
    
    /* pgmperargs can be null, in case the return type is void and arguments are not used at all... */
    if (!pgmffidata) {
        return 0.0;
    }
    
    if (pgmffidata->unvarargs == 0) {
        fstatus = ffi_prep_cif(
            &fcif,
            pgmffidata->unffiabi,
            pgmffidata->unargs,
            pgmffidata->prettype,
            pgmffidata->ptypes
        );
    }
    else {
        fstatus = ffi_prep_cif_var(
            &fcif,
            pgmffidata->unffiabi,
            pgmffidata->unvarargs,
            pgmffidata->unargs,
            pgmffidata->prettype,
            pgmffidata->ptypes
        );
    }
    
    if (fstatus != FFI_OK) {
        return ((double)(-(int)(fstatus)));
    }
    
    ffi_call(
        &fcif,
        FFI_FN(pgmffidata->pfunction),
        pgmffidata->pretmem,
        pgmffidata->pargsmem
    );
    
    /* all is good, hopefully... */
    return 1.0;
}

#define GMFFI_ABI_ERROR -1

FFI_API double gmffi_raw_abi(const char* sabiname) {
    int fabiret;
    fabiret = GMFFI_ABI_ERROR;
    
    // default abi on empty string
    if (!sabiname || (*sabiname) == '\0' || strcmp(sabiname, "FFI_DEFAULT_ABI") == 0) { fabiret = FFI_DEFAULT_ABI; goto lbl_done; }
    // those are always defined:
    if (strcmp(sabiname, "FFI_FIRST_ABI") == 0) { fabiret = FFI_FIRST_ABI; goto lbl_done; }
    if (strcmp(sabiname, "FFI_LAST_ABI") == 0) { fabiret = FFI_LAST_ABI; goto lbl_done; }
    // custom, comment out individually when it errors out:
    if (strcmp(sabiname, "FFI_WIN64") == 0) { fabiret = FFI_WIN64; goto lbl_done; }
    if (strcmp(sabiname, "FFI_EFI64") == 0) { fabiret = FFI_EFI64; goto lbl_done; }
    if (strcmp(sabiname, "FFI_GNUW64") == 0) { fabiret = FFI_GNUW64; goto lbl_done; }
    if (strcmp(sabiname, "FFI_SYSV") == 0) { fabiret = FFI_SYSV; goto lbl_done; }
    if (strcmp(sabiname, "FFI_STDCALL") == 0) { fabiret = FFI_STDCALL; goto lbl_done; }
    if (strcmp(sabiname, "FFI_THISCALL") == 0) { fabiret = FFI_THISCALL; goto lbl_done; }
    if (strcmp(sabiname, "FFI_FASTCALL") == 0) { fabiret = FFI_FASTCALL; goto lbl_done; }
    if (strcmp(sabiname, "FFI_MS_CDECL") == 0) { fabiret = FFI_MS_CDECL; goto lbl_done; }
    if (strcmp(sabiname, "FFI_PASCAL") == 0) { fabiret = FFI_PASCAL; goto lbl_done; }
    if (strcmp(sabiname, "FFI_REGISTER") == 0) { fabiret = FFI_REGISTER; goto lbl_done; }
    if (strcmp(sabiname, "FFI_VFP") == 0) { fabiret = FFI_VFP; goto lbl_done; }
    // we're done here.
    
lbl_done:
    return ((double)(fabiret));
}

#endif /* _GMFFI_C_ */
/* gmffi end */