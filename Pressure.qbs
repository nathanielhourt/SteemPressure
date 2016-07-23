import qbs

Application {
    name: "Pressure"

    qbsSearchPaths: "qbsmodules"

    Depends { name: "Qt"; submodules: ["quick", "network", "websockets"] }
    Depends { name: "cpp" }
    Depends { name: "fc" }

    cpp.cxxLanguageVersion: "c++14"

    files: [
        "KeyPair.cpp",
        "KeyPair.hpp",
        "main.cpp",
        "qml.qrc",
        "*.qml",
    ]
}
