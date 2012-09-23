#!/bin/sh
# -*- mode:shell-script; coding:utf-8 -*-

# ALL_NODES=(hibari1 hibari2 hibari3)
ALL_NODES=(hibari)

die() {
    echo $@
    exit 1
}

delete_node_data() {
   local N0=${#ALL_NODES[@]}
   local N=$(($N0 - 1))

   for I in `seq 0 $N`; do
       (
           local NODE=${ALL_NODES[$I]}
           cd $HIBARI_HOME/rel/$NODE; \
               rm -rf data/* || \
               die "node $NODE reset failed"
           rm Schema.local
           echo deleted data on $NODE
       ) &
   done

   wait
}

delete_node_data
