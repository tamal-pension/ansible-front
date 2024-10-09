#!/usr/bin/env bash
set -euo pipefail

# Set directories relative to the app_home directory
APP_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
BIN_DIR="$APP_HOME/bin"
LIB_DIR="$APP_HOME/lib"
CONFIG_DIR="$APP_HOME/config"

# JVM options for logging and metrics
LOGGING_OPTS=(
  "-Dvertx.logger-delegate-factory-class-name=io.vertx.core.logging.Log4j2LogDelegateFactory"
)

# General JVM options
GENERAL_OPTS=(
  "-XX:+HeapDumpOnOutOfMemoryError"
  "-XX:+ShowCodeDetailsInExceptionMessages"
)

# Module and export options for Java
MODULE_OPTS=(
  "--add-modules java.se"
  "--add-exports java.base/jdk.internal.ref=ALL-UNNAMED"
  "--add-opens java.base/java.lang=ALL-UNNAMED"
  "--add-opens java.base/java.nio=ALL-UNNAMED"
  "--add-opens java.base/sun.nio.ch=ALL-UNNAMED"
  "--add-opens java.management/sun.management=ALL-UNNAMED"
  "--add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED"
)

# Function to run the Java application
run_app() {
  local jar_file=$1
  local conf_file=$2
  local log_file=$3
  local options_file=$4
  local class_name=$5
  local jmx_port=$6
  local jmx_domain=$7

  local jmx_opts=(
    "-Dcom.sun.management.jmxremote"
    "-Dcom.sun.management.jmxremote.port=$jmx_port"
    "-Dcom.sun.management.jmxremote.local.only=false"
    "-Dcom.sun.management.jmxremote.authenticate=false"
    "-Dcom.sun.management.jmxremote.ssl=false"
  )

  echo "Running $class_name with JMX port $jmx_port and JMX domain $jmx_domain"

  java \
    ${LOGGING_OPTS[@]} \
    ${GENERAL_OPTS[@]} \
    ${jmx_opts[@]} \
    ${MODULE_OPTS[@]} \
    -classpath "$jar_file" \
    io.vertx.core.Launcher run "$class_name" \
    -options "$options_file" \
    -conf "$conf_file"
}

# Move to the app_home directory to execute
cd "$APP_HOME"

# Run pension-site
run_app "$LIB_DIR/pension-user-fat.jar" \
        "$CONFIG_DIR/user.json" \
        "$CONFIG_DIR/log4j2-user.xml" \
        "$CONFIG_DIR/options.json" \
        "com.tamal.pension.user.Server" \
        7778 \
        "pension-user"