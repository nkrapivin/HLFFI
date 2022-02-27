/*
    High-Level Foreign Function Interface.
*/

#macro __HLFFI_EXCARGS debug_get_callstack(), instanceof(self)

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

enum HLFFITypeFlags {
    FTMask   = 0xFFF,
    FFMask   = ~0xFFF
};

// This class only exists for right allocation and deallocation of buffers in an HLFFI call
// We allocate buffers and then store them in a stack
// So that when we want to destroy them, they're destroyed in a nice, recent-to-first order
// (meaning from highest buffer id to lowest buffer id)
function HLFFIBufferStack() constructor {
// private:
    m_stack = ds_stack_create();
// public:
    Buffer  = function(argSizeNumber, argTypeConstant, argAlignmentNumber) {
        if (m_stack < 0) {
            throw new HLFFIException("This buffer stack has already been disposed.", __HLFFI_EXCARGS);
        }
        
        // don't allocate anything on less-than-one size, return a "fake" buffer.
        if (argSizeNumber < 1) {
            return -1;
        }
        
        if (argAlignmentNumber < 1) {
            throw new HLFFIException("Invalid buffer alignment value. Must be one or higher. v=" + string(argAlignmentNumber), __HLFFI_EXCARGS);
        }
        
        var bufid = buffer_create(argSizeNumber, argTypeConstant, argAlignmentNumber);
        if (bufid < 0) {
            throw new HLFFIException("Unable to allocate a new buffer for the stack.", __HLFFI_EXCARGS);
        }
        
        // ensure that the space will be allocated.
        buffer_fill(bufid, 0, buffer_u8, 0, argSizeNumber);
        // ensure that the buffer seek starts at 0.
        buffer_seek(bufid, buffer_seek_start, 0);
        // push to our funny stack.
        ds_stack_push(m_stack, bufid);
        return bufid;
    };
    Dispose = function() {
        // don't throw anything on double-disposes, they must be allowed.
        if (m_stack < 0) {
            return false;
        }
        
        while (!ds_stack_empty(m_stack)) {
            var bufid = ds_stack_pop(m_stack);
            if (!is_undefined(bufid) && bufid >= 0) {
                buffer_delete(bufid);
            }
        }
        
        ds_stack_destroy(m_stack);
        m_stack = -1;
        return true;
    };
}

function HLFFITypeMap() constructor {
    NullPtr  = ptr(pointer_null);
    PtrSize  = gmffi_raw_sizeof_ptr(); // return (double)(sizeof(char*));
    PtrFmt   = (PtrSize == 4) ? buffer_u32 : buffer_u64;
    TVoid    = HLFFIType.TVoid;
    TInt8    = HLFFIType.TInt8;
    TUInt8   = HLFFIType.TUInt8;
    TInt16   = HLFFIType.TInt16;
    TUInt16  = HLFFIType.TUInt16;
    TInt32   = HLFFIType.TInt32;
    TUInt32  = HLFFIType.TUInt32;
    TInt64   = HLFFIType.TInt64;
    TUInt64  = HLFFIType.TUInt64;
    TFloat   = HLFFIType.TFloat;
    TDouble  = HLFFIType.TDouble;
    TPointer = HLFFIType.TPointer;
    Reverse  = function(argValueEnumHLFFIType) {
        if (argValueEnumHLFFIType & HLFFIType.TVoid)    return "TVoid";
        if (argValueEnumHLFFIType & HLFFIType.TInt8)    return "TInt8";
        if (argValueEnumHLFFIType & HLFFIType.TUInt8)   return "TUInt8";
        if (argValueEnumHLFFIType & HLFFIType.TInt16)   return "TInt16";
        if (argValueEnumHLFFIType & HLFFIType.TUInt16)  return "TUInt16";
        if (argValueEnumHLFFIType & HLFFIType.TInt32)   return "TInt32";
        if (argValueEnumHLFFIType & HLFFIType.TUInt32)  return "TUInt32";
        if (argValueEnumHLFFIType & HLFFIType.TInt64)   return "TInt64";
        if (argValueEnumHLFFIType & HLFFIType.TUInt64)  return "TUInt64";
        if (argValueEnumHLFFIType & HLFFIType.TFloat)   return "TFloat";
        if (argValueEnumHLFFIType & HLFFIType.TDouble)  return "TDouble";
        if (argValueEnumHLFFIType & HLFFIType.TPointer) return "TPointer";
        throw new HLFFIException("Invalid HLFFIType enum value.", __HLFFI_EXCARGS);
    };
    Formats  = function(argValueEnumHLFFIType) {
        if (argValueEnumHLFFIType & HLFFIType.TVoid)    return undefined; // kinda wrong...
        if (argValueEnumHLFFIType & HLFFIType.TInt8)    return buffer_s8;
        if (argValueEnumHLFFIType & HLFFIType.TUInt8)   return buffer_u8;
        if (argValueEnumHLFFIType & HLFFIType.TInt16)   return buffer_s16;
        if (argValueEnumHLFFIType & HLFFIType.TUInt16)  return buffer_u16;
        if (argValueEnumHLFFIType & HLFFIType.TInt32)   return buffer_s32;
        if (argValueEnumHLFFIType & HLFFIType.TUInt32)  return buffer_u32;
        if (argValueEnumHLFFIType & HLFFIType.TInt64)   return buffer_u64;
        if (argValueEnumHLFFIType & HLFFIType.TUInt64)  return buffer_u64;
        if (argValueEnumHLFFIType & HLFFIType.TFloat)   return buffer_f32;
        if (argValueEnumHLFFIType & HLFFIType.TDouble)  return buffer_f64;
        if (argValueEnumHLFFIType & HLFFIType.TPointer) return PtrFmt;
        throw new HLFFIException("Invalid HLFFIType enum value.", __HLFFI_EXCARGS);
    };
    Sizes    = function(argValueEnumHLFFIType) {
        if (argValueEnumHLFFIType & HLFFIType.TVoid) return 0;
        return buffer_sizeof(Formats(argValueEnumHLFFIType));
    };
}

global.HLFFITypes = new HLFFITypeMap();

function HLFFITypeLookup(argValueAny) {
    if (is_string(argValueAny)) {
        return global.HLFFITypes[$ argValueAny];
    }
    else {
        return global.HLFFITypes.Reverse(argValueAny);
    }
}

function HLFFITypeSize(argValueEnumHLFFIType) {
    return global.HLFFITypes.Sizes(argValueEnumHLFFIType);
}

function HLFFITypeFormat(argValueEnumHLFFIType) {
    return global.HLFFITypes.Formats(argValueEnumHLFFIType);
}

function HLFFIException(argMessageString, argMyCallstackArray, argMyInstanceofString) constructor {
    m_message     = argMessageString;
    m_callstack   = argMyCallstackArray;
    m_instanceof  = argMyInstanceofString;
    GetMessage    = function() {
        return m_message;
    };
    GetCallstack  = function() {
        return m_callstack;
    };
    GetInstanceof = function() {
        return m_instanceof;
    };
}

function HLFFIFunction(argMyLibraryObject, argMySymbolObject, argMyHandleString, argRetEnumHLFFIType, argArgsEnumHLFFITypeArrayOpt, argFixedargsNumber, argAbiStringOpt) constructor {
// private:
    m_library                 = argMyLibraryObject; // gc link
    m_symbol                  = argMySymbolObject; // gc link
    m_handle                  = argMyHandleString;
    m_returntype              = argRetEnumHLFFIType;
    m_argumenttypes           = argArgsEnumHLFFITypeArrayOpt;
    m_argumentlen             = -1;
    m_mainvecbuff             = -1;
    m_mainvecptr              = global.HLFFITypes.NullPtr;
    m_myffiabi                = argAbiStringOpt;
    m_retmemstart             = -1;
    m_retmemsize              = 16;
    m_argptrsstart            = -1;
    m_argptrssize             = -1;
    m_numfixedargs            = argFixedargsNumber;
    // this one is not static intentionally.
    PrivatePreAllocateBuffers = function() {
        var ptrsiz = global.HLFFITypes.PtrSize;
        var ptrfmt = global.HLFFITypes.PtrFmt;
        
        // we still need an allocated block of memory even if we have no arguments
        // (index 0 must hold type void)
        m_argumentlen = array_length(m_argumenttypes);
        
        // validate arguments before actually doing anything.
        var rettstr = gmffi_raw_type_ptr(m_returntype);
        if (string_length(rettstr) <= 0) {
            throw new HLFFIException("Invalid return type enum.", __HLFFI_EXCARGS);
        }
        
        var myabi = is_string(m_myffiabi) ? gmffi_raw_abi(m_myffiabi) : m_myffiabi;
        if (myabi < 0) {
            throw new HLFFIException("Invalid FFI abi constant.", __HLFFI_EXCARGS);
        }
        
        var fixedargsn = max(0, m_numfixedargs);
        
        var argsstrs = array_create(m_argumentlen, "");
        for (var i = 0; i < m_argumentlen; ++i) {
            var myargtype = m_argumenttypes[@ i];
            if (i > 0 && (myargtype & HLFFIType.TVoid)) {
                throw new HLFFIException("HLFFIType.TVoid is only allowed as either return type, or argument0.", __HLFFI_EXCARGS);
            }
            
            var myargstr = gmffi_raw_type_ptr(myargtype);
            if (string_length(myargstr) <= 0) {
                throw new HLFFIException("Invalid argument type enum.", __HLFFI_EXCARGS);
            }
            
            argsstrs[@ i] = myargstr;
        }
        
        m_argptrssize = ptrsiz * m_argumentlen;
        
        var mainvecsiz = 0;
        mainvecsiz += 5 * ptrsiz; // pfunction, prettype, pargtypes, retmem, argmem.
        mainvecsiz += 4 * buffer_sizeof(buffer_u32); // nargs, varargs, ffiabi, reserved
        var RETMEMOFFSET = mainvecsiz;
        mainvecsiz += m_retmemsize; // return memory, 16 bytes should be more than enough.
        var ARGPTRSOFFSET = mainvecsiz;
        mainvecsiz += m_argptrssize; // argument ffi type pointers
        var ARGVALSOFFSET = mainvecsiz;
        mainvecsiz += m_argptrssize; // argument value pointers
        
        m_retmemstart = RETMEMOFFSET;
        m_argptrsstart = ARGVALSOFFSET;
        /*
            struct GMFFIData {
                void*        pfunction;
                ffi_type*    prettype;
                ffi_type**   ptypes;
                void*        pretmem;
                void**       pargsmem;
                unsigned int unargs;
                unsigned int varargs;
                unsigned int unffiabi;
                unsigned int ureserved;
            };
        */
        m_mainvecbuff = buffer_create(mainvecsiz, buffer_fixed, 1);
        // -- ensure the memory is allocated and is empty:
        buffer_fill(m_mainvecbuff, 0, buffer_u8, 0, buffer_get_size(m_mainvecbuff));
        buffer_seek(m_mainvecbuff, buffer_seek_start, 0);
        m_mainvecptr = buffer_get_address(m_mainvecbuff);
        // -- function address:
        buffer_write(m_mainvecbuff, ptrfmt, int64(ptr(m_handle)));
        // -- return type:
        buffer_write(m_mainvecbuff, ptrfmt, int64(ptr(rettstr)));
        // -- argument types:
        buffer_write(m_mainvecbuff, ptrfmt, int64(int64(m_mainvecptr) + int64(ARGPTRSOFFSET)));
        var BACKOFFSET = buffer_tell(m_mainvecbuff);
        buffer_seek(m_mainvecbuff, buffer_seek_start, ARGPTRSOFFSET);
        for (var i = 0; i < m_argumentlen; ++i) {
            buffer_write(m_mainvecbuff, ptrfmt, int64(ptr(argsstrs[@ i])));
        }
        buffer_seek(m_mainvecbuff, buffer_seek_start, BACKOFFSET);
        // -- return buffer memory (initialised to 0):
        buffer_write(m_mainvecbuff, ptrfmt, int64(int64(m_mainvecptr) + int64(RETMEMOFFSET)));
        // -- argument pointers (initialised to 0):
        buffer_write(m_mainvecbuff, ptrfmt, int64(int64(m_mainvecptr) + int64(ARGVALSOFFSET)));
        // -- argument count:
        if (m_argumenttypes[@ 0] & HLFFIType.TVoid) {
            // this is intentional, we still reserve space for 1 arg just in case.
            m_argumentlen = 0;
        }
        buffer_write(m_mainvecbuff, buffer_u32, m_argumentlen);
        // -- variadic argument cnt:
        buffer_write(m_mainvecbuff, buffer_u32, fixedargsn);
        // -- ffi abi:
        buffer_write(m_mainvecbuff, buffer_u32, myabi);
        // -- reserved:
        buffer_write(m_mainvecbuff, buffer_u32, 0);
        // we're done here.
    };
    PrivateCreateValueBuffer  = function(argStackStruct, argTypeEnumHLFFIType, argValueAny) {
        var ptrfmt = global.HLFFITypes.PtrFmt;
        var ptrsiz = global.HLFFITypes.PtrSize;
            
        if (argTypeEnumHLFFIType & HLFFIType.TVoid) {
            return global.HLFFITypes.NullPtr;
        }
        else if (argTypeEnumHLFFIType & HLFFIType.TPointer) {
            if (is_string(argValueAny)) {
                // stuff into one buffer...
                var buff = argStackStruct.Buffer(ptrsiz + string_byte_length(argValueAny) + 1, buffer_fixed, ptrsiz);
                buffer_write(buff, ptrfmt, int64(int64(buffer_get_address(buff)) + int64(ptrsiz)));
                buffer_write(buff, buffer_string, argValueAny);
                buffer_seek(buff, buffer_seek_start, 0);
                return buffer_get_address(buff);
            }
            else if (is_array(argValueAny)) {
                var arrlen = array_length(argValueAny);
                // TODO: finish
                throw new HLFFIException("Arrays are not yet implemented.", __HLFFI_EXCARGS);
                buffer_seek(buff, buffer_seek_start, 0);
                return buffer_get_address(buff);
            }
            else if (is_struct(argValueAny)) {
                var buff = argValueAny.ToBuffer();
                
                var ptrwrap = argStackStruct.Buffer(ptrsiz, buffer_fixed, ptrsiz);
                buffer_write(ptrwrap, ptrfmt, int64(buffer_get_address(buff)));
                buffer_seek(ptrwrap, buffer_seek_start, 0);
                return ptrwrap;
            }
            // fall through:
        }
        
        // numeric value:
        var nsiz = HLFFITypeSize(argTypeEnumHLFFIType);
        var buff = argStackStruct.Buffer(nsiz, buffer_fixed, nsiz);
        buffer_write(buff, HLFFITypeFormat(argTypeEnumHLFFIType), argValueAny ?? 0);
        buffer_seek(buff, buffer_seek_start, 0);
        return buffer_get_address(buff);
    };
    PrivateReadReturnValue    = function(argBufferIndex, argTypeEnumHLFFIType) {
        var buff = argBufferIndex;
        if (argTypeEnumHLFFIType & HLFFIType.TVoid) {
            return undefined;
        }
        else if (argTypeEnumHLFFIType & HLFFIType.TPointer) {
            // TODO: do it better?
            return ptr(buffer_read(buff, global.HLFFITypes.PtrFmt));
        }
        
        return buffer_read(buff, HLFFITypeFormat(argTypeEnumHLFFIType));
    };
    PrivateCallImplementation = function() {
        // only allocate stuff on first call,
        // -1 means was not initialised yet.
        if (m_argumentlen == -1) {
            PrivatePreAllocateBuffers(); 
        }
        
        // clear out return memory...
        buffer_fill(m_mainvecbuff, m_retmemstart, buffer_u8, 0, m_retmemsize);
        
        // do we have arguments?
        var buffstack = undefined;
        if (m_argumentlen > 0) {
            // empty out arg pointers to NULL...
            //buffer_fill(m_mainvecbuff, m_argptrsstart, buffer_u8, 0, m_argptrssize);
            // before allocating anything ensure we have enough arguments
            // (excess arguments are ignored)
            if (argument_count < m_argumentlen) {
                throw new HLFFIException("Not enough arguments provided to callable.", __HLFFI_EXCARGS);
            }
            // -- args begin:
            buffstack = new HLFFIBufferStack();
            buffer_seek(m_mainvecbuff, buffer_seek_start, m_argptrsstart);
            var ptrfmt = global.HLFFITypes.PtrFmt;
            for (var i = 0; i < m_argumentlen; ++i) {
                var mytype = m_argumenttypes[@ i];
                var myarg = argument[i];
                buffer_write(m_mainvecbuff, ptrfmt, int64(PrivateCreateValueBuffer(buffstack, mytype, myarg)));
            }
        }
        
        // -- do the call:
        buffer_seek(m_mainvecbuff, buffer_seek_start, 0);
        var callstatus = gmffi_raw_library_function_call(m_mainvecptr);
        var callok = callstatus == 1.0;
        
        // -- dispose arguments if any:
        if (!is_undefined(buffstack)) {
            for (var i = 0; i < m_argumentlen; ++i) {
                var mytype = m_argumenttypes[@ i];
                var myarg = argument[i];
                
                if (mytype & HLFFIType.TPointer) {
                    if (is_struct(argument[i])) {
                        // post call deserialize.
                        myarg.FromBuffer(callok);
                    }
                }
            }
            
            buffstack.Dispose();
            buffstack = undefined;
        }
        
        if (!callok) {
            throw new HLFFIException("HLFFI function call failed. st=" + string(callstatus), __HLFFI_EXCARGS);
        }
        
        // -- parse ret value:
        buffer_seek(m_mainvecbuff, buffer_seek_start, m_retmemstart);
        return PrivateReadReturnValue(m_mainvecbuff, m_returntype);
    };
}

function HLFFISymbol(argMyLibraryObject, argMyHandleString) constructor {
// private:
    m_library      = argMyLibraryObject; // gc link
    m_handle       = string(argMyHandleString);
// public:
    DefineFunction = function(argReturnEnumHLFFIType, argArgumentsEnumHLFFIType, argFixedargsNumber, argAbiEnumHLFFIAbi, argFuncOutOpt) {
        var rtt = argReturnEnumHLFFIType ?? HLFFIType.TVoid;
        var argtt = argArgumentsEnumHLFFIType;
        // no need to allocate arguments?
        if (is_undefined(argtt) || array_length(argtt) <= 0) {
            // we must have at least one element in the array
            argtt = [ HLFFIType.TVoid ];
        }
        // empty string is default abi
        var ffiabi = argAbiEnumHLFFIAbi ?? "";
        var fixedn = argFixedargsNumber ?? 0;
        
        var hlfunc = new HLFFIFunction(m_library, self, m_handle, rtt, argtt, fixedn, ffiabi);
        if (!is_undefined(argFuncOutOpt)) {
            argFuncOutOpt.val = hlfunc.PrivateCallImplementation;
            return self;
        }
        else {
            return hlfunc.PrivateCallImplementation;
        }
    };
    GetLibrary     = function() {
        return m_library;
    };
    toString       = function() {
        if (string_length(m_handle) > 0) {
            return "HLFFISymbol: " + string(m_handle);
        }
        else {
            return "HLFFISymbol: Undefined symbol.";
        }
    };
}

function HLFFILibrary() constructor {
// private:
    m_handle      = "";
// public:
    Load          = function(argLibraryPathString) {
        if (string_length(m_handle) > 0) {
            throw new HLFFIException("This library is already loaded, instantiate a new class please.", __HLFFI_EXCARGS);
        }
        
        var hh = gmffi_raw_library_load(string(argLibraryPathString));
        if (string_length(hh) <= 0) {
            throw new HLFFIException("Library load was unsuccessful.", __HLFFI_EXCARGS);
        }
        
        m_handle = hh;
        return self;
    };
    ResolveSymbol = function(argSymbolString, argSymbolOutOpt) {
        if (string_length(m_handle) <= 0) {
            throw new HLFFIException("This library was not defined yet, call Load() please.", __HLFFI_EXCARGS);
        }
        
        var hh = gmffi_raw_library_resolve(m_handle, string(argSymbolString));
        if (string_length(hh) <= 0) {
            throw new HLFFIException("Symbol resolve was unsuccessful.", __HLFFI_EXCARGS);
        }
        
        var symb = new HLFFISymbol(self, hh);
        if (!is_undefined(argSymbolOutOpt)) {
            argSymbolOutOpt.val = symb;
            return self;
        }
        else {
            return symb;
        }
    };
    toString      = function() {
        if (string_length(m_handle) > 0) {
            return "HLFFILibrary: " + string(m_handle);
        }
        else {
            return "HLFFILibrary: No library loaded";
        }
    };
}
