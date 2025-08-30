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
	uint32_t get_screen_resolution_x();
	uint32_t get_screen_resolution_y();
	bool queue_packet(struct netConnectionManager* mgr, int msg_id, void* data, int size, int flags, uint16_t* out_seq_id);
	struct CNetworkPlayerMgr* get_network_player_mgr();
	struct scrProgramTable* get_script_program_table();
	struct atArray* get_script_threads();
	int64_t** get_script_globals();

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

	void unload();

	typedef union
	{
		float data[4];
		struct
		{
			float x, y, z, w;
		};
	} fvector4;

	typedef union
	{
		float data[4];
		struct
		{
			float x, y, z, w;
		};
	} fvector3;

	typedef union
	{
		float data[4][4];
		struct
		{
			struct
			{
				float x, y, z, w;
			} rows[4];
		};
	} fmatrix44;

	uint32_t bitbuffer_GetPosition(struct datBitBuffer* buf);
	void bitbuffer_ReadBitsSingle(uint8_t* data, uint32_t* out, int size, int offset);
	void bitbuffer_WriteBitsSingle(uint8_t* data, int value, int size, int offset);
	bool bitbuffer_CopyBits(struct datBitBuffer* buf, const void* dest, const void* source, int length, int destBitOffset, int sourceBitOffset);
	bool bitbuffer_IsReadBuffer(struct datBitBuffer* buf);
	bool bitbuffer_IsSizeCalculator(struct datBitBuffer* buf);
	void bitbuffer_Seek(struct datBitBuffer* buf, int bits);

	bool bitbuffer_ReadDword(struct datBitBuffer* buf, uint32_t* out, int size);
	bool bitbuffer_WriteDword(struct datBitBuffer* buf, int val, int size);
	bool bitbuffer_ReadQword(struct datBitBuffer* buf, uint64_t* out, int size);
	bool bitbuffer_WriteQword(struct datBitBuffer* buf, uint64_t val, int size);
	bool bitbuffer_ReadInt64(struct datBitBuffer* buf, int64_t* out, int size);
	bool bitbuffer_WriteInt64(struct datBitBuffer* buf, int64_t val, int size);

	void bitbuffer_WriteArray(struct datBitBuffer* buf, const void* array, int bits);
	void bitbuffer_WriteArrayBytes(struct datBitBuffer* buf, const void* array, int bytes);
	void bitbuffer_ReadArray(struct datBitBuffer* buf, void* array, int bits);
	void bitbuffer_ReadArrayBytes(struct datBitBuffer* buf, void* array, int bytes);

	void bitbuffer_WriteString(struct datBitBuffer* buf, const char* string, int max_len);
	void bitbuffer_ReadString(struct datBitBuffer* buf, char* string, int max_len);
	int bitbuffer_GetDataLength(struct datBitBuffer* buf);
	bool bitbuffer_ReadRockstarId(struct datBitBuffer* buf, int64_t* rockstar_id);

	float bitbuffer_ReadFloat(struct datBitBuffer* buf, int size, float divisor);
	void bitbuffer_WriteFloat(struct datBitBuffer* buf, int size, float divisor, float value);
	float bitbuffer_ReadSignedFloat(struct datBitBuffer* buf, int size, float divisor);
	void bitbuffer_WriteSignedFloat(struct datBitBuffer* buf, int size, float divisor, float value);

	void bitbuffer_ReadPosition(struct datBitBuffer* buf, int size, fvector3* pos);
	void bitbuffer_WritePosition(struct datBitBuffer* buf, int size, fvector3* pos);

	void bitbuffer_ReadVector3(struct datBitBuffer* buf, int size, float divisor, fvector3* vec);
	void bitbuffer_WriteVector3(struct datBitBuffer* buf, int size, float divisor, fvector3* vec);
	void bitbuffer_AlignToByteBoundary(struct datBitBuffer* buf);

]]

local menu_path = menu.get_dll_path()
if menu_path then
	menu_exports = ffi.load(menu_path)
else
	log.fatal("Failed to get the path to our dll, ffi functions will fail.")
end
