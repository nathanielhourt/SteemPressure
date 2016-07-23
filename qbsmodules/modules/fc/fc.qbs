import qbs
import qbs.File
import qbs.Environment

Module {
    Depends { name: "cpp" }
    property string fcPath: Environment.getEnv("FC_PATH")
    property bool found: File.exists(fcPath+"/lib/libfc_debug.a") || File.exists(fcPath+"/lib/libfc.a")
    property bool debug: {
       var isDebug = File.exists(fcPath+"/lib/libfc_debug.a");
       console.log(isDebug? "Configuring for debug FC build" : "Configuring for release FC build");
       return isDebug;
    }
    cpp.includePaths: fcPath+"/include"
    cpp.libraryPaths: [fcPath+"/lib", fcPath+"/lib/cryptonomex"]
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
        debug? "fc_debug" : "fc",
        "secp256k1",
        "z"
    ]
}
