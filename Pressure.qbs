import qbs

Application {
    name: "Pressure"

    qbsSearchPaths: "qbsmodules"

    Depends { name: "Qt"; submodules: ["quick", "network", "websockets"] }
    Depends { name: "cpp" }
    Depends { name: "fc" }

    cpp.cxxLanguageVersion: "c++14"

    files: [
        "AccountKeys.cpp",
        "AccountKeys.hpp",
        "KeyPair.cpp",
        "KeyPair.hpp",
        "KeyStore.cpp",
        "KeyStore.hpp",
        "main.cpp",
        "qml.qrc",
    ]
}
