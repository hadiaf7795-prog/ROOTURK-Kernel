#ifndef __KSU_H_MANAGER_IDENTITY
#define __KSU_H_MANAGER_IDENTITY

#include <linux/cred.h>
#include <linux/types.h>

#define KSU_INVALID_APPID -1
#define KSU_PER_USER_RANGE 100000

#ifdef CONFIG_KSU_DISABLE_MANAGER
static inline bool ksu_is_manager_appid_valid()
{
    return true;
}

static inline bool is_manager()
{
    return current_uid().val == 0;
}

static inline bool is_uid_manager(uid_t uid)
{
    return uid == 0;
}

static inline uid_t ksu_get_manager_appid()
{
    return 0;
}

static inline void ksu_set_manager_appid(uid_t appid)
{
    (void)appid;
}

static inline void ksu_invalidate_manager_uid()
{
}
#else
extern uid_t ksu_manager_appid; // DO NOT DIRECT USE
extern uid_t ksu_manager_appid_extra;

static inline bool ksu_is_manager_appid_valid()
{
    return ksu_manager_appid != KSU_INVALID_APPID ||
           ksu_manager_appid_extra != KSU_INVALID_APPID;
}

static inline bool is_uid_manager(uid_t uid)
{
    uid_t appid = uid % KSU_PER_USER_RANGE;
    return unlikely(ksu_manager_appid == appid) ||
           unlikely(ksu_manager_appid_extra == appid);
}

static inline bool is_manager()
{
    return is_uid_manager(current_uid().val);
}

static inline uid_t ksu_get_manager_appid()
{
    if (ksu_manager_appid != KSU_INVALID_APPID)
        return ksu_manager_appid;
    return ksu_manager_appid_extra;
}

static inline void ksu_set_manager_appid(uid_t appid)
{
    uid_t a = appid % KSU_PER_USER_RANGE;
    if (ksu_manager_appid == a || ksu_manager_appid_extra == a)
        return;
    if (ksu_manager_appid == KSU_INVALID_APPID)
        ksu_manager_appid = a;
    else if (ksu_manager_appid_extra == KSU_INVALID_APPID)
        ksu_manager_appid_extra = a;
    else
        ksu_manager_appid_extra = a;
}

static inline void ksu_invalidate_manager_uid()
{
    ksu_manager_appid = KSU_INVALID_APPID;
    ksu_manager_appid_extra = KSU_INVALID_APPID;
}
#endif

#endif // __KSU_H_MANAGER_IDENTITY
