#!/bin/bash

# Quick switch to launch the wallet by default instead while preserving
# the single entrypoint.
USE_WALLET_BINARY=${USE_WALLET_BINARY:=false}

# NOTE(canardleteer): Zano isn't quite yet aligned toward environment
#                     configuration (afaik), so I'm leaving just using
#                     a broken out script to figure out what I want.

# exec so the binary replaces bash as PID 1: without it, bash (which installs
# no SIGTERM handler as a non-interactive PID 1) swallows the stop signal,
# `docker stop` waits out the full grace period and then SIGKILLs the daemon
# mid-flush — stop_grace_period in the compose files would be ineffective.
if [ "${USE_WALLET_BINARY}" = true ]; then
    exec /usr/bin/simplewallet "$@"
else
    exec /usr/bin/zanod "$@"
fi

