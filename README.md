# maui-gcdump-collect
Script to collect dotnet MAUI GC dumps, iOS only currently.

## Usage

### Quick Start
1. Update the configuration parameters in `gcdumpcollect.sh` (see Configuration section below)
2. Run the script:
   ```bash
   ./gcdumpcollect.sh ios-sim    # For iOS Simulator
   ./gcdumpcollect.sh ios        # For physical iOS device
   ./gcdumpcollect.sh --help     # Show help information
   ```

Update the following parameters in the script `gcdumpcollect.sh` based on your project and environment:

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

### Prerequisites
The script will automatically check for the following required tools:
- `dotnet-dsrouter` - .NET diagnostic router
- `dotnet-gcdump` - .NET GC dump collection tool  
- `xcrun` - Xcode command line tools
- `mlaunch` - iOS app launcher (part of .NET iOS SDK)

### Steps
1. Configure the script parameters (see Configuration section above)
2. Make the script executable: `chmod +x ./gcdumpcollect.sh`
3. Run the script:
   - For iOS Simulator: `./gcdumpcollect.sh ios-sim`
   - For physical iOS device: `./gcdumpcollect.sh ios`

### Features
- ✅ Automatic validation of configuration parameters
- ✅ Dependency checking for required tools
- ✅ Improved error handling and user feedback
- ✅ Better command-line help and usage information
- ✅ Shell scripting best practices (shellcheck clean)
