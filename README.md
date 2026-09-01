# ROOTURK Kernel

POCO X7 Pro (`rodin`) için Android 15 **GKI 6.6.142** çekirdeği. EVONIX (KernelSU Next + SuSFS) tabanı, ROOTURK imzası ve oyun Wi‑Fi gecikmesi için `teo` idle kapalı.

Bu depo **tam AOSP ağacını içermez**. Derleme scriptleri, config parçası ve flaş notları vardır. Kaynak [NEESCHAL-3/EVONIX-Kernel](https://github.com/NEESCHAL-3/EVONIX-Kernel) `hyperos/ksu-susfs` dalından alınır.

Kardeş uygulama: [ROOTURK-Manager](https://github.com/RooTurkk/ROOTURK-Manager)

**UTS (mevcut derleme):**  
`6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k`

---

## Cihaz

| | |
|---|---|
| Kod adı | `rodin` |
| Model | POCO X7 Pro (2412DPC0AG) |
| SoC | MediaTek Dimensity (mt6899 / gen4m_6899) |
| Wi‑Fi | MT663x / connac2, `wlan_drv_gen4m_6899` |
| Sayfa | 4K |
| Root | KernelSU Next 3.3.0 (in-kernel), SuSFS v2.2.0 GKI |
| Recovery | **`vendor_boot`** (OrangeFox). `recovery` partition yok. |
| Slot | A/B |

`fastboot boot` **kullanma**. Bu cihazda boot imajını geçici yüklemek brick / yanlış partition riski taşır. AnyKernel3 yalnızca **`boot`** yazar.

---

## EVONIX’ten ne değişti

1. **İsim:** `EXTRAVERSION = -1.0.0-ROOTURK-V1.0`, `CONFIG_LOCALVERSION="-android15-8-4k"`.
2. **Vendor ABI:** EVONIX v2.0 ile aynı `task_struct` / MTE / KASAN_HW_TAGS. `TRIM_UNUSED_KSYMS` yok (Kleaf whitelist olmadan bootloop).
3. **ZSWAP + KSM** varsayılan açık (LZ4 / zbud).
4. **Idle:** `CONFIG_CPU_IDLE_GOV_TEO` **kapalı**, `MENU` açık. Vendor modülü `lpm_gov_mhsp` durur.
5. **BBR** GKI’de mevcutsa TCP varsayılanı Manager’dan BBR seçilebilir.
6. Paketleme: AnyKernel3 zip, sadece `boot`.

Parça dosyası: [`configs/rooturk.config`](configs/rooturk.config).

---

## Neden `teo` kapatıldı

`teo` (Timer Events Oriented) UDP oyun paket aralığını yanlış tahmin edip CPU0’ı `s2idle`’a sokuyordu. MediaTek `wlan0` IRQ’su CPU0’daydı (little, termal tavan ~1400 MHz). `s2idle` uyanması ~20 ms.

rodin, 5 GHz, modem ping (oyun kapalı):

| Ayar | Ort. | Max |
|---|---|---|
| `teo` + Wi‑Fi power save | ~15 ms | **83 ms** |
| `lpm_gov_mhsp` + PS off + IRQ CPU7 | ~5 ms | **~12 ms** |

Çekirdek `teo`’yu hiç kaydetmez. Kullanıcı alanında ROOTURK Manager **Ağ → Hız güçlendirme** ayrıca power save’i kapatır ve IRQ’yu CPU7’ye pinler. Script: [`scripts/98-rooturk-wifi-latency.sh`](scripts/98-rooturk-wifi-latency.sh).

---

## Dizin

```text
configs/rooturk.config          # kconfig fragment
scripts/build-config.sh         # gki_defconfig + evonix.config merge
scripts/fix-rooturk-config.sh   # ROOTURK fragment + Image.gz
scripts/build-image.sh          # yalnızca Image.gz (mevcut .config)
scripts/pack-rooturk.sh         # AnyKernel3 zip
scripts/flash_rooturk.sh        # cihaz içi AK3 (su)
scripts/98-rooturk-wifi-latency.sh
scripts/rebrand-rooturk.sh
scripts/patch-setlocalversion.py
scripts/patch-extract-cert.py
docs/BUILDING.md
docs/FLASH.md
docs/WIFI.md
```

---

## Kısa derleme

Tam adımlar: [docs/BUILDING.md](docs/BUILDING.md).

Özet (WSL2 Ubuntu 24.04, Clang r510928, kaynak `/root/android/src/common`):

```bash
bash scripts/build-config.sh
bash scripts/fix-rooturk-config.sh    # Image.gz üretir
bash scripts/pack-rooturk.sh          # AnyKernel zip
```

Flaş: [docs/FLASH.md](docs/FLASH.md). Recovery’den zip veya `flash_rooturk.sh` (root, `boot`).

---

## Ne flaşlanmaz

- `vendor_boot` / recovery (OrangeFox ayrı proje)
- `init_boot` (AK3 init_boot görürse split_boot kullanır; rodin’de asıl hedef `boot`)
- Super / system / vendor
- Manager APK (ayrı repo; zip’e gömülmez)

---

## Lisans

Kernel ve bu scriptler **GPL-2.0**. EVONIX ve KernelSU Next kendi lisansları + atıflarıyla gelir.
