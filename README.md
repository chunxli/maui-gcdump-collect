# maui-gcdump-collect
Script to collect dotnet maui gcdump

1. Update the following parameters in the script: gcdumpcollect.sh based on your project and environment:

```
PROJECT_NAME='<YOUR PROJECT NAME>'
APP_NAME='<YOUR PROJECT NAME>.app'

WORKDIR='<YOUR PROJECT PATH>'

TARGET_FRAMEWORK='net9.0-ios'
CONFIGURATION='Debug'

DEVICE_RUNTIMEIDENTIFIER='ios-arm64'
# Run command: `xcrun xctrace list devices` to get the device name
DEVICE_NAME="Kevin’s iPhone"

SIM_RUNTIMEIDENTIFIER='iossimulator-x64'
# Run command: `xcrun simctl list runtimes` to get the runtime
SIM_RUNTIME='com.apple.CoreSimulator.SimRuntime.iOS-18-1'
# Run command: `xcrun simctl list devicetypes` to get the device type
SIM_DEVICE_TYPE='com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro'

# Run command: `cd /usr/local/share/dotnet/packs/ && ls Microsoft.iOS.Sdk.net*` to get the available version
MLAUNCH='/usr/local/share/dotnet/packs/Microsoft.iOS.Sdk.net9.0_18.0/18.0.9617/tools/bin/mlaunch'
```

2. Save the script.
3. `chmod +x ./gcdumpcollect.sh`
4. Run `./gcdumpcollect.sh` ios-sim for Simulator
5. Run `./gcdumpcollect.sh` ios-sim for Device
