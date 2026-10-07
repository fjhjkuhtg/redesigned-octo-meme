#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#include <string.h>

typedef int (*luaL_loadbufferx_t)(void*, const char*, size_t, const char*, const char*);
typedef int (*lua_pcall_t)(void*, int, int, int);

static luaL_loadbufferx_t p_load = nullptr;
static lua_pcall_t p_call = nullptr;
static void* g_L = nullptr;

static void resolve() {
    void* h = dlopen(NULL, RTLD_NOW);
    if (!h) return;
    p_load = (luaL_loadbufferx_t)dlsym(h, "luaL_loadbufferx");
    p_call = (lua_pcall_t)dlsym(h, "lua_pcall");
}

static void* state() {
    void* h = dlopen(NULL, RTLD_NOW);
    if (!h) return nullptr;
    typedef void* (*fn_t)(void);
    auto fn = (fn_t)dlsym(h, "lua_getstate");
    return fn ? fn() : nullptr;
}

extern "C" int eni_execute(const char* src) {
    if (!g_L) g_L = state();
    if (!g_L || !p_load || !p_call) return -1;
    if (p_load(g_L, src, strlen(src), "@eni", "t") != 0) return -2;
    return p_call(g_L, 0, 0, 0);
}

__attribute__((constructor))
static void eni_init() {
    NSLog(@"[ENI] loaded pid %d", getpid());
    resolve();
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        for (int i = 0; i < 120; i++) {
            g_L = state();
            if (g_L) {
                NSLog(@"[ENI] state %p", g_L);
                eni_execute("print('[ENI] hello')");
                break;
            }
            usleep(500000);
        }
    });
}
