param ([String]$mode = 'full')

Set-StrictMode -Version latest
$ErrorActionPreference = 'Stop'

.\dev-env\windows\bin\dadew.ps1 install
.\dev-env\windows\bin\dadew.ps1 sync
.\dev-env\windows\bin\dadew.ps1 enable

write-output "Path before: `n`t ${env:PATH}"

$env:Path='C:\Users\VssAdministrator\dadew\scoop\apps\msys2-20180531\current;D:\a\1\s\dev-env\windows\libexec\..\bin;C:\Users\VssAdministrator\dadew\scoop\shims;C:\WINDOWS\System32\WindowsPowerShell\v1.0'

write-output "Path after: `n`t ${env:PATH}"

write-output "ENV: `n`n"
${gci env:* | sort-object name}

if (!(Test-Path .\.bazelrc.local)) {
   Set-Content -Path .\.bazelrc.local -Value 'build --config windows'
}

$ARTIFACT_DIRS = if ("$env:BUILD_ARTIFACTSTAGINGDIRECTORY") { $env:BUILD_ARTIFACTSTAGINGDIRECTORY } else { Get-Location }

function bazel() {
    Write-Output ">> bazel $args"
    $global:lastexitcode = 0
    $backupErrorActionPreference = $script:ErrorActionPreference
    $script:ErrorActionPreference = "Continue"
    & bazel.exe @args 2>&1 | %{ "$_" }
    $script:ErrorActionPreference = $backupErrorActionPreference
    if ($global:lastexitcode -ne 0 -And $args[0] -ne "shutdown") {
        Write-Output "<< bazel $args (failed, exit code: $global:lastexitcode)"
        throw ("Bazel returned non-zero exit code: $global:lastexitcode")
    }
    Write-Output "<< bazel $args (ok)"
}

function build-partial() {
    bazel clean `-`-expunge

    bazel build @io_tweag_rules_haskell_ghc_windows_amd64//:toolchain

    bazel shutdown

    write-output "----- 1"
    write-output "ls C:\\users\\vssadministrator\\_bazel_vssadministrator\\w3d6ug6o\\execroot\\com_github_digital_asset_daml\\external\\io_tweag_rules_haskell_ghc_windows_amd64\\"
    ls C:\\users\\vssadministrator\\_bazel_vssadministrator\\w3d6ug6o\\execroot\\com_github_digital_asset_daml\\external\\io_tweag_rules_haskell_ghc_windows_amd64\\

    write-output "----- 2"
    write-output "ls C:\\users\\vssadministrator\\_bazel_vssadministrator\\w3d6ug6o\\execroot\\com_github_digital_asset_daml\\external\\io_tweag_rules_haskell_ghc_windows_amd64\\mingw\\include\\c++\\7.2.0\\bits\\stl_raw_storage_iter.h"
    ls C:\\users\\vssadministrator\\_bazel_vssadministrator\\w3d6ug6o\\execroot\\com_github_digital_asset_daml\\external\\io_tweag_rules_haskell_ghc_windows_amd64\\mingw\\include\\c++\\7.2.0\\bits\\stl_raw_storage_iter.h

    write-output "----- 3"
    write-output "ls C:\\users\\vssadministrator\\_bazel_vssadministrator\\w3d6ug6o\\execroot\\com_github_digital_asset_daml\\external\\io_tweag_rules_haskell_ghc_windows_amd64\\mingw\\bin/../lib/gcc/x86_64-w64-mingw32/7.2.0/../../../../include/c++/7.2.0/bits/stl_raw_storage_iter.h"
    ls C:\\users\\vssadministrator\\_bazel_vssadministrator\\w3d6ug6o\\execroot\\com_github_digital_asset_daml\\external\\io_tweag_rules_haskell_ghc_windows_amd64\\mingw\\bin/../lib/gcc/x86_64-w64-mingw32/7.2.0/../../../../include/c++/7.2.0/bits/stl_raw_storage_iter.h

    write-output "----- 4"
    try { bazel build -s @boringssl//:ssl } catch {
        write-output "ERROR: bazel build @boringssl//:ssl - failed!"
    }

    cd C:/users/vssadministrator/_bazel_vssadministrator/w3d6ug6o/execroot/com_github_digital_asset_daml

    write-output "----- 6"
    $env:PATH

    write-output "----- 7"
    ./external/io_tweag_rules_haskell_ghc_windows_amd64/mingw/bin/gcc `-std=gnu++0x `-MD `-MF bazel-out/x64_windows-fastbuild/bin/external/boringssl/_objs/ssl/ssl_session.d `-frandom-seed=bazel-out/x64_windows-fastbuild/bin/external/boringssl/_objs/ssl/ssl_session.o `-iquote external/boringssl `-iquote bazel-out/x64_windows-fastbuild/genfiles/external/boringssl `-iquote bazel-out/x64_windows-fastbuild/bin/external/boringssl `-isystem external/boringssl/src/include `-isystem bazel-out/x64_windows-fastbuild/genfiles/external/boringssl/src/include `-isystem bazel-out/x64_windows-fastbuild/bin/external/boringssl/src/include `-DGRPC_BAZEL_BUILD `-DWIN32_LEAN_AND_MEAN `-DOPENSSL_NO_ASM `-no-canonical-prefixes `-fno-canonical-system-headers `-c external/boringssl/src/ssl/ssl_session.cc `-o bazel-out/x64_windows-fastbuild/bin/external/boringssl/_objs/ssl/ssl_session.o

    write-output "----- 8"
    ls ./bazel-out/x64_windows-fastbuild/bin/external/boringssl/_objs/ssl/ssl_session.o

    bazel shutdown
}

function build-full() {
    # FIXME: Until all bazel issues on Windows are resolved we will be testing only specific bazel targets
    bazel build `-`-experimental_execution_log_file ${ARTIFACT_DIRS}/build_full_execution_windows.log `
        //release:sdk-release-tarball `
        //:git-revision `
        @com_github_grpc_grpc//:grpc `
        //3rdparty/... `
        //nix/third-party/gRPC-haskell:grpc-haskell `
        //daml-assistant:daml `
        //daml-foundations/daml-tools/daml-extension/... `
        //daml-foundations/daml-tools/da-hs-damlc-app:damlc-dist `
        //daml-foundations/daml-tools/docs/... `
        //daml-foundations/daml-tools/language-server-tests:lib-js `
        //daml-lf/archive:daml_lf_archive_scala `
        //daml-lf/archive:daml_lf_archive_protos_zip `
        //daml-lf/archive:daml_lf_archive_protos_tarball `
        //compiler/haskell-ide-core/... `
        //compiler/daml-lf-ast/... `
        //daml-lf/data/... `
        //daml-lf/engine:engine `
        //daml-lf/interface/... `
        //daml-lf/interpreter/... `
        //daml-lf/lfpackage/... `
        //daml-lf/parser/... `
        //daml-lf/repl/... `
        //daml-lf/scenario-interpreter/... `
        //daml-lf/transaction-scalacheck/... `
        //daml-lf/validation/... `
        //extractor:extractor-binary `
        //language-support/java/testkit:testkit `
        //language-support/java/bindings/... `
        //language-support/java/bindings-rxjava/... `
        //ledger/api-server-damlonx:api-server-damlonx `
        //ledger/api-server-damlonx/reference:reference `
        //ledger/backend-api/... `
        //ledger/ledger-api-akka/... `
        //ledger/ledger-api-client/... `
        //ledger/ledger-api-common/... `
        //ledger/ledger-api-domain/... `
        //ledger/ledger-api-server-example/... `
        //ledger/ledger-api-scala-logging/... `
        //ledger/ledger-api-server-example/... `
        //ledger/participant-state/... `
        //ledger/participant-state-index/... `
        //ledger/sandbox:sandbox `
        //ledger/sandbox:sandbox-binary `
        //ledger/sandbox:sandbox-tarball `
        //ledger/sandbox:sandbox-head-tarball `
        //ledger-api/... `
        //navigator/backend/... `
        //navigator/frontend/... `
        //pipeline/... `
        //scala-protoc-plugins/...

    # ScalaCInvoker, a Bazel worker, created by rules_scala opens some of the bazel execroot's files,
    # which later causes issues on Bazel init (source forest creation) on Windows. A shutdown closes workers,
    # which is a workaround for this problem.
    bazel shutdown

    bazel run `
        //daml-foundations/daml-tools/da-hs-damlc-app `-`- `-h

    # ScalaCInvoker, a Bazel worker, created by rules_scala opens some of the bazel execroot's files,
    # which later causes issues on Bazel init (source forest creation) on Windows. A shutdown closes workers,
    # which is a workaround for this problem.
    bazel shutdown

    bazel test `
        //daml-lf/data/... `
        //daml-lf/interface/... `
        //daml-lf/interpreter/... `
        //daml-lf/lfpackage/... `
        //daml-lf/parser/... `
        //daml-lf/validation/... `
        //language-support/java/bindings/... `
        //language-support/java/bindings-rxjava/... `
        //ledger/ledger-api-client/... `
        //ledger/ledger-api-common/... `
        //ledger-api/... `
        //navigator/backend/... `
        //pipeline/...
}

# FIXME:
# @haskell_c2hs//... `
#ERROR: C:/users/vssadministrator/_bazel_vssadministrator/w3d6ug6o/external/haskell_c2hs/BUILD.bazel:16:3: unterminated string literal at eol
#ERROR: C:/users/vssadministrator/_bazel_vssadministrator/w3d6ug6o/external/haskell_c2hs/BUILD.bazel:17:1: unterminated string literal at eol
#ERROR: C:/users/vssadministrator/_bazel_vssadministrator/w3d6ug6o/external/haskell_c2hs/BUILD.bazel:17:1: Implicit string concatenation is forbidden, use the + operator
#ERROR: C:/users/vssadministrator/_bazel_vssadministrator/w3d6ug6o/external/haskell_c2hs/BUILD.bazel:17:1: syntax error at '",
#"': expected ,

Write-Output "Running in $mode mode"

bazel shutdown

if ($mode -eq "partial") {
    build-partial
} else {
    build-full
}
