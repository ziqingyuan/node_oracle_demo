#!/bin/bash

# Set Oracle environment
if [ -d /opt/oracle/instantclient_19_8 ]; then
    export ORACLE_HOME=/opt/oracle/instantclient_19_8
    export LD_LIBRARY_PATH=$ORACLE_HOME
elif [ -d /usr/lib/oracle/19.6/client64/lib ]; then
    export ORACLE_HOME=/usr/lib/oracle/19.6/client64
    # 19.* libraries will be already configured by ldconfig
    #export LD_LIBRARY_PATH=$ORACLE_HOME/lib
elif [ -d /usr/lib/oracle/12.2/client64/lib ]; then
    export ORACLE_HOME=/usr/lib/oracle/12.2/client64
    export LD_LIBRARY_PATH=$ORACLE_HOME/lib
else
    echo "Oracle not found..."
    exit 1
fi


# need to change after packages installed in such specific directory
#export NODE_PATH=/Users/Shared/node_shared_libs


# File path
ENV_SERVER_PATH="./.env"

# Define a range
START=50000
END=60000

# Loop through the range and check if the port is in use
for PORT in $(seq $START $END); do
    # Use lsof to check if the port is in use
    if ! lsof -i :$PORT > /dev/null; then
        # Bind to the port using a temporary process
        nc -l -p $PORT &
        TEMP_PID=$!

        # Update the .env file
        sed -i "/^PORT=/c\PORT=$PORT" $ENV_SERVER_PATH
        echo "Updated $ENV_SERVER_PATH with PORT=$PORT."

        # Kill the temporary process
        kill $TEMP_PID

        # Replace the bash process with the Node process
        exec node server.js
        break
    fi
done

