{
  "optionsFile": "options.json",
  "options": [],
  "exportToGame": true,
  "supportedTargets": -1,
  "extensionVersion": "0.0.1",
  "packageId": "",
  "productId": "",
  "author": "",
  "date": "2022-02-27T00:15:41.0424664+05:00",
  "license": "",
  "description": "",
  "helpfile": "",
  "iosProps": false,
  "tvosProps": false,
  "androidProps": false,
  "installdir": "",
  "files": [
    {"filename":"libffi.dll","origname":"","init":"","final":"","kind":1,"uncompress":false,"functions":[
        {"externalName":"gmffi_raw_sizeof_ptr","kind":1,"help":"gmffi_raw_sizeof_ptr()","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"gmffi_raw_sizeof_ptr","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"gmffi_raw_library_load","kind":1,"help":"gmffi_raw_library_load(argLibraryString)","hidden":false,"returnType":1,"argCount":0,"args":[
            1,
          ],"resourceVersion":"1.0","name":"gmffi_raw_library_load","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"gmffi_raw_library_resolve","kind":1,"help":"gmffi_raw_library_resolve(argLibraryHandle, argSymbolString)","hidden":false,"returnType":1,"argCount":0,"args":[
            1,
            1,
          ],"resourceVersion":"1.0","name":"gmffi_raw_library_resolve","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"gmffi_raw_type_ptr","kind":1,"help":"gmffi_raw_type_ptr(argTypeEnumHLFFIType)","hidden":false,"returnType":1,"argCount":0,"args":[
            2,
          ],"resourceVersion":"1.0","name":"gmffi_raw_type_ptr","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"gmffi_raw_library_function_call","kind":1,"help":"gmffi_raw_library_function_call(argDataBufferPointer)","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
          ],"resourceVersion":"1.0","name":"gmffi_raw_library_function_call","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"gmffi_raw_abi","kind":1,"help":"gmffi_raw_abi(argAbiString)","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
          ],"resourceVersion":"1.0","name":"gmffi_raw_abi","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[],"ProxyFiles":[
        {"TargetMask":6,"resourceVersion":"1.0","name":"libffi_x64.dll","tags":[],"resourceType":"GMProxyFile",},
        {"TargetMask":7,"resourceVersion":"1.0","name":"libffi_linux.so","tags":[],"resourceType":"GMProxyFile",},
      ],"copyToTargets":-1,"order":[
        {"name":"gmffi_raw_sizeof_ptr","path":"extensions/gmFFI/gmFFI.yy",},
        {"name":"gmffi_raw_library_load","path":"extensions/gmFFI/gmFFI.yy",},
        {"name":"gmffi_raw_library_resolve","path":"extensions/gmFFI/gmFFI.yy",},
        {"name":"gmffi_raw_type_ptr","path":"extensions/gmFFI/gmFFI.yy",},
        {"name":"gmffi_raw_library_function_call","path":"extensions/gmFFI/gmFFI.yy",},
        {"name":"gmffi_raw_abi","path":"extensions/gmFFI/gmFFI.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
    {"filename":"gmffi.c","origname":"","init":"","final":"","kind":4,"uncompress":false,"functions":[],"constants":[],"ProxyFiles":[],"copyToTargets":0,"order":[],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
  ],
  "classname": "",
  "tvosclassname": null,
  "tvosdelegatename": null,
  "iosdelegatename": "",
  "androidclassname": "",
  "sourcedir": "",
  "androidsourcedir": "",
  "macsourcedir": "",
  "maccompilerflags": "",
  "tvosmaccompilerflags": "",
  "maclinkerflags": "",
  "tvosmaclinkerflags": "",
  "iosplistinject": "",
  "tvosplistinject": "",
  "androidinject": "",
  "androidmanifestinject": "",
  "androidactivityinject": "",
  "gradleinject": "",
  "androidcodeinjection": "",
  "hasConvertedCodeInjection": true,
  "ioscodeinjection": "",
  "tvoscodeinjection": "",
  "iosSystemFrameworkEntries": [],
  "tvosSystemFrameworkEntries": [],
  "iosThirdPartyFrameworkEntries": [],
  "tvosThirdPartyFrameworkEntries": [],
  "IncludedResources": [],
  "androidPermissions": [],
  "copyToTargets": -1,
  "iosCocoaPods": "",
  "tvosCocoaPods": "",
  "iosCocoaPodDependencies": "",
  "tvosCocoaPodDependencies": "",
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy",
  },
  "resourceVersion": "1.2",
  "name": "gmFFI",
  "tags": [],
  "resourceType": "GMExtension",
}