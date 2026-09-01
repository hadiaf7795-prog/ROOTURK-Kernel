# Flaş

## Kural

- **`fastboot boot` yok.**
- Recovery bu telefonda **`vendor_boot`**. `fastboot flash recovery` yanlış partition.
- ROOTURK zip **yalnızca `boot`** (AnyKernel3 `block=boot`).

## Recovery

OrangeFox (vendor_boot) içinden `1.0.0-ROOTURK-V1.0.zip` kur. Slot A/B otomatik (`is_slot_device=auto`).

Zip’i git’e koyma; Release veya kendi derlemen.

## Android içinden (root)

`scripts/flash_rooturk.sh`:

1. Zip’i `/sdcard/Download/1.0.0-ROOTURK-V1.0.zip` koy.
2. Script’i cihaza it, `su` ile çalıştır.
3. AK3 `dump_boot` / `write_boot` (veya init_boot varsa split).
4. **Yeniden başlat.** Çalışan kernel flaş anında değişmez.

```text
adb push 1.0.0-ROOTURK-V1.0.zip /sdcard/Download/
adb push scripts/flash_rooturk.sh /data/local/tmp/flash_rooturk.sh
adb shell su -c "sh /data/local/tmp/flash_rooturk.sh"
adb reboot
```

`update-binary` `/proc/self/fd/1` uyarıları (adb tty) flaşı bozmaz. `rc=0` ve `KERNEL_SZ` artışı yeter.

## Doğrulama

```text
uname -r
# 6.6.142-1.0.0-ROOTURK-V1.0-android15-8-4k

cat /sys/devices/system/cpu/cpuidle/available_governors
# menu lpm_gov_mhsp     (teo olmamalı)
```

KernelSU Next ve SuSFS aynı Image’de gömülü. Ayrı LKM gerekmez.

## Geri dönüş

Önceki çalışan `boot` yedeği olmadan flaşlama. EVONIX v2.0 zip’i aynı AnyKernel yöntemiyle geri yazılabilir.

Bootloop: Vol− + güç → fastboot, eski `boot.img` `fastboot flash boot` (slot’a dikkat). Yine `fastboot boot` kullanma.

## Manager

Kernel zip’e APK gömülmez. [ROOTURK-Manager](https://github.com/RooTurkk/ROOTURK-Manager) ayrı `adb install`.
