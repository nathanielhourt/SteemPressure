import qbs

Project {
    Application {
        name: "Pressure"

        qbsSearchPaths: "qbsmodules"

        Depends { name: "Qt"; submodules: ["quick", "network", "websockets"] }
        Depends { name: "cpp" }
        Depends { name: "fc" }
        Depends { name: "libqtqmltricks-qtqmlmodels" }

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

    SubProject {
        filePath: "vendor/QtQmlModels/QtQmlModels.qbs"
        Properties {
            name: "QtQmlModels"
        }
    }
}
