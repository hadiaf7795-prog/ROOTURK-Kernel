# ROOTURK Kernel

**POCO X7 Pro** (`rodin`) için özel **Android 15 GKI** çekirdeği.

English: [README.en.md](README.en.md)

| | |
|---|---|
| Cihaz | POCO X7 Pro (2412DPC0AG) |
| SoC | MediaTek Dimensity 8400 Ultra (MT6899) |
| Sürüm | `6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k` |
| Sayfa boyutu | 4K |
| Root | KernelSU Next 3.3.0 (çekirdeğin içinde) |
| Gizleme | SuSFS v2.2.0 (GKI) |

**Telegram:** [t.me/RooTurk](https://t.me/RooTurk)

Bu depoda **tam çekirdek kaynağı**, AnyKernel3 paketleme, derleme betikleri ve Wi‑Fi gecikme açılış betiği vardır. **ROOTURK Manager** ayrı repo değildir; flaş zip’inin içinden kurulur.

---

## Özellikler

- **Çekirdek içi KernelSU Next** — LKM yok, `ksu.ko` yok. ROOTURK Manager bir KernelSU yöneticisidir (otomatik root). KernelSU Next’in kendi uygulaması da çalışır.
- **SuSFS** — şüpheli yol / mount / kstat / map gizleme, uname ve cmdline spoof, open-redirect, KSU/SuSFS sembol gizleme.
- **Vendor Wi‑Fi / BT modülleri yüklenir** — BTF uyumsuzluğuna izin, modül sürüm sihri gevşek, ağaç içi `CFG80211` kapalı; MediaTek `wlan_drv_gen4m_6899` yönetir.
- **TCP BBR + FQ** — varsayılan tıkanıklık denetimi BBR; Manager çalışma anında Cubic’e geçebilir.
- **ZSWAP varsayılan açık** (LZ4 + zbud) ve **KSM**.
- **Oyun için idle** — `CONFIG_CPU_IDLE_GOV_TEO` **kapalı**. MENU durur; vendor `lpm_gov_mhsp` kullanılabilir. TEO, CPU0’ı `s2idle`’da (~20 ms uyanma) bırakıyordu; WLAN kesmeleri o little çekirdekteydi ([docs/WIFI.md](docs/WIFI.md)).
- **Vendor ABI** — stok GKI ile aynı `task_struct`, ARM64 MTE ve KASAN HW etiketleri. `TRIM_UNUSED_KSYMS` kapalı (bu telefonda bootloop).
- **Şarj yardımcı yolu** — MT6899 / Xiaomi şarj hattı (Manager ile kullanılır).
- **Zip içinde ROOTURK Manager** — AnyKernel APK’yi sistem uygulaması (`priv-app`) olarak kurar; Ayarlar’dan silinemez. Durum sekmesinin altında Destek, Telegram’a gider. Çekirdek, APK’nin v2 imza sertifikasını KernelSU yöneticisi olarak tanır (`su` izni penceresi yok).
- **AnyKernel3 zip yalnızca `boot` yazar.** Recovery **`vendor_boot`** üzerindedir. **`fastboot boot` kullanma.**

---

## Kurulum

Ayrıntılı adımlar: **[INSTALL.md](INSTALL.md)** (İngilizce).

Kısa özet:

1. Açık bootloader, özel recovery **`vendor_boot`** içinde (bu cihazda OrangeFox).
2. AnyKernel zip’ini derle (veya GitHub Release varsa onu kullan).
3. Zip’i recovery’den **veya** root ile Android’den `scripts/flash_rooturk.sh` ile flaşla.
4. Yeniden başlat. Kontrol:

```text
adb shell uname -r
# 6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k

adb shell su -c "cat /sys/devices/system/cpu/cpuidle/available_governors"
# menu lpm_gov_mhsp
```

5. Manager sistem uygulaması olarak kurulur (silinemez); imzası KernelSU yöneticisi olarak işlenir. KernelSU Next’in kendi yöneticisi de geçerlidir.

İsteğe bağlı Wi‑Fi oyun kipi (Manager **Ağ** sayfasından da kurulur): betik `scripts/98-rooturk-wifi-latency.sh`.

---

## Derleme

Ayrıntı: **[docs/BUILDING.md](docs/BUILDING.md)**.

**WSL2 Ubuntu 24.04** (veya yerli Linux), Android 15 **Clang r510928**, yaklaşık 12 GB RAM gerekir.

```bash
git clone --recurse-submodules https://github.com/RooTurkk/ROOTURK-Kernel.git
cd ROOTURK-Kernel
# Linux/WSL ext4 üzerine klonla. NTFS bazı çekirdek dosya adlarını tutamaz.
# CLANG_BIN → clang-r510928/bin
bash scripts/build-config.sh
bash scripts/fix-rooturk-config.sh   # Image.gz
bash scripts/pack-rooturk.sh         # 1.0.0-ROOTURK-V1.0.zip
```

Kaynak: [`kernel/`](kernel/). `TRIM_UNUSED_KSYMS` açma.

Zip’e Manager koymak için imzalı `anykernel/rooturk-manager.apk` dosyasını paketlemeden önce yerleştir (`anykernel/*.apk` git’te yok).

---

## Ağaç

```text
kernel/                                  Linux 6.6 GKI + KernelSU Next + SuSFS
  arch/arm64/configs/gki_defconfig
  arch/arm64/configs/rooturk_gki.config
  KernelSU-Next/
anykernel/                               AnyKernel3 (yalnızca boot)
configs/rooturk.config                   idle, ZSWAP, LOCALVERSION
scripts/build-config.sh
scripts/fix-rooturk-config.sh
scripts/build-image.sh
scripts/pack-rooturk.sh
scripts/flash_rooturk.sh
scripts/98-rooturk-wifi-latency.sh
docs/BUILDING.md
docs/WIFI.md
INSTALL.md
README.en.md
```

---

## Bu zip’in flaşlamadığı şeyler

- `vendor_boot` / recovery
- `init_boot` (AK3 bu bölüm varsa `split_boot` kullanır; rodin’de yük `boot`)
- super / system / vendor

ROOTURK Manager zip’in içindedir; ayrı uygulama deposu yoktur.

---

## Destek

Telegram: **[https://t.me/RooTurk](https://t.me/RooTurk)**

---

## Lisans

GPL-2.0. [`LICENSE`](LICENSE) ve [`kernel/COPYING`](kernel/COPYING).  
KernelSU Next: `kernel/KernelSU-Next/LICENSE`.
