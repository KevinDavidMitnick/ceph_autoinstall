#!/bin/sh
echo "set eraure code profile"
ceph osd erasure-code-profile set myprofile k=$1 m=$2 ruleset-failure-domain=host

echo "create erasure pool"
ceph osd pool create ecpool 128 128 erasure myprofile

echo "create cache pool"
ceph osd pool create cache 512 512 

echo "set cache pool as tier pool"
ceph osd tier add ecpool cache
ceph osd tier cache-mode cache writeback
ceph osd tier set-overlay ecpool cache

echo "config cache pool"
ceph osd pool set cache hit_set_type bloom
ceph osd pool set cache hit_set_count 1
ceph osd pool set cache hit_set_period 3600
ceph osd pool set cache target_max_bytes 1000000000000
ceph osd pool set cache min_read_recency_for_promote 1
ceph osd pool set cache min_write_recency_for_promote 1

echo "set cache pool flush and evict time period"
ceph osd pool set cache cache_target_dirty_ratio 0.4
ceph osd pool set cache cache_target_dirty_high_ratio 0.6
ceph osd pool set cache cache_target_full_ratio 0.8
