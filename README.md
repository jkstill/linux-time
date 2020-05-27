
Linux Time Keeping and Related Topics
=====================================

LinuxPTP is a timekeeping system that can replace NTP and provide microsecond accuracy.

Here there is just a reference to LinuxPTP. 

Though I did configure it and run on a RAC 19.3 cluster, I didn't document that very well.

As I recall, I was trying to get a HW NIC to work as a time source, but
did not seem to work. Likely that could be due to the NIC, as not all
have time source that is externally available.

# Scripts and References

Some documentation on some scripts used to compare the current time between two nodes.

The method to obtain the difference is not highly accurate, probably good to within a few milliseconds.

See comments in `get-ntp-time-diff.sh` for more info.

## linuxptp

chrony can be configured to use the ptp protocol, allowing single digit microsecond accuracy of clocks in a cluster.

While this would not guarantee the timestamps would always be ascending, it does make it more likely.

More about linuxptp:

[http://linuxptp.sourceforge.net](http://linuxptp.sourceforge.net)

[CONFIGURING PTP USING PTP4L](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/ch-configuring_ptp_using_ptp4l)

For best results, an external (to the cluster) timekeeper server should be used.
The timekeeper should be on HW, not a virtual machine, as linuxptp can use the clock on the NIC.

This is particularly true for Virtual clusters, as there is no HW clock on the virtual NICs.

## Hardware NIC

The linuxptp software can use the clock source from a NIC. 

However, not all network interfaces provide the time from their clock

The linux command `ethtool` can be used to determine if a NIC provides the time.

### ethtool

Following is an example from a server with 3 NICs, where only 2 of them provide the time.

Interface enp4s0 does not provide a hardware time source.

See [Using PTP](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/s1-using_ptp)

```text

[root@lestrade ~]# ethtool -T enp4s0
Time stamping parameters for enp4s0:
Capabilities:
        software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)
        software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)
        software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
PTP Hardware Clock: none
Hardware Transmit Timestamp Modes: none
Hardware Receive Filter Modes: none


[root ~]# ethtool -T enp2s0
Time stamping parameters for enp2s0:
Capabilities:
        hardware-transmit     (SOF_TIMESTAMPING_TX_HARDWARE)
        software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)
        hardware-receive      (SOF_TIMESTAMPING_RX_HARDWARE)
        software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)
        software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
        hardware-raw-clock    (SOF_TIMESTAMPING_RAW_HARDWARE)
PTP Hardware Clock: 1
Hardware Transmit Timestamp Modes:
        off                   (HWTSTAMP_TX_OFF)
        on                    (HWTSTAMP_TX_ON)
Hardware Receive Filter Modes:
        none                  (HWTSTAMP_FILTER_NONE)
        all                   (HWTSTAMP_FILTER_ALL)
        ptpv1-l4-sync         (HWTSTAMP_FILTER_PTP_V1_L4_SYNC)
        ptpv1-l4-delay-req    (HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ)
        ptpv2-l4-sync         (HWTSTAMP_FILTER_PTP_V2_L4_SYNC)
        ptpv2-l4-delay-req    (HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ)
        ptpv2-l2-sync         (HWTSTAMP_FILTER_PTP_V2_L2_SYNC)
        ptpv2-l2-delay-req    (HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ)
        ptpv2-event           (HWTSTAMP_FILTER_PTP_V2_EVENT)
        ptpv2-sync            (HWTSTAMP_FILTER_PTP_V2_SYNC)
        ptpv2-delay-req       (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ)



[root ~]# ethtool -T eno1
Time stamping parameters for eno1:
Capabilities:
        hardware-transmit     (SOF_TIMESTAMPING_TX_HARDWARE)
        software-transmit     (SOF_TIMESTAMPING_TX_SOFTWARE)
        hardware-receive      (SOF_TIMESTAMPING_RX_HARDWARE)
        software-receive      (SOF_TIMESTAMPING_RX_SOFTWARE)
        software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
        hardware-raw-clock    (SOF_TIMESTAMPING_RAW_HARDWARE)
PTP Hardware Clock: 0
Hardware Transmit Timestamp Modes:
        off                   (HWTSTAMP_TX_OFF)
        on                    (HWTSTAMP_TX_ON)
Hardware Receive Filter Modes:
        none                  (HWTSTAMP_FILTER_NONE)
        all                   (HWTSTAMP_FILTER_ALL)
        ptpv1-l4-sync         (HWTSTAMP_FILTER_PTP_V1_L4_SYNC)
        ptpv1-l4-delay-req    (HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ)
        ptpv2-l4-sync         (HWTSTAMP_FILTER_PTP_V2_L4_SYNC)
        ptpv2-l4-delay-req    (HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ)
        ptpv2-l2-sync         (HWTSTAMP_FILTER_PTP_V2_L2_SYNC)
        ptpv2-l2-delay-req    (HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ)
        ptpv2-event           (HWTSTAMP_FILTER_PTP_V2_EVENT)
        ptpv2-sync            (HWTSTAMP_FILTER_PTP_V2_SYNC)
        ptpv2-delay-req       (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ)

```

## Scripts

A few time related scripts for use on Linux.

### get-ntp-time-diff.sh

This script tries to calculate the difference in time between a remote server and the local server.

It is not highly accurate, as the time required to execute the `date` command may vary, but it close enough to determine if server clocks are within a few milliseconds.

```text

$  debug=1 ./get-ntp-time-diff.sh jks-atl
dateCmd: date '+%s.%N'
getting local average command time
    avgRunTime: .000834100
      overhead: .000834100
  negative gap: the local server is ahead of the remote server
  positive gap: the local server is behind the remote server
      this is not necessarily 100% true due to changes in overhead
            t1: 1590540364.074458418
            t2: 1590540364.091399252
-.017774934

```

### start-watch.sh

The `start-watch.sh` script is used to visually compare the time between different servers.

When the file described by the `lockfile` variable is no longer readable, all invocations scripts will start `watch -n 5 'date +%Y-%m-%d_%H-%M-%S_%N'`

### time-command-avg.sh

Get the average time required to run a command.

This can be particularly useful when running commands remotely, as the network overhead can vary.

example:  `time-command-avg.sh iterations command`

This was formerly used byt `get-ntp-time-diff.sh`, but is no longer necessary in that script


### time-command.sh

Show the time required to run a command.

```text
>  ./time-command.sh ls
0.001831
```

This script is a little different than most, in that it uses `strace` to get the execution time.

Due to that, it is best to run it on commands that only take a very short time due to the `strace` overhead.

Following is a good illustration of why that is so, as using strace cause execution time to increase nearly 10x:

```text
$ time ls -R ../../.. >/dev/null

real    0m0.245s
user    0m0.108s
sys     0m0.132s

$  time-command.sh  ls -R ../../..
2.352839

```

This script was created just as an experiment, and left here to illustrate strace overhead.


### timestamp.sh

Sets a variable TIMESTAMP.

The format is YYYY-MM-DD_HH24-MI-SS, more or less as per [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)

```text
>  . ./timestamp.sh

>  echo $TIMESTAMP
2020-05-26_11-37-40
```


