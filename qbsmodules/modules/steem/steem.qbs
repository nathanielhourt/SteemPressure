import qbs
import qbs.File
import qbs.Environment

Module {
    Depends { name: "cpp" }
    property string steemPath: Environment.getEnv("STEEM_PATH")
    property bool found: File.exists(steemPath+"/lib/libsteem_app.a")
    cpp.includePaths: steemPath+"/include"
    cpp.libraryPaths: [steemPath+"/lib", steemPath+"/lib/cryptonomex"]
    cpp.staticLibraries: [
        "boost_system",
        "boost_filesystem",
        "boost_program_options",
        "boost_chrono",
        "boost_date_time",
        "boost_coroutine",
        qbs.hostOS.contains("osx")? "boost_context-mt" : "boost_context",
        qbs.hostOS.contains("osx")? "boost_thread-mt" : "boost_thread",
        "ssl",
        "crypto",
        "fc",
        "steemit_chain",
        "secp256k1",
        "z"
    ]
}
