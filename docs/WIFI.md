# Wi‑Fi gecikmesi (rodin)

## Belirti

Sabit 5 GHz görünür, oyunda anlık ms dalgası. Kernel yüklemeden önce yoktu.

## Ölçüm

USB ADB ile `ping -c 30 -i 0.2 <gateway>`. Kablosuz ADB aynı radyo; ölçümü kirletir.

Önce `iw dev wlan0 link` — `freq:` 2462 = 2.4 GHz, 5180/5500 = 5 GHz. Aynı SSID çift bantta Android çoğu zaman 2.4’ü seçer (RSSI daha yüksek).

2.4 GHz’de TX retry yüksek, komşu ağ ve ARP yayını ping’i şişirir. Bu kernel bug’ı değil.

## Çekirdek tarafı

`teo` governor CPU0’ı `s2idle` / `mcusysoff` / `system-vcore`’a sokuyordu. wlan IRQ CPU0’da. GKI’de TEO kapatıldı.

Vendor idle `lpm_gov_mhsp` (MediaTek LPM) `vendor_dlkm`’den gelir, GKI Image’de yoktur. Kullanılabilir kalır.

## Kullanıcı alanı (Manager)

`/data/adb/service.d/98-rooturk-wifi-latency.sh`

| `net_mode` | idle | Wi‑Fi PS | derin C-state | IRQ |
|---|---|---|---|---|
| `boost` (varsayılan) | `lpm_gov_mhsp` | off | disable state2–5 | CPU 7 |
| `save` | `menu` | on | enable | 0–7 |

Android `wlan_assistant` bazen power save’i geri açar. Manager Ağ sayfası veya `sh 98-rooturk-wifi-latency.sh apply` tekrar basar.

`iw get power_save` çıktısı `Power save: off` — **off** içinde **on** geçer. Durum satırını parse ederken önce `off` bak.

## 5 GHz DFS

ByGusion 5500 MHz (kanal 100) DFS. Zayıf RSSI (−70 dBm) ilk ping’lerde 100–300 ms sıçrama yapabilir; oturunca 2–4 ms’e iner. Oyun için daha yakın 5 GHz (UNII-1, 5180) daha temizdir.
