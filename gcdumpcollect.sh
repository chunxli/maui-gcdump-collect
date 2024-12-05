#!/bin/bash

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

run_command() {
  COMMAND="$*"
  osascript << EOF
tell application "Terminal"
    do script "$COMMAND"
    activate
end tell
EOF
}

if [[ "$ARG1" == "ios" ]]; then
	COMMAND='dotnet-dsrouter ios'
elif [[ "$ARG1" == "ios-sim" ]]; then
	COMMAND='dotnet-dsrouter ios-sim'
else
	echo "Use ios-sim by default"
	echo "Usage: gcdumpcollect.sh ios|ios-sim"
	echo "App Runs on iOS Device: gcdumpcollect.sh ios"
	echo "App Runs on iOS Simulator: gcdumpcollect.sh ios-sim"
	COMMAND='dotnet-dsrouter ios-sim'
fi

echo "Running command: $COMMAND"
run_command $COMMAND


if [[ "$ARG1" == "ios" ]]; then
    COMMAND="cd $WORKDIR && $MLAUNCH --launchdev $PROJECT_NAME/bin/$CONFIGURATION/$TARGET_FRAMEWORK/$DEVICE_RUNTIMEIDENTIFIER/$APP_NAME --devname $DEVICE_NAME --wait-for-exit --stdout=$(tty) --stderr=$(tty) --argument --connection-mode --argument none '--setenv:DOTNET_DiagnosticPorts=127.0.0.1:9000,nosuspend,listen'"
elif [[ "$ARG1" == "ios-sim" ]]; then    
	COMMAND="cd $WORKDIR && $MLAUNCH --launchsim=$PROJECT_NAME/bin/$CONFIGURATION/$TARGET_FRAMEWORK/$SIM_RUNTIMEIDENTIFIER/$APP_NAME --device :v2:runtime=$SIM_RUNTIME,devicetype=$SIM_DEVICE_TYPE --wait-for-exit --stdout=$(tty) --stderr=$(tty) --argument --connection-mode --argument none '--setenv:DOTNET_DiagnosticPorts=127.0.0.1:9000,nosuspend,listen'"
else
	exit 1
fi

echo "Running command: $COMMAND"
run_command $COMMAND

echo "Waiting for mlaunch running..."
sleep 5

PS_OUTPUT=$(dotnet-gcdump ps | grep 'dotnet-dsrouter' | awk '{print $1}')
COMMAND="dotnet-gcdump ps && cd $WORKDIR && dotnet-gcdump collect -p $PS_OUTPUT"

echo "Running command: $COMMAND"
run_command $COMMAND
