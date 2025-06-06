#if defined(__CDT_PARSER__) || defined (__INTELLISENSE__) || defined (Q_CREATOR_RUN) || defined (__clang__)
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include "stdbool.h"
#endif



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

#pragma pack(push, 8)
typedef struct
{
	void* m_data;
	uint16_t m_size;
	uint16_t m_count;
} atArray;
#pragma pack(pop)


struct phArchetype
{
	char pad_0000[32]; //0x0000
	struct phBound* m_bound; //0x0020
	char pad_0028[16]; //0x0028
}; //Size: 0x0038

struct phArchetypePhys
{
	struct phArchetype;
	char pad_0038[8]; //0x0028
	float m_mass;
	float m_pad0044;
	float m_pad0048;
	float m_pad004C;
	float m_pad0050;
	float m_water_collision; //0x0054
	char pad_0058[40]; //0x0058
}; //Size: 0x0080

struct phArchetypeDamp
{
	struct phArchetypePhys;
	char pad_0080[96]; //0x0080
}; //Size: 0x00E0

#pragma pack(push, 1)
struct CNavigation
{

	char pad_0000[16]; //0x0000
	struct phArchetypeDamp* m_damp; //0x0010
	char pad_0018[8]; //0x0018
	fmatrix44 m_transformation_matrix;
};
#pragma pack(pop)



#pragma pack(push, 1)
struct fwExtensibleBase
{
	void* vtable;
	void* m_ref;
	void* m_extension_container;
	void* m_extensible_unk;
};
#pragma pack(pop)

#pragma pack(push, 8)
struct fwEntity
{
	struct fwExtensibleBase;
	uint64_t* m_ModelInfo; //0x0020
	uint8_t m_Type; //0x0028
	char gap29; //0x0029
	uint16_t gap2A; //0x002A
	uint32_t m_Flags; //0x002D
	struct CNavigation* m_Navigation; //0x0030
	uint16_t gap38; //0x0038
	uint16_t gap3A; //0x003A
	uint32_t gap3C; //0x003C
	uint64_t* m_DynamicEntityComponent; //0x0040 (stores attachments and stuff)
	uint64_t* m_DrawData; //0x0048
	uint64_t* gap50; //0x0050
	uint64_t gap58; //0x0058
	fmatrix44 m_Transform; //0x0060
	struct fwEntity* m_RenderFocusEntity; //0x00A0
	uint32_t m_RenderFocusDistance; //0x00A8
	uint32_t m_Flags2; //0x00AC
	uint32_t m_ShadowFlags; //0x00B0
	char gapB4[4]; //0x00B4
	uint8_t byteB8; //0x00B8
};
#pragma pack(pop)

struct CEntity
{
	struct fwEntity;
	uint32_t m_flags_3; //0x00C0
	uint32_t m_flags_4; //0x00C4
	uint32_t dwordC8;
	uint32_t dwordCC;
};

struct CDynamicEntity
{
	struct CEntity;
	struct netObject* m_NetObject;
	struct 
	{
		uint16_t unk0 : 1;
		uint16_t unk1 : 1;
		uint16_t unk2 : 1;
		uint16_t unk3 : 1;
		uint16_t unk4 : 1;
		uint16_t unk5 : 1;
		uint16_t unk6 : 1;
		uint16_t unk7 : 1;
		uint16_t unk8 : 1;
		uint16_t unk9 : 1;
		uint16_t unk10 : 1;
		uint16_t unk11 : 1;
		uint16_t unk12 : 1;
		uint16_t unk13 : 1;
		uint16_t unk14 : 1;
		uint16_t unk15 : 1;
	} m_DynamicFlags;
	char gapD8[14];
	uint64_t qwordE8;
};

#pragma pack(push, 1)
struct CAttackers
{
    struct CPed* m_attacker0; //0x0000 
    char pad_0x0008[0x10]; //0x0008
    struct CPed* m_attacker1; //0x0018 
    char pad_0x0020[0x10]; //0x0020
    struct CPed* m_attacker2; //0x0030 
}; //Size=0x0038
#pragma pack(pop)

#pragma pack(push, 1)
struct DamageFlags
{
	uint32_t unk0 : 1;
	uint32_t unk1 : 1;
	uint32_t unk2 : 1;
	uint32_t unk3 : 1;
	uint32_t isBulletProof : 1;
	uint32_t isFireProof : 1;
	uint32_t isCollisionProof : 1;
	uint32_t isMeleeProof : 1;
	uint32_t isInvincible : 1;
	uint32_t unk9 : 1;
	uint32_t unk10 : 1;
	uint32_t isExplosionProof : 1;
	uint32_t unk12 : 1;
	uint32_t unk13 : 1;
	uint32_t unk14 : 1;
	uint32_t isSteamProof : 1;
	uint32_t isWaterProof : 1;
	uint32_t unk17 : 1;
	uint32_t unk18 : 1;
	uint32_t unk19 : 1;
	uint32_t unk20 : 1;
	uint32_t unk21 : 1;
	uint32_t unk22 : 1;
	uint32_t unk23 : 1;
	uint32_t unk24 : 1;
	uint32_t unk25 : 1;
	uint32_t unk26 : 1;
	uint32_t unk27 : 1;
	uint32_t unk28 : 1;
	uint32_t unk29 : 1;
	uint32_t unk30 : 1;
	uint32_t unk31 : 1;
};

struct CPhysical
{
	struct CDynamicEntity;
	char gapF0[144];
	uint64_t qword180;
	struct DamageFlags m_damage_bits; //0x0188
	uint8_t m_hostility; //0x018C
	char gap18D[3];
	uint8_t byte190;
	char gap191[3];
	uint32_t dword194;
	char gap198[232];
	float m_health; //0x0280
	float m_maxhealth; //0x0284
	struct CAttackers* m_attackers;
	char gap2B0[72];
	uint64_t qword2F8;
	uint64_t qword300;
	uint32_t dword308;
};
#pragma pack(pop)

struct CPedBoneInfo
{
	fvector3 model_coords;
};

#pragma pack(push, 1)
struct CPed
{
	struct CPhysical;
	char gap2EC[20];
	fvector3 m_velocity; //0x0300
	char pad_030C[256]; //0x030C
	struct CPedBoneInfo m_bone_info[9]; //0x0410
	char pad_04A0[2160]; //0x04A0
	struct CVehicle* m_vehicle; //0x0D10
	char pad_0D18[896]; //0x0D18
	uint32_t m_ped_type; //0x1098
	char pad_109C[4]; //0x109C
	struct CPedIntelligence* m_ped_intelligence; //0x10A0
	struct CPlayerInfo* m_player_info; //0x10A8
	struct CPedInventory* m_inventory; //0x10B0
	struct CPedWeaponManager* m_weapon_manager; //0x10B8
	char pad_10C0[892]; //0x10C0
	uint8_t m_seatbelt; //0x143C
	char pad_143D[13]; //0x143D
	uint8_t m_can_switch_weapon; //0x144A
	uint8_t m_ped_task_flag; //0x144B
	char pad_144C[4]; //0x144C
	uint8_t m_forced_aim; //0x1450 m_forced_aim ^= (m_forced_aim ^ -(char)toggle) & 0x20;
	char pad_1451[187]; //0x1451
	float m_armor; //0x150C
	float unk_health_threshold; //0x1510
	float m_fatigued_health_threshold; //0x1514
	float m_injured_health_threshold; //0x1518
	float m_dying_health_threshold; //0x151C
	float m_hurt_health_threshold; //0x1520
	char pad_1524[12]; //0x1524
	void* m_seat_info; //0x1530
	char pad_1538[220]; //0x1538
	uint16_t m_cash; //0x1614
	char pad_1616[846]; //0x1616
	uint8_t fired_sticky_bombs; //0x1964 reverse from 1.69 3258 function E8 ? ? ? ? 48 8B F8 EB ? 48 8B 47 add(1).rip(), function string: WM_MAX_STICKY
	uint8_t fired_unk_0; //0x1965
	uint8_t fired_flares; //0x1966
	uint8_t fired_unk_1; //0x1967
};
#pragma pack(pop)

#pragma pack(push, 1)
struct CDeformation
{
	char pad_0000[732]; //0x0000
}; //Size: 0x02DC

struct CVehicleDamage
{
	char pad_0000[16]; //0x0000
	struct CDeformation m_deformation; //0x0010
	char pad_02EC[284]; //0x02EC
	struct CVehicle* m_vehicle; //0x0408
	float m_body_health; //0x0410
	float m_petrol_tank_health; //0x0414
}; //Size: 0x0418


struct CVehicle
{
	struct CPhysical;
	char pad_02EC[12]; //0x02EC
	bool m_boosting; //0x02F8
	char pad_02F9[2]; //0x02F9
	bool m_boost_allow_recharge; //0x02FB
	char pad_02FC[4]; //0x02FC
	float m_boost; //0x0300
	float m_rocket_recharge_speed; //0x0304
	char pad_0308[152]; //0x0308
	float m_jump_boost_charge; //0x03A0
	bool m_can_boost_jump; //0x03A4
	char pad_03A5[123]; //0x03A5
	struct CVehicleDamage m_vehicle_damage; //0x0420
	char pad_0838[72]; //0x0838
	int16_t m_next_gear; //0x0880
	int16_t m_current_gear; //0x0882
	char pad_0884[2]; //0x0884
	int8_t m_top_gear; //0x0886
	char pad_0887[137]; //0x0887
	float m_engine_health; //0x0910
	char pad_0914[24]; //0x0914
	float m_kers_boost_max; //0x092C
	float m_kers_boost; //0x0930
	char pad_0934[44]; //0x0934
	struct CHandlingData* m_handling_data; //0x0960
	char pad_0968[2]; //0x0968
	uint8_t m_drivable_bitset; //0x096A
	uint8_t m_tyre_burst_bitset; //0x096B
	uint8_t m_deform_god; //0x096C
	char pad_096D[179]; //0x096D
	float m_dirt_level; //0x0A20
	char pad_0A24[202]; //0x0A24
	bool m_is_targetable; //0x0AEE
	char pad_0AEF[129]; //0x0AEF
	fvector3 pad_0B70;
	fvector3 pad_0B80;
	fvector3 pad_0B90;
	fvector3 pad_0BA0;
	fvector3 pad_0BB0;
	fvector3 pad_0BC0;
	fvector3 pad_0BD0;
	fvector3 pad_0BE0;
	fvector3 pad_0BF0;
	fvector3 pad_0C00;
	char pad_0C10[24];
	uint32_t m_type; //0x0C28
	char pad_0C2C[112]; //0x0C2C
	float m_gravity; //0x0C9C
	uint8_t m_max_passengers; //0x0CA0
	char pad_0CA1[1]; //0x0CA1
	uint8_t m_num_of_passengers; //0x0CA2
	char pad_0CA3[5]; //0x0CA3
	struct CPed* m_driver; //0x0CA8
	struct CPed* m_passengers[15]; //0x0CB0
	struct CPed* m_last_driver; //0x0CB0
	char pad_0D30[1696]; //0x0D30
	uint32_t m_door_lock_status; //0x13D0
	char pad_13D4[204]; //0x13D4
}; //Size: 0x14A0
#pragma pack(pop)

#pragma pack(push, 2)
struct CObject
{
	struct CPhysical;
	char gap30C[60];
	uint64_t qword348;
	char gap350[8];
	uint64_t qword358;
	uint16_t word360;
	uint32_t dword362;
	uint16_t word366;
	char gap368[120];
	uint64_t qword3E0;
	char gap3E8[8];
	uint64_t qword3F0;
	uint64_t qword3F8;
	uint64_t qword400;
	uint64_t qword408;
	uint64_t qword410;
};
#pragma pack(pop)






enum eHandlingType
{
	HANDLING_TYPE_BIKE,
	HANDLING_TYPE_FLYING,
	HANDLING_TYPE_VERTICAL_FLYING,
	HANDLING_TYPE_BOAT,
	HANDLING_TYPE_SEAPLANE,
	HANDLING_TYPE_SUBMARINE,
	HANDLING_TYPE_TRAIN,
	HANDLING_TYPE_TRAILER,
	HANDLING_TYPE_CAR,
	HANDLING_TYPE_WEAPON,
	HANDLING_TYPE_MAX_TYPES
};

#pragma pack(push, 16)
struct CHandlingData
{
	void* vtable;
	uint32_t handlingName;
	float fMass;
	float fInitialDragCoeff;
	float fDownforceModifier;
	float fPopUpLightRotation;
	__declspec(align(16)) fvector3 vecCentreOfMassOffset;
	fvector3 vecInertiaMultiplier;
	float fPercentSubmerged;
	float fBoyancy;
	float fDriveBiasFront;
	float fDriveBiasRear;
	uint8_t nInitialDriveGears;
	float fDriveInertia;
	float fClutchChangeRateScaleUpShift;
	float fClutchChangeRateScaleDownShift;
	float fInitialDriveForce;
	float fDriveMaxFlatVelocity;
	float fInitialDriveMaxFlatVel;
	float fBrakeForce;
	float pad_0070;
	float fBrakeBiasFront;
	float fBrakeBiasRear;
	float fHandBrakeForce;
	float fSteeringLock;
	float fSteeringLockRatio;
	float fTractionCurveMax;
	float pad_008C;
	float fTractionCurveMin;
	float pad_0094;
	float fTractionCurveLateral;
	float pad_009C;
	float fTractionSpringDeltaMax;
	float pad_00A4;
	float fLowSpeedTractionLossMult;
	float fCamberStiffnesss;
	float fTractionBiasFront;
	float fTractionBiasRear;
	float fTractionLossMult;
	float fSuspensionForce;
	float fSuspensionCompDamp;
	float fSuspensionReboundDamp;
	float fSuspensionUpperLimit;
	float fSuspensionLowerLimit;
	float fSuspensionRaise;
	float fSuspensionBiasFront;
	float fSuspensionBiasRear;
	float fAntiRollBarForce;
	float fAntiRollBarBiasFront;
	float fAntiRollBarBiasRear;
	float fRollCentreHeightFront;
	float fRollCentreHeightRear;
	float fCollisionDamageMult;
	float fWeaponDamageMult;
	float fDeformationDamageMult;
	float fEngineDamageMult;
	float fPetrolTankVolume;
	float fOilVolume;
	float fPetrolConsumptionRate;
	float fSeatOffsetDistX;
	float fSeatOffsetDistY;
	float fSeatOffsetDistZ;
	uint32_t nMonetaryValue;
	float fRocketBoostCapacity;
	float fBoostMaxSpeed;
	uint32_t pad_0124;
	uint32_t pad_0128;
	uint32_t pad_012C;
	uint32_t strModelFlags;
	uint32_t strHandlingFlags;
	uint32_t strDamageFlags;
	uint32_t AIHandling;
	char pad_140[24];
	atArray SubHandlingData;
	float fWeaponDamageScaledToVehHealthMult;
};
#pragma pack(pop)

#pragma pack(push, 8)
struct CBikeHandlingData
{
	void* vtable;
	float fLeanFwdCOMMult;
	float fLeanFwdForceMult;
	float fLeanBakCOMMult;
	float fLeanBakForceMult;
	float fMaxBankAngle;
	float fFullAnimAngle;
	float pad_0020;
	float fDesLeanReturnFrac;
	float fStickLeanMult;
	float fBrakingStabilityMult;
	float fInAirSteerMult;
	float fWheelieBalancePoint;
	float fStoppieBalancePoint;
	float fWheelieSteerMult;
	float fRearBalanceMult;
	float fFrontBalanceMult;
	float fBikeGroundSideFrictionMult;
	float fBikeWheelGroundSideFrictionMult;
	float fBikeOnStandLeanAngle;
	float fBikeOnStandSteerAngle;
	float fJumpForce;
};
#pragma pack(pop)

#pragma pack(push, 16)
struct CBoatHandlingData
{
	void* vtable;
	float fBoxFrontMult;
	float fBoxRearMult;
	float fBoxSideMult;
	float fSampleTop;
	float fSampleBottom;
	float fSampleBottomTestCorrection;
	float fAquaplaneForce;
	float fAquaplanePushWaterMult;
	float fAquaplanePushWaterCap;
	float fAquaplanePushWaterApply;
	float fRudderForce;
	float fRudderOffsetSubmerge;
	float fRudderOffsetForce;
	float fRudderOffsetForceZMult;
	float fWaveAudioMult;
	__declspec(align(16)) fvector3 vecMoveResistance;
	fvector3 vecTurnResistance;
	float fLook_L_R_CamHeight;
	float fDragCoefficient;
	float fKeelSphereSize;
	float fPropRadius;
	float fLowLodAngOffset;
	float fLowLodDraughtOffset;
	float fImpellerOffset;
	float fImpellerForceMult;
	float fDinghySphereBuoyConst;
	float fProwRaiseMult;
	float fDeepWaterSampleBuoyancyMult;
	float fTransmissionMultiplier;
	float fTractionMultiplier;
};

#pragma pack(pop)

#pragma pack(push, 8)
struct CCarHandlingData
{
	void* vtable;
	float fBackEndPopUpCarImpulseMult;
	float fBackEndPopUpBuildingImpulseMult;
	float fBackEndPopUpMaxDeltaSpeed;
	float fToeFront;
	float fToeRear;
	float fCamberFront;
	float fCamberRear;
	float fCastor;
	float fEngineResistance;
	float fMaxDriveBiasTransfer;
	float fJumpForceScale;
	float fIncreasedRammingForceScale;
	uint32_t strAdvancedFlags;
	atArray AdvancedData;
};
#pragma pack(pop)

#pragma pack(push, 16)
struct CFlyingHandlingData
{
	void* vtable;
	float fThrust;
	float fThrustFallOff;
	float fThrustVectoring;
	float fInitialThrust;
	float fInitialThrustFallOff;
	float fYawMult;
	float fYawStabilise;
	float fSideSlipMult;
	float fInitialYawMult;
	float fRollMult;
	float fRollStabilise;
	float fInitialRollMult;
	float fPitchMult;
	float fPitchStabilise;
	float fInitialPitchMult;
	float fFormLiftMult;
	float fAttackLiftMult;
	float fAttackDiveMult;
	float fGearDownDragV;
	float fGearDownLiftMult;
	float fWindMult;
	float fMoveRes;
	fvector3 vecTurnRes;
	fvector3 vecSpeedRes;
	float fGearDoorFrontOpen;
	float fGearDoorRearOpen;
	float fGearDoorRearOpen2;
	float fGearDoorRearMOpen;
	float fTurublenceMagnitudeMax;
	float fTurublenceForceMulti;
	float fTurublenceRollTorqueMulti;
	float fTurublencePitchTorqueMulti;
	float fBodyDamageControlEffectMult;
	float fInputSensitivityForDifficulty;
	float fOnGroundYawBoostSpeedPeak;
	float fOnGroundYawBoostSpeedCap;
	float fEngineOffGlideMulti;
	float fAfterburnerEffectRadius;
	float fAfterburnerEffectDistance;
	float fAfterburnerEffectForceMulti;
	float fSubmergeLevelToPullHeliUnderwater;
	float fExtraLiftWithRoll;
	enum eHandlingType handlingType;
};
#pragma pack(pop)

#pragma pack(push, 8)
struct CSeaPlaneHandlingData
{
	void* vtable;
	int fLeftPontoonComponentId;
	int fRightPontoonComponentId;
	float fPontoonBuoyConst;
	float fPontoonSampleSizeFront;
	float fPontoonSampleSizeMiddle;
	float fPontoonSampleSizeRear;
	float fPontoonLengthFractionForSamples;
	float fPontoonDragCoefficient;
	float fPontoonVerticalDampingCoefficientUp;
	float fPontoonVerticalDampingCoefficientDown;
	float fKeelSphereSize;
};
#pragma pack(pop)

#pragma pack(push, 16)
struct CSpecialFlightHandlingData
{
	void* vtable;
	__declspec(align(16)) fvector3 vecAngularDamping;
	fvector3 vecAngularDampingMin;
	fvector3 vecLinearDamping;
	fvector3 vecLinearDampingMin;
	float fLiftCoefficient;
	float fCriticalLiftAngle;
	float fInitialLiftAngle;
	float fMaxLiftAngle;
	float fDragCoefficient;
	float fBrakingDrag;
	float fMaxLiftVelocity;
	float fMinLiftVelocity;
	float fRollTorqueScale;
	float fMaxTorqueVelocity;
	float fMinTorqueVelocity;
	float fYawTorqueScale;
	float fSelfLevelingPitchTorqueScale;
	float fInitalOverheadAssist;
	float fMaxPitchTorque;
	float fMaxSteeringRollTorque;
	float fPitchTorqueScale;
	float fSteeringTorqueScale;
	float fMaxThrust;
	float fTransitionDuration;
	float fHoverVelocityScale;
	float fStabilityAssist;
	float fMinSpeedForThrustFalloff;
	float fBrakingThrustScale;
	int mode;
	uint32_t strFlags;
};
#pragma pack(pop)

#pragma pack(push, 16)
struct CSubmarineHandlingData
{
	void* vtable;
	__declspec(align(16)) fvector3 vTurnRes;
	float fMoveResXY;
	float fMoveResZ;
	float fPitchMult;
	float fPitchAngle;
	float fYawMult;
	float fDiveSpeed;
	float fRollMult;
	float fRollStab;
};
#pragma pack(pop)

#pragma pack(push, 8)
struct CTrailerHandlingData
{
	void* vtable;
	float fAttachLimitPitch;
	float fAttachLimitRoll;
	float fAttachLimitYaw;
	float fUprightSpringConstant;
	float fUprightDampingConstant;
	float fAttachedMaxDistance;
	float fAttachedMaxPenetration;
	float fAttachRaiseZ;
	float fPosConstraintMassRatio;
};
#pragma pack(pop)

#pragma pack(push, 8)
enum eVehicleModType
{
	VMT_SPOILER = 0,
	VMT_BUMPER_F = 1,
	VMT_BUMPER_R = 2,
	VMT_SKIRT = 3,
	VMT_EXHAUST = 4,
	VMT_CHASSIS = 5,
	VMT_GRILL = 6,
	VMT_BONNET = 7,
	VMT_WING_L = 8,
	VMT_WING_R = 9,
	VMT_ROOF = 10,
	VMT_PLTHOLDER = 11,
	VMT_PLTVANITY = 12,
	VMT_INTERIOR1 = 13,
	VMT_INTERIOR2 = 14,
	VMT_INTERIOR3 = 15,
	VMT_INTERIOR4 = 16,
	VMT_INTERIOR5 = 17,
	VMT_SEATS = 18,
	VMT_STEERING = 19,
	VMT_KNOB = 20,
	VMT_PLAQUE = 21,
	VMT_ICE = 22,
	VMT_TRUNK = 23,
	VMT_HYDRO = 24,
	VMT_ENGINEBAY1 = 25,
	VMT_ENGINEBAY2 = 26,
	VMT_ENGINEBAY3 = 27,
	VMT_CHASSIS2 = 28,
	VMT_CHASSIS3 = 29,
	VMT_CHASSIS4 = 30,
	VMT_CHASSIS5 = 31,
	VMT_DOOR_L = 32,
	VMT_DOOR_R = 33,
	VMT_LIVERY_MOD = 34,
	VMT_LIGHTBAR = 35,
	VMT_ENGINE = 36,
	VMT_BRAKES = 37,
	VMT_GEARBOX = 38,
	VMT_HORN = 39,
	VMT_SUSPENSION = 40,
	VMT_ARMOUR = 41,
	VMT_NITROUS = 42,
	VMT_TURBO = 43,
	VMT_SUBWOOFER = 44,
	VMT_TYRE_SMOKE = 45,
	VMT_HYDRAULICS = 46,
	VMT_XENON_LIGHTS = 47,
	VMT_WHEELS = 48,
	VMT_WHEELS_REAR_OR_HYDRAULICS = 49,
};
struct CVehicleWeaponHandlingData
{
	void* vtable;
	uint32_t uWeaponHash[6];
	int WeaponSeats[6];
	enum eVehicleModType WeaponVehicleModType[6];
	float fTurretSpeed[12];
	float fTurretPitchMin[12];
	float fTurretPitchMax[12];
	float fTurretCamPitchMin[12];
	float fTurretCamPitchMax[12];
	float fBulletVelocityForGravity[12];
	float fTurretPitchForwardMin[12];
	struct sTurretPitchLimits
	{
		void* vtable;
		float fForwardAngleMin;
		float fForwardAngleMax;
		float fBackwardAngleMin;
		float fBackwardAngleMid;
		float fBackwardAngleMax;
		float fBackwardForcedPitch;
	} TurretPitchLimitData[12];
	float fUvAnimationMult;
	float fMiscGadgetVar;
	float fWheelImpactOffset;
};
#pragma pack(pop)






union scrValue
{
	int Int;
	unsigned int Uns;
	float Float;
	const char* String;
	void* Reference;
	uint64_t Any;
};

struct scrNativeCallContext
{
	void* m_return_value;
	uint32_t m_arg_count;
	void* m_args;
	int32_t m_data_count;
	union scrValue* m_orig[4];
	fvector4 m_buffer[4];
};


enum eThreadState
{
	IDLE,
	RUNNING,
	KILLED,
	PAUSED,
	UNK4
};

struct scrThreadContext
{
	uint32_t m_ThreadId;
#if ENHANCED
	uint64_t m_ScriptHash;
#else
	uint32_t m_ScriptHash;
#endif
	enum eThreadState m_State;
	uint32_t m_ProgramCounter;
	uint32_t m_FramePointer;
	uint32_t m_StackPointer;
	float m_TimerA;
	float m_TimerB;
	float m_WaitTimer;
	char m_padding1[0x2C];
	uint32_t m_StackSize;
	char m_padding2[0x10];
	uint8_t m_CallDepth;
	uint32_t m_CallStack[16];
};

struct scrThread
{
	void* vtable;
	struct scrThreadContext m_Context;
	union scrValue* m_Stack;
	char m_padding[0x4];
	uint32_t m_ParameterSize;
	uint32_t m_ParameterLoc;
	char m_padding2[0x4];
#if ENHANCED
	char m_ErrorMessage[128];
#else
	const char* m_ErrorMessage;
#endif
	uint32_t m_ScriptHash;
	char m_ScriptName[0x40];
};

struct GtaThread
{
	struct scrThread;
	struct scriptHandler* m_ScriptHandler;
	struct scriptHandlerNetComponent* m_NetComponent;
	uint32_t m_ScriptHash2;                    // 0x120
	char m_padding3[0x14];                     // 0x124
	int32_t m_instance_id;                     // 0x138
	char m_padding4[0x04];                     // 0x13C
	uint8_t m_flag1;                           // 0x140
	bool m_safe_for_network_game;              // 0x141
	char m_padding5[0x02];                     // 0x142
	bool m_is_minigame_script;                 // 0x144
	char m_padding6[0x02];                     // 0x145
	bool m_can_be_paused;                      // 0x147
	bool m_can_remove_blips_from_other_scripts;// 0x148
	char m_padding7[0x0F];                     // 0x149
};


enum eInputMethod
{
	INPUT_KEYBOARD = 0,
	INPUT_KEYBOARD_UNK = 22,
	INPUT_MOUSE = 3,
	INPUT_MOUSE_ONE_AXIS = 1,
	INPUT_MOUSE_ONE_AXIS_AND_SIDE = 4,
	INPUT_MOUSE_ONE_AXIS_UNK = 5,
	INPUT_MOUSE_SCROLLWHEEL = 6,
	INPUT_MOUSE_BUTTON = 7,
	INPUT_GAMEPAD_BUTTON = 9,
	INPUT_GAMEPAD_TRIGGER = 11,
	INPUT_GAMEPAD_STICK = 11,
};

struct CInput
{
	enum eInputMethod m_InputMethod;
	int32_t m_Key; // Maps to virtual keys, unless we use a controller, then I don't know what it maps to.
	int32_t m_Unk;
};

struct CControlAction
{
	float m_Unk;
	float m_Value;
	float m_Value2;
	float m_Unk2;
	struct CInput m_Input;
	struct CInput m_Input2;
	uint32_t N00000054;
	uint32_t N00000087;
	uint32_t N00000055;
	uint32_t N0000008A;
	uint8_t N00000056;
	char pad_0039[15]; //0x0039
};
