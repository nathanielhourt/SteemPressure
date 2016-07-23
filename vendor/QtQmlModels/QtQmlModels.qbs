import qbs;

Project {
    name: "Qt QML Models";

    Product {
        name: "libqtqmltricks-qtqmlmodels";
        type: "staticlibrary";
        targetName: "QtQmlModels";
        cpp.cxxLanguageVersion: "c++11"

        Export {
            cpp.includePaths: ".";
            cpp.cxxLanguageVersion: "c++11"

            Depends { name: "cpp"; }
            Depends {
                name: "Qt";
                submodules: ["core", "qml"];
            }
        }
        Depends { name: "cpp"; }
        Depends {
            name: "Qt";
                submodules: ["core", "qml"];
        }
        Group {
            name: "C++ sources";
            files: [
                "QQmlObjectListModel.cpp",
                "QQmlVariantListModel.cpp",
            ]
        }
        Group {
            name: "C++ headers";
            files: [
                "QQmlObjectListModel.h",
                "QQmlVariantListModel.h",
                "QtQmlTricksPlugin_SmartDataModels.h",
            ]
        }
        Group {
            qbs.install: (product.type === "dynamiclibrary");
            fileTagsFilter: product.type;
        }
    }
}
