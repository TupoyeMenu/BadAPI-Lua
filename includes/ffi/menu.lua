local ffi = require("ffi")

ffi.cdef[[
	void* detour_hook_ctor(const char* name, void* target, void* detour);
	void detour_hook_dtor(void* _this);

	void detour_hook_enable(void* _this);
	void detour_hook_disable(void* _this);
	void* detour_hook_get_original(void* _this);


	typedef void(* scrNativeHandler)(struct scrNativeCallContext*);
	void add_native_detour(uint32_t script_hash, uint64_t native_hash, scrNativeHandler detour);
	void hook_program(void* scr_program);


	uint64_t scan_pattern(const char* pattern, const char* module);
	struct fwEntity* handle_to_ptr(int handle);
	int ptr_to_handle(struct fwEntity* ptr);

	enum eLogLevel
	{
		VERBOSE,
		INFO,
		WARNING,
		FATAL
	};
	void logf_level(enum eLogLevel log_level, const char* fmt, ...);
	void logf_no_level(const char* fmt, ...);

	int printf(const char *fmt, ...);

	bool is_enhanced();
	uint32_t joaat(const char* str);
	uint32_t literal_joaat(const char* str);
	void* get_tls_context();
	bool script_can_tick();

#pragma pack(push, 8)
	typedef struct
	{
		float x;
		float y;
		float z;
	} Vector3;
#pragma pack(pop)

	scrNativeHandler get_native_handler(uint64_t hash);
	void cache_handlers();
	bool are_native_handlers_cached();
	void begin_call();
	void end_call(uint64_t hash);
	void push_arg_int(int arg);
	void push_arg_float(float arg);
	void push_arg_char(const char* arg);
	void push_arg_ptr(void* arg);
	int get_return_value_int();
	float get_return_value_float();
	const char* get_return_value_char();
	void* get_return_value_ptr();
	Vector3* get_return_value_vector3();
	void* get_return_address();

]]

local menu_path = get_dll_path()
if menu_path then
	menu_exports = ffi.load(menu_path)
else
	log.fatal("Failed to get the path to our dll, ffi functions will fail.")
end