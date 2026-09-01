# Wi-Fi latency (rodin)

## Symptom

5 GHz looks fine in Settings, but in-game ping spikes. Often blamed on the modem or the kernel “being heavy”. On this phone the usual cause is **Wi-Fi power save + CPU idle**, not a broken WLAN driver.

## Measure

Use **USB** ADB:

```text
ping -c 30 -i 0.2 <gateway>
iw dev wlan0 link
```

Wireless ADB shares the radio and pollutes the test.

Read `freq:` from `iw`:

| MHz | Band |
|---|---|
| 2412–2472 | 2.4 GHz |
| 5180 / 5500 / … | 5 GHz |

Android often prefers 2.4 GHz when the same SSID is dual-band (higher RSSI). 2.4 GHz has more TX retries and neighbor noise. That is not a kernel bug. Join the **5 GHz** SSID explicitly.

## Kernel side

The TEO idle governor guessed UDP / game packet gaps wrongly and parked **CPU0** in `s2idle` / deeper MediaTek C-states. `wlan0` IRQs were on CPU0 (little cluster, thermal cap ~1400 MHz). Wake from `s2idle` is ~20 ms.

ROOTURK **does not compile TEO**. Available governors after flash:

```text
menu lpm_gov_mhsp
```

`lpm_gov_mhsp` comes from **vendor_dlkm**, not from this Image.

Live A/B on rodin, 5 GHz, modem ping (game closed):

| Setup | Avg | Max |
|---|---|---|
| TEO + Wi-Fi power save | ~15 ms | **~83 ms** |
| `lpm_gov_mhsp` + PS off + WLAN IRQ on CPU7 | ~5 ms | **~12 ms** |

## Userspace (ROOTURK Manager)

Script: [`scripts/98-rooturk-wifi-latency.sh`](../scripts/98-rooturk-wifi-latency.sh)  
Mode file: `/data/adb/rooturk/net_mode` (`boost` or `save`)  
Install path: `/data/adb/service.d/98-rooturk-wifi-latency.sh`

| `net_mode` | Idle | Wi-Fi PS | Deep C-state | WLAN IRQ |
|---|---|---|---|---|
| `boost` (default) | `lpm_gov_mhsp` | off | disable state2–5 | CPU 7 |
| `save` | `menu` | on | enable | 0–7 |

Android `wlan_assistant` may turn power save back on. Re-apply from Manager **Network** or:

```text
sh /data/adb/service.d/98-rooturk-wifi-latency.sh apply
```

`iw get power_save` prints `Power save: off`. The word **off** contains **on**. Parse **off first**.

## 5 GHz DFS

A DFS channel (for example 5500 MHz / 100) with weak RSSI (−70 dBm) can show 100–300 ms on the first pings, then settle to a few ms. For games, a closer UNII-1 AP (5180 MHz) is usually cleaner.
