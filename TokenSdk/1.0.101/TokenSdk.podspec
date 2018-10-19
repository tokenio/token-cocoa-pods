#
# Performs protos codegen. The code is adopted after examples distributed with
# gRPC.
#

def Pod::tokenSdkVer; "1.0.101"; end

Pod::Spec.new do |s|
    s.name     = "TokenSdk"
    s.version  = tokenSdkVer
    s.license  = "New BSD"
    s.authors  = { "Token" => "eng@token.io" }
    s.homepage = "http://www.token.io/"
    s.source = { :git => "https://github.com/tokenio/sdk-objc.git",
                 :tag => "v1.0.101",
                 :submodules => true }
    s.summary = "Token Objective-C SDK"

    s.platform = :osx, '10.11'
    s.platform = :ios, '9.0'

    # Files generated by protoc

    # Where the gRPC and proto generated files were placed
    gendir = "src/generated"

    # Non arc protoc *.m files and all generated headers
    # These headers need the directory structure preserved
    s.subspec "Messages" do |ss|
        ss.public_header_files = gendir
        ss.header_mappings_dir = gendir
        ss.source_files = "#{gendir}/*.pbobjc.m", "#{gendir}/**/*.pbobjc.m", "#{gendir}/**/*.h"
        ss.exclude_files = "#{gendir}/fank/*"
        ss.requires_arc = false
        ss.dependency "Protobuf"
    end

    # SDK & gRPC plugin on top of Messages. Needs arc
    s.subspec "Implementation" do |ss|
        ss.source_files = "src/api/*.{h,c,m}","src/rpc/*.{h,c,m}","src/authorization/*.{h,c,m}","src/security/*.{h,c,m}",
                "src/util/*.{h,c,m}","src/ed25519/src/*.{h,c,m}","src/security/**/*.{h,c,m}",
                "#{gendir}/*.pbrpc.m", "#{gendir}/**/*.pbrpc.m"
        ss.ios.source_files = "src/authorization/ios/*.{h,c,m}"
        ss.requires_arc = true
        ss.public_header_files = "src/api", "src/security", "src/security/secureenclave", "src/authorization/", "src/security/token", "src/util"
        ss.ios.public_header_files =  "src/authorization/ios"
        ss.exclude_files = "**/*_test.*","**/test_*.*","**/test/*.*","**/test.*", "#{gendir}/fank/*"
        ss.dependency "BoringSSL-GRPC"
        ss.dependency "gRPC-ProtoRPC"
        ss.dependency "#{s.name}/Messages"
        ss.dependency "OrderedDictionary"
        ss.platform = :osx, '10.11'
        ss.platform = :ios, '9.0'
    end

    # SDK resources
    s.subspec "Resources" do |ss|
        ss.resource = "resources/*.lproj/*.*",  "resources/*.*"
        ss.ios.resource = "resources/ios/*.*"
    end

    currentdir = Dir.getwd

    s.pod_target_xcconfig = {
       # This is needed by all pods that depend on Protobuf:
       'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
       # This is needed by all pods that depend on gRPC-RxLibrary:
       'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
       # Needed to find our generated headers that are quoted
       'HEADER_SEARCH_PATHS' => "'#{currentdir}/#{gendir}' \"${PODS_ROOT}/TokenSdk/src/generated\" \"${PODS_ROOT}/TokenSdk/src/generated/fank\""
    }
end
