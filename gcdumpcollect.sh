#!/bin/bash

# Exit on any error
set -e

ARG1="${1:-default}"

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

# Function to validate required configuration
validate_config() {
    local errors=0
    
    if [[ "$PROJECT_NAME" == "<YOUR PROJECT NAME>" ]]; then
        echo "Error: PROJECT_NAME must be configured" >&2
        errors=$((errors + 1))
    fi
    
    if [[ "$APP_NAME" == "<YOUR PROJECT NAME>.app" ]]; then
        echo "Error: APP_NAME must be configured" >&2
        errors=$((errors + 1))
    fi
    
    if [[ "$WORKDIR" == "<YOUR PROJECT PATH>" ]]; then
        echo "Error: WORKDIR must be configured" >&2
        errors=$((errors + 1))
    fi
    
    if [[ $errors -gt 0 ]]; then
        echo "Please update the configuration variables in the script before running." >&2
        echo "See README.md for configuration instructions." >&2
        exit 1
    fi
}

# Function to check required tools
check_dependencies() {
    local missing_tools=()
    
    if ! command -v dotnet-dsrouter &> /dev/null; then
        missing_tools+=("dotnet-dsrouter")
    fi
    
    if ! command -v dotnet-gcdump &> /dev/null; then
        missing_tools+=("dotnet-gcdump")
    fi
    
    if ! command -v xcrun &> /dev/null; then
        missing_tools+=("xcrun")
    fi
    
    if [[ ! -f "$MLAUNCH" ]]; then
        missing_tools+=("mlaunch (not found at: $MLAUNCH)")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "Error: The following required tools are missing:" >&2
        printf "  - %s\n" "${missing_tools[@]}" >&2
        echo "Please install the required tools before running this script." >&2
        exit 1
    fi
}

run_command() {
    local command="$*"
    echo "Executing: $command" >&2
    osascript << EOF
tell application "Terminal"
    do script "$command"
    activate
end tell
EOF
}

# Show usage information
show_usage() {
    echo "Usage: $0 [ios|ios-sim]"
    echo ""
    echo "Collect GC dumps from .NET MAUI iOS applications"
    echo ""
    echo "Arguments:"
    echo "  ios        Run on physical iOS device"
    echo "  ios-sim    Run on iOS simulator (default)"
    echo ""
    echo "Examples:"
    echo "  $0 ios        # Collect GC dump from app running on physical device"
    echo "  $0 ios-sim    # Collect GC dump from app running on simulator"
    echo ""
    echo "Configuration:"
    echo "  Before running, update the configuration variables in this script:"
    echo "  - PROJECT_NAME"
    echo "  - APP_NAME"
    echo "  - WORKDIR"
    echo "  - Device/simulator settings"
    echo ""
    echo "See README.md for detailed configuration instructions."
}

# Check for help request first
if [[ "$ARG1" == "help" || "$ARG1" == "--help" || "$ARG1" == "-h" ]]; then
    show_usage
    exit 0
fi

# Validate configuration and dependencies
validate_config
check_dependencies

if [[ "$ARG1" == "ios" ]]; then
    COMMAND='dotnet-dsrouter ios'
elif [[ "$ARG1" == "ios-sim" ]]; then
    COMMAND='dotnet-dsrouter ios-sim'
else
    echo "Using ios-sim by default"
    show_usage
    echo ""
    COMMAND='dotnet-dsrouter ios-sim'
fi

echo "Starting dotnet-dsrouter..."
run_command "$COMMAND"


if [[ "$ARG1" == "ios" ]]; then
    LAUNCH_CMD="cd '$WORKDIR' && '$MLAUNCH' --launchdev '$PROJECT_NAME/bin/$CONFIGURATION/$TARGET_FRAMEWORK/$DEVICE_RUNTIMEIDENTIFIER/$APP_NAME' --devname '$DEVICE_NAME' --wait-for-exit --stdout=\$(tty) --stderr=\$(tty) --argument --connection-mode --argument none '--setenv:DOTNET_DiagnosticPorts=127.0.0.1:9000,nosuspend,listen'"
elif [[ "$ARG1" == "ios-sim" ]]; then    
    LAUNCH_CMD="cd '$WORKDIR' && '$MLAUNCH' --launchsim='$PROJECT_NAME/bin/$CONFIGURATION/$TARGET_FRAMEWORK/$SIM_RUNTIMEIDENTIFIER/$APP_NAME' --device :v2:runtime='$SIM_RUNTIME',devicetype='$SIM_DEVICE_TYPE' --wait-for-exit --stdout=\$(tty) --stderr=\$(tty) --argument --connection-mode --argument none '--setenv:DOTNET_DiagnosticPorts=127.0.0.1:9000,nosuspend,listen'"
else
    exit 1
fi

echo "Launching application..."
run_command "$LAUNCH_CMD"

echo "Waiting for application to start..."
sleep 5

echo "Finding dotnet-dsrouter process..."
PS_OUTPUT=$(dotnet-gcdump ps | grep 'dotnet-dsrouter' | awk '{print $1}')

if [[ -z "$PS_OUTPUT" ]]; then
    echo "Error: Could not find dotnet-dsrouter process" >&2
    echo "Make sure the application is running and dotnet-dsrouter is connected" >&2
    exit 1
fi

echo "Found process ID: $PS_OUTPUT"
COLLECT_CMD="dotnet-gcdump ps && cd '$WORKDIR' && dotnet-gcdump collect -p '$PS_OUTPUT'"

echo "Collecting GC dump..."
run_command "$COLLECT_CMD"
