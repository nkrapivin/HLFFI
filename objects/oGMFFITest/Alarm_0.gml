/// @description fun[ction]

libc = new HLFFILibrary().Load((os_type == os_windows) ? "msvcrt.dll" : "libc.so");
printf_symbol = libc.ResolveSymbol("printf");
printf_int_dbl = printf_symbol.DefineFunction(
    HLFFIType.TInt32, // return type
    [ HLFFIType.TPointer /* 0=required */, HLFFIType.TInt32 /* 1=variadic */, HLFFIType.TDouble /* 2=variadic */ ],
    1 // <=0?? - static function, >0 - variadic function, how many fixed arguments do you have?
    //[optional] abi name, default is "FFI_DEFAULT_ABI"
    //[optional] return by reference, refthing.val = retval; return self; for fluent stuff
);
printf_str = printf_symbol.DefineFunction(
    HLFFIType.TInt32,
    [ HLFFIType.TPointer, HLFFIType.TPointer ],
    1
);
system_symbol = libc.ResolveSymbol("system");
system = system_symbol.DefineFunction(
    HLFFIType.TInt32,
    [ HLFFIType.TPointer ]
    // not a variadic func
);


printf_int_dbl("Hello, int=%d, funnynumber=%f\n", 1337, 69.420);
printf_str("omg %s\n", "candy!!!!");

var wedidntstartthefire = "https://www.youtube.com/watch?v=dGZLYB-ay34";
if (os_type == os_windows) system("start " + wedidntstartthefire);
else system("xdg-open " + wedidntstartthefire);
