#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>

// Generated WIT interface for example:greeter/greeter@0.1.0
#include "greeter_world.h"

// --- WIT helper implementations (native build; no Wasm ABI glue needed) ---

extern "C" void *cabi_realloc(void *ptr, size_t, size_t, size_t new_size) {
    if (new_size == 0) return nullptr;
    void *r = realloc(ptr, new_size);
    if (!r) abort();
    return r;
}

extern "C" void greeter_world_string_set(greeter_world_string_t *ret, const char *s) {
    ret->ptr = reinterpret_cast<uint8_t *>(const_cast<char *>(s));
    ret->len = strlen(s);
}

extern "C" void greeter_world_string_dup(greeter_world_string_t *ret, const char *s) {
    ret->len = strlen(s);
    ret->ptr = reinterpret_cast<uint8_t *>(malloc(ret->len));
    memcpy(ret->ptr, s, ret->len);
}

extern "C" void greeter_world_string_free(greeter_world_string_t *ret) {
    if (ret->len > 0) free(ret->ptr);
    ret->ptr = nullptr;
    ret->len = 0;
}

// --- Adapter: C++ implementation of the greeter interface ---
//   WIT:  greet: func(name: string) -> string

extern "C" void exports_example_greeter_greeter_greet(
    greeter_world_string_t *name,
    greeter_world_string_t *ret
) {
    std::string n(reinterpret_cast<char *>(name->ptr), name->len);
    std::string greeting = "Hello, " + n + "!";
    greeter_world_string_dup(ret, greeting.c_str());
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: mask greet-cpp <name>\n";
        return 1;
    }

    greeter_world_string_t name;
    greeter_world_string_set(&name, argv[1]);

    greeter_world_string_t result{};
    exports_example_greeter_greeter_greet(&name, &result);

    std::cout << std::string(reinterpret_cast<char *>(result.ptr), result.len) << "\n";
    greeter_world_string_free(&result);
    return 0;
}
