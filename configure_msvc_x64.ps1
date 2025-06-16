param(
    [string]$InstallPrefix = ""
)

# Set up MSVC 64-bit environment

cmd /c '"C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" && set' |
  ForEach-Object {
    $pair = $_ -split '=', 2
    if ($pair.Length -eq 2) {
      [System.Environment]::SetEnvironmentVariable($pair[0], $pair[1], "Process")
    }
  }

# Call Qt's configure.bat with your options

&".\configure.bat"  -skip qtwebengine -skip qtspeech -- -DCMAKE_CXX_FLAGS="/wd4838 /wd4244 /wd4267 /DQT_FORCE_DISABLE_NARROWING_CONVERSIONS" -DQT_FEATURE_quickcontrols2_fluentwinui3=OFF -DCMAKE_INSTALL_PREFIX="$InstallPrefix"