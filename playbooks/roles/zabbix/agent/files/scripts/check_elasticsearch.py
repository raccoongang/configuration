#!/usr/bin/env /etc/zabbix/.venv/bin/python
# -*- coding: utf-8 -*-

from elasticsearch import Elasticsearch
import sys

# Try to establish a connection to elasticsearch.
try:
    es = Elasticsearch()
except Exception as e:
    print 'Connection failed.'
    sys.exit(1)

# Print error message in case of unsupported  metric.
def err_message(option, metric):

    print "%s metric is not under support for %s option." % (metric, option)
    sys.exit(1)


def cluster_health(metric):

    result = es.cluster.health()

    print result[metric]


def cluster_mem_stats(metric):

    result = es.cluster.stats()
    size = result['nodes']['jvm']['mem'][metric]

    print size


def node_mem_stats(metric):

    node_stats = es.nodes.stats(node_id='_local', metric='jvm')
    node_id = node_stats['nodes'].keys()[0]

    if 'heap_used_percent' in metric:

        result = node_stats['nodes'][node_id]['jvm']['mem'][metric]
        print result
    else:
        if 'pool_young' in metric:

            result = node_stats['nodes'][node_id]['jvm']['mem']['pools']['young']
            size = result['used_in_bytes']
        elif 'pool_old' in metric:

            result = node_stats['nodes'][node_id]['jvm']['mem']['pools']['old']
            size = result['used_in_bytes']
        elif 'pool_survivor' in metric:

            result = node_stats['nodes'][node_id]['jvm']['mem']['pools']['survivor']
            size = result['used_in_bytes']
        else:

            result = node_stats['nodes'][node_id]['jvm']['mem']
            size = result[metric]

        print size


def node_index_stats(metric):

    node_stats = es.nodes.stats(node_id='_local', metric='indices')
    node_id = node_stats['nodes'].keys()[0]

    if metric == 'total_merges_mem':
        result = node_stats['nodes'][node_id]['indices']['merges']
        size = result['total_size_in_bytes']

    if metric == 'total_filter_cache_mem':
        result = node_stats['nodes'][node_id]['indices']['filter_cache']
        size = result['memory_size_in_bytes']

    if metric == 'total_field_data_mem':
        result = node_stats['nodes'][node_id]['indices']['fielddata']
        size = result['memory_size_in_bytes']

    print size


# Definition of checks

cluster_checks = {'active_primary_shards': cluster_health,
                  'active_shards': cluster_health,
                  'number_of_pending_tasks': cluster_health,
                  'relocating_shards': cluster_health,
                  'status': cluster_health,
                  'unassigned_shards': cluster_health,
                  'number_of_nodes': cluster_health,
                  'heap_max_in_bytes': cluster_mem_stats,
                  'heap_used_in_bytes': cluster_mem_stats}

node_checks = {'heap_pool_young_gen_mem': node_mem_stats,
               'heap_pool_old_gen_mem': node_mem_stats,
               'heap_pool_survivor_gen_mem': node_mem_stats,
               'heap_max_in_bytes': node_mem_stats,
               'heap_used_in_bytes': node_mem_stats,
               'heap_used_percent': node_mem_stats,
               'total_filter_cache_mem': node_index_stats,
               'total_field_data_mem': node_index_stats,
               'total_merges_mem': node_index_stats}


if __name__ == '__main__':

    if len(sys.argv) < 3:
        print "Positional arguments count should be 3."
        sys.exit(2)

    try:
        if sys.argv[1] == 'cluster':
            cluster_checks.get(sys.argv[2])(sys.argv[2])

        if sys.argv[1] == 'node':
            node_checks.get(sys.argv[2])(sys.argv[2])

    except TypeError:
        err_message(sys.argv[1], sys.argv[2])
