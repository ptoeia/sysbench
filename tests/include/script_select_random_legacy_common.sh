#!/usr/bin/env bash
#
################################################################################
# Common code for select_random_* tests
#
# Expects the following variables and callback functions to be defined by the
# caller:
#
#   DB_DRIVER_ARGS -- extra driver-specific arguments to pass to sysbench
#
#   db_show_table() -- called with a single argument to dump a specified table
#                      schema
################################################################################

set -eu

for test in select_random_points select_random_ranges
do
    ARGS="--test=${SBTEST_INCDIR}/oltp_legacy/${test}.lua $DB_DRIVER_ARGS --oltp-tables-count=8"

    sysbench $ARGS prepare

    db_show_table sbtest1

    for i in $(seq 2 8)
    do
        db_show_table sbtest${i} || true # Error on non-existing table
    done

    sysbench $ARGS --max-requests=100 --num-threads=1 run

    sysbench $ARGS cleanup

    for i in $(seq 1 8)
    do
        db_show_table sbtest${i} || true # Error on non-existing table
    done

    ARGS="--test=${SBTEST_INCDIR}/oltp_legacy/select_random_points.lua $DB_DRIVER_ARGS --oltp-tables-count=8"
done
