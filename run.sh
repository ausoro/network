#!/bin/bash
# Copyright 2014 CloudHarmony Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
  cat << EOF
Usage: run.sh [options]

Tests network performance characteristics including latency, throughput and
DNS query time metrics. curl, ping and dig are used to conduct tests. 
Throughput test endpoints should have CloudHarmony test files installed on an 
http/https accessible URI (see: https://github.com/cloudharmony/web-probe)


TESTING PARAMETERS
The following test parameters are supported. Parameters with a 'meta_' prefix 
are informational and used in conjunction with use of save.sh

--collectd_rrd              If set, collectd rrd stats will be captured from 
                            --collectd_rrd_dir. To do so, when testing starts,
                            existing directories in --collectd_rrd_dir will 
                            be renamed to .bak, and upon test completion 
                            any directories not ending in .bak will be zipped
                            and saved along with other test artifacts (as 
                            collectd-rrd.zip). User MUST have sudo privileges
                            to use this option
                            
--collectd_rrd_dir          Location where collectd rrd files are stored - 
                            default is /var/lib/collectd/rrd

--abort_threshold           Number of failures to permit before aborting 
                            testing. If set and this number of failures is 
                            reached, testing will stop and no result metrics 
                            will be generated
                            
--discard_fastest           If set, this percentage of the fastest metrics will 
                            be discarded prior to metric calculations (mean, 
                            median, standard deviation)
                            
--discard_slowest           If set, this percentage of the slowest metrics will 
                            be discarded prior to metric calculations (mean, 
                            median, standard deviation)

--dns_one_server            If set, only 1 (randomly selected) authoritative 
                            DNS server will be tested for each --test_endpoint 
                            for DNS testing
                            
--dns_recursive             Use recursive instead of authoritative queries for
                            DNS tests (uses the name servers in 
                            /etc/resolv.conf)
                            
--dns_retry                 Optional explicit number of (UDP) DNS query retries
                            (default is 2)
                            
--dns_samples               The number of test samples for DNS tests. Default 
                            is 10. DNS queries will be performed against 
                            delegated servers in round robin order. If 
                            --dns_one_server is set, each test will use just 1 
                            randomly selected server
                            
--dns_tcp                   Perform DNS tests with TCP queries (default is UDP)
                            
--dns_timeout:              Timeout in seconds for DNS queries. Default is 5 
                            seconds
                            
--geoiplookup               Get --test_endpoint locations using a geoiplookup
                            if --test_location is not specified. In order to 
                            use this option, geoiplookup must be installed with 
                            current country/state GeoIp databases (may required 
                            commercial licensing - geoiplookup is a command 
                            line tool from MaxMind included in the GeoIP 
                            package)
                            
--geo_regions               Geo regions to use for *_geo_region parameters and 
                            included in results. This parameter should be a 
                            comma or space separated list of desired geo region 
                            identifiers. The file lib/config/geo-regions.ini 
                            lists and defines the possible identifiers 
                            including associated countries/states. Default for 
                            this parameter is:
                            
                            us_west us_central us_east canada 
                            eu_west eu_central eu_east 
                            oceania asia america_south africa
                            
                            Geo region associations are based on first match.
                            For example, based on the default value above, 
                            Australia match 'oceania' even though AU is listed 
                            in both oceania and asia_apac regions
                            
--latency_interval          Wait interval seconds between sending each packet.
                            Only super-user may set interval to values less 0.2 
                            seconds. Default is 0.2
                            
--latency_samples           The number of test samples for latency tests. 
                            Default is 100
                            
--latency_skip              Endpoint, service or provider ID to ignore latency 
                            tests for. May be repeated for multiple
                            
--latency_timeout:          Timeout in seconds for latency tests. Default is 3
                            seconds
                            
--max_runtime               Optional max runtime in seconds - if this time is 
                            reached before all tests have completed, testing 
                            will stop and report on the completed tests

--max_tests                 Optional max number of tests to perform. If the 
                            number of tests assigns exceeds this number testing
                            will stop and report on the completed tests

--meta_compute_service      Optional name of the service for the compute 
                            instance performing the tests (e.g. Amazon EC2)

--meta_compute_service_id   Optional id of the service for the compute instance 
                            performing the tests (e.g. aws:ec2)
                            
--meta_cpu                  CPU descriptor - if not specified, it will be set 
                            using 'model name' from /proc/cpuinfo
                            
--meta_instance_id          Optional compute service instance type identifier
                            (e.g. c3.xlarge)
                            
--meta_location             Optional geographical location of the compute 
                            instance performing tests. This parameter may be 
                            either a two character ISO 3166 country code, or a 
                            state abbreviation and country code. (e.g. 
                            --meta_location "CA, US" or --meta_location US)
                            
--meta_memory               Memory description - if not specified, the system
                            memory size will be used
                            
--meta_os                   Operating system description - if not set, the 
                            first line of /etc/issue will be used
                            
--meta_provider             Optional name of the provider for the compute 
                            instance performing the tests (e.g. Amazon)

--meta_provider_id          Optional id of the provider for the compute instance 
                            performing the tests (e.g. aws)
                            
--meta_region               Optional region name or identifier for the compute 
                            instance performing the tests (e.g. us-east-1)
                            
--meta_resource_id          Optional unique identifier of the compute instance
                            performing the tests (e.g. 1234)
                            
--meta_run_id               Optional unique identifier for the test (e.g. 4567)
                            
--meta_test_id              Optional unique identifier for a sequential of 
                            tests (e.g. aws-0914)
                            
--min_runtime               May define an optional minimum runtime. If testing
                            completes before this time is reached, the process
                            will sleep for the remaining duration
                            
--min_runtime_in_save       If set, --min_runtime will be applied by save.sh
                            
--output                    The output directory for writing test artifacts. If 
                            not specified, the current working directory will
                            be used
                            
--params_url                Optional URL that will respond to requests with one
                            or more JSON encoded test parameters. This URL 
                            should support GET requests and provide a 2XX 
                            response code. The response body should be a JSON 
                            encoded string containing a hash with one or more 
                            parameters. If duplicate parameters exist between
                            the command line and URL, command line parameters 
                            have precedence
                            
--params_url_service_type   Optional service type filter to apply to test 
                            endpoints defined by --params_url. Services not of 
                            this type (or with no type defined) will not be 
                            tested. This parameter may be repeated for multiple
                            service types
                            
--params_url_header         Optional request header(s) to set for --params_url.
                            These should use the format [name]:[value]. This 
                            parameter may be repeated for multiple headers
                            (e.g. api_key:12345)
                            
--randomize                 If set, the order of testing will be randomized 
                            (if multiple tests are defined)
                            
--same_continent_only:      If set, only --test_endpoint hosts located in the 
                            same continent will be tested (others are skipped)
                            Does not apply to CDN or DNS services
                            
--same_country_only:        If set, only --test_endpoint hosts located in the 
                            same country will be tested (others are skipped)
                            Does not apply to CDN or DNS services
                            
--same_geo_region           If set, only --test_endpoint hosts located in the 
                            same geo region will be tested (others are skipped)
                            See --geo_regions parameter above. Does not apply 
                            to CDN or DNS services

--same_provider_only:       If set, only --test_endpoint hosts from the same 
                            provider (e.g. aws) will be tested (others are 
                            skipped)

--same_region_only:         If set, only --test_endpoint hosts from the same 
                            service and service region (e.g. us-east-1) will be 
                            tested (others are skipped)

--same_service_only:        If set, only --test_endpoint hosts from the same 
                            service (e.g. aws:ec2) will be tested (others are 
                            skipped)

--same_state_only:          If set, only --test_endpoint hosts located in the 
                            same country and state will be tested (others are 
                            skipped). Does not apply to CDN or DNS services
                            
--service_lookup            If set, the CloudHarmony 'Identify Service' API 
                            method will be used to attempt to correlate 
                            --test_endpoint hosts to their associated cloud 
                            provider, service, service type, region and 
                            location. For more information, see:
                            https://cloudharmony.com/docs/api#!/api/GET_Identify_Service
                            NOTE: if used, response will be cached in /tmp
                                                        
--sleep_before_start        an optional numeric value or range defining a 
                            sleep period (seconds) to apply before starting 
                            testing. If a single numeric value, that exact 
                            period will be applied. If a range of values 
                            (e.g. 30-90), then a random sleep period will be 
                            applied within that range
                            
--spacing                   Spacing in milliseconds to apply between each 
                            test (default is 200 ms => 1/5 second)
                            
--suppress_failed           If set, failed tests will be excluded from results 
                            generated by save.sh. Otherwise, they are included 
                            with status=failed
                            
--test                      The test(s) to perform - one of the following:
                              latency    test latency using ping - use of this 
                                         test requires ICMP connectivity to
                                         --test_endpoint
                              downlink   test downlink throughput - use of this  
                                         or uplink tests require the 
                                         CloudHarmony web-probe repository be 
                                         http/https accessible on 
                                         --test_endpoint (see --throughput_uri)
                              uplink     test uplink throughput - use of this 
                                         test requires support for large POST 
                                         requests against the URI 
                                         [throughput_uri]/up.html
                              throughput test both downlink and uplink
                              dns        measure the time to make a DNS query. 
                                         Authoritative name servers for the 
                                         domain in --test_endpoint will be used 
                                         for this testing unless the 
                                         --dns_recursive flag is set
                            Multiple tests may be specified each separated by a
                            space or comma. If multiple --test_endpoint 
                            parameters are specified, --test may be specified 
                            just once (all test endpoints have the same tests),
                            or multiple times (different tests for each test 
                            endpoint). Default value for this parameter is 
                            'latency'
                            
--test_endpoint             REQUIRED: hostname or IP address to perform tests 
                            against. For throughput tests this may include an 
                            optional http/https prefix (if set, overrides the 
                            --throughput_https parameter) and web-probe URI
                            suffix (if set, overrides the --throughput_uri 
                            parameter). May also contain a wildcard character 
                            which will be replaced with a random string for 
                            each test.
                            Examples:
                            
                              --test_endpoint test.mydomain.com
                              --test_endpoint *.test.mydomain.com
                              --test_endpoint https://test.mydomain.com
                              --test_endpoint https://test.mydomain.com/test-files
                            
                            For DNS tests, name servers used during testing 
                            are those delegated for the base domain (e.g. 
                            mydomains.com), unless the --dns_recursive flag is
                            set. However, if this parameter contains a comma
                            or space separated values, the values proceeding 
                            the first will be considered to be custom name 
                            servers to use instead of those delegate
                            
                            For test endpoints with both public and private 
                            hostnames/IP addresses, this parameter may be a 
                            space or comma separated where the second value is 
                            the private hostname/IP. The private hostname/IP 
                            will be used if the compute instance and the test 
                            endpoint from the same provider, service and 
                            service region (if it fails, the public 
                            hostname/IP will be used instead)
                            
--test_instance_id          Optional instance type that --test_endpoint 
                            belongs to (e.g. c3.xlarge). If multiple 
                            --test_endpoint parameters are specified, 
                            --test_instance_id may be set only once (same 
                            instance type for all endpoints), or the same 
                            number of times as --test_endpoint (different 
                            instance types for each endpoint)
                            
--test_location             The geographic location of --test_endpoint. The 
                            value for this parameter may be either a two 
                            character ISO 3166 country code, or a state 
                            abbreviation and country code. (e.g. 
                            --meta_location "CA, US" or --meta_location US)
                            If multiple --test_endpoint parameters are specified, 
                            --test_location may be set only once (same location 
                            for all endpoints), or the same number of times as 
                            --test_endpoint (different locations for each 
                            endpoint)

--test_private_network_type If --test_endpoint contains both public and private
                            hostnames/IP addresses, this parameter may describe
                            the type of private network it refers to (e.g. vpc, 
                            vpc-enhanced-networking). The value of this 
                            parameter is included in the corresponding results 
                            (testing logic does not change). If multiple 
                            --test_endpoint parameters are specified, 
                            --test_private_network_type may be set only once 
                            (same private network type for all endpoints), or 
                            the same number of times as --test_endpoint 
                            (different private network types for each endpoint)
                            
--test_provider             Optional name of the provider that --test_endpoint 
                            belongs to. If multiple --test_endpoint parameters
                            are specified, --test_provider may be set only 
                            once (same provider for all endpoints), or the same 
                            number of times as --test_endpoint (different 
                            providers for each endpoint)

--test_provider_id          Optional ID of the provider that --test_endpoint 
                            belongs to. If multiple --test_endpoint parameters
                            are specified, --test_provider_id may be set only 
                            once (same provider for all endpoints), or the same 
                            number of times as --test_endpoint (different 
                            providers for each endpoint)
                            
--test_region               Optional service regions where --test_endpoint is
                            located in (e.g. --test_region us-east-1 for EC2).
                            If multiple --test_endpoint parameters are 
                            specified, --test_region may be set only once (same
                            for all endpoints), or the same number of times as 
                            --test_endpoint (different for each endpoint)
                            
--test_service              Optional name of the service that --test_endpoint 
                            belongs to. If multiple --test_endpoint parameters
                            are specified, --test_service may be set only 
                            once (same service for all endpoints), or the same 
                            number of times as --test_endpoint (different 
                            services for each endpoint) 

--test_service_id           Optional ID of the service that --test_endpoint 
                            belongs to. If multiple --test_endpoint parameters
                            are specified, --test_service_id may be set only 
                            once (same service for all endpoints), or the same 
                            number of times as --test_endpoint (different 
                            services for each endpoint)
                            
--test_service_type         Optional type of service that --test_endpoint 
                            belongs to. If multiple --test_endpoint parameters
                            are specified, --test_service_type may be set only 
                            once (same service type for all endpoints), or the 
                            same number of times as --test_endpoint (different 
                            service type for each endpoint). Only the following
                            values are allowed: compute, storage (i.e. object 
                            storage), cdn or dns. Not required for DNS tests. 
                            Optionally, the service type can be imbedded into 
                            --test_service_id (e.g. google:compute). If used 
                            this attribute will also be used to determine which
                            --test are supported by each endpoint based on the 
                            following type to test correlations:
                            
                              compute => throughput, latency
                              storage => downlink, latency
                              cdn     => downlink, latency
                              dns     => dns
                            
                            If an endpoint is specified for which there are no
                            supported tests, it will be disregarded
                            
--throughput_header         Optional headers to include in http requests - 
                            multiple OK. For example, to simulate a user agent:
                            User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3)

--throughput_https          If set, the protocol for throughput tests will 
                            default to https - otherwise it defaults to http
                            
--throughput_inverse        If set, and a throughput test record contains both
                            meta_compute_service_id and test_service_id, and 
                            test_service_type is 'compute', and --test is 
                            'downlink' OR 'uplink' (not 'throughput'), then 
                            an inverse of each test record will be added to the
                            results. The inverse record will use the same 
                            metrics, but replace 'test' for the opposite type
                            (e.g. download => uplink or uplink => downlink), 
                            and the following test record attributes will be 
                            substituted:
                            
                              meta_compute_service <=> test_service
                              meta_compute_service_id <=> test_service_id
                              meta_geo_region <=> test_geo_region
                              meta_instance_id <=> test_instance_id
                              meta_hostname <=> test_endpoint
                              [ip of host] => test_ip
                              meta_location <=> test_location
                              meta_location_country <=> test_location_country
                              meta_location_state <=> test_location_state
                              meta_provider <=> test_provider
                              meta_provider_id <=> test_provider_id
                              meta_region <=> test_region
                            
                            Additionally, the following attributes will be 
                            set to null:
                              
                              meta_cpu
                              meta_memory
                              meta_memory_gb
                              meta_memory_mb
                              meta_os_info
                              meta_resource_id
                              
--throughput_keepalive      If set, throughput tests will use http keep alive,
                            meaning http connections will be re-used for 
                            multiple requests. When used, throughput_samples 
                            will be equally spread across throughput_threads 
                            for each test
                            
--throughput_same_continent Throughput test size to use in megabytes if the 
                            compute instance performing tests is in the same 
                            continent as --test_endpoint. Overrides 
                            --throughput_size in that case. CDN services will 
                            always match this parameter
                            Default is 10
                            
--throughput_same_country   Throughput test size to use in megabytes if the 
                            compute instance performing tests is in the same 
                            country as --test_endpoint. Overrides 
                            --throughput_size in that case. CDN services will 
                            always match this parameter
                            Default is 20
                            
--throughput_same_geo_region Throughput test size to use in megabytes if the 
                            compute instance performing tests is in the same 
                            geo region as --test_endpoint. Overrides 
                            --throughput_size in that case (see --geo_regions 
                            parameter above). CDN services will always match 
                            this parameter
                            Default is 30
                            
--throughput_same_provider  Throughput test size to use in megabytes if the 
                            compute instance performing tests is from the same 
                            provider as --test_endpoint. Overrides 
                            --throughput_size in that case
                            Default is 10
                            
--throughput_same_region    Throughput test size to use in megabytes if the 
                            compute instance performing tests is from the same 
                            service AND in the same region as --test_endpoint. 
                            Overrides --throughput_size in that case
                            Default is 100

--throughput_same_service   Throughput test size to use in megabytes if the 
                            compute instance performing tests is from the same 
                            service as --test_endpoint. Overrides 
                            --throughput_size in that case
                            No default value
                            
--throughput_same_state     Throughput test size to use in megabytes if the 
                            compute instance performing tests is located in the
                            same country and state as --test_endpoint. 
                            Overrides --throughput_size in that case
                            Default is 50
                            
--throughput_samples        The number of test samples for throughput tests. 
                            Default is 5 unless --throughput_small_file is set
                            or --throughput_size is 0, in which case it is 10. 
                            Total number of test samples is 
                            [throughput_samples] --[throughput_threads]
                            
--throughput_size           Default size for throughput tests in megabytes. 
                            For downlink throughput tests, the test file from 
                            the CloudHarmony web-probe repository with the 
                            closest matching size will be used. For uplink 
                            throughput tests, POST requests of this exact size 
                            (request body containing random data) will be used.
                            If set to 0, tests will use an 8 byte request and 
                            --throughput_time will be set to true (result 
                            metrics will represent request times in ms instead 
                            of rates in Mb/s)
                            Default is 5
                            
--throughput_slowest_thread If set, throughput metrics will be based on the 
                            speed of the slowest thread instead of average 
                            speed X number of threads
                            
--throughput_small_file     If set, --throughput_size is ignored and throughput 
                            tests are constrained to test files smaller than 
                            128KB. Each thread of each request will randomly 
                            select one such file. When used, the 
                            throughput_size result value will be the average 
                            file size
                            
--throughput_threads        The number of concurrent threads for throughput 
                            tests. Default is 2
                            
--throughput_time           If set, throughput metrics will be average request 
                            times (ms) instead of rates (Mb/s). When used with
                            throughput_webpage, metrics will be the total page
                            load time
                            
--throughput_timeout        Timeout in seconds for throughput tests. Default is
                            180 seconds unless --throughput_size is 0 or 
                            --throughput_small_file is set in which case it is
                            5
                            
--throughput_tolerance      The permitted variation between requested and 
                            transferred bytes for a throughput test. Default 
                            is 0.6 - meaning transferred bytes must be within
                            60%
                            
--throughput_uri            Defines the base URI/location of the http/https 
                            accessible CloudHarmony web-probe directory on 
                            --test_endpoint. Default is '/web-probe'. May be 
                            overridden using a URI suffix within 
                            --test_endpoint
                            
--throughput_use_mean       If set, mean metrics will be used for reporting and 
                            calculations instead of the default median
                            
--throughput_webpage        May be used to designate contents of a single web 
                            page. When set, the value should be a space or 
                            comma separated list of URIs relative to  
                            test_endpoint (or optionally absolute for an
                            external endpoint). If set, throughput_same_*,
                            throughput_size, throughput_small_file and 
                            throughput_uri will be ignored, 
                            throughput_keepalive will be implicitly set, and
                            throughput_samples will designate the number of 
                            full page loads to perform (each metric 
                            representing one such load). To accomplish this, 
                            webpage resources will be evenly divided between
                            throughput_threads
                            
--throughput_webpage_check  If set, the URLs designated by throughput_webpage 
                            will individually be checked for validity before 
                            testing begins. To be considered valid, the URL 
                            should have a 2XX response and be within 5% of the 
                            same size as the first endpoint. If any URL is not 
                            valid, that index will be removed for all test 
                            endpoints. To use this parameter, the number of 
                            URLs in each throughput_webpage parameter must be 
                            equal
                            
--traceroute                Perform a traceroute if a test fails - results of 
                            the traceroutes are written to traceroute.log in 
                            the --output directory
                            
--verbose                   Show verbose output


DEPENDENCIES
This benchmark has the following dependencies:

 curl                       Used for throughput testing
 dig                        Used for DNS testing
 php-cli                    Used for test automation
 ping                       Used for latency testing
 zip                        Used to archive collectd rrd files

USAGE

# test latency against cloudharmony.com
./run.sh --test_endpoint app.cloudharmony.com -v

# test throughput against cloudharmony.com
./run.sh --test_endpoint http://us-east-1.ec2.cloudharmony.net/probe  --test throughput -v


EXIT CODES:
  0 test successful
  1 test failed

EOF
  exit
elif [ -f "/usr/bin/php" ]; then
  $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/run.php $@
  exit $?
else
  echo "Error: missing dependency php-cli (/usr/bin/php)"
  exit 1
fi
