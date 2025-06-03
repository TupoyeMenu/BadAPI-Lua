local ffi = require("ffi")

ffi.cdef[[
	void* ffi_detour_hook_ctor(const char* name, void* target, void* detour);
	void ffi_detour_hook_dtor(void* _this);

	void ffi_detour_hook_enable(void* _this);
	void ffi_detour_hook_disable(void* _this);
	void* ffi_detour_hook_get_original(void* _this);


	typedef void(* scrNativeHandler)(struct scrNativeCallContext*);
	void ffi_add_native_detour(uint32_t script_hash, uint64_t native_hash, scrNativeHandler detour);
	void ffi_hook_program(void* scr_program);


	uint64_t ffi_scan_pattern(const char* pattern, const char* module);
	struct fwEntity* ffi_handle_to_ptr(int handle);
	int ffi_ptr_to_handle(struct fwEntity* ptr);

	enum eLogLevel
	{
		VERBOSE,
		INFO,
		WARNING,
		FATAL
	};
	void ffi_logf(enum eLogLevel log_level, const char* fmt, ...);
	void ffi_logf_no_level(const char* fmt, ...);

	int printf(const char *fmt, ...);
]]

local menu_path = get_dll_path()
if menu_path then
	menu_exports = ffi.load(menu_path)
else
	log.fatal("Failed to get the path to our dll, ffi functions will fail.")
end