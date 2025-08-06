local ffi = require("ffi")
ffi.cdef[[

# 0 "gta.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "gta.c"
# 9 "gta.c"
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
 char pad_0000[32];
 struct phBound* m_bound;
 char pad_0028[16];
};

struct phArchetypePhys
{
 struct phArchetype;
 char pad_0038[8];
 float m_mass;
 float m_pad0044;
 float m_pad0048;
 float m_pad004C;
 float m_pad0050;
 float m_water_collision;
 char pad_0058[40];
};

struct phArchetypeDamp
{
 struct phArchetypePhys;
 char pad_0080[96];
};

#pragma pack(push, 1)
struct CNavigation
{

 char pad_0000[16];
 struct phArchetypeDamp* m_damp;
 char pad_0018[8];
 fmatrix44 m_transformation_matrix;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct RAGE_RTTI
{
 void* (*_0x00)(void*_this);
 void* (*_0x08)(void*_this);
 uint32_t (*_0x10)(void*_this);
 void* (*_0x18)(void*_this, void*);
 bool (*_0x20)(void*_this, void*);
 bool (*_0x28)(void*_this, void**);
 void (*destructor)(void*_this);
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

struct fwCollisionFlags
{
 bool m_Unk1 : 1;
 bool m_HasCollision : 1;
 bool m_Unk2 : 1;
 bool m_Unk3 : 1;
 bool m_Unk4 : 1;
 bool m_Unk5 : 1;
 bool m_Unk6 : 1;
 bool m_Unk7 : 1;
};

struct fwEntityFlags
{
 bool m_Visible : 1;
 bool m_Unk1 : 1;
 bool m_Unk2 : 1;
 bool m_Unk3 : 1;
 bool m_Unk4 : 1;
 bool m_Unk5 : 1;
 bool m_Unk6 : 1;
 bool m_Unk7 : 1;
 bool m_Unk8 : 1;
 bool m_Unk9 : 1;
 bool m_Unk10 : 1;
 bool m_Unk11 : 1;
 bool m_Unk12 : 1;
 bool m_Unk13 : 1;
 bool m_Unk14 : 1;
 bool m_Unk15 : 1;
 bool m_Dynamic : 1;
 bool m_Frozen : 1;
 bool m_Unk18 : 1;
 bool m_Unk19 : 1;
 bool m_Unk20 : 1;
 bool m_Unk21 : 1;
 bool m_Unk22 : 1;
 bool m_Unk23 : 1;
 bool m_Unk24 : 1;
 bool m_Unk25 : 1;
 bool m_Unk26 : 1;
 bool m_Unk27 : 1;
 bool m_Unk28 : 1;
 bool m_Unk29 : 1;
 bool m_Unk30 : 1;
 bool m_Unk31 : 1;
};

#pragma pack(push, 8)
struct fwEntity
{
 struct fwExtensibleBase;
 uint64_t* m_ModelInfo;
 uint8_t m_Type;
 struct fwCollisionFlags m_CollisionFlags;
 uint16_t gap2A;
 struct fwEntityFlags m_Flags;
 struct CNavigation* m_Navigation;
 uint16_t gap38;
 uint16_t gap3A;
 uint32_t gap3C;
 struct fwDynamicEntityComponent* gap40;
 uint64_t* m_DrawData;
 struct fwDynamicEntityComponent* m_DynamicEntityComponent;
 uint64_t gap58;
 fmatrix44 m_Transform;
 struct fwEntity* m_RenderFocusEntity;
 uint32_t m_RenderFocusDistance;
 uint32_t m_Flags2;
 uint32_t m_ShadowFlags;
 char gapB4[4];
 uint8_t byteB8;
};
#pragma pack(pop)

struct CEntity
{
 struct fwEntity;
 uint32_t m_flags_3;
 uint32_t m_flags_4;
 uint32_t dwordC8;
 uint32_t dwordCC;
};

struct CDynamicEntity
{
 struct CEntity;
 struct netObject* m_NetObject;
 struct
 {
  uint16_t m_Unk0 : 1;
  uint16_t m_Unk1 : 1;
  uint16_t m_Unk2 : 1;
  uint16_t m_Unk3 : 1;
  uint16_t m_Unk4 : 1;
  uint16_t m_Unk5 : 1;
  uint16_t m_Unk6 : 1;
  uint16_t m_Unk7 : 1;
  uint16_t m_Unk8 : 1;
  uint16_t m_Unk9 : 1;
  uint16_t m_Unk10 : 1;
  uint16_t m_Unk11 : 1;
  uint16_t m_Unk12 : 1;
  uint16_t m_Unk13 : 1;
  uint16_t m_Unk14 : 1;
  uint16_t m_Unk15 : 1;
 } m_DynamicFlags;
 char gapD8[14];
 uint64_t qwordE8;
};

#pragma pack(push, 1)
struct CAttackers
{
    struct CPed* m_attacker0;
    char pad_0x0008[0x10];
    struct CPed* m_attacker1;
    char pad_0x0020[0x10];
    struct CPed* m_attacker2;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct DamageFlags
{
 bool m_Unk0 : 1;
 bool m_Unk1 : 1;
 bool m_Unk2 : 1;
 bool m_Unk3 : 1;
 bool m_IsBulletProof : 1;
 bool m_IsFireProof : 1;
 bool m_IsCollisionProof : 1;
 bool m_IsMeleeProof : 1;
 bool m_IsInvincible : 1;
 bool m_Unk9 : 1;
 bool m_Unk10 : 1;
 bool m_IsExplosionProof : 1;
 bool m_Unk12 : 1;
 bool m_Unk13 : 1;
 bool m_Unk14 : 1;
 bool m_IsSteamProof : 1;
 bool m_IsWaterProof : 1;
 bool m_Unk17 : 1;
 bool m_Unk18 : 1;
 bool m_Unk19 : 1;
 bool m_Unk20 : 1;
 bool m_Unk21 : 1;
 bool m_Unk22 : 1;
 bool m_Unk23 : 1;
 bool m_Unk24 : 1;
 bool m_Unk25 : 1;
 bool m_Unk26 : 1;
 bool m_Unk27 : 1;
 bool m_Unk28 : 1;
 bool m_Unk29 : 1;
 bool m_Unk30 : 1;
 bool m_Unk31 : 1;
};

struct CPhysical
{
 struct CDynamicEntity;
 char gapF0[144];
 uint64_t qword180;
 struct DamageFlags m_damage_bits;
 uint8_t m_hostility;
 char gap18D[3];
 uint8_t byte190;
 char gap191[3];
 uint32_t dword194;
 char gap198[232];
 float m_health;
 float m_maxhealth;
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
 fvector3 m_velocity;
 char pad_030C[256];
 struct CPedBoneInfo m_bone_info[9];
 char pad_04A0[2160];
 struct CVehicle* m_vehicle;
 char pad_0D18[896];
 uint32_t m_ped_type;
 char pad_109C[4];
 struct CPedIntelligence* m_ped_intelligence;
 struct CPlayerInfo* m_player_info;
 struct CPedInventory* m_inventory;
 struct CPedWeaponManager* m_weapon_manager;
 char pad_10C0[892];
 uint8_t m_seatbelt;
 char pad_143D[13];
 uint8_t m_can_switch_weapon;
 uint8_t m_ped_task_flag;
 char pad_144C[4];
 uint8_t m_forced_aim;
 char pad_1451[187];
 float m_armor;
 float unk_health_threshold;
 float m_fatigued_health_threshold;
 float m_injured_health_threshold;
 float m_dying_health_threshold;
 float m_hurt_health_threshold;
 char pad_1524[12];
 void* m_seat_info;
 char pad_1538[220];
 uint16_t m_cash;
 char pad_1616[846];
 uint8_t fired_sticky_bombs;
 uint8_t fired_unk_0;
 uint8_t fired_flares;
 uint8_t fired_unk_1;
};
#pragma pack(pop)

#pragma pack(push, 1)
struct CDeformation
{
 char pad_0000[732];
};

struct CVehicleDamage
{
 char pad_0000[16];
 struct CDeformation m_deformation;
 char pad_02EC[284];
 struct CVehicle* m_vehicle;
 float m_body_health;
 float m_petrol_tank_health;
};


struct CVehicle
{
 struct CPhysical;
 char pad_02EC[12];
 bool m_boosting;
 char pad_02F9[2];
 bool m_boost_allow_recharge;
 char pad_02FC[4];
 float m_boost;
 float m_rocket_recharge_speed;
 char pad_0308[152];
 float m_jump_boost_charge;
 bool m_can_boost_jump;
 char pad_03A5[123];
 struct CVehicleDamage m_vehicle_damage;
 char pad_0838[72];
 int16_t m_next_gear;
 int16_t m_current_gear;
 char pad_0884[2];
 int8_t m_top_gear;
 char pad_0887[137];
 float m_engine_health;
 char pad_0914[24];
 float m_kers_boost_max;
 float m_kers_boost;
 char pad_0934[44];
 struct CHandlingData* m_handling_data;
 char pad_0968[2];
 uint8_t m_drivable_bitset;
 uint8_t m_tyre_burst_bitset;
 uint8_t m_deform_god;
 char pad_096D[179];
 float m_dirt_level;
 char pad_0A24[202];
 bool m_is_targetable;
 char pad_0AEF[129];
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
 uint32_t m_type;
 char pad_0C2C[112];
 float m_gravity;
 uint8_t m_max_passengers;
 char pad_0CA1[1];
 uint8_t m_num_of_passengers;
 char pad_0CA3[5];
 struct CPed* m_driver;
 struct CPed* m_passengers[15];
 struct CPed* m_last_driver;
 char pad_0D30[1696];
 uint32_t m_door_lock_status;
 char pad_13D4[204];
};
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



 uint32_t m_ScriptHash;

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



 const char* m_ErrorMessage;

 uint32_t m_ScriptHash;
 char m_ScriptName[0x40];
};

struct GtaThread
{
 struct scrThread;
 struct scriptHandler* m_ScriptHandler;
 struct scriptHandlerNetComponent* m_NetComponent;
 uint32_t m_ScriptHash2;
 char m_padding3[0x14];
 int32_t m_instance_id;
 char m_padding4[0x04];
 uint8_t m_flag1;
 bool m_safe_for_network_game;
 char m_padding5[0x02];
 bool m_is_minigame_script;
 char m_padding6[0x02];
 bool m_can_be_paused;
 bool m_can_remove_blips_from_other_scripts;
 char m_padding7[0x0F];
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
 int32_t m_Key;
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
 char pad_0039[15];
};

struct Obf32
{
 uint32_t m_unk1;
 uint32_t m_unk2;
 uint32_t m_unk3;
 uint32_t m_unk4;
};

#pragma pack(push, 8)
struct CGameDataHash
{
 bool m_IsJapaneseVersion;
 struct Obf32 m_Data[16];
};
#pragma pack(pop)

struct datBitBuffer
{
 void* m_data;
 uint32_t m_bitOffset;
 uint32_t m_maxBit;
 uint32_t m_bitsRead;
 uint32_t m_curBit;
 uint32_t m_highestBitsRead;
 uint8_t m_flagBits;
};

struct netSocketAddress
{
 union {
  uint32_t m_Packed;
  struct
  {
   uint8_t m_Field4;
   uint8_t m_Field3;
   uint8_t m_Field2;
   uint8_t m_Field1;
  };
 } m_IpAddress;
 uint16_t m_Port;
};


struct netAddress
{
 struct netSocketAddress m_InternalIp;
 struct netSocketAddress m_ExternalIp;
 uint64_t m_PeerId;
 char m_Pad[6];
 uint8_t m_ConnectionType;
};

enum rlPlatforms
{
 UNK0,
 XBOX,
 PLAYSTATION,
 PC,
};

struct rlGamerHandle
{
 int64_t m_RockstarId;
 uint8_t m_Platform;
 uint8_t m_ProfileIndex;
};

struct rlGamerInfoBase
{
 bool m_SecurityEnabled;
 uint64_t m_PeerId;
 struct rlGamerHandle m_GamerHandle;
 char m_AESKey[0x28];
 struct netAddress m_RelayAddress;
 char m_RelaySignature[0x40];
 struct netSocketAddress m_ExternalAddress;
 struct netSocketAddress m_InternalAddress;
 uint32_t m_NatType;
 bool m_ForceRelays;
};

struct rlGamerInfo
{
 struct rlGamerInfoBase;
 uint64_t m_HostToken;

 union {
  struct rlGamerHandle m_GamerHandle2;
  uint32_t m_PeerId2;
 };
 uint32_t m_ROSPrivilege;
 char m_name[17];
};

struct CBattlEyePlayerModifyContext
{
 atArray m_Ticket;
 atArray m_GamerHandleHash;
 struct netSocketAddress m_Address;
 uint64_t m_HostToken;
 char m_Name[17];
 bool m_IsLocal;
};

#pragma pack(push, 8)
struct netPlayerVtable
{
 struct RAGE_RTTI;
 void (*Reset)(void*_this);
 bool (*IsPhysical)(void*_this);
 const char* (*GetName)(void*_this);
 uint64_t (*GetHostToken)(void*_this);
 void (*UpdatePermissions)(void*_this);
 bool (*IsHost)(void*_this);
 struct rlGamerInfo* (*GetGamerInfo)(void*_this);
 void (*UpdateUnk)(void*_this);
};

struct netPlayer
{
 struct netPlayerVtable* vtable;
 int m_AccountId;
 int64_t m_RockstarId;



 char new_0018[0x90];
 uint32_t m_player_type;

 struct CNonPhysicalPlayerData* m_NonPhysicalPlayer;
 uint32_t m_MessageId;
 char pad_001C[4];
 uint8_t m_ActiveIndex;
 uint8_t m_PlayerIndex;





 char pad_0022[3];
 uint16_t m_complaints;
 char pad_0027[17];
 struct CNetGamePlayer* m_unk_net_player_list[10];
 char pad_0090[4];
 uint64_t pad_0098;

};
#pragma pack(pop)

struct CNetGamePlayer
{
 struct netPlayer;
 void* m_Unk;
 struct CPlayerInfo* m_PlayerInfo;
};

struct netPlayerMgrBase
{
 struct netPlayerMgrBaseVtable* vtable;
 struct netConnectionManager* m_NetConnectionMgr;
 void* m_BandwidthMgr;
 char pad_0018[216];
 struct CNetGamePlayer* m_LocalPlayer;
 char pad_00F8[144];
 struct CNetGamePlayer* m_Players[32];
 uint32_t m_MaxPlayers;
 char pad_028C[4];
 int m_UnloadedPlayerCount;
 int m_LoadedPlayerCount;
 int m_LoadedNonLocalPlayerCount;
 int m_PhysicalPlayerCount;
 int m_LocalPhysicalPlayerCount;
 int m_NonLocalPhysicalPlayerCount;
 char pad_0296[1608];
};

struct CNetworkPlayerMgr
{
 struct netPlayerMgrBase;
};

struct netEvent
{
 void* vtable;
 uint32_t m_Timestamp;
 char pad_0008[52];
 uint32_t m_MsgId;
 uint32_t m_CxnId;
 struct netEvent* m_This;
 uint32_t m_PeerId;
 char pad_0084[4];
};


struct netEventFrameReceived
{
 struct netEvent;
 int m_SecurityId;
 struct netAddress m_Address;
 uint32_t m_Length;
 void* m_Data;
};




#pragma region Textures

struct grcTexture
{
 struct {
  void (*Destructor)(void*_this);
  void (*Unk1)(void*_this);
  void (*Unk2)(void*_this);
  void (*Unk3)(void*_this);
  void (*Unk4)(void*_this);
  uint16_t (*GetWidth)(void*_this);
  uint16_t (*GetHeight)(void*_this);
  uint16_t (*GetDepth)(void*_this);
  uint8_t (*GetMipLevels)(void*_this);
  void (*Unk9)(void*_this);
  uint8_t (*GetBitsPerPixel)(void*_this);
  void (*Unk11)(void*_this);
  void (*Unk12)(void*_this);
  void (*Unk13)(void*_this);
  void (*Unk14)(void*_this);
  void (*Unk15)(void*_this);
  void (*Unk16)(void*_this);
  void (*Unk17)(void*_this);
  void (*Unk18)(void*_this);
  void (*Unk19)(void*_this);
  void (*Unk20)(void*_this);
  void (*Unk21)(void*_this);
  void* (*GetShaderResourceView)(void*_this);
  void (*Unk23)(void*_this);
  void (*Unk24)(void*_this);
  void (*Unk25)(void*_this);
  void (*Unk26)(void*_this);
  void (*Unk27)(void*_this);
  void (*Unk28)(void*_this);
  void (*Unk29)(void*_this);
  void (*Unk30)(void*_this);
  void (*Unk31)(void*_this);
  void (*Unk32)(void*_this);
  void (*Unk33)(void*_this);
  void (*Unk34)(void*_this);
  void (*Unk35)(void*_this);
  void (*Unk36)(void*_this);
  void (*Unk37)(void*_this);
  void (*Unk38)(void*_this);
  void (*Unk39)(void*_this);
  void (*Unk40)(void*_this);
  void (*Unk41)(void*_this);
  void (*Unk42)(void*_this);
  void (*Unk43)(void*_this);
  void (*Unk44)(void*_this);
  void (*Unk45)(void*_this);
  void (*Unk46)(void*_this);
 } *vtable;

 char m_Pad1[0x18];
 const char* m_Name;
 int16_t word30;
 int8_t byte32;
 uint8_t m_ArraySize;
 int32_t dword34;
 void* m_Resource;
 int32_t dword40;
 int32_t dword44;
};

#pragma endregion

]]