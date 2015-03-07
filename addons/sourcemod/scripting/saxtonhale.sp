/*
    ===Versus Saxton Hale Mode===
    Created by Rainbolt Dash (formerly Dr.Eggman): programmer, model-maker, mapper.
    Notoriously famous for creating plugins with terrible code and then abandoning them

    FlaminSarge - He makes cool things. He improves on terrible things until they're good.
    Chdata - A Hale enthusiast and a coder. An Integrated Data Sentient Entity.
    nergal - Added some very nice features to the plugin and fixed important bugs.

    New plugin thread on AlliedMods: https://forums.alliedmods.net/showthread.php?p=2167912
*/
#define PLUGIN_VERSION "1.53"
#pragma semicolon 1
#include <tf2items>
#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN
#if SOURCEMOD_V_MINOR > 7
  #pragma newdecls required
  #define SMEIGHT
#endif
#include <tf2_stocks>
#include <regex>
#include <sdkhooks>
#include <clientprefs>
#if !defined SMEIGHT
  #pragma newdecls required
#endif
#include <morecolors>
#include <sourcemod>
#include <nextmap>
#include <saxtonhale>

#define CBS_MAX_ARROWS 9

#define EASTER_BUNNY_ON

#define HALEHHH_TELEPORTCHARGETIME 2
#define HALE_JUMPCHARGETIME 1

#define HALEHHH_TELEPORTCHARGE (25 * HALEHHH_TELEPORTCHARGETIME)
#define HALE_JUMPCHARGE (25 * HALE_JUMPCHARGETIME)


#define TF_MAX_PLAYERS          34             //  Sourcemod supports up to 64 players? Too bad TF2 doesn't. 33 player server +1 for 0 (console/world)
#define MAX_ENTITIES            2049           //  This is probably TF2 specific
#define MAX_CENTER_TEXT         192            //  PrintCenterText()

#define ITFTEAM(%0) view_as<TFTeam>(%0)
#define TFTInt(%0) view_as<int>(%0)

#define MAX_INT                 2147483647     //  PriorityCenterText
#define MIN_INT                 -2147483648    //  PriorityCenterText
#define MAX_DIGITS              12             //  10 + \0 for IntToString. And negative signs.

//#define OVERRIDE_MEDIGUNS_ON

// TF2 Weapon Loadout Slots
enum
{
    TFWeaponSlot_DisguiseKit = 3,
    TFWeaponSlot_Watch = 4,
    TFWeaponSlot_DestroyKit = 4,
    TFWeaponSlot_BuildKit = 5
}

// m_lifeState
enum
{
    LifeState_Alive = 0,
    LifeState_Dead = 2
}

//  For IsDate()
enum
{
    Month_None = 0,
    Month_Jan,
    Month_Feb,
    Month_Mar,
    Month_Apr,
    Month_May,
    Month_Jun,
    Month_Jul,
    Month_Aug,
    Month_Sep,
    Month_Oct,
    Month_Nov,
    Month_Dec
}

// START FILE DEFINTIONS

// Saxton Hale Files

// Model
#define HaleModel               "models/player/saxton_hale/saxton_hale.mdl"

// Materials
// Prepared Manually

// SFX
#define HaleYellName            "saxton_hale/saxton_hale_responce_1a.wav"
#define HaleRageSoundB          "saxton_hale/saxton_hale_responce_1b.wav"
#define HaleComicArmsFallSound  "saxton_hale/saxton_hale_responce_2.wav"
#define HaleLastB               "vo/announcer_am_lastmanalive"

#define HaleKSpree              "saxton_hale/saxton_hale_responce_3.wav"
//HaleKSpree2 - this line is broken and unused
#define HaleKSpree2             "saxton_hale/saxton_hale_responce_4.wav"

//===New responces===
#define HaleRoundStart          "saxton_hale/saxton_hale_responce_start"                // 1-5
#define HaleJump                "saxton_hale/saxton_hale_responce_jump"                 // 1-2
#define HaleRageSound           "saxton_hale/saxton_hale_responce_rage"                 // 1-4
#define HaleKillMedic           "saxton_hale/saxton_hale_responce_kill_medic.wav"
#define HaleKillSniper1         "saxton_hale/saxton_hale_responce_kill_sniper1.wav"
#define HaleKillSniper2         "saxton_hale/saxton_hale_responce_kill_sniper2.wav"
#define HaleKillSpy1            "saxton_hale/saxton_hale_responce_kill_spy1.wav"
#define HaleKillSpy2            "saxton_hale/saxton_hale_responce_kill_spy2.wav"
#define HaleKillEngie1          "saxton_hale/saxton_hale_responce_kill_eggineer1.wav"
#define HaleKillEngie2          "saxton_hale/saxton_hale_responce_kill_eggineer2.wav"
#define HaleKSpreeNew           "saxton_hale/saxton_hale_responce_spree"                // 1-5
#define HaleWin                 "saxton_hale/saxton_hale_responce_win"                  // 1-2
#define HaleLastMan             "saxton_hale/saxton_hale_responce_lastman"              // 1-5
//#define HaleLastMan2Fixed     "saxton_hale/saxton_hale_responce_lastman2.wav"
#define HaleFail                "saxton_hale/saxton_hale_responce_fail"                 // 1-3

//===1.32 responces===
#define HaleJump132             "saxton_hale/saxton_hale_132_jump_"                     // 1-2
#define HaleStart132            "saxton_hale/saxton_hale_132_start_"                    // 1-5
#define HaleKillDemo132         "saxton_hale/saxton_hale_132_kill_demo.wav"
#define HaleKillEngie132        "saxton_hale/saxton_hale_132_kill_engie_"               // 1-2
#define HaleKillHeavy132        "saxton_hale/saxton_hale_132_kill_heavy.wav"
#define HaleKillScout132        "saxton_hale/saxton_hale_132_kill_scout.wav"
#define HaleKillSpy132          "saxton_hale/saxton_hale_132_kill_spie.wav"
#define HaleKillPyro132         "saxton_hale/saxton_hale_132_kill_w_and_m1.wav"
#define HaleSappinMahSentry132  "saxton_hale/saxton_hale_132_kill_toy.wav"
#define HaleKillKSpree132       "saxton_hale/saxton_hale_132_kspree_"                   // 1-2
#define HaleKillLast132         "saxton_hale/saxton_hale_132_last.wav"
#define HaleStubbed132          "saxton_hale/saxton_hale_132_stub_"                     // 1-4

// Unused
//#define HaleEnabled             QueuePanelH(Handle:0, MenuAction:0, 9001, 0)


// Christian Brutal Sniper Files

// Model
#define CBSModel                "models/player/saxton_hale/cbs_v4.mdl"

// Materials
// Prepared Manually

// SFX
#define CBSTheme                "saxton_hale/the_millionaires_holiday.mp3"
#define CBS0                    "vo/sniper_specialweapon08.wav"
#define CBS1                "vo/taunts/sniper_taunts02.wav"
#define CBS2                    "vo/sniper_award"
#define CBS3                "vo/sniper_battlecry03.wav"
#define CBS4                    "vo/sniper_domination"
#define CBSJump1                "vo/sniper_specialcompleted02.wav"

// Unused
//#define ShivModel               "models/weapons/c_models/c_wood_machete/c_wood_machete.mdl"


// Horseless Headless Horsemann Files

// Model
#define HHHModel                "models/player/saxton_hale/hhh_jr_mk3.mdl"

// Materials

// SFX
#define HHHLaught               "vo/halloween_boss/knight_laugh"
#define HHHRage                 "vo/halloween_boss/knight_attack01.wav"
#define HHHRage2                "vo/halloween_boss/knight_alert.wav"
#define HHHAttack               "vo/halloween_boss/knight_attack"

#define HHHTheme                "saxton_hale/hhh_theme.mp3"

// Unused
//#define AxeModel                "models/weapons/c_models/c_headtaker/c_headtaker.mdl"


// Vagineer Files

// Model
#define VagineerModel           "models/player/saxton_hale/vagineer_v134.mdl"

// Materials
// None! He uses Engineer's stuff

// SFX
#define VagineerLastA           "saxton_hale/lolwut_0.wav"
#define VagineerRageSound       "saxton_hale/lolwut_2.wav"
#define VagineerStart           "saxton_hale/lolwut_1.wav"
#define VagineerKSpree          "saxton_hale/lolwut_3.wav"
#define VagineerKSpree2         "saxton_hale/lolwut_4.wav"
#define VagineerHit             "saxton_hale/lolwut_5.wav"

//===New Vagineer's responces===
#define VagineerRoundStart      "saxton_hale/vagineer_responce_intro.wav"
#define VagineerJump            "saxton_hale/vagineer_responce_jump_"         //  1-2
#define VagineerRageSound2      "saxton_hale/vagineer_responce_rage_"         //  1-4
#define VagineerKSpreeNew       "saxton_hale/vagineer_responce_taunt_"        //  1-5
#define VagineerFail            "saxton_hale/vagineer_responce_fail_"         //  1-2

// Unused
//#define VagineerModel           "models/player/saxton_hale/vagineer_v150.mdl"
//#define WrenchModel             "models/weapons/w_models/w_wrench.mdl"


#if defined EASTER_BUNNY_ON
// Easter Bunny Files

// Model
#define BunnyModel              "models/player/saxton_hale/easter_demo.mdl"
#define EggModel                "models/player/saxton_hale/w_easteregg.mdl"

// Materials
static const char BunnyMaterials[][] = {
    "materials/models/player/easter_demo/demoman_head_red.vmt",
    "materials/models/player/easter_demo/easter_body.vmt",
    "materials/models/player/easter_demo/easter_body.vtf",
    "materials/models/player/easter_demo/easter_rabbit.vmt",
    "materials/models/player/easter_demo/easter_rabbit.vtf",
    "materials/models/player/easter_demo/easter_rabbit_normal.vtf",
    "materials/models/player/easter_demo/eyeball_r.vmt"
    // "materials/models/player/easter_demo/demoman_head_blue_invun.vmt", // This is for the new version of easter demo which VSH isn't using
    // "materials/models/player/easter_demo/demoman_head_red_invun.vmt",
    // "materials/models/player/easter_demo/easter_rabbit_blue.vmt",
    // "materials/models/player/easter_demo/easter_rabbit_blue.vtf",
    // "materials/models/player/easter_demo/easter_rabbit_invun.vmt",
    // "materials/models/player/easter_demo/easter_rabbit_invun.vtf",
    // "materials/models/player/easter_demo/easter_rabbit_invun_blue.vmt",
    // "materials/models/player/easter_demo/easter_rabbit_invun_blue.vtf",
    // "materials/models/player/easter_demo/eyeball_invun.vmt"
};

// SFX
static const char BunnyWin[][] = {
    "vo/demoman_gibberish01.wav",
    "vo/demoman_gibberish12.wav",
    "vo/demoman_cheers02.wav",
    "vo/demoman_cheers03.wav",
    "vo/demoman_cheers06.wav",
    "vo/demoman_cheers07.wav",
    "vo/demoman_cheers08.wav",
    "vo/taunts/demoman_taunts12.wav"
};

static const char BunnyJump[][] = {
    "vo/demoman_gibberish07.wav",
    "vo/demoman_gibberish08.wav",
    "vo/demoman_laughshort01.wav",
    "vo/demoman_positivevocalization04.wav"
};

static const char BunnyRage[][] = {
    "vo/demoman_positivevocalization03.wav",
    "vo/demoman_dominationscout05.wav",
    "vo/demoman_cheers02.wav"
};

static const char BunnyFail[][] = {
    "vo/demoman_gibberish04.wav",
    "vo/demoman_gibberish10.wav",
    "vo/demoman_jeers03.wav",
    "vo/demoman_jeers06.wav",
    "vo/demoman_jeers07.wav",
    "vo/demoman_jeers08.wav"
};

static const char BunnyKill[][] = {
    "vo/demoman_gibberish09.wav",
    "vo/demoman_cheers02.wav",
    "vo/demoman_cheers07.wav",
    "vo/demoman_positivevocalization03.wav"
};

static const char BunnySpree[][] = {
    "vo/demoman_gibberish05.wav",
    "vo/demoman_gibberish06.wav",
    "vo/demoman_gibberish09.wav",
    "vo/demoman_gibberish11.wav",
    "vo/demoman_gibberish13.wav",
    "vo/demoman_autodejectedtie01.wav"
};

static const char BunnyLast[][] = {
    "vo/taunts/demoman_taunts05.wav",
    "vo/taunts/demoman_taunts04.wav",
    "vo/demoman_specialcompleted07.wav"
};

static const char BunnyPain[][] = {
    "vo/demoman_sf12_badmagic01.wav",
    "vo/demoman_sf12_badmagic07.wav",
    "vo/demoman_sf12_badmagic10.wav"
};

static const char BunnyStart[][] = {
    "vo/demoman_gibberish03.wav",
    "vo/demoman_gibberish11.wav"
};

static const char BunnyRandomVoice[][] = {
    "vo/demoman_positivevocalization03.wav",
    "vo/demoman_jeers08.wav",
    "vo/demoman_gibberish03.wav",
    "vo/demoman_cheers07.wav",
    "vo/demoman_sf12_badmagic01.wav",
    "vo/burp02.wav",
    "vo/burp03.wav",
    "vo/burp04.wav",
    "vo/burp05.wav",
    "vo/burp06.wav",
    "vo/burp07.wav"
};

// Unused
//#define ReloadEggModel          "models/player/saxton_hale/c_easter_cannonball.mdl"
#endif

// END FILE DEFINTIONS

#define SOUNDEXCEPT_MUSIC 0
#define SOUNDEXCEPT_VOICE 1
#if defined _steamtools_included
bool steamtools = false;
#endif
TFTeam OtherTeam = TFTeam_Red, HaleTeam = TFTeam_Blue;
VSHRState VSHRoundState = VSHRState_Disabled;
VSHSpecial Special, Incoming;
int playing, healthcheckused, RedAlivePlayers, RoundCount, Damage[TF_MAX_PLAYERS], AirDamage[TF_MAX_PLAYERS], ourHelp[TF_MAX_PLAYERS], uberTarget[TF_MAX_PLAYERS];
static bool g_bReloadVSHOnRoundEnd = false;
#define VSHFLAG_HELPED          (1 << 0)
#define VSHFLAG_UBERREADY       (1 << 1)
#define VSHFLAG_NEEDSTODUCK (1 << 2)
#define VSHFLAG_BOTRAGE     (1 << 3)
#define VSHFLAG_CLASSHELPED (1 << 4)
#define VSHFLAG_HASONGIVED  (1 << 5)
int VSHFlags[TF_MAX_PLAYERS], Hale = -1, HaleHealthMax, HaleHealth, HaleHealthLast, HaleCharge = 0, HaleRage, NextHale, KSpreeCount = 1, HHHClimbCount;
float g_flStabbed, g_flMarketed, HPTime, KSpreeTimer, WeighDownTimer, UberRageCount, GlowTimer, HaleSpeed = 340.0, RageDist = 800.0, Announce = 120.0, tf_scout_hype_pep_max;
bool bEnableSuperDuperJump, bTenSecStart[2] = {false, false}, bSpawnTeleOnTriggerHurt = false, bNoTaunt = false, g_bEnabled = false, g_bAreEnoughPlayersPlaying = false;
ConVar cvarVersion, cvarHaleSpeed, cvarPointDelay, cvarRageDMG, cvarRageDist, cvarAnnounce, cvarSpecials, cvarEnabled, cvarAliveToEnable, cvarPointType, cvarCrits, cvarRageSentry;
ConVar cvarFirstRound, cvarDemoShieldCrits, cvarDisplayHaleHP, cvarEnableEurekaEffect, cvarForceHaleTeam;
Handle PointCookie, MusicCookie, VoiceCookie, ClasshelpinfoCookie, doorchecktimer, jumpHUD, rageHUD, healthHUD, infoHUD, MusicTimer;
//new Handle:cvarCircuitStun;
//new Handle:cvarForceSpecToHale;
int PointDelay = 6, RageDMG = 3500, bSpecials = true, AliveToEnable = 5, PointType = 0, TeamRoundCounter, botqueuepoints = 0, tf_arena_use_queue, mp_teams_unbalance_limit;
int tf_arena_first_blood, mp_forcecamera, defaulttakedamagetype;
bool haleCrits = false, bDemoShieldCrits = false, bAlwaysShowHealth = true, newRageSentry = true, checkdoors = false, PointReady;
//new Float:circuitStun = 0.0;
char currentmap[99];

static const char haleversiontitles[][] =     //the last line of this is what determines the displayed plugin version
{
    "1.0",
    "1.1",
    "1.11",
    "1.12",
    "1.2",
    "1.22",
    "1.23",
    "1.24",
    "1.25",
    "1.26",
    "Christian Brutal Sniper",
    "1.28",
    "1.29",
    "1.30",
    "1.31",
    "1.32",
    "1.33",
    "1.34",
    "1.35",
    "1.35_3",
    "1.36",
    "1.36",
    "1.36",
    "1.36",
    "1.36",
    "1.36",
    "1.362",
    "1.363",
    "1.364",
    "1.365",
    "1.366",
    "1.367",
    "1.368",
    "1.369",
    "1.369",
    "1.369",
    "1.37",
    "1.37b",    //15 Nov 2011
    "1.38",
    "1.38",
    "1.39beta",
    "1.39beta",
    "1.39beta",
    "1.39c",
    "1.39c",
    "1.39c",
    "1.40",
    "1.41",
    "1.42",
    "1.43",
    "1.43",
    "1.43",
    "1.44",
    "1.44",
    "1.45",
    "1.45",
    "1.45",
    "1.45",
    "1.45",
    "1.46",
    "1.46",
    "1.46",
    "1.47",
    "1.47",
    "1.48",
    "1.48",
    "1.49",
    "1.50",
    "1.51",
    "1.52",
    PLUGIN_VERSION
};
static const char haleversiondates[][] =
{
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "--",
    "25 Aug 2011",
    "26 Aug 2011",
    "09 Oct 2011",
    "09 Oct 2011",
    "09 Oct 2011",
    "15 Nov 2011",
    "15 Nov 2011",
    "17 Dec 2011",
    "17 Dec 2011",
    "05 Mar 2012",
    "05 Mar 2012",
    "05 Mar 2012",
    "16 Jul 2012",
    "16 Jul 2012",
    "16 Jul 2012",
    "10 Oct 2012",
    "25 Feb 2013",
    "30 Mar 2013",
    "14 Jul 2014",
    "15 Jul 2014",
    "15 Jul 2014",
    "15 Jul 2014",
    "15 Jul 2014",
    "18 Jul 2014",
    "17 Jul 2014",
    "17 Jul 2014",
    "17 Jul 2014",
    "17 Jul 2014",
    "27 Jul 2014",
    "19 Jul 2014",
    "19 Jul 2014",
    "04 Aug 2014",
    "04 Aug 2014",
    "14 Aug 2014",
    "14 Aug 2014",
    "18 Aug 2014",
    "04 Oct 2014",
    "29 Oct 2014", //  An update I never bothered to throw outdate
    "25 Dec 2014"  //  Merry Xmas
};
static const int maxversion = (sizeof(haleversiontitles) - 1);
Handle OnHaleJump, OnHaleRage, OnHaleWeighdown, OnMusic, OnHaleNext;

//new Handle:hEquipWearable;
//new Handle:hSetAmmoVelocity;

/*new Handle:OnIsVSHMap;
new Handle:OnIsEnabled;
new Handle:OnGetHale;
new Handle:OnGetTeam;
new Handle:OnGetSpecial;
new Handle:OnGetHealth;
new Handle:OnGetHealthMax;
new Handle:OnGetDamage;
new Handle:OnGetRoundState;*/

//new bool:ACH_Enabled;
public Plugin myinfo = {
    name = "Versus Saxton Hale",
    author = "Rainbolt Dash, FlaminSarge, Chdata, nergal, fiagram",
    description = "RUUUUNN!! COWAAAARRDSS!",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?p=2167912",
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("GetUserMessageType");
    MarkNativeAsOptional("PbSetInt");
    MarkNativeAsOptional("PbSetBool");
    MarkNativeAsOptional("PbSetString");
    MarkNativeAsOptional("PbAddString");
/*  CreateNative("VSH_IsSaxtonHaleModeMap", Native_IsVSHMap);
    OnIsVSHMap = CreateGlobalForward("VSH_OnIsSaxtonHaleModeMap", ET_Hook, Param_CellByRef);

    CreateNative("VSH_IsSaxtonHaleModeEnabled", Native_IsEnabled);
    OnIsEnabled = CreateGlobalForward("VSH_OnIsSaxtonHaleModeEnabled", ET_Hook, Param_CellByRef);

    CreateNative("VSH_GetSaxtonHaleUserId", Native_GetHale);
    OnGetHale = CreateGlobalForward("VSH_OnGetSaxtonHaleUserId", ET_Hook, Param_CellByRef);

    CreateNative("VSH_GetSaxtonHaleTeam", Native_GetTeam);
    OnGetTeam = CreateGlobalForward("VSH_OnGetSaxtonHaleTeam", ET_Hook, Param_CellByRef);

    CreateNative("VSH_GetSpecialRoundIndex", Native_GetSpecial);
    OnGetSpecial = CreateGlobalForward("VSH_OnGetSpecialRoundIndex", ET_Hook, Param_CellByRef);

    CreateNative("VSH_GetSaxtonHaleHealth", Native_GetHealth);
    OnGetHealth = CreateGlobalForward("VSH_OnGetSaxtonHaleHealth", ET_Hook, Param_CellByRef);

    CreateNative("VSH_GetSaxtonHaleHealthMax", Native_GetHealthMax);
    OnGetHealthMax = CreateGlobalForward("VSH_OnGetSaxtonHaleHealthMax", ET_Hook, Param_CellByRef);

    CreateNative("VSH_GetClientDamage", Native_GetDamage);
    OnGetDamage = CreateGlobalForward("VSH_OnGetClientDamage", ET_Hook, Param_Cell,Param_CellByRef);

    CreateNative("VSH_GetRoundState", Native_GetRoundState);
    OnGetRoundState = CreateGlobalForward("VSH_OnGetRoundState", ET_Hook, Param_CellByRef);*/
    //Methodmap natives.
    CreateNative("VSH.IsVSHMap.get", Native_IsVSHMap);
    CreateNative("VSH.IsEnabled.get", Native_IsEnabled);
    CreateNative("VSH.BossUserId.get", Native_GetHale);
    CreateNative("VSH.BossTeam.get", Native_GetTeam);
    CreateNative("VSH.SpecialIndex.get", Native_GetSpecial);
    CreateNative("VSH.BossHealth.get", Native_GetHealth);
    CreateNative("VSH.BossHealthMax.get", Native_GetHealthMax);
    CreateNative("VSH.RoundState.get", Native_GetRoundState);
    //End methodmap natives.
    CreateNative("VSH_IsSaxtonHaleModeMap", Native_IsVSHMap);
    CreateNative("VSH_IsSaxtonHaleModeEnabled", Native_IsEnabled);
    CreateNative("VSH_GetSaxtonHaleUserId", Native_GetHale);
    CreateNative("VSH_GetSaxtonHaleTeam", Native_GetTeam);
    CreateNative("VSH_GetSpecialRoundIndex", Native_GetSpecial);
    CreateNative("VSH_GetSaxtonHaleHealth", Native_GetHealth);
    CreateNative("VSH_GetSaxtonHaleHealthMax", Native_GetHealthMax);
    CreateNative("VSH_GetClientDamage", Native_GetDamage);
    CreateNative("VSH_GetRoundState", Native_GetRoundState);
    OnHaleJump = CreateGlobalForward("VSH_OnDoJump", ET_Hook, Param_CellByRef);
    OnHaleRage = CreateGlobalForward("VSH_OnDoRage", ET_Hook, Param_FloatByRef);
    OnHaleWeighdown = CreateGlobalForward("VSH_OnDoWeighdown", ET_Hook);
    OnMusic = CreateGlobalForward("VSH_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
    OnHaleNext = CreateGlobalForward("VSH_OnHaleNext", ET_Hook, Param_Cell);
    RegPluginLibrary("saxtonhale");
#if defined _steamtools_included
    MarkNativeAsOptional("Steam_SetGameDescription");
#endif
    return APLRes_Success;
}
/*InitGamedata()
{
#if defined EASTER_BUNNY_ON
    new Handle:hGameConf = LoadGameConfigFile("saxtonhale");
    if (hGameConf == INVALID_HANDLE)
    {
        SetFailState("[VSH] Unable to load gamedata file 'saxtonhale.txt'");
        return;
    }
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
    PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
    hEquipWearable = EndPrepSDKCall();
    if (hEquipWearable == INVALID_HANDLE)
    {
        SetFailState("[VSH] Failed to initialize call to CTFPlayer::EquipWearable");
        return;
    }
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CTFAmmoPack::SetInitialVelocity");
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
    hSetAmmoVelocity = EndPrepSDKCall();
    if (hSetAmmoVelocity == INVALID_HANDLE)
    {
        SetFailState("[VSH] Failed to initialize call to CTFAmmoPack::SetInitialVelocity");
        CloseHandle(hGameConf);
        return;
    }
    CloseHandle(hGameConf);
#endif
}*/
/*public Action:Command_Eggs(client, args)
{
    SpawnManyAmmoPacks(client, EggModel, 1);
}*/
public void OnPluginStart()
{
//  InitGamedata();
//  RegAdminCmd("hale_eggs", Command_Eggs, ADMFLAG_ROOT);   //WILL CRASH.
    //ACH_Enabled=LibraryExists("hale_achievements");
    LogMessage("===Versus Saxton Hale Initializing - v%s===", haleversiontitles[maxversion]);
    cvarVersion = CreateConVar("hale_version", haleversiontitles[maxversion], "VS Saxton Hale Version", FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD);
    cvarHaleSpeed = CreateConVar("hale_speed", "340.0", "Speed of Saxton Hale", FCVAR_PLUGIN);
    cvarPointType = CreateConVar("hale_point_type", "0", "Select condition to enable point (0 - alive players, 1 - time)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarPointDelay = CreateConVar("hale_point_delay", "6", "Addition (for each player) delay before point's activation.", FCVAR_PLUGIN);
    cvarAliveToEnable = CreateConVar("hale_point_alive", "5", "Enable control points when there are X people left alive.", FCVAR_PLUGIN);
    cvarRageDMG = CreateConVar("hale_rage_damage", "3500", "Damage required for Hale to gain rage", FCVAR_PLUGIN, true, 0.0);
    cvarRageDist  = CreateConVar("hale_rage_dist", "800.0", "Distance to stun in Hale's rage. Vagineer and CBS are /3 (/2 for sentries)", FCVAR_PLUGIN, true, 0.0);
    cvarAnnounce = CreateConVar("hale_announce", "120.0", "Info about mode will show every X seconds. Must be greater than 1.0 to show.", FCVAR_PLUGIN, true, 0.0);
    cvarSpecials = CreateConVar("hale_specials", "1", "Enable Special Rounds (Vagineer, HHH, CBS)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarEnabled = CreateConVar("hale_enabled", "1", "Do you really want set it to 0?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarCrits = CreateConVar("hale_crits", "0", "Can Hale get crits?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarDemoShieldCrits = CreateConVar("hale_shield_crits", "0", "Does Demoman's shield grant crits (1) or minicrits (0)?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarDisplayHaleHP = CreateConVar("hale_hp_display", "1", "Display Hale Health at all times.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarRageSentry = CreateConVar("hale_ragesentrydamagemode", "1", "If 0, to repair a sentry that has been damaged by rage, the Engineer must pick it up and put it back down.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarFirstRound = CreateConVar("hale_first_round", "0", "Disable(0) or Enable(1) VSH in 1st round.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    //cvarCircuitStun = CreateConVar("hale_circuit_stun", "0", "0 to disable Short Circuit stun, >0 to make it stun Hale for x seconds", FCVAR_PLUGIN, true, 0.0);
    //cvarForceSpecToHale = CreateConVar("hale_spec_force_boss", "0", "1- if a spectator is up next, will force them to Hale + spectators will gain queue points, else spectators are ignored by plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarEnableEurekaEffect = CreateConVar("hale_enable_eureka", "0", "1- allow Eureka Effect, else disallow", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvarForceHaleTeam = CreateConVar("hale_force_team", "0", "0- Use plugin logic, 1- random team, 2- red, 3- blue", FCVAR_PLUGIN, true, 0.0, true, 3.0);

    // bFriendlyFire = GetConVarBool(FindConVar("mp_friendlyfire"));
    // HookConVarChange(FindConVar("mp_friendlyfire"), HideCvarNotify);
    FindConVar("tf_bot_count").AddChangeHook(HideCvarNotify);
    FindConVar("tf_arena_use_queue").AddChangeHook(HideCvarNotify);
    FindConVar("tf_arena_first_blood").AddChangeHook(HideCvarNotify);
    FindConVar("mp_friendlyfire").AddChangeHook(HideCvarNotify);

    HookEvent("teamplay_round_start", event_round_start);
    HookEvent("teamplay_round_win", event_round_end);
    HookEvent("player_changeclass", event_changeclass);
    HookEvent("player_spawn", event_player_spawn);
    HookEvent("player_death", event_player_death, EventHookMode_Pre);
    HookEvent("player_chargedeployed", event_uberdeployed);
    HookEvent("player_hurt", event_hurt, EventHookMode_Pre);
    HookEvent("object_destroyed", event_destroy, EventHookMode_Pre);
    HookEvent("object_deflected", event_deflect, EventHookMode_Pre);
    OnPluginStart_TeleportToMultiMapSpawn(); // Setup adt_array
    HookUserMessage(GetUserMessageId("PlayerJarated"), event_jarate);
    cvarEnabled.AddChangeHook(CvarChange);
    cvarHaleSpeed.AddChangeHook(CvarChange);
    cvarRageDMG.AddChangeHook(CvarChange);
    cvarRageDist.AddChangeHook(CvarChange);
    cvarAnnounce.AddChangeHook(CvarChange);
    cvarSpecials.AddChangeHook(CvarChange);
    cvarPointType.AddChangeHook(CvarChange);
    cvarPointDelay.AddChangeHook(CvarChange);
    cvarAliveToEnable.AddChangeHook(CvarChange);
    cvarCrits.AddChangeHook(CvarChange);
    cvarDemoShieldCrits.AddChangeHook(CvarChange);
    cvarDisplayHaleHP.AddChangeHook(CvarChange);
    cvarRageSentry.AddChangeHook(CvarChange);
    //HookConVarChange(cvarCircuitStun, CvarChange);
    g_bReloadVSHOnRoundEnd = false;
    RegAdminCmd("sm_hale_reload", Debug_ReloadVSH, ADMFLAG_ROOT, "Reloads the VSH plugin safely and silently.");
    RegConsoleCmd("sm_hale", HalePanel);
    RegConsoleCmd("sm_hale_hp", Command_GetHPCmd);
    RegConsoleCmd("sm_halehp", Command_GetHPCmd);
    RegConsoleCmd("sm_hale_next", QueuePanelCmd);
    RegConsoleCmd("sm_halenext", QueuePanelCmd);
    RegConsoleCmd("sm_hale_help", HelpPanelCmd);
    RegConsoleCmd("sm_halehelp", HelpPanelCmd);
    RegConsoleCmd("sm_hale_class", HelpPanel2Cmd);
    RegConsoleCmd("sm_haleclass", HelpPanel2Cmd);
    RegConsoleCmd("sm_hale_classinfotoggle", ClasshelpinfoCmd);
    RegConsoleCmd("sm_haleclassinfotoggle", ClasshelpinfoCmd);
    RegConsoleCmd("sm_infotoggle", ClasshelpinfoCmd);
    RegConsoleCmd("sm_hale_new", NewPanelCmd);
    RegConsoleCmd("sm_halenew", NewPanelCmd);
//  RegConsoleCmd("hale_me", SkipHalePanelCmd);
//  RegConsoleCmd("haleme", SkipHalePanelCmd);
    RegConsoleCmd("sm_halemusic", MusicTogglePanelCmd);
    RegConsoleCmd("sm_hale_music", MusicTogglePanelCmd);
    RegConsoleCmd("sm_halevoice", VoiceTogglePanelCmd);
    RegConsoleCmd("sm_hale_voice", VoiceTogglePanelCmd);
    RegAdminCmd("sm_hale_resetqueuepoints", ResetQueuePointsCmd, 0);
    RegAdminCmd("sm_hale_resetq", ResetQueuePointsCmd, 0);
    RegAdminCmd("sm_halereset", ResetQueuePointsCmd, 0);
    RegAdminCmd("sm_resetq", ResetQueuePointsCmd, 0);
    RegAdminCmd("sm_hale_special", Command_MakeNextSpecial, 0, "Call a special to next round.");
    AddCommandListener(DoTaunt, "taunt");
    AddCommandListener(DoTaunt, "+taunt");
    AddCommandListener(cdVoiceMenu, "voicemenu");
    AddCommandListener(DoSuicide, "explode");
    AddCommandListener(DoSuicide, "kill");
    AddCommandListener(DoSuicide2, "jointeam");
    AddCommandListener(Destroy, "destroy");
    RegAdminCmd("sm_hale_select", Command_HaleSelect, ADMFLAG_CHEATS, "hale_select <target> - Select a player to be next boss");
    //RegAdminCmd("sm_hale_special", Command_MakeNextSpecial, ADMFLAG_CHEATS, "Call a special to next round.");
    RegAdminCmd("sm_hale_addpoints", Command_Points, ADMFLAG_CHEATS, "hale_addpoints <target> <points> - Add queue points to user.");
    RegAdminCmd("sm_hale_point_enable", Command_Point_Enable, ADMFLAG_CHEATS, "Enable CP. Only with hale_point_type = 0");
    RegAdminCmd("sm_hale_point_disable", Command_Point_Disable, ADMFLAG_CHEATS, "Disable CP. Only with hale_point_type = 0");
    RegAdminCmd("sm_hale_stop_music", Command_StopMusic, ADMFLAG_CHEATS, "Stop any currently playing Boss music.");
    AutoExecConfig(true, "SaxtonHale");
    PointCookie = RegClientCookie("hale_queuepoints1", "Amount of VSH Queue points player has", CookieAccess_Protected);
    MusicCookie = RegClientCookie("hale_music_setting", "HaleMusic setting", CookieAccess_Public);
    VoiceCookie = RegClientCookie("hale_voice_setting", "HaleVoice setting", CookieAccess_Public);
    ClasshelpinfoCookie = RegClientCookie("hale_classinfo", "HaleClassinfo setting", CookieAccess_Public);
    jumpHUD = CreateHudSynchronizer();
    rageHUD = CreateHudSynchronizer();
    healthHUD = CreateHudSynchronizer();
    infoHUD = CreateHudSynchronizer();
    LoadTranslations("saxtonhale.phrases");
#if defined EASTER_BUNNY_ON
    LoadTranslations("saxtonhale_bunny.phrases");
#endif
    LoadTranslations("common.phrases");
    for (int client = 1; client <= MaxClients; client++)
    {
        VSHFlags[client] = 0;
        Damage[client] = 0;
        AirDamage[client] = 0;
        uberTarget[client] = -1;
        if (IsClientInGame(client)) // IsValidClient(client, false)
        {
            SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
            SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
#if defined _tf2attributes_included
            if (IsPlayerAlive(client))
                TF2Attrib_RemoveByName(client, "damage force reduction");
#endif
        }
    }
    AddNormalSoundHook(HookSound);
#if defined _steamtools_included
    steamtools = LibraryExists("SteamTools");
#endif
    AddMultiTargetFilter("@hale", HaleTargetFilter, "the current Boss", false);
    AddMultiTargetFilter("@!hale", HaleTargetFilter, "all non-Boss players", false);
}

public bool HaleTargetFilter(const char[] pattern, Handle clients)
{
    ArrayList clientsArray = view_as<ArrayList>(clients);
    bool non = StrContains(pattern, "!", false) != -1;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && clientsArray.FindValue(client) == -1)
        {
            if (g_bEnabled && client == Hale && !non)
                clientsArray.Push(client);
            else if (non)
                clientsArray.Push(client);
        }
    }
    clients = view_as<Handle>(clientsArray);
    return true;
}

public void OnLibraryAdded(const char[] name)
{
#if defined _steamtools_included
    if (strcmp(name, "SteamTools", false) == 0)
        steamtools = true;
#endif
//  if (strcmp(name, "hale_achievements", false) == 0)
//      ACH_Enabled = true;
}

public void OnLibraryRemoved(const char[] name)
{
#if defined _steamtools_included
    if (strcmp(name, "SteamTools", false) == 0)
        steamtools = false;
#endif
//  if (strcmp(name, "hale_achievements", false) == 0)
//      ACH_Enabled = false;
}

public void OnConfigsExecuted()
{
    char oldversion[64];
    cvarVersion.GetString(oldversion, sizeof(oldversion));
    if (strcmp(oldversion, haleversiontitles[maxversion], false) != 0)
        LogError("[VS Saxton Hale] Warning: your config may be outdated. Back up your tf/cfg/sourcemod/SaxtonHale.cfg file and delete it, and this plugin will generate a new one that you can then modify to your original values.");
    cvarVersion.SetString(haleversiontitles[maxversion]);
    HaleSpeed = cvarHaleSpeed.FloatValue;
    RageDMG = cvarRageDMG.IntValue;
    RageDist = cvarRageDist.FloatValue;
    Announce = cvarAnnounce.FloatValue;
    bSpecials = cvarSpecials.BoolValue;
    PointType = cvarPointType.IntValue;
    PointDelay = cvarPointDelay.IntValue;
    if (PointDelay < 0) PointDelay *= -1;
    AliveToEnable = cvarAliveToEnable.IntValue;
    haleCrits = cvarCrits.BoolValue;
    bDemoShieldCrits = cvarDemoShieldCrits.BoolValue;
    bAlwaysShowHealth = cvarDisplayHaleHP.BoolValue;
    newRageSentry = cvarRageSentry.BoolValue;
    //circuitStun = GetConVarFloat(cvarCircuitStun);
    if (IsSaxtonHaleMap() && cvarEnabled.BoolValue)
    {
        tf_arena_use_queue = FindConVar("tf_arena_use_queue").IntValue;
        mp_teams_unbalance_limit = FindConVar("mp_teams_unbalance_limit").IntValue;
        tf_arena_first_blood = FindConVar("tf_arena_first_blood").IntValue;
        mp_forcecamera = FindConVar("mp_forcecamera").IntValue;
        tf_scout_hype_pep_max = FindConVar("tf_scout_hype_pep_max").FloatValue;
        FindConVar("tf_arena_use_queue").IntValue = 0;
        FindConVar("mp_teams_unbalance_limit").IntValue = TF2_GetRoundWinCount() ? 0 : 1; // s_bLateLoad ? 0 :
        //SetConVarInt(FindConVar("mp_teams_unbalance_limit"), GetConVarBool(cvarFirstRound)?0:1);
        FindConVar("tf_arena_first_blood").IntValue = 0;
        FindConVar("mp_forcecamera").IntValue = 0;
        FindConVar("tf_scout_hype_pep_max").FloatValue = 100.0;
        FindConVar("tf_damage_disablespread").IntValue = 1;
#if defined _steamtools_included
        if (steamtools)
        {
            char gameDesc[64];
            Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale (%s)", haleversiontitles[maxversion]);
            Steam_SetGameDescription(gameDesc);
        }
#endif

        g_bEnabled = true;
        g_bAreEnoughPlayersPlaying = true;
        if (Announce > 1.0)
            CreateTimer(Announce, Timer_Announce, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    }
    else
    {
        g_bAreEnoughPlayersPlaying = false;
        g_bEnabled = false;
    }
}

public void OnMapStart()
{
    HPTime = 0.0;
    KSpreeTimer = 0.0;
    TeamRoundCounter = 0;
    MusicTimer = INVALID_HANDLE;
    doorchecktimer = INVALID_HANDLE;
    Hale = -1;
    for (int i = 1; i <= MaxClients; i++)
    {
        VSHFlags[i] = 0;
    }
    if (IsSaxtonHaleMap(true))
    {
        AddToDownload();
        IsDate(.bForceRecalc = true);
        MapHasMusic(true);
        CheckToChangeMapDoors();
        CheckToTeleportToSpawn();
    }
    RoundCount = 0;
}

public void OnMapEnd()
{
    if (g_bAreEnoughPlayersPlaying || g_bEnabled)
    {
        FindConVar("tf_arena_use_queue").IntValue = tf_arena_use_queue;
        FindConVar("mp_teams_unbalance_limit").IntValue = mp_teams_unbalance_limit;
        FindConVar("tf_arena_first_blood").IntValue = tf_arena_first_blood;
        FindConVar("mp_forcecamera").IntValue = mp_forcecamera;
        FindConVar("tf_scout_hype_pep_max").FloatValue = tf_scout_hype_pep_max;
#if defined _steamtools_included
        if (steamtools)
            Steam_SetGameDescription("Team Fortress");
#endif
    }
    ClearTimer(MusicTimer);
}

public void OnPluginEnd()
{
    OnMapEnd();
    if (!g_bReloadVSHOnRoundEnd && VSHRoundState == VSHRState_Active)
    {
        ServerCommand("mp_restartround 5");
        CPrintToChatAll("{olive}[VSH]{default} The plugin has been unexpectedly unloaded!");
    }
}

void AddToDownload()
{
    /*
        Files to precache that are originally part of TF2 or HL2 / etc and don't need to be downloaded
    */
    PrecacheSound("vo/announcer_am_capincite01.wav", true);
    PrecacheSound("vo/announcer_am_capincite03.wav", true);
    PrecacheSound("vo/announcer_am_capenabled02.wav", true);
    //PrecacheSound("weapons/barret_arm_zap.wav", true);
    PrecacheSound("player/doubledonk.wav", true);
    PrecacheParticleSystem("ghost_appearation");
    PrecacheParticleSystem("yikes_fx");
    /*
        Files to download + precache that are not originally part of TF2 or HL2 / etc
    */
    PrepareSound("saxton_hale/9000.wav");
    /*
        All boss related files
    */
    // Saxton Hale
    // Precache
    // None.. he's all custom
    // Download
    PrepareModel(HaleModel);
    PrepareMaterial("materials/models/player/saxton_hale/eye");
    PrepareMaterial("materials/models/player/saxton_hale/hale_head");
    PrepareMaterial("materials/models/player/saxton_hale/hale_body");
    PrepareMaterial("materials/models/player/saxton_hale/hale_misc");
    PrepareMaterial("materials/models/player/saxton_hale/sniper_red");
    PrepareMaterial("materials/models/player/saxton_hale/sniper_lens");
    //Saxton Hale Materials
    AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head.vtf");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head_red.vmt");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_misc_normal.vtf");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_body_normal.vtf");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_l.vmt");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_r.vmt");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_egg.vtf");
    AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_egg.vmt");
    PrepareSound(HaleComicArmsFallSound);
    PrepareSound(HaleKSpree);

    int i;
    char s[PLATFORM_MAX_PATH];
    for (i = 1; i <= 4; i++)
    {
        Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, i);
        PrecacheSound(s, true);
        /*Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, i);
        PrecacheSound(s, true);
        Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHAttack, i);
        PrecacheSound(s, true);*/
    }
    PrepareSound(HaleKillMedic);
    PrepareSound(HaleKillSniper1);
    PrepareSound(HaleKillSniper2);
    PrepareSound(HaleKillSpy1);
    PrepareSound(HaleKillSpy2);
    PrepareSound(HaleKillEngie1);
    PrepareSound(HaleKillEngie2);
    PrepareSound(HaleKillDemo132);
    PrepareSound(HaleKillHeavy132);
    PrepareSound(HaleKillScout132);
    PrepareSound(HaleKillSpy132);
    PrepareSound(HaleKillPyro132);
    PrepareSound(HaleSappinMahSentry132);
    PrepareSound(HaleKillLast132);
    PrepareSound(HaleKillDemo132);
    PrepareSound(HaleKillDemo132);
    PrepareSound(HaleKillDemo132);
    PrepareSound(HaleKillDemo132);
    PrepareSound(HaleKillDemo132);
    for (i = 1; i <= 5; i++)
    {
        if (i <= 2)
        {
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump, i);
            PrepareSound(s);
            /*Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
            PrepareSound(s);*/
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump132, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, i);
            PrepareSound(s);
        }
        if (i <= 3)
        {
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, i);
            PrepareSound(s);
        }
        if (i <= 4)
        {
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, i);
            PrepareSound(s);
        }
        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, i);
        PrepareSound(s);
        //Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
        //PrepareSound(s);
        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, i);
        PrepareSound(s);
        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, i);
        PrepareSound(s);
        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, i);
        PrepareSound(s);
    }
    if (!bSpecials)
        return;
    // Christian Brutal Sniper
    // Precache
    PrecacheSound(CBS0, true);
    PrecacheSound(CBS1, true);
    PrecacheSound(CBS3, true);
    PrecacheSound(CBSJump1, true);
    for (i = 1; i <= 25; i++)
    {
        if (i <= 9)
        {
            Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS2, i);
            PrecacheSound(s, true);
        }
        Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS4, i);
        PrecacheSound(s, true);
    }
    PrecacheSound("vo/sniper_dominationspy04.wav", true);
    // Download
    PrepareModel(CBSModel);
    PrepareSound(CBSTheme);
    // Horseless Headless Horsemann
    // Precache
    PrecacheSound(HHHRage, true);
    PrecacheSound(HHHRage2, true);
    for (i = 1; i <= 4; i++)
    {
        Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, i);
        PrecacheSound(s, true);
        Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHAttack, i);
        PrecacheSound(s, true);
    }
    PrecacheSound("ui/halloween_boss_summoned_fx.wav", true);
    PrecacheSound("ui/halloween_boss_defeated_fx.wav", true);
    PrecacheSound("vo/halloween_boss/knight_pain01.wav", true);
    PrecacheSound("vo/halloween_boss/knight_pain02.wav", true);
    PrecacheSound("vo/halloween_boss/knight_pain03.wav", true);
    PrecacheSound("vo/halloween_boss/knight_death01.wav", true);
    PrecacheSound("vo/halloween_boss/knight_death02.wav", true);
    PrecacheSound("misc/halloween/spell_teleport.wav", true);
    // Download
    PrepareModel(HHHModel);
    PrepareSound(HHHTheme);
    // Vagineer
    // Precache
    PrecacheSound("vo/engineer_no01.wav", true);
    PrecacheSound("vo/engineer_jeers02.wav", true);
    // Download
    PrepareModel(VagineerModel);
    PrepareSound(VagineerLastA);
    PrepareSound(VagineerStart);
    PrepareSound(VagineerRageSound);
    PrepareSound(VagineerKSpree);
    PrepareSound(VagineerKSpree2);
    PrepareSound(VagineerHit);
    for (i = 1; i <= 5; i++)
    {
        if (i <= 2)
        {
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
            PrepareSound(s);
            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
            PrepareSound(s);
        }
        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
        PrepareSound(s);
    }
    PrepareSound(VagineerRoundStart);
#if defined EASTER_BUNNY_ON
    // Easter Bunny
    // Precache
    PrecacheSoundList(BunnyWin, sizeof(BunnyWin));
    PrecacheSoundList(BunnyJump, sizeof(BunnyJump));
    PrecacheSoundList(BunnyRage, sizeof(BunnyRage));
    PrecacheSoundList(BunnyFail, sizeof(BunnyFail));
    PrecacheSoundList(BunnyKill, sizeof(BunnyKill));
    PrecacheSoundList(BunnySpree, sizeof(BunnySpree));
    PrecacheSoundList(BunnyLast, sizeof(BunnyLast));
    PrecacheSoundList(BunnyPain, sizeof(BunnyPain));
    PrecacheSoundList(BunnyStart, sizeof(BunnyStart));
    PrecacheSoundList(BunnyRandomVoice, sizeof(BunnyRandomVoice));
    // Download
    PrepareModel(BunnyModel);
    PrepareModel(EggModel);
    // PrepareModel(ReloadEggModel);
    DownloadMaterialList(BunnyMaterials, sizeof(BunnyMaterials));
    PrepareMaterial("materials/models/props_easteregg/c_easteregg");
    AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg_gold.vmt");
#endif
}

public void HideCvarNotify(ConVar convar, const char[] oldValue, const char[] newValue)
{
    FindConVar("sv_tags").Flags &= ~FCVAR_NOTIFY;
    convar.Flags &= ~FCVAR_NOTIFY;
}

public void CvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == cvarHaleSpeed)
        HaleSpeed = convar.FloatValue;
    else if (convar == cvarPointDelay)
    {
        PointDelay = convar.IntValue;
        if (PointDelay < 0) PointDelay *= -1;
    }
    else if (convar == cvarRageDMG)
        RageDMG = convar.IntValue;
    else if (convar == cvarRageDist)
        RageDist = convar.FloatValue;
    else if (convar == cvarAnnounce)
        Announce = convar.FloatValue;
    else if (convar == cvarSpecials)
        bSpecials = convar.BoolValue;
    else if (convar == cvarPointType)
        PointType = convar.IntValue;
    else if (convar == cvarAliveToEnable)
        AliveToEnable = convar.IntValue;
    else if (convar == cvarCrits)
        haleCrits = convar.BoolValue;
    else if (convar == cvarDemoShieldCrits)
        bDemoShieldCrits = cvarDemoShieldCrits.BoolValue;
    else if (convar == cvarDisplayHaleHP)
        bAlwaysShowHealth = cvarDisplayHaleHP.BoolValue;
    else if (convar == cvarRageSentry)
        newRageSentry = convar.BoolValue;
    //else if (convar == cvarCircuitStun)
    //  circuitStun = GetConVarFloat(convar);
    else if (convar == cvarEnabled)
    {
        if (convar.BoolValue && IsSaxtonHaleMap())
        {
            g_bAreEnoughPlayersPlaying = true;
#if defined _steamtools_included
            if (steamtools)
            {
                char gameDesc[64];
                Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale (%s)", haleversiontitles[maxversion]);
                Steam_SetGameDescription(gameDesc);
            }
#endif
        }
    }
}

public Action Timer_Announce(Handle hTimer)
{
    static int announcecount = -1;
    announcecount++;
    if (Announce > 1.0 && g_bAreEnoughPlayersPlaying)
    {
        switch (announcecount)
        {
            case 1:
            {
                CPrintToChatAll("{olive}[VSH]{default} VS Saxton Hale group: {olive}http://steamcommunity.com/groups/vssaxtonhale{default}");
            }
            case 3:
            {
                CPrintToChatAll("{default}VSH v%s by {olive}Rainbolt Dash{default}, {olive}FlaminSarge{default}, & {lightsteelblue}Chdata{default}.", haleversiontitles[maxversion]);
            }
            case 5:
            {
                announcecount = 0;
                CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_last_update", haleversiontitles[maxversion], haleversiondates[maxversion]);
            }
            default:
            {
//              if (ACH_Enabled)
//                  CPrintToChatAll("{olive}[VSH]{default} %t\n%t (experimental)", "vsh_open_menu", "vsh_open_ach");
//              else
                    CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_open_menu");
            }
        }
    }
    return Plugin_Continue;
}

/*public Action:OnGetGameDescription(String:gameDesc[64])
{
    if (g_bAreEnoughPlayersPlaying)
    {
        Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale (%s)", haleversiontitles[maxversion]);
        return Plugin_Changed;
    }
    return Plugin_Continue;
}*/

bool IsSaxtonHaleMap(bool forceRecalc = false)
{
    static bool found = false;
    static bool isVSHMap = false;
    if (forceRecalc)
    {
        isVSHMap = false;
        found = false;
    }
    if (!found)
    {
        char s[PLATFORM_MAX_PATH];
        GetCurrentMap(currentmap, sizeof(currentmap));
        if (FileExists("bNextMapToHale"))
        {
            isVSHMap = true;
            found = true;
            return true;
        }
        BuildPath(Path_SM, s, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_maps.cfg");
        if (!FileExists(s))
        {
            LogError("[VSH] Unable to find %s, disabling plugin.", s);
            isVSHMap = false;
            found = true;
            return false;
        }
        File fileh = OpenFile(s, "r");
        if (fileh == INVALID_HANDLE)
        {
            LogError("[VSH] Error reading maps from %s, disabling plugin.", s);
            isVSHMap = false;
            found = true;
            return false;
        }
        int pingas = 0;
        while (!fileh.EndOfFile() && fileh.ReadLine(s, sizeof(s)) && (pingas < 100))
        {
            pingas++;
            if (pingas == 100)
                LogError("[VS Saxton Hale] Breaking infinite loop when trying to check the map.");
            Format(s, strlen(s)-1, s);
            if (strncmp(s, "//", 2, false) == 0) continue;
            if ((StrContains(currentmap, s, false) != -1) || (StrContains(s, "all", false) == 0))
            {
                delete fileh;
                isVSHMap = true;
                found = true;
                return true;
            }
        }
        delete fileh;
    }
    return isVSHMap;
}

bool MapHasMusic(bool forceRecalc = false)
{
    static bool hasMusic;
    static bool found = false;
    if (forceRecalc)
    {
        found = false;
        hasMusic = false;
    }
    if (!found)
    {
        int i = -1;
        char name[64];
        while ((i = FindEntityByClassname2(i, "info_target")) != -1)
        {
            GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
            if (strcmp(name, "hale_no_music", false) == 0) hasMusic = true;
        }
        found = true;
    }
    return hasMusic;
}

bool CheckToChangeMapDoors()
{
    char s[PLATFORM_MAX_PATH];
    GetCurrentMap(currentmap, sizeof(currentmap));
    checkdoors = false;
    BuildPath(Path_SM, s, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_doors.cfg");
    if (!FileExists(s))
    {
        if (strncmp(currentmap, "vsh_lolcano_pb1", 15, false) == 0)
            checkdoors = true;
        return false;
    }
    File fileh = OpenFile(s, "r");
    if (fileh == INVALID_HANDLE)
    {
        if (strncmp(currentmap, "vsh_lolcano_pb1", 15, false) == 0)
            checkdoors = true;
        return false;
    }
    while (!fileh.EndOfFile() && fileh.ReadLine(s, sizeof(s)))
    {
        Format(s, strlen(s)-1, s);
        if (strncmp(s, "//", 2, false) == 0) continue;
        if (StrContains(currentmap, s, false) != -1 || StrContains(s, "all", false) == 0)
        {
            delete fileh;
            checkdoors = true;
            return true;
        }
    }
    delete fileh;
    return false;
}

void CheckToTeleportToSpawn()
{
    char s[PLATFORM_MAX_PATH];
    GetCurrentMap(currentmap, sizeof(currentmap));
    bSpawnTeleOnTriggerHurt = false;
    BuildPath(Path_SM, s, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_spawn_teleport.cfg");
    if (!FileExists(s))
        return;
    File fileh = OpenFile(s, "r");
    if (fileh == INVALID_HANDLE)
        return;
    while (!fileh.EndOfFile() && fileh.ReadLine(s, sizeof(s)))
    {
        Format(s, strlen(s) - 1, s);
        if (strncmp(s, "//", 2, false) == 0)
            continue;
        if (StrContains(currentmap, s, false) != -1 || StrContains(s, "all", false) == 0)
        {
            bSpawnTeleOnTriggerHurt = true;
            delete fileh;
            return;
        }
    }
    delete fileh;
}

bool CheckNextSpecial()
{
    if (!bSpecials)
    {
        Special = VSHSpecial_Hale;
        return true;
    }
    if (Incoming != VSHSpecial_None)
    {
        Special = Incoming;
        Incoming = VSHSpecial_None;
        return true;
    }
    while (Incoming == VSHSpecial_None || (Special && Special == Incoming))
    {
        if (Special != VSHSpecial_Hale && !GetRandomInt(0, 5)) 
            Incoming = VSHSpecial_Hale;
        else
        {
            int randomBoss = GetRandomInt(0, 8);
            switch (randomBoss)
            {
                case 1: Incoming = VSHSpecial_Vagineer;
                case 2: Incoming = VSHSpecial_HHH;
                case 3: Incoming = VSHSpecial_CBS;
#if defined EASTER_BUNNY_ON
                case 4: Incoming = VSHSpecial_Bunny;
#endif
                default: Incoming = VSHSpecial_Hale;
            }
//            if (IsDate(Month_Oct, 15) && !GetRandomInt(0, 7)) Incoming = VSHSpecial_HHH; //IsHalloweenHoliday()
            if (IsDate(Month_Dec, 15) && !GetRandomInt(0, 7)) Incoming = VSHSpecial_CBS; //IsDecemberHoliday()
#if defined EASTER_BUNNY_ON
            if (IsDate(Month_Mar, 25, Month_Apr, 20) && !GetRandomInt(0, 7)) Incoming = VSHSpecial_Bunny; //IsEasterHoliday()
#endif
        }
    }
    Special = Incoming;
    Incoming = VSHSpecial_None;
    return true;        //OH GOD WHAT AM I DOING THIS ALWAYS RETURNS TRUE (still better than using QueuePanelH as a dummy)
}

public Action event_round_start(Event event, const char[] name, bool dontBroadcast)
{
    teamplay_round_start_TeleportToMultiMapSpawn(); // Cache spawns
    if (!cvarEnabled.BoolValue)
    {
#if defined _steamtools_included
        if (g_bAreEnoughPlayersPlaying && steamtools)
            Steam_SetGameDescription("Team Fortress");
#endif
        g_bAreEnoughPlayersPlaying = false;
    }
    g_bEnabled = g_bAreEnoughPlayersPlaying;
    if (CheckNextSpecial() && !g_bEnabled) //QueuePanelH(Handle:0, MenuAction:0, 9001, 0) is HaleEnabled
        return Plugin_Continue;
    if (FileExists("bNextMapToHale"))
        DeleteFile("bNextMapToHale");
    ClearTimer(MusicTimer);
    KSpreeCount = 0;
    CheckArena();
    GetCurrentMap(currentmap, sizeof(currentmap));
    bool bBluHale;
    int convarsetting = cvarForceHaleTeam.IntValue;
    switch (convarsetting)
    {
        case 3: bBluHale = true;
        case 2: bBluHale = false;
        case 1: bBluHale = GetRandomInt(0, 1) == 1;
        default:
        {
            if (strncmp(currentmap, "vsh_", 4, false) == 0)
                bBluHale = true;
            else if (TeamRoundCounter >= 3 && GetRandomInt(0, 1))
            {
                bBluHale = (HaleTeam != TFTeam_Blue);
                TeamRoundCounter = 0;
            }
            else
                bBluHale = (HaleTeam == TFTeam_Blue);
        }
    }
    if (bBluHale)
    {
        int score1 = GetTeamScore(view_as<int>(OtherTeam)), score2 = GetTeamScore(view_as<int>(HaleTeam));
        SetTeamScore(view_as<int>(TFTeam_Red), score1);
        SetTeamScore(view_as<int>(TFTeam_Blue), score2);
        OtherTeam = TFTeam_Red;
        HaleTeam = TFTeam_Blue;
        bBluHale = false;
    }
    else
    {
        int score1 = GetTeamScore(view_as<int>(OtherTeam)), score2 = GetTeamScore(view_as<int>(HaleTeam));
        SetTeamScore(view_as<int>(TFTeam_Red), score2);
        SetTeamScore(view_as<int>(TFTeam_Blue), score1);
        HaleTeam = TFTeam_Red;
        OtherTeam = TFTeam_Blue;
        bBluHale = true;
    }
    playing = 0;
    for (int ionplay = 1; ionplay <= MaxClients; ionplay++)
    {
        Damage[ionplay] = 0;
        AirDamage[ionplay] = 0;
        uberTarget[ionplay] = -1;
        if (IsClientInGame(ionplay))
        {
#if defined _tf2attributes_included
            if (IsPlayerAlive(ionplay))
                TF2Attrib_RemoveByName(ionplay, "damage force reduction");
#endif
            StopHaleMusic(ionplay);
            if (IsClientParticipating(ionplay)) //GetEntityTeamNum(ionplay) > _:TFTeam_Spectator)
                playing++;
            //if (GetEntityTeamNum(ionplay) > _:TFTeam_Spectator) playing++;
        }
    }
    if (GetClientCount() <= 1 || playing < 2)
    {
        CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_needmoreplayers");
        g_bEnabled = false;
        VSHRoundState = VSHRState_Disabled;
        SetControlPoint(true);
        return Plugin_Continue;
    }
    else if (RoundCount >= 0 && cvarFirstRound.BoolValue) // This line was breaking the first round sometimes
        g_bEnabled = true;
    else if (RoundCount <= 0 && !cvarFirstRound.BoolValue)
    {
        CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_first_round");
        g_bEnabled = false;
        VSHRoundState = VSHRState_Disabled;
        SetArenaCapEnableTime(60.0);
        SearchForItemPacks();
        FindConVar("mp_teams_unbalance_limit").IntValue = 1;
        CreateTimer(71.0, Timer_EnableCap, _, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Continue;
    }
    FindConVar("mp_teams_unbalance_limit").IntValue =  TF2_GetRoundWinCount() ? 0 : 1; // s_bLateLoad ? 0 :
    if (FixUnbalancedTeams())
        return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (!IsPlayerAlive(i)) continue;
        if (!(VSHFlags[i] & VSHFLAG_HASONGIVED)) TF2_RespawnPlayer(i);
    }
    bool see[TF_MAX_PLAYERS];
    int tHale = FindNextHale(see);
    if (tHale == -1)
    {
        CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_needmoreplayers");
        g_bEnabled = false;
        VSHRoundState = VSHRState_Disabled;
        SetControlPoint(true);
        return Plugin_Continue;
    }
    if (NextHale > 0)
    {
        Hale = NextHale;
        NextHale = -1;
    }
    else
        Hale = tHale;
    bTenSecStart[0] = true;
    bTenSecStart[1] = true;
    CreateTimer(29.1, tTenSecStart, 0);
    CreateTimer(60.0, tTenSecStart, 1);
    CreateTimer(9.1, StartHaleTimer, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(3.5, StartResponceTimer, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(9.6, MessageTimer, true, TIMER_FLAG_NO_MAPCHANGE);
    bNoTaunt = false;
    HaleRage = 0;
    g_flStabbed = 0.0;
    g_flMarketed = 0.0;
    HHHClimbCount = 0;
    PointReady = false;
    int ent = -1;
    while ((ent = FindEntityByClassname2(ent, "func_regenerate")) != -1)
        AcceptEntityInput(ent, "Disable");
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "func_respawnroomvisualizer")) != -1)
        AcceptEntityInput(ent, "Disable");
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "obj_dispenser")) != -1)
    {
        SetVariantInt(view_as<int>(OtherTeam));
        AcceptEntityInput(ent, "SetTeam");
        AcceptEntityInput(ent, "skin");
        int skin = view_as<int>(OtherTeam);
        SetEntProp(ent, Prop_Send, "m_nSkin", skin-2);
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "mapobj_cart_dispenser")) != -1)
    {
        SetVariantInt(view_as<int>(OtherTeam));
        AcceptEntityInput(ent, "SetTeam");
        AcceptEntityInput(ent, "skin");
    }
    SearchForItemPacks();
    CreateTimer(0.3, MakeHale);
    healthcheckused = 0;
    VSHRoundState = VSHRState_Waiting;
    return Plugin_Continue;
}

bool FixUnbalancedTeams()
{
    if (GetTeamClientCount(view_as<int>(HaleTeam)) <= 0 || GetTeamClientCount(view_as<int>(OtherTeam)) <= 0)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i))
                ChangeTeam(i, i==Hale?HaleTeam:OtherTeam);
        }
        return true;
    }
    return false;
}

void SearchForItemPacks()
{
    bool foundAmmo = false, foundHealth = false;
    int ent = -1;
    float pos[3];
    while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        if (g_bEnabled)
        {
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            AcceptEntityInput(ent, "Kill");
            int ent2 = CreateEntityByName("item_ammopack_small");
            TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent2);
            SetEntProp(ent2, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
            foundAmmo = true;
        }
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        if (g_bEnabled)
        {
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            AcceptEntityInput(ent, "Kill");
            int ent2 = CreateEntityByName("item_ammopack_small");
            TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent2);
            SetEntProp(ent2, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        }
        foundAmmo = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "Item_ammopack_small")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        foundAmmo = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        foundHealth = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        foundHealth = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
        foundHealth = true;
    }
    if (!foundAmmo)
        SpawnRandomAmmo();
    if (!foundHealth)
        SpawnRandomHealth();
}

void SpawnRandomAmmo()
{
    int iEnt = MaxClients + 1;
    float vPos[3], vAng[3];
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (GetRandomInt(0, 4))
            continue;
        // Technically you'll never find a map without a spawn point.
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
        int iEnt2 = !GetRandomInt(0, 3) ? CreateEntityByName("item_ammopack_medium") : CreateEntityByName("item_ammopack_small");
        TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
        DispatchSpawn(iEnt2);
        SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
    }
}

void SpawnRandomHealth()
{
    int iEnt = MaxClients + 1;
    float vPos[3], vAng[3];
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (GetRandomInt(0, 4))
            continue;
        // Technically you'll never find a map without a spawn point.
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
        int iEnt2 = !GetRandomInt(0, 3) ? CreateEntityByName("item_healthkit_medium") : CreateEntityByName("item_healthkit_small");
        TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
        DispatchSpawn(iEnt2);
        SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", g_bEnabled?view_as<int>(OtherTeam):0, 4);
    }
}

public Action Timer_EnableCap(Handle timer)
{
    if (VSHRoundState == VSHRState_Disabled)
    {
        SetControlPoint(true);
        if (checkdoors)
        {
            int ent = -1;
            while ((ent = FindEntityByClassname2(ent, "func_door")) != -1)
            {
                AcceptEntityInput(ent, "Open");
                AcceptEntityInput(ent, "Unlock");
            }
            if (doorchecktimer == INVALID_HANDLE)
                doorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
        }
    }
}

public Action Timer_CheckDoors(Handle hTimer)
{
    if (!checkdoors)
    {
        doorchecktimer = INVALID_HANDLE;
        return Plugin_Stop;
    }

    if ((!g_bEnabled && VSHRoundState != VSHRState_Disabled) || (g_bEnabled && VSHRoundState != VSHRState_Active)) return Plugin_Continue;
    int ent = -1;
    while ((ent = FindEntityByClassname2(ent, "func_door")) != -1)
    {
        AcceptEntityInput(ent, "Open");
        AcceptEntityInput(ent, "Unlock");
    }
    return Plugin_Continue;
}

public void CheckArena()
{
    if (PointType)
        SetArenaCapEnableTime(float(45 + PointDelay * (playing - 1)));
    else
    {
        SetArenaCapEnableTime(0.0);
        SetControlPoint(false);
    }
}

public int numHaleKills = 0;    //See if the Hale was boosting his buddies or afk

public Action event_round_end(Event event, const char[] name, bool dontBroadcast)
{
    char s[265], s2[265];
    bool see = false;
    GetNextMap(s, 64);
    if (!strncmp(s, "Hale ", 5, false))
    {
        see = true;
        strcopy(s2, sizeof(s2), s[5]);
    }
    else if (!strncmp(s, "(Hale) ", 7, false))
    {
        see = true;
        strcopy(s2, sizeof(s2), s[7]);
    }
    else if (!strncmp(s, "(Hale)", 6, false))
    {
        see = true;
        strcopy(s2, sizeof(s2), s[6]);
    }
    if (see)
    {
        File fileh = OpenFile("bNextMapToHale", "w");
        fileh.WriteString(s2, false);
        delete fileh;
        SetNextMap(s2);
        CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_nextmap", s2);
    }
    RoundCount++;
    if (g_bReloadVSHOnRoundEnd)
    {
        SetClientQueuePoints(Hale, 0);
        ServerCommand("sm plugins reload saxtonhale");
    }
    if (!g_bEnabled)
        return Plugin_Continue;
    VSHRoundState = VSHRState_End;
    TeamRoundCounter++;
    if (event.GetInt("team") == view_as<int>(HaleTeam))
    {
        switch (Special)
        {
            case VSHSpecial_Hale:
            {
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
                EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
            }
            case VSHSpecial_Vagineer:
            {
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
                EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
            }
            case VSHSpecial_Bunny:
            {
                strcopy(s, PLATFORM_MAX_PATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin)-1)]);
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
                EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
            }
        }
    }
    for (int i = 1 ; i <= MaxClients; i++)
    {
        VSHFlags[i] &= ~VSHFLAG_HASONGIVED;
        if (!IsClientInGame(i))
            continue;
        StopHaleMusic(i);
    }
    ClearTimer(MusicTimer);
    if (IsClientInGame(Hale))
    {
        SetEntProp(Hale, Prop_Send, "m_bGlowEnabled", 0);
        GlowTimer = 0.0;
        if (IsPlayerAlive(Hale))
        {
            char translation[32];
            switch (Special)
            {
                case VSHSpecial_Bunny:      strcopy(translation, sizeof(translation), "vsh_bunny_is_alive");
                case VSHSpecial_Vagineer:   strcopy(translation, sizeof(translation), "vsh_vagineer_is_alive");
                case VSHSpecial_HHH:        strcopy(translation, sizeof(translation), "vsh_hhh_is_alive");
                case VSHSpecial_CBS:        strcopy(translation, sizeof(translation), "vsh_cbs_is_alive");
                default:                    strcopy(translation, sizeof(translation), "vsh_hale_is_alive");
            }
            CPrintToChatAll("{olive}[VSH]{default} %t", translation, Hale, HaleHealth, HaleHealthMax);
            SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
            for (int i = 1; i <= MaxClients; i++)
            {
                if (IsClientInGame(i) && !(GetClientButtons(i) & IN_SCORE))
                    ShowHudText(i, -1, "%T", translation, i, Hale, HaleHealth, HaleHealthMax);
            }
        }
        else
            ChangeTeam(Hale, HaleTeam);
        int top[3];
        Damage[0] = 0;
        for (int i = 1; i <= MaxClients; i++)
        {
            if (Damage[i] >= Damage[top[0]])
            {
                top[2]=top[1];
                top[1]=top[0];
                top[0]=i;
            }
            else if (Damage[i] >= Damage[top[1]])
            {
                top[2]=top[1];
                top[1]=i;
            }
            else if (Damage[i] >= Damage[top[2]])
                top[2]=i;
        }
        if (Damage[top[0]] > 9000)
            CreateTimer(1.0, Timer_NineThousand, _, TIMER_FLAG_NO_MAPCHANGE);
        char scores[3][80];
        for (int i = 0; i < sizeof(top); i++)
        {
            if (IsClientInGame(top[i]) && (GetEntityTeamNum(top[i]) >= TFTeam_Spectator))
                GetClientName(top[i], scores[i], 80);
            else
            {
                top[i] = 0;
                strcopy(scores[i], 80, "---");
            }
        }
        SetHudTextParams(-1.0, 0.3, 10.0, 255, 255, 255, 255);
        PriorityCenterTextAll(_, ""); //Should clear center text
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && !(GetClientButtons(i) & IN_SCORE))
            {
                SetGlobalTransTarget(i);
//              if (numHaleKills < 2 && false) ShowHudText(i, -1, "%t\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\n%t %i\n%t %i", "vsh_top_3", Damage[top[0]], s, Damage[top[1]], s1, Damage[top[2]], s2, "vsh_damage_fx", Damage[i], "vsh_scores", RoundFloat(Damage[i] / 600.0));
//              else
                ShowSyncHudText(i, infoHUD, "%t\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\n%t %i\n%t %i", "vsh_top_3",
                    Damage[top[0]], scores[0],
                    Damage[top[1]], scores[1],
                    Damage[top[2]], scores[2],
                    "vsh_damage_fx",Damage[i],
                    "vsh_scores", RoundFloat(Damage[i] / 600.0)
                );
            }
        }
    }
    CreateTimer(3.0, Timer_CalcScores, _, TIMER_FLAG_NO_MAPCHANGE);     //CalcScores();
    return Plugin_Continue;
}

public Action Timer_NineThousand(Handle timer)
{
    EmitSoundToAll("saxton_hale/9000.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
    EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "saxton_hale/9000.wav", _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
    EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "saxton_hale/9000.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
}

public Action Timer_CalcScores(Handle timer)
{
    CalcScores();
    return Plugin_Continue;
}

void CalcScores()
{
    int j, damage;
    //new bool:spec = GetConVarBool(cvarForceSpecToHale);
    botqueuepoints += 5;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            damage = Damage[i];
            Event aevent = CreateEvent("player_escort_score", true);
            aevent.SetInt("player", i);
            for (j = 0; damage - 600 > 0; damage -= 600, j++){}
            aevent.SetInt("points", j);
            aevent.Fire();
            if (i == Hale)
            {
                if (IsFakeClient(Hale))
                    botqueuepoints = 0;
                else
                    SetClientQueuePoints(i, 0);
            }
            else if (!IsFakeClient(i) && (GetEntityTeamNum(i) > TFTeam_Spectator))
            {
                CPrintToChat(i, "{olive}[VSH]{default} %t", "vsh_add_points", 10);
                SetClientQueuePoints(i, GetClientQueuePoints(i)+10);
            }
        }
    }
}

public Action StartResponceTimer(Handle hTimer)
{
    char s[PLATFORM_MAX_PATH];
    float pos[3];
    switch (Special)
    {
        case VSHSpecial_Bunny:
            strcopy(s, PLATFORM_MAX_PATH, BunnyStart[GetRandomInt(0, sizeof(BunnyStart)-1)]);
        case VSHSpecial_Vagineer:
        {
            if (!GetRandomInt(0, 1))
                strcopy(s, PLATFORM_MAX_PATH, VagineerStart);
            else
                strcopy(s, PLATFORM_MAX_PATH, VagineerRoundStart);
        }
        case VSHSpecial_HHH:
            Format(s, PLATFORM_MAX_PATH, "ui/halloween_boss_summoned_fx.wav");
        case VSHSpecial_CBS:
            strcopy(s, PLATFORM_MAX_PATH, CBS0);
        default:
        {
            if (!GetRandomInt(0, 1))
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, GetRandomInt(1, 5));
            else
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, GetRandomInt(1, 5));
        }
    }
    EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
    EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
    if (Special == VSHSpecial_CBS)
    {
        EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
        EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
    }
    return Plugin_Continue;
}

public Action tTenSecStart(Handle hTimer, any ofs)
{
    bTenSecStart[ofs] = false;
}

public Action StartHaleTimer(Handle hTimer)
{
    CreateTimer(0.1, GottamTimer);
    if (!IsClientInGame(Hale))
    {
        VSHRoundState = VSHRState_End;
        return Plugin_Continue;
    }
    FixUnbalancedTeams();
    if (!IsPlayerAlive(Hale))
        TF2_RespawnPlayer(Hale);
    playing = 0; // nergal's FRoG fix
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || !IsPlayerAlive(client) || client == Hale)
            continue;
        playing++;
        CreateTimer(0.2, MakeNoHale, GetClientUserId(client));
    }
    //if (playing < 5)
    //  playing += 2;
    // Chdata's slightly reworked Hale HP calculation (in light of removing the above two lines)
    HaleHealthMax = RoundFloat(Pow(((760.8+playing)*(playing-1)), 1.0341)) + 2046;
    //HaleHealthMax = RoundFloat(Pow(((760.0+playing)*(playing-1)), 1.04));
    if (HaleHealthMax < 2046)
        HaleHealthMax = 2046;
    SetEntProp(Hale, Prop_Data, "m_iMaxHealth", HaleHealthMax);
    SetEntityHealth(Hale, HaleHealthMax);
    HaleHealth = HaleHealthMax;
    HaleHealthLast = HaleHealth;
    CreateTimer(0.2, CheckAlivePlayers);
    CreateTimer(0.2, HaleTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.2, StartRound);
    CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    if (!PointType && playing > cvarAliveToEnable.IntValue)
        SetControlPoint(false);
    if (VSHRoundState == VSHRState_Waiting)
        CreateTimer(2.0, Timer_MusicPlay, _, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public Action Timer_MusicPlay(Handle timer)
{
    if (VSHRoundState != VSHRState_Active)
        return Plugin_Stop;
    char sound[PLATFORM_MAX_PATH] = "";
    float time = -1.0;
    ClearTimer(MusicTimer);
    if (MapHasMusic())
    {
        strcopy(sound, sizeof(sound), "");
        time = -1.0;
    }
    else
    {
        switch (Special)
        {
//          case VSHSpecial_Hale:
//          {
//              strcopy(sound, sizeof(sound), HaleTempTheme);
//              time = 162.0;
//          }
            case VSHSpecial_CBS:
            {
                strcopy(sound, sizeof(sound), CBSTheme);
                time = 137.0;
            }
            case VSHSpecial_HHH:
            {
                strcopy(sound, sizeof(sound), HHHTheme);
                time = 87.0;
            }
        }
    }
    Action act = Plugin_Continue;
    Call_StartForward(OnMusic);
    char sound2[PLATFORM_MAX_PATH];
    float time2 = time;
    strcopy(sound2, PLATFORM_MAX_PATH, sound);
    Call_PushStringEx(sound2, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
    Call_PushFloatRef(time2);
    Call_Finish(act);
    switch (act)
    {
        case Plugin_Stop, Plugin_Handled:
        {
            strcopy(sound, sizeof(sound), "");
            time = -1.0;
        }
        case Plugin_Changed:
        {
            strcopy(sound, PLATFORM_MAX_PATH, sound2);
            time = time2;
        }
    }
    if (sound[0] != '\0')
    {
//      Format(sound, sizeof(sound), "#%s", sound);
        EmitSoundToAllExcept(SOUNDEXCEPT_MUSIC, sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
    }
    if (time != -1.0)
    {
        Handle pack;
        MusicTimer = CreateDataTimer(time, Timer_MusicTheme, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
        WritePackString(pack, sound);
        WritePackFloat(pack, time);
    }
    return Plugin_Continue;
}

public Action Timer_MusicTheme(Handle timer, Handle pack)
{
    char sound[PLATFORM_MAX_PATH];
    ResetPack(pack);
    ReadPackString(pack, sound, sizeof(sound));
    float time = ReadPackFloat(pack);
    if (g_bEnabled && VSHRoundState == VSHRState_Active)
    {
/*      new String:sound[PLATFORM_MAX_PATH] = "";
        switch (Special)
        {
            case VSHSpecial_CBS:
                strcopy(sound, sizeof(sound), CBSTheme);
            case VSHSpecial_HHH:
                strcopy(sound, sizeof(sound), HHHTheme);
        }*/
        Action act = Plugin_Continue;
        Call_StartForward(OnMusic);
        char sound2[PLATFORM_MAX_PATH];
        float time2 = time;
        strcopy(sound2, PLATFORM_MAX_PATH, sound);
        Call_PushStringEx(sound2, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
        Call_PushFloatRef(time2);
        Call_Finish(act);
        switch (act)
        {
            case Plugin_Stop, Plugin_Handled:
            {
                strcopy(sound, sizeof(sound), "");
                time = -1.0;
                MusicTimer = INVALID_HANDLE;
                return Plugin_Stop;
            }
            case Plugin_Changed:
            {
                strcopy(sound, PLATFORM_MAX_PATH, sound2);
                if (time2 != time)
                {
                    time = time2;
                    ClearTimer(MusicTimer);
                    if (time != -1.0)
                    {
                        Handle datapack;
                        MusicTimer = CreateDataTimer(time, Timer_MusicTheme, datapack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
                        WritePackString(datapack, sound);
                        WritePackFloat(datapack, time);
                    }
                }
            }
        }
        if (sound[0] != '\0')
        {
//          Format(sound, sizeof(sound), "#%s", sound);
            EmitSoundToAllExcept(SOUNDEXCEPT_MUSIC, sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
        }
    }
    else
    {
        MusicTimer = INVALID_HANDLE;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

void EmitSoundToAllExcept(int exceptiontype = SOUNDEXCEPT_MUSIC, const char[] sample,
                 int entity = SOUND_FROM_PLAYER,
                 int channel = SNDCHAN_AUTO,
                 int level = SNDLEVEL_NORMAL,
                 int flags = SND_NOFLAGS,
                 float volume = SNDVOL_NORMAL,
                 int pitch = SNDPITCH_NORMAL,
                 int speakerentity = -1,
                 const float origin[3] = NULL_VECTOR,
                 const float dir[3] = NULL_VECTOR,
                 bool updatePos = true,
                 float soundtime = 0.0)
{
    int[] clients = new int[MaxClients];
    int total = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && CheckSoundException(i, exceptiontype))
            clients[total++] = i;
    }
    if (!total)
        return;
    EmitSound(clients, total, sample, entity, channel,
        level, flags, volume, pitch, speakerentity,
        origin, dir, updatePos, soundtime);
}

bool CheckSoundException(int client, int excepttype)
{
    if (!IsValidClient(client))
        return false;
    if (IsFakeClient(client))
        return true;
    if (!AreClientCookiesCached(client))
        return true;
    char strCookie[32];
    if (excepttype == SOUNDEXCEPT_VOICE)
        GetClientCookie(client, VoiceCookie, strCookie, sizeof(strCookie));
    else
        GetClientCookie(client, MusicCookie, strCookie, sizeof(strCookie));
    if (strCookie[0] == 0)
        return true;
    else
        return view_as<bool>(StringToInt(strCookie));
}

void SetClientSoundOptions(int client, int excepttype, bool on)
{
    if (!IsValidClient(client))
        return;
    if (IsFakeClient(client))
        return;
    if (!AreClientCookiesCached(client))
        return;
    char strCookie[32];
    if (on)
        strCookie = "1";
    else
        strCookie = "0";
    if (excepttype == SOUNDEXCEPT_VOICE)
        SetClientCookie(client, VoiceCookie, strCookie);
    else
        SetClientCookie(client, MusicCookie, strCookie);
}

public Action GottamTimer(Handle hTimer)
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && IsPlayerAlive(i))
            SetEntityMoveType(i, MOVETYPE_WALK);
}

public Action StartRound(Handle hTimer)
{
    VSHRoundState = VSHRState_Active;
    if (IsValidClient(Hale))
    {
        if (!IsPlayerAlive(Hale) && GetEntityTeamNum(Hale) != TFTeam_Spectator && GetEntityTeamNum(Hale) != TFTeam_Unassigned)
            TF2_RespawnPlayer(Hale);
        ChangeTeam(Hale, HaleTeam);
        if (GetEntityTeamNum(Hale) == HaleTeam)
        {
            bool pri = IsValidEntity(GetPlayerWeaponSlot(Hale, TFWeaponSlot_Primary)), sec = IsValidEntity(GetPlayerWeaponSlot(Hale, TFWeaponSlot_Secondary)), mel = IsValidEntity(GetPlayerWeaponSlot(Hale, TFWeaponSlot_Melee));
            TF2_RemovePlayerDisguise(Hale);
            if (pri || sec || !mel)
                CreateTimer(0.05, Timer_ReEquipSaxton, _, TIMER_FLAG_NO_MAPCHANGE);
            //EquipSaxton(Hale);
        }
    }
    CreateTimer(10.0, Timer_SkipHalePanel);
    return Plugin_Continue;
}

public Action Timer_ReEquipSaxton(Handle timer)
{
    if (IsValidClient(Hale))
        EquipSaxton(Hale);
}

public Action Timer_SkipHalePanel(Handle hTimer)
{
    bool added[TF_MAX_PLAYERS];
    int i, j, client = Hale;
    do
    {
        client = FindNextHale(added);
        if (client >= 0)
            added[client] = true;
        if (IsValidClient(client) && client != Hale)
        {
            if (!IsFakeClient(client))
            {
                CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_to0_near");
                if (i == 0)
                    SkipHalePanelNotify(client);
            }
            i++;
        }
        j++;
    }
    while (i < 3 && j < TF_MAX_PLAYERS);
}

void SkipHalePanelNotify(int client) // , bool:newchoice = true
{
    if (!g_bEnabled || !IsValidClient(client) || IsVoteInProgress())
        return;
    Action result = Plugin_Continue;
    Call_StartForward(OnHaleNext);
    Call_PushCell(client);
    Call_Finish(result);
    switch(result)
    {
        case Plugin_Stop, Plugin_Handled:
            return;
    }
    Panel panel = new Panel();
    char s[256];
    panel.SetTitle("[VSH] You're Hale next!");
    Format(s, sizeof(s), "%t\nAlternatively, use !resetq.", "vsh_to0_near");
    CRemoveTags(s, sizeof(s));
    ReplaceString(s, sizeof(s), "{olive}", "");
    ReplaceString(s, sizeof(s), "{default}", "");
    panel.DrawItem(s);
    panel.Send(client, SkipHalePanelH, 30);
    delete panel;
    return;
}

public int SkipHalePanelH(Menu menu, MenuAction action, int param1, int param2)
{
    return 0;
}

public Action EnableSG(Handle hTimer, any iid)
{
    int i = EntRefToEntIndex(iid);
    if (VSHRoundState == VSHRState_Active && IsValidEdict(i) && i > MaxClients)
    {
        char s[64];
        GetEdictClassname(i, s, 64);
        if (StrEqual(s, "obj_sentrygun"))
        {
            SetEntProp(i, Prop_Send, "m_bDisabled", 0);
            // We destroy this manually now
            /*for (new ent = MaxClients + 1; ent < MAX_ENTITIES; ent++)
            {
                if (IsValidEdict(ent))
                {
                    decl String:s2[64];

                    GetEdictClassname(ent, s2, 64);

                    if (StrEqual(s2, "info_particle_system") && (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == i))
                    {
                        AcceptEntityInput(ent, "Kill");
                    }
                }
            }*/
        }
    }
    return Plugin_Continue;
}

// public Action:RemoveEnt(Handle:timer, any:entid)
// {
//     new ent = EntRefToEntIndex(entid);
//     if (ent > 0 && IsValidEntity(ent))
//         AcceptEntityInput(ent, "Kill");
//     return Plugin_Continue;
// }

public Action MessageTimer(Handle hTimer, any allclients)
{
    if (!IsValidClient(Hale)) // || ((client != 9001) && !IsValidClient(client))
        return Plugin_Continue;
    if (checkdoors)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname2(ent, "func_door")) != -1)
        {
            AcceptEntityInput(ent, "Open");
            AcceptEntityInput(ent, "Unlock");
        }
        if (doorchecktimer == INVALID_HANDLE)
            doorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
    }
    char translation[32];
    switch (Special)
    {
        case VSHSpecial_Bunny: strcopy(translation, sizeof(translation), "vsh_start_bunny");
        case VSHSpecial_Vagineer: strcopy(translation, sizeof(translation), "vsh_start_vagineer");
        case VSHSpecial_HHH: strcopy(translation, sizeof(translation), "vsh_start_hhh");
        case VSHSpecial_CBS: strcopy(translation, sizeof(translation), "vsh_start_cbs");
        default: strcopy(translation, sizeof(translation), "vsh_start_hale");
    }
    SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
    //if (client != 9001 && !(GetClientButtons(client) & IN_SCORE)) //bad
    if (!allclients)    // FlaminSarge: Not a clue what this is for
    {                   // Chdata: "{1} became Saxton Hale with {2} HP!" .. I guess
        ShowSyncHudText(Hale, infoHUD, "%T", translation, Hale, Hale, HaleHealthMax);
        // ShowHudText(client, -1, "%T", translation, client, Hale, HaleHealthMax);
    }
    else
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i)) //&& !(GetClientButtons(i) & IN_SCORE)        //try without the scoreboard button check
                ShowSyncHudText(i, infoHUD, "%T", translation, i, Hale, HaleHealthMax);
        }
    }
    return Plugin_Continue;
}

public Action MakeModelTimer(Handle hTimer)
{
    if (!IsValidClient(Hale) || !IsPlayerAlive(Hale) || VSHRoundState == VSHRState_End)
        return Plugin_Stop;
    int body = 0;
    switch (Special)
    {
        case VSHSpecial_Bunny:
            SetVariantString(BunnyModel);
        case VSHSpecial_Vagineer:
        {
            SetVariantString(VagineerModel);
//          SetEntProp(Hale, Prop_Send, "m_nSkin", GetEntityTeamNum(Hale)-2);
        }
        case VSHSpecial_HHH:
            SetVariantString(HHHModel);
        case VSHSpecial_CBS:
            SetVariantString(CBSModel);
        default:
        {
            SetVariantString(HaleModel);
//          decl String:steamid[32];
//          GetClientAuthString(Hale, steamid, sizeof(steamid));
            if (GetUserFlagBits(Hale) & ADMFLAG_CUSTOM1)
                body = (1 << 0)|(1 << 1);
        }
    }
//  DispatchKeyValue(Hale, "targetname", "hale");
    AcceptEntityInput(Hale, "SetCustomModel");
    SetEntProp(Hale, Prop_Send, "m_bUseClassAnimations", 1);
    SetEntProp(Hale, Prop_Send, "m_nBody", body);
    return Plugin_Continue;
}

void EquipSaxton(int client)
{
    bEnableSuperDuperJump = false;
    int SaxtonWeapon;
    TF2_RemoveAllWeapons(client);
    HaleCharge = 0;
    switch (Special)
    {
        case VSHSpecial_Bunny:
        {
            SaxtonWeapon = SpawnWeapon(client, "tf_weapon_bottle", 1, 100, 5, "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 326 ; 1.3 ; 252 ; 0.6");
            SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
        }
        case VSHSpecial_Vagineer:
        {
            SaxtonWeapon = SpawnWeapon(client, "tf_weapon_wrench", 197, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 436 ; 1.0");
            SetEntProp(SaxtonWeapon, Prop_Send, "m_iWorldModelIndex", -1);
            SetEntProp(SaxtonWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
            SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
        }
        case VSHSpecial_HHH:
        {
            SaxtonWeapon = SpawnWeapon(client, "tf_weapon_sword", 266, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 551 ; 1");
            SetEntProp(SaxtonWeapon, Prop_Send, "m_iWorldModelIndex", -1);
            SetEntProp(SaxtonWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
            SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
            HaleCharge = -1000;
        }
        case VSHSpecial_CBS:
        {
            SaxtonWeapon = SpawnWeapon(client, "tf_weapon_club", 171, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0");
            SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
            SetEntProp(client, Prop_Send, "m_nBody", 0);
            SetEntProp(SaxtonWeapon, Prop_Send, "m_nModelIndexOverrides", GetEntProp(SaxtonWeapon, Prop_Send, "m_iWorldModelIndex"), _, 0);
        }
        default:
        {
            char attribs[64];
            Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %d", GetRandomInt(9999, 99999));
            SaxtonWeapon = SpawnWeapon(client, "tf_weapon_shovel", 5, 100, 4, attribs);
            SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
        }
    }
}

public Action MakeHale(Handle hTimer)
{
    if (!IsValidClient(Hale))
        return Plugin_Continue;
    switch (Special)
    {
        case VSHSpecial_Hale:
            TF2_SetPlayerClass(Hale, TFClass_Soldier, _, false);
        case VSHSpecial_Vagineer:
            TF2_SetPlayerClass(Hale, TFClass_Engineer, _, false);
        case VSHSpecial_HHH, VSHSpecial_Bunny:
            TF2_SetPlayerClass(Hale, TFClass_DemoMan, _, false);
        case VSHSpecial_CBS:
            TF2_SetPlayerClass(Hale, TFClass_Sniper, _, false);
    }
    TF2_RemovePlayerDisguise(Hale);
    ChangeTeam(Hale, HaleTeam);
    if (VSHRoundState < VSHRState_Waiting)
        return Plugin_Continue;
    if (!IsPlayerAlive(Hale))
    {
        if (VSHRoundState == VSHRState_Waiting)
            TF2_RespawnPlayer(Hale);
        else
            return Plugin_Continue;
    }
    int iFlags = GetCommandFlags("r_screenoverlay");
    SetCommandFlags("r_screenoverlay", iFlags & ~FCVAR_CHEAT);
    ClientCommand(Hale, "r_screenoverlay \"\"");
    SetCommandFlags("r_screenoverlay", iFlags);
    CreateTimer(0.2, MakeModelTimer, _);
    CreateTimer(20.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    int ent = -1;
    while ((ent = FindEntityByClassname2(ent, "tf_wearable")) != -1)
    {
        if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == Hale)
        {
            int index = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
            switch (index)
            {
                case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607: {}
                default:    TF2_RemoveWearable(Hale, ent); //AcceptEntityInput(ent, "kill");
            }
        }
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "tf_powerup_bottle")) != -1)
    {
        if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == Hale)
        {
            int index = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
            switch (index)
            {
                case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607: {}
                default:    TF2_RemoveWearable(Hale, ent); //AcceptEntityInput(ent, "kill");
            }
        }
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
    {
        if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == Hale)
        {
            TF2_RemoveWearable(Hale, ent);
            //AcceptEntityInput(ent, "kill");
        }
    }
    EquipSaxton(Hale);
    if (VSHRoundState >= VSHRState_Waiting && GetClientClasshelpinfoCookie(Hale))
        HintPanel(Hale);
    return Plugin_Continue;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
//    if (!g_bEnabled) return Plugin_Continue; // This messes up the first round sometimes
    if (RoundCount <= 0 && !cvarFirstRound.BoolValue) return Plugin_Continue;

//  if (client == Hale) return Plugin_Continue;
//  if (hItem != INVALID_HANDLE) return Plugin_Continue;
    switch (iItemDefinitionIndex)
    {
        case 39, 351, 1081: // Megadetonator
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2", true);

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 40, 1146: // Backburner
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "165 ; 1");
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 648: // Wrap assassin
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 2.0");
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 224: // Letranger
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 225, 574: // YER
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1", true);

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 232, 401: // Bushwacka + Shahanshah
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 356: // Kunai
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "125 ; -60");

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 405, 608: // Demo boots have falling stomp damage
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "259 ; 1 ; 252 ; 0.25");

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 220: // Shortstop (Removed shortstop reload penalty I guess? Makes it act like scattergun...)
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "328 ; 1", true);
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 226: // The Battalion's Backup
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25"); //125 ; -10

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
        case 305, 1079: // Medic Xbow
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.15 ; 2 ; 1.45"); // ; 266 ; 1.0");
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 56, 1005, 1092: // Huntsman
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 1.5 ; 76 ; 2.0");
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 38, 457: // Axtinguisher
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "", true);
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 43, 239, 1100, 1084: // GRU
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "107 ; 1.5 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -7", true);
            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;
                return Plugin_Changed;
            }
        }
        case 415: // Reserve Shooter
        {
            Handle hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1 ; 265 ; 99999.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.5 ; 551 ; 1", true);

            if (hItemOverride != INVALID_HANDLE)
            {
                hItem = hItemOverride;

                return Plugin_Changed;
            }
        }
//      case 526: Soldier rocket launchers / shotguns
    }
    if (TF2_GetPlayerClass(client) == TFClass_Soldier && (strncmp(classname, "tf_weapon_rocketlauncher", 24, false) == 0 || strncmp(classname, "tf_weapon_shotgun", 17, false) == 0))
    {
        Handle hItemOverride;
        if (iItemDefinitionIndex == 127) hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 99999.0 ; 179 ; 1.0");
        else hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 99999.0");
        if (hItemOverride != INVALID_HANDLE)
        {
            hItem = hItemOverride;
            return Plugin_Changed;
        }
    }
    #if defined OVERRIDE_MEDIGUNS_ON
    //Medic mediguns
    if (TF2_GetPlayerClass(client) == TFClass_Medic && (strncmp(classname, "tf_weapon_medigun", 17, false) == 0))
    {
        Handle hItemOverride;
        hItemOverride = PrepareItemHandle(hItem, _, _, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0", true);
        if (hItemOverride != INVALID_HANDLE)
        {
            hItem = hItemOverride;
            return Plugin_Changed;
        }
    }
    #endif
    return Plugin_Continue;
}

Handle PrepareItemHandle(Handle hItem, char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false)
{
    static Handle hWeapon;
    int addattribs = 0;

    char weaponAttribsArray[32][32];
    int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

    int flags = OVERRIDE_ATTRIBUTES;
    if (!dontpreserve) flags |= PRESERVE_ATTRIBUTES;
    if (hWeapon == INVALID_HANDLE) hWeapon = TF2Items_CreateItem(flags);
    else TF2Items_SetFlags(hWeapon, flags);
//  new Handle:hWeapon = TF2Items_CreateItem(flags);    //INVALID_HANDLE;
    if (hItem != INVALID_HANDLE)
    {
        addattribs = TF2Items_GetNumAttributes(hItem);
        if (addattribs > 0)
        {
            for (int i = 0; i < 2 * addattribs; i += 2)
            {
                bool dontAdd = false;
                int attribIndex = TF2Items_GetAttributeId(hItem, i);
                for (int j = 0; j < attribCount+i; j += 2)
                {
                    if (StringToInt(weaponAttribsArray[j]) == attribIndex)
                    {
                        dontAdd = true;
                        break;
                    }
                }
                if (!dontAdd)
                {
                    IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
                    FloatToString(TF2Items_GetAttributeValue(hItem, i), weaponAttribsArray[i+1+attribCount], 32);
                }
            }
            attribCount += 2 * addattribs;
        }
        delete hItem; //probably returns false but whatever
    }

    if (name[0] != '\0')
    {
        flags |= OVERRIDE_CLASSNAME;
        TF2Items_SetClassname(hWeapon, name);
    }
    if (index != -1)
    {
        flags |= OVERRIDE_ITEM_DEF;
        TF2Items_SetItemIndex(hWeapon, index);
    }
    if (attribCount > 1)
    {
        TF2Items_SetNumAttributes(hWeapon, (attribCount/2));
        int i2 = 0;
        for (int i = 0; i < attribCount && i < 32; i += 2)
        {
            TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
            i2++;
        }
    }
    else
    {
        TF2Items_SetNumAttributes(hWeapon, 0);
    }
    TF2Items_SetFlags(hWeapon, flags);
    return hWeapon;
}

public Action MakeNoHale(Handle hTimer, any clientid)
{
    int client = GetClientOfUserId(clientid);
    if (!client || !IsClientInGame(client) || !IsPlayerAlive(client) || VSHRoundState == VSHRState_End || client == Hale)
        return Plugin_Continue;
//  SetVariantString("");
//  AcceptEntityInput(client, "SetCustomModel");
    ChangeTeam(client, OtherTeam);
    //TF2_RegeneratePlayer(client);   // Added fix by Chdata to correct team colors Edit: I guess it's not necessary

//  SetEntityRenderColor(client, 255, 255, 255, 255);
    if (!VSHRoundState && GetClientClasshelpinfoCookie(client) && !(VSHFlags[client] & VSHFLAG_CLASSHELPED))
        HelpPanel2(client);
#if defined _tf2attributes_included
    if (IsValidEntity(FindPlayerBack(client, { 444 }, 1)))    //  Fixes mantreads to have jump height again
        TF2Attrib_SetByDefIndex(client, 58, 1.8);          //  "self dmg push force increased"
    else
        TF2Attrib_RemoveByDefIndex(client, 58);
#endif
    int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary), index = -1;
    if (weapon > MaxClients && IsValidEdict(weapon))
    {
        index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
        switch (index)
        {
            case 41:    // ReplacelistPrimary
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                SpawnWeapon(client, "tf_weapon_minigun", 15, 1, 0, "");
            }
            case 402:
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                SpawnWeapon(client, "tf_weapon_sniperrifle", 14, 1, 0, "");
            }
            case 772, 448: // Block BFB and Soda Popper
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                SpawnWeapon(client, "tf_weapon_scattergun", 13, 1, 0, "");
            }
            case 237:
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 99999.0");
                SetAmmo(client, 0, 20);
            }
            case 17, 204, 36, 412:
            {
                if (GetEntProp(weapon, Prop_Send, "m_iEntityQuality") != 10)
                {
                    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                    SpawnWeapon(client, "tf_weapon_syringegun_medic", 17, 1, 10, "17 ; 0.05 ; 144 ; 1");
                }
            }
        }
    }
    weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
    if (weapon > MaxClients && IsValidEdict(weapon))
    {
        index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
        switch (index)
        {
//          case 226:
//          {
//              TF2_RemoveWeaponSlot(client, 1);
//              weapon = SpawnWeapon(client, "tf_weapon_shotgun_soldier", 10, 1, 0, "");
//          }
            case 528:   // ReplacelistSecondary
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
                SpawnWeapon(client, "tf_weapon_laser_pointer", 140, 1, 0, "");
            }
            case 46, 1145:
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
                SpawnWeapon(client, "tf_weapon_lunchbox_drink", 163, 1, 0, "144 ; 2");
            }
            case 57:
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
                SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
            }
            case 265:
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
                SpawnWeapon(client, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
                SetAmmo(client, 1, 24);
            }
//          case 39, 351:
//          {
//              if (GetEntProp(weapon, Prop_Send, "m_iEntityQuality") != 10)
//              {
//                  TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
//                  weapon = SpawnWeapon(client, "tf_weapon_flaregun", 39, 5, 10, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2")
//              }
//          }
        }
    }
    if (IsValidEntity(FindPlayerBack(client, { 57 }, 1)))
    {
        RemovePlayerBack(client, { 57 }, 1);
        SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
    }
    if (IsValidEntity(FindPlayerBack(client, { 642 }, 1)))
        SpawnWeapon(client, "tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 15 ; 0.0 ; 1 ; 0.85");
    weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
    if (weapon > MaxClients && IsValidEdict(weapon))
    {
        index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
        switch (index)
        {
            case 331:
            {
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
                SpawnWeapon(client, "tf_weapon_fists", 195, 1, 6, "");
            }
            case 357:
                CreateTimer(1.0, Timer_NoHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
            case 589:
            {
                if (!cvarEnableEurekaEffect.BoolValue)
                {
                    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
                    SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
                }
            }
        }
    }
    weapon = GetPlayerWeaponSlot(client, 4);
    if (weapon > MaxClients && IsValidEdict(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 60)
    {
        TF2_RemoveWeaponSlot(client, 4);
        SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
    }
    if (TF2_GetPlayerClass(client) == TFClass_Medic)
    {
        weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
        #if defined OVERRIDE_MEDIGUNS_ON
        if (GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel") < 0.41)
            SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.41);
        #endif

        #if !defined OVERRIDE_MEDIGUNS_ON
        int mediquality = (weapon > MaxClients && IsValidEdict(weapon) ? GetEntProp(weapon, Prop_Send, "m_iEntityQuality") : -1);
        if (mediquality != 10)
        {
            TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
            weapon = SpawnWeapon(client, "tf_weapon_medigun", 35, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0");  //200 ; 1 for area of effect healing    // ; 178 ; 0.75 ; 128 ; 1.0 Faster switch-to
            if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 142)
            {
                SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
                SetEntityRenderColor(weapon, 255, 255, 255, 75); // What is the point of making gunslinger translucent? When will a medic ever even have a gunslinger equipped???
            }
            SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.41);
        }
        #endif
    }
    return Plugin_Continue;
}

public Action Timer_NoHonorBound(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client) && IsPlayerAlive(client))
    {
        int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
        int index = ((IsValidEntity(weapon) && weapon > MaxClients) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1), active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        char classname[64];
        if (IsValidEdict(active))
            GetEdictClassname(active, classname, sizeof(classname));
        if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
        {
            SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
            if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
                SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
        }
    }
}

public Action event_destroy(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bEnabled)
    {
        int attacker = GetClientOfUserId(event.GetInt("attacker")), customkill = event.GetInt("customkill");
        if (attacker == Hale) /* || (attacker == Companion)*/
        {
            if (Special == VSHSpecial_Hale)
            {
                if (customkill != TF_CUSTOM_BOOTS_STOMP)
                    event.SetString("weapon", "fists");
                if (!GetRandomInt(0, 4))
                {
                    char s[PLATFORM_MAX_PATH];
                    strcopy(s, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
                    EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                    EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action event_changeclass(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled)
        return Plugin_Continue;
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client == Hale)
    {
        switch(Special)
        {
            case VSHSpecial_Hale:
                if (TF2_GetPlayerClass(client) != TFClass_Soldier)
                    TF2_SetPlayerClass(client, TFClass_Soldier, _, false);
            case VSHSpecial_Vagineer:
                if (TF2_GetPlayerClass(client) != TFClass_Engineer)
                    TF2_SetPlayerClass(client, TFClass_Engineer, _, false);
            case VSHSpecial_HHH, VSHSpecial_Bunny:
                if (TF2_GetPlayerClass(client) != TFClass_DemoMan)
                    TF2_SetPlayerClass(client, TFClass_DemoMan, _, false);
            case VSHSpecial_CBS:
                if (TF2_GetPlayerClass(client) != TFClass_Sniper)
                    TF2_SetPlayerClass(client, TFClass_Sniper, _, false);
        }
        TF2_RemovePlayerDisguise(client);
    }
    return Plugin_Continue;
}

public Action event_uberdeployed(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled)
        return Plugin_Continue;
    int client = GetClientOfUserId(event.GetInt("userid"));
    char s[64];
    if (client && IsClientInGame(client) && IsPlayerAlive(client))
    {
        int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
        if (IsValidEntity(medigun))
        {
            GetEdictClassname(medigun, s, sizeof(s));
            if (strcmp(s, "tf_weapon_medigun", false) == 0)
            {
                TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5, client);
                int target = GetHealingTarget(client);
                if (IsValidClient(target) && IsPlayerAlive(target)) // IsValidClient(target, false)
                {
                    TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, client);
                    uberTarget[client] = target;
                }
                else
                    uberTarget[client] = -1;
                SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 1.51);
                CreateTimer(0.4, Timer_Lazor, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
            }
        }
    }
    return Plugin_Continue;
}

public Action Timer_Lazor(Handle hTimer, any medigunid)
{
    int medigun = EntRefToEntIndex(medigunid);
    if (medigun && IsValidEntity(medigun) && VSHRoundState == VSHRState_Active)
    {
        int client = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
        float charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
        if (IsValidClient(client) && IsPlayerAlive(client) && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == medigun) // IsValidClient(client, false)
        {
            int target = GetHealingTarget(client);
            if (charge > 0.05)
            {
                TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5);
                if (IsValidClient(target) && IsPlayerAlive(target)) // IsValidClient(target, false)
                {
                    TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
                    uberTarget[client] = target;
                }
                else
                    uberTarget[client] = -1;
            }
        }
        if (charge <= 0.05)
        {
            CreateTimer(3.0, Timer_Lazor2, EntIndexToEntRef(medigun));
            VSHFlags[client] &= ~VSHFLAG_UBERREADY;
            return Plugin_Stop;
        }
    }
    else
        return Plugin_Stop;
    return Plugin_Continue;
}

public Action Timer_Lazor2(Handle hTimer, any medigunid)
{
    int medigun = EntRefToEntIndex(medigunid);
    if (IsValidEntity(medigun))
        SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")+0.31);
    return Plugin_Continue;
}

public Action Command_GetHPCmd(int client, int args)
{
    if (!client)
        return Plugin_Handled;
    Command_GetHP(client);
    return Plugin_Handled;
}

public Action Command_GetHP(int client)
{
    if (!g_bEnabled || VSHRoundState != VSHRState_Active)
        return Plugin_Continue;
    if (client == Hale)
    {
        switch (Special)
        {
            case VSHSpecial_Bunny:
                PriorityCenterTextAll(_, "%t", "vsh_bunny_show_hp", HaleHealth, HaleHealthMax);
            case VSHSpecial_Vagineer:
                PriorityCenterTextAll(_, "%t", "vsh_vagineer_show_hp", HaleHealth, HaleHealthMax);
            case VSHSpecial_HHH:
                PriorityCenterTextAll(_, "%t", "vsh_hhh_show_hp", HaleHealth, HaleHealthMax);
            case VSHSpecial_CBS:
                PriorityCenterTextAll(_, "%t", "vsh_cbs_show_hp", HaleHealth, HaleHealthMax);
            default:
                PriorityCenterTextAll(_, "%t", "vsh_hale_show_hp", HaleHealth, HaleHealthMax);
        }
        HaleHealthLast = HaleHealth;
        return Plugin_Continue;
    }
    if (GetGameTime() >= HPTime)
    {
        healthcheckused++;
        switch (Special)
        {
            case VSHSpecial_Bunny:
            {
                PriorityCenterTextAll(_, "%t", "vsh_bunny_hp", HaleHealth, HaleHealthMax);
                CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_bunny_hp", HaleHealth, HaleHealthMax);
            }
            case VSHSpecial_Vagineer:
            {
                PriorityCenterTextAll(_, "%t", "vsh_vagineer_hp", HaleHealth, HaleHealthMax);
                CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_vagineer_hp", HaleHealth, HaleHealthMax);
            }
            case VSHSpecial_HHH:
            {
                PriorityCenterTextAll(_, "%t", "vsh_hhh_hp", HaleHealth, HaleHealthMax);
                CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_hhh_hp", HaleHealth, HaleHealthMax);
            }
            case VSHSpecial_CBS:
            {
                PriorityCenterTextAll(_, "%t", "vsh_cbs_hp", HaleHealth, HaleHealthMax);
                CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_cbs_hp", HaleHealth, HaleHealthMax);
            }
            default:
            {
                PriorityCenterTextAll(_, "%t", "vsh_hale_hp", HaleHealth, HaleHealthMax);
                CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_hale_hp", HaleHealth, HaleHealthMax);
            }
        }
        HaleHealthLast = HaleHealth;
        HPTime = GetGameTime() + (healthcheckused < 3 ? 20.0 : 80.0);
    }
    else if (RedAlivePlayers == 1)
        CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_already_see");
    else
        CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_wait_hp", RoundFloat(HPTime-GetGameTime()), HaleHealthLast);
    return Plugin_Continue;
}

public Action Command_MakeNextSpecial(int client, int args)
{
    if (!CheckCommandAccess(client, "sm_hale_special", ADMFLAG_CHEATS, true))
    {
        ReplyToCommand(client, "[SM] You do not have access to this command.");
        return Plugin_Handled;
    }
    char arg[32], name[64];
    if (!bSpecials)
    {
        CReplyToCommand(client, "{olive}[VSH]{default} This server isn't set up to use special bosses! Set the cvar hale_specials 1 in the VSH config to enable on next map!");
        return Plugin_Handled;
    }
    if (args < 1)
    {
        CReplyToCommand(client, "{olive}[VSH]{default} Usage: hale_special <hale, vagineer, hhh, christian>");
        return Plugin_Handled;
    }
    GetCmdArgString(arg, sizeof(arg));
    if (StrContains(arg, "hal", false) != -1)
    {
        Incoming = VSHSpecial_Hale;
        name = "Saxton Hale";
    }
    else if (StrContains(arg, "vag", false) != -1)
    {
        Incoming = VSHSpecial_Vagineer;
        name = "the Vagineer";
    }
    else if (StrContains(arg, "hhh", false) != -1)
    {
        Incoming = VSHSpecial_HHH;
        name = "the Horseless Headless Horsemann Jr.";
    }
    else if (StrContains(arg, "chr", false) != -1 || StrContains(arg, "cbs", false) != -1)
    {
        Incoming = VSHSpecial_CBS;
        name = "the Christian Brutal Sniper";
    }
#if defined EASTER_BUNNY_ON
    else if (StrContains(arg, "bun", false) != -1 || StrContains(arg, "eas", false) != -1)
    {
        Incoming = VSHSpecial_Bunny;
        name = "the Easter Bunny";
    }
#endif
    else
    {
        CReplyToCommand(client, "{olive}[VSH]{default} Usage: hale_special <hale, vagineer, hhh, christian>");
        return Plugin_Handled;
    }
    CReplyToCommand(client, "{olive}[VSH]{default} Set the next Special to %s", name);
    return Plugin_Handled;
}

public Action Command_NextHale(int client, int args)
{
    if (g_bEnabled)
        CreateTimer(0.2, MessageTimer);
    return Plugin_Continue;
}

public Action Command_HaleSelect(int client, int args)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Continue;
    if (args < 1)
    {
        CReplyToCommand(client, "{olive}[VSH]{default} Usage: hale_select <target> [\"hidden\"]");
        return Plugin_Handled;
    }
    char s2[12], targetname[32];
    GetCmdArg(1, targetname, sizeof(targetname));
    GetCmdArg(2, s2, sizeof(s2));
    int target = FindTarget(client, targetname);
    if (IsValidClient(target) && IsClientParticipating(target))
        ForceHale(client, target, StrContains(s2, "hidden", false) >= 0);
    else
        CReplyToCommand(client, "{olive}[VSH]{default} Target is not valid for being selected as the boss.");
    return Plugin_Handled;
}

public Action Command_Points(int client, int args)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Continue;
    if (args != 2)
    {
        CReplyToCommand(client, "{olive}[VSH]{default} Usage: hale_addpoints <target> <points>");
        return Plugin_Handled;
    }
    char s2[MAX_DIGITS], targetname[PLATFORM_MAX_PATH], target_name[MAX_TARGET_LENGTH];
    GetCmdArg(1, targetname, sizeof(targetname));
    GetCmdArg(2, s2, sizeof(s2));
    int points = StringToInt(s2), target_list[TF_MAX_PLAYERS], target_count;
    /**
     * target_name - stores the noun identifying the target(s)
     * target_list - array to store clients
     * target_count - variable to store number of clients
     * tn_is_ml - stores whether the noun must be translated
     */
    bool tn_is_ml;
    if ((target_count = ProcessTargetString(
            targetname,
            client,
            target_list,
            TF_MAX_PLAYERS,
            0,
            target_name,
            sizeof(target_name),
            tn_is_ml)) <= 0)
    {
        /* This function replies to the admin with a failure message */
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }
    for (int i = 0; i < target_count; i++)
    {
        SetClientQueuePoints(target_list[i], GetClientQueuePoints(target_list[i])+points);
        LogAction(client, target_list[i], "\"%L\" added %d VSH queue points to \"%L\"", client, points, target_list[i]);
    }
    CReplyToCommand(client, "{olive}[VSH]{default} Added %d queue points to %s", points, target_name);
    return Plugin_Handled;
}

void StopHaleMusic(int client)
{
    if (!IsValidClient(client))
        return;
//  StopSound(client, SNDCHAN_AUTO, HaleTempTheme);
    StopSound(client, SNDCHAN_AUTO, HHHTheme);
    StopSound(client, SNDCHAN_AUTO, CBSTheme);
}

public Action Command_StopMusic(int client, int args)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
            continue;
        StopHaleMusic(i);
    }
    CReplyToCommand(client, "{olive}[VSH]{default} Stopped boss music.");
    return Plugin_Handled;
}

public Action Command_Point_Disable(int client, int args)
{
    if (g_bEnabled)
        SetControlPoint(false);
    return Plugin_Handled;
}

public Action Command_Point_Enable(int client, int args)
{
    if (g_bEnabled)
        SetControlPoint(true);
    return Plugin_Handled;
}

void SetControlPoint(bool enable)
{
    int CPm=-1; //CP = -1;
    while ((CPm = FindEntityByClassname2(CPm, "team_control_point")) != -1)
    {
        if (CPm > MaxClients && IsValidEdict(CPm))
        {
            AcceptEntityInput(CPm, (enable ? "ShowModel" : "HideModel"));
            SetVariantInt(enable ? 0 : 1);
            AcceptEntityInput(CPm, "SetLocked");
        }
    }
}

stock void ForceHale(int admin, int client, bool hidden, bool forever = false)
{
    if (forever)
        Hale = client;
    else
        NextHale = client;
    if (!hidden)
        CPrintToChatAllEx(client, "{olive}[VSH] {teamcolor}%N {default}%t", client, "vsh_hale_select_text");
}

public void OnClientPostAdminCheck(int client)
{
    VSHFlags[client] = 0;
//  MusicDisabled[client] = false;
//  VoiceDisabled[client] = false;
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
    //bSkipNextHale[client] = false;
    Damage[client] = 0;
    AirDamage[client] = 0;
    uberTarget[client] = -1;
}

public void OnClientDisconnect(int client)
{
    Damage[client] = 0;
    AirDamage[client] = 0;
    uberTarget[client] = -1;
    VSHFlags[client] = 0;
    if (g_bEnabled)
    {
        if (client == Hale)
        {
            if (VSHRoundState >= VSHRState_Active)
            {
                char authid[32];
                GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
                DataPack pack;
                CreateDataTimer(3.0, Timer_SetDisconQueuePoints, view_as<Handle>(pack), TIMER_FLAG_NO_MAPCHANGE);
                pack.WriteString(authid);
                bool see[TF_MAX_PLAYERS];
                see[Hale] = true;
                int tHale = FindNextHale(see);
                if (NextHale > 0)
                    tHale = NextHale;
                if (IsValidClient(tHale))
                    ChangeTeam(tHale, HaleTeam);
            }
            if (VSHRoundState == VSHRState_Active)
                ForceTeamWin(OtherTeam);
            if (VSHRoundState == VSHRState_Waiting)
            {
                bool see[TF_MAX_PLAYERS];
                see[Hale] = true;
                int tHale = FindNextHale(see);
                if (NextHale > 0)
                {
                    tHale = NextHale;
                    NextHale = -1;
                }
                if (IsValidClient(tHale))
                {
                    Hale = tHale;
                    ChangeTeam(Hale, HaleTeam);
                    CreateTimer(0.1, MakeHale);
                    CPrintToChat(Hale, "{olive}[VSH]{default} Surprise! You're on NOW!");
                }
            }
            CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_hale_disconnected");
        }
        else
        {
            if (IsClientInGame(client))
            {
                if (IsPlayerAlive(client))
                    CreateTimer(0.0, CheckAlivePlayers);
                if (client == FindNextHaleEx())
                    CreateTimer(1.0, Timer_SkipHalePanel, _, TIMER_FLAG_NO_MAPCHANGE);
            }
            if (client == NextHale)
                NextHale = -1;
        }
    }
}

public Action Timer_SetDisconQueuePoints(Handle timer, Handle pack)
{
    DataPack dPack = view_as<DataPack>(pack);
    dPack.Reset();
    char authid[32];
    dPack.ReadString(authid, sizeof(authid));
    SetAuthIdQueuePoints(authid, 0);
}

public Action Timer_RegenPlayer(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client))
        TF2_RegeneratePlayer(client);
}

public Action event_player_spawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!client || !IsClientInGame(client))
        return Plugin_Continue; // IsValidClient(client, false)   - You can probably assume the player is valid at this point though.. TODO
    if (!g_bEnabled)
        return Plugin_Continue;
    SetVariantString("");
    AcceptEntityInput(client, "SetCustomModel");
    if (client == Hale && VSHRoundState < VSHRState_End && VSHRoundState != VSHRState_Disabled)
        CreateTimer(0.1, MakeHale);
    if (VSHRoundState != VSHRState_Disabled)
    {
        CreateTimer(0.2, MakeNoHale, GetClientUserId(client));
        if (!(VSHFlags[client] & VSHFLAG_HASONGIVED))
        {
            VSHFlags[client] |= VSHFLAG_HASONGIVED;
            int array[] = { 57, 133, 231, 405, 444, 608, 642 };
            RemovePlayerBack(client, array, sizeof(array));
            RemoveDemoShield(client);
            TF2_RemoveAllWeapons(client);
            TF2_RegeneratePlayer(client);
            CreateTimer(0.1, Timer_RegenPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        }
    }
    if (!(VSHFlags[client] & VSHFLAG_HELPED))
    {
        HelpPanel(client);
        VSHFlags[client] |= VSHFLAG_HELPED;
    }
    VSHFlags[client] &= ~VSHFLAG_UBERREADY;
    VSHFlags[client] &= ~VSHFLAG_CLASSHELPED;
    return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    if (g_bEnabled && client == Hale)
    {
        if (Special == VSHSpecial_HHH)
        {
            if (VSHFlags[client] & VSHFLAG_NEEDSTODUCK)
                buttons |= IN_DUCK;
            if (HaleCharge >= 47 && (buttons & IN_ATTACK))
            {
                buttons &= ~IN_ATTACK;
                return Plugin_Changed;
            }
        }
        if (Special == VSHSpecial_Bunny)
        {
            if (GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
            {
                buttons &= ~IN_ATTACK;
                return Plugin_Changed;
            }
        }
    }
    return Plugin_Continue;
}

public Action ClientTimer(Handle hTimer)
{
    if (VSHRoundState != VSHRState_Active)
        return Plugin_Stop;
    char wepclassname[32];
    int i = -1;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (client != Hale && IsClientInGame(client) && GetEntityTeamNum(client) == OtherTeam)
        {
            SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
            if (!IsPlayerAlive(client))
            {
                int obstarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
                if (obstarget != client && obstarget != Hale && IsValidClient(obstarget))
                {
                    if (!(GetClientButtons(client) & IN_SCORE))
                        ShowSyncHudText(client, rageHUD, "%t", "vsh_damage_others", Damage[client], obstarget, Damage[obstarget]);
                }
                else
                {
                    if (!(GetClientButtons(client) & IN_SCORE))
                        ShowSyncHudText(client, rageHUD, "%t: %d", "vsh_damage_own", Damage[client]);
                }
                continue;
            }
            if (!(GetClientButtons(client) & IN_SCORE))
                ShowSyncHudText(client, rageHUD, "%t: %d", "vsh_damage_own", Damage[client]);
            TFClassType class = TF2_GetPlayerClass(client);
            int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
            if (weapon <= MaxClients || !IsValidEntity(weapon) || !GetEdictClassname(weapon, wepclassname, sizeof(wepclassname)))
                strcopy(wepclassname, sizeof(wepclassname), "");
            bool validwep = (strncmp(wepclassname, "tf_wea", 6, false) == 0);
            int index = (validwep ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
            if (TF2_IsPlayerInCondition(client, TFCond_Cloaked))
            {
                if (GetClientCloakIndex(client) == 59)
                {
                    if (TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
                        TF2_RemoveCondition(client, TFCond_DeadRingered);
                }
                else
                    TF2_AddCondition(client, TFCond_DeadRingered, 0.3);
            }
            bool bHudAdjust = false;
            // Chdata's Deadringer Notifier
            if (TF2_GetPlayerClass(client) == TFClass_Spy)
            {
                if (GetClientCloakIndex(client) == 59)
                {
                    bHudAdjust = true;
                    int drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
                    char s[32];
                    switch (drstatus)
                    {
                        case 1:
                        {
                            SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
                            Format(s, sizeof(s), "Status: Feign Death Ready");
                        }
                        case 2:
                        {
                            SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
                            Format(s, sizeof(s), "Status: Deadringed");
                        }
                        default:
                        {
                            SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
                            Format(s, sizeof(s), "Status: Inactive");
                        }
                    }
                    if (!(GetClientButtons(client) & IN_SCORE))
                        ShowSyncHudText(client, jumpHUD, "%s", s);
                }
            }
            if (class == TFClass_Medic)
            {
                int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
                char mediclassname[64];
                if (IsValidEdict(medigun) && GetEdictClassname(medigun, mediclassname, sizeof(mediclassname)) && strcmp(mediclassname, "tf_weapon_medigun", false) == 0)
                {
                    bHudAdjust = true;
                    SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
                    int charge = RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") * 100);
                    if (!(GetClientButtons(client) & IN_SCORE))
                        ShowSyncHudText(client, jumpHUD, "%T: %i", "vsh_uber-charge", client, charge);
                    if (charge == 100 && !(VSHFlags[client] & VSHFLAG_UBERREADY))
                    {
                        FakeClientCommandEx(client, "voicemenu 1 7");
                        VSHFlags[client] |= VSHFLAG_UBERREADY;
                    }
                }
                if (weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
                {
                    int healtarget = GetHealingTarget(client);
                    if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
                        TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.3);
                }
            }
            if (class == TFClass_Soldier)
            {
                if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary) == 1104)
                {
                    bHudAdjust = true;
                    SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
                    if (!(GetClientButtons(client) & IN_SCORE))
                        ShowSyncHudText(client, jumpHUD, "Air Strike Damage: %i", AirDamage[client]);
                }
            }
            if (bAlwaysShowHealth)
            {
                SetHudTextParams(-1.0, bHudAdjust?0.78:0.83, 0.35, 255, 255, 255, 255);
                if (!(GetClientButtons(client) & IN_SCORE))
                    ShowSyncHudText(client, healthHUD, "%t", "vsh_health", HaleHealth, HaleHealthMax);
            }
//          else if (AirBlastReload[client]>0)
//          {
//              SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
//              ShowHudText(client, -1, "%t", "vsh_airblast", RoundFloat(AirBlastReload[client])+1);
//              AirBlastReload[client]-=0.2;
//          }
            if (RedAlivePlayers == 1 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
            {
                TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.3);
                int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
                if (class == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
                    SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
                TF2_AddCondition(client, TFCond_Buffed, 0.3);
                continue;
            }
            if (RedAlivePlayers == 2 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
                TF2_AddCondition(client, TFCond_Buffed, 0.3);
            TFCond cond = TFCond_HalloweenCritCandy;
            if (TF2_IsPlayerInCondition(client, TFCond_CritCola) && (class == TFClass_Scout || class == TFClass_Heavy))
            {
                TF2_AddCondition(client, cond, 0.3);
                continue;
            }
            bool addmini = false;
            for (i = 1; i <= MaxClients; i++)
            {
                if (IsClientInGame(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client)
                {
                    addmini = true;
                    break;
                }
            }
            bool addthecrit = false;
            if (validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))  //&& index != 4 && index != 194 && index != 225 && index != 356 && index != 461 && index != 574) addthecrit = true; //class != TFClass_Spy
            {
                //slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
                if (strcmp(wepclassname, "tf_weapon_knife", false) != 0 && index != 416)
                    addthecrit = true;
            }
            switch (index)
            {
                case 305, 1079, 1081, 56, 16, 1149, 203, 58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595: //Critlist
                {
                    int flindex = GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary);
                    if (TF2_GetPlayerClass(client) == TFClass_Pyro && flindex == 594) // No crits if using phlog
                        addthecrit = false;
                    else
                        addthecrit = true;
                }
                case 22, 23, 160, 209, 294, 449, 773:
                {
                    addthecrit = true;
                    if (class == TFClass_Scout && cond == TFCond_HalloweenCritCandy)
                        cond = TFCond_Buffed;
                }
                case 656:
                {
                    addthecrit = true;
                    cond = TFCond_Buffed;
                }
            }
            if (index == 16 && addthecrit && IsValidEntity(FindPlayerBack(client, { 642 }, 1)))
                addthecrit = false;
            if (class == TFClass_DemoMan && !IsValidEntity(GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary)))
            {
                addthecrit = true;
                if (!bDemoShieldCrits && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))
                    cond = TFCond_Buffed;
            }
/*          if (Special != VSHSpecial_HHH && index != 56 && index != 1005 && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
            {
                new meleeindex = GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee);
                new melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
                if (melee <= MaxClients || !IsValidEntity(melee) || !GetEdictClassname(melee, wepclassname, sizeof(wepclassname))) strcopy(wepclassname, sizeof(wepclassname), "");
                new meleeindex = ((strncmp(wepclassname, "tf_wea", 6, false) == 0) ? GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") : -1);
                if (meleeindex == 232) addthecrit = false;
            }*/
            if (addthecrit)
            {
                TF2_AddCondition(client, cond, 0.3);
                if (addmini && cond != TFCond_Buffed)
                    TF2_AddCondition(client, TFCond_Buffed, 0.3);
            }
            if (class == TFClass_Spy && validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
            {
                if (!TF2_IsPlayerCritBuffed(client) && !TF2_IsPlayerInCondition(client, TFCond_Buffed) && !TF2_IsPlayerInCondition(client, TFCond_Cloaked) && !TF2_IsPlayerInCondition(client, TFCond_Disguised) && !GetEntProp(client, Prop_Send, "m_bFeignDeathReady"))
                    TF2_AddCondition(client, TFCond_CritCola, 0.3);
            }
            if (class == TFClass_Engineer && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
            {
                int sentry = FindSentry(client);
                if (IsValidEntity(sentry) && GetEntPropEnt(sentry, Prop_Send, "m_hEnemy") == Hale)
                {
                    SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
                    TF2_AddCondition(client, TFCond_Kritzkrieged, 0.3);
                }
                else
                {
                    if (GetEntProp(client, Prop_Send, "m_iRevengeCrits"))
                        SetEntProp(client, Prop_Send, "m_iRevengeCrits", 0);
                    else if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(client, TFCond_Healing))
                        TF2_RemoveCondition(client, TFCond_Kritzkrieged);
                }
            }
        }
    }
    return Plugin_Continue;
}

/*
Runs every frame for clients

*/
public void OnPreThinkPost(int client)
{
    if (IsNearSpencer(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
    {
        float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;
        if (cloak < 0.0)
            cloak = 0.0;
        SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
        /*if (RoundFloat(GetGameTime()) == GetGameTime())
        {
            CPrintToChdata("%N DISPENSE %f", client, GetGameTime());
        }*/
    }
}

public Action HaleTimer(Handle hTimer)
{
    if (VSHRoundState == VSHRState_End)
    {
        if (IsValidClient(Hale) && IsPlayerAlive(Hale))
            TF2_AddCondition(Hale, TFCond_SpeedBuffAlly, 14.0); // IsValidClient(Hale, false)
        return Plugin_Stop;
    }
    if (!IsValidClient(Hale))
        return Plugin_Continue;
    if (TF2_IsPlayerInCondition(Hale, TFCond_Jarated))
        TF2_RemoveCondition(Hale, TFCond_Jarated);
    if (TF2_IsPlayerInCondition(Hale, TFCond_MarkedForDeath))
        TF2_RemoveCondition(Hale, TFCond_MarkedForDeath);
    if (TF2_IsPlayerInCondition(Hale, TFCond_Disguised))
        TF2_RemoveCondition(Hale, TFCond_Disguised);
    if (TF2_IsPlayerInCondition(Hale, view_as<TFCond>(42)) && TF2_IsPlayerInCondition(Hale, TFCond_Dazed))
        TF2_RemoveCondition(Hale, TFCond_Dazed);
    float speed = HaleSpeed + 0.7 * (100 - HaleHealth * 100 / HaleHealthMax);
    SetEntPropFloat(Hale, Prop_Send, "m_flMaxspeed", speed);
    if (HaleHealth <= 0 && IsPlayerAlive(Hale))
        HaleHealth = 1;
    SetEntityHealth(Hale, HaleHealth);
    SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
    SetGlobalTransTarget(Hale);
    if (!(GetClientButtons(Hale) & IN_SCORE))
        ShowSyncHudText(Hale, healthHUD, "%t", "vsh_health", HaleHealth, HaleHealthMax);
    if (HaleRage/RageDMG >= 1)
    {
        if (IsFakeClient(Hale) && !(VSHFlags[Hale] & VSHFLAG_BOTRAGE))
        {
            CreateTimer(1.0, Timer_BotRage, _, TIMER_FLAG_NO_MAPCHANGE);
            VSHFlags[Hale] |= VSHFLAG_BOTRAGE;
        }
        else if (!(GetClientButtons(Hale) & IN_SCORE))
        {
            SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255);
            ShowSyncHudText(Hale, rageHUD, "%t", "vsh_do_rage");
        }
    }
    else if (!(GetClientButtons(Hale) & IN_SCORE))
    {
        SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255);
        ShowSyncHudText(Hale, rageHUD, "%t", "vsh_rage_meter", HaleRage*100/RageDMG);
    }
    SetHudTextParams(-1.0, 0.88, 0.35, 255, 255, 255, 255);
    if (GlowTimer <= 0.0)
    {
        SetEntProp(Hale, Prop_Send, "m_bGlowEnabled", 0);
        GlowTimer = 0.0;
    }
    else
        GlowTimer -= 0.2;
    if (bEnableSuperDuperJump)
    {
        /*if (HaleCharge <= 0)
        {
            HaleCharge = 0;
            if (!(GetClientButtons(Hale) & IN_SCORE)) ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_super_duper_jump");
        }*/
        SetHudTextParams(-1.0, 0.88, 0.35, 255, 64, 64, 255);
    }
    int buttons = GetClientButtons(Hale);
    if (((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (HaleCharge >= 0)) // && !(buttons & IN_JUMP)
    {
        if (Special == VSHSpecial_HHH)
        {
            if (HaleCharge + 5 < HALEHHH_TELEPORTCHARGE)
                HaleCharge += 5;
            else
                HaleCharge = HALEHHH_TELEPORTCHARGE;
            if (!(GetClientButtons(Hale) & IN_SCORE))
            {
                if (bEnableSuperDuperJump)
                    ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_super_duper_jump");
                else
                    ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_teleport_status", HaleCharge * 2);
            }
        }
        else
        {
            if (HaleCharge + 5 < HALE_JUMPCHARGE)
                HaleCharge += 5;
            else
                HaleCharge = HALE_JUMPCHARGE;
            if (!(GetClientButtons(Hale) & IN_SCORE))
            {
                if (bEnableSuperDuperJump)
                    ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_super_duper_jump");
                else
                    ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_jump_status", HaleCharge * 4);
            }
        }
    }
    else if (HaleCharge < 0)
    {
        HaleCharge += 5;
        if (Special == VSHSpecial_HHH)
        {
            if (!(GetClientButtons(Hale) & IN_SCORE))
                ShowSyncHudText(Hale, jumpHUD, "%t %i", "vsh_teleport_status_2", -HaleCharge/20);
        }
        else if (!(GetClientButtons(Hale) & IN_SCORE))
            ShowSyncHudText(Hale, jumpHUD, "%t %i", "vsh_jump_status_2", -HaleCharge/20);
    }
    else
    {
        float ang[3];
        GetClientEyeAngles(Hale, ang);
        if ((ang[0] < -45.0) && (HaleCharge > 1))
        {
            Action act = Plugin_Continue;
            bool super = bEnableSuperDuperJump;
            Call_StartForward(OnHaleJump);
            Call_PushCellRef(super);
            Call_Finish(act);
            if (act != Plugin_Continue)
            {
                if (act == Plugin_Changed)
                    bEnableSuperDuperJump = super;
                else
                    return Plugin_Continue;
            }
            float pos[3];
            if (Special == VSHSpecial_HHH && (HaleCharge == HALEHHH_TELEPORTCHARGE || bEnableSuperDuperJump))
            {
                int target = -1;
                do
                    target = GetRandomInt(1, MaxClients);
                while ((RedAlivePlayers > 0) && (!IsClientInGame(target) || (target == Hale) || !IsPlayerAlive(target) || GetEntityTeamNum(target) != OtherTeam)); // IsValidClient(target, false)
                if (IsValidClient(target)) // Maybe it can fail it we teleport to nobody?
                {
                    // Chdata's HHH teleport rework
                    if (TF2_GetPlayerClass(target) != TFClass_Scout && TF2_GetPlayerClass(target) != TFClass_Soldier)
                    {
                        SetEntProp(Hale, Prop_Send, "m_CollisionGroup", 2); //Makes HHH clipping go away for player and some projectiles
                        CreateTimer(bEnableSuperDuperJump ? 4.0:2.0, HHHTeleTimer, _, TIMER_FLAG_NO_MAPCHANGE);
                    }
                    SetEntPropFloat(Hale, Prop_Send, "m_flNextAttack", GetGameTime() + (bEnableSuperDuperJump ? 4.0 : 2.0));
                    SetEntProp(Hale, Prop_Send, "m_bGlowEnabled", 0);
                    GlowTimer = 0.0;
                    AttachParticle(Hale, "ghost_appearation", 3.0);             // One is parented and one is not
                    if (TeleMeToYou(Hale, target)) // This returns true if teleport to a ducking player happened
                    {
                        VSHFlags[Hale] |= VSHFLAG_NEEDSTODUCK;
                        DataPack timerpack;
                        CreateDataTimer(0.2, Timer_StunHHH, view_as<Handle>(timerpack), TIMER_FLAG_NO_MAPCHANGE);
                        timerpack.WriteCell(bEnableSuperDuperJump);
                        timerpack.WriteCell(GetClientUserId(target));
                    }
                    else
                        TF2_StunPlayer(Hale, (bEnableSuperDuperJump ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);

                    AttachParticle(Hale, "ghost_appearation", 3.0, _, true);    // So the teleport smoke appears at both destinations
                    // Chdata's HHH teleport rework
                    float vPos[3];
                    GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);
                    EmitSoundToClient(Hale, "misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
                    EmitSoundToClient(target, "misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
                    PriorityCenterText(target, true, "You've been teleported to!");
                    HaleCharge = -1100;
                }
                if (bEnableSuperDuperJump)
                    bEnableSuperDuperJump = false;
            }
            else if (Special != VSHSpecial_HHH)
            {
                float vel[3];
                GetEntPropVector(Hale, Prop_Data, "m_vecVelocity", vel);
                if (bEnableSuperDuperJump)
                {
                    vel[2]=750 + HaleCharge * 13.0 + 2000;
                    bEnableSuperDuperJump = false;
                }
                else
                    vel[2]=750 + HaleCharge * 13.0;
                SetEntProp(Hale, Prop_Send, "m_bJumping", 1);
                vel[0] *= (1+Sine(float(HaleCharge) * FLOAT_PI / 50));
                vel[1] *= (1+Sine(float(HaleCharge) * FLOAT_PI / 50));
                TeleportEntity(Hale, NULL_VECTOR, NULL_VECTOR, vel);
                HaleCharge=-120;
                char s[PLATFORM_MAX_PATH];
                switch (Special)
                {
                    case VSHSpecial_Vagineer:
                        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
                    case VSHSpecial_CBS:
                        strcopy(s, PLATFORM_MAX_PATH, CBSJump1);
                    case VSHSpecial_Bunny:
                        strcopy(s, PLATFORM_MAX_PATH, BunnyJump[GetRandomInt(0, sizeof(BunnyJump)-1)]);
                    case VSHSpecial_Hale:
                        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", GetRandomInt(0, 1) ? HaleJump : HaleJump132, GetRandomInt(1, 2));
                }
                if (s[0] != '\0')
                {
                    GetEntPropVector(Hale, Prop_Send, "m_vecOrigin", pos);
                    EmitSoundToAll(s, Hale, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
                    EmitSoundToAll(s, Hale, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
                    for (int i = 1; i <= MaxClients; i++)
                    {
                        if (IsClientInGame(i) && (i != Hale))
                        {
                            EmitSoundToClient(i, s, Hale, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
                            EmitSoundToClient(i, s, Hale, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
                        }
                    }
                }
            }
        }
        else
            HaleCharge = 0;
    }
    if (RedAlivePlayers == 1)
    {
        switch (Special)
        {
            case VSHSpecial_Bunny:
                PriorityCenterTextAll(_, "%t", "vsh_bunny_hp", HaleHealth, HaleHealthMax);
            case VSHSpecial_Vagineer:
                PriorityCenterTextAll(_, "%t", "vsh_vagineer_hp", HaleHealth, HaleHealthMax);
            case VSHSpecial_HHH:
                PriorityCenterTextAll(_, "%t", "vsh_hhh_hp", HaleHealth, HaleHealthMax);
            case VSHSpecial_CBS:
                PriorityCenterTextAll(_, "%t", "vsh_cbs_hp", HaleHealth, HaleHealthMax);
            default:
                PriorityCenterTextAll(_, "%t", "vsh_hale_hp", HaleHealth, HaleHealthMax);
        }
    }
    if (OnlyScoutsLeft())
    {
        float rage = 0.001*RageDMG;
        HaleRage += RoundToCeil(rage);
        if (HaleRage > RageDMG)
            HaleRage = RageDMG;
    }
    if (!(GetEntityFlags(Hale) & FL_ONGROUND))
        WeighDownTimer += 0.2;
    else
    {
        HHHClimbCount = 0;
        WeighDownTimer = 0.0;
    }
    if (WeighDownTimer >= 4.0 && buttons & IN_DUCK && GetEntityGravity(Hale) != 6.0)
    {
        float ang[3];
        GetClientEyeAngles(Hale, ang);
        if ((ang[0] > 60.0))
        {
            Action act = Plugin_Continue;
            Call_StartForward(OnHaleWeighdown);
            Call_Finish(act);
            if (act != Plugin_Continue)
                return Plugin_Continue;
            float fVelocity[3];
            GetEntPropVector(Hale, Prop_Data, "m_vecVelocity", fVelocity);
            fVelocity[2] = -1000.0;
            TeleportEntity(Hale, NULL_VECTOR, NULL_VECTOR, fVelocity);
            SetEntityGravity(Hale, 6.0);
            CreateTimer(2.0, Timer_GravityCat, GetClientUserId(Hale), TIMER_FLAG_NO_MAPCHANGE);
            CPrintToChat(Hale, "{olive}[VSH]{default} %t", "vsh_used_weighdown");
            WeighDownTimer = 0.0;
        }
    }
    return Plugin_Continue;
}

public Action HHHTeleTimer(Handle timer)
{
    if (IsValidClient(Hale))
        SetEntProp(Hale, Prop_Send, "m_CollisionGroup", 5); //Fix HHH's clipping.
}

public Action Timer_StunHHH(Handle timer, Handle pack)
{
    if (!IsValidClient(Hale))
        return; // IsValidClient(Hale, false)
    DataPack dPack = view_as<DataPack>(pack);
    dPack.Reset();
    bool superduper = dPack.ReadCell();
    int targetid = dPack.ReadCell();
    int target = GetClientOfUserId(targetid);
    if (!IsValidClient(target))
        target = 0; // IsValidClient(target, false)
    VSHFlags[Hale] &= ~VSHFLAG_NEEDSTODUCK;
    TF2_StunPlayer(Hale, (superduper ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}

public Action Timer_BotRage(Handle timer)
{
    if (!IsValidClient(Hale))
        return Plugin_Continue; // IsValidClient(Hale, false)
    if (!TF2_IsPlayerInCondition(Hale, TFCond_Taunting))
        FakeClientCommandEx(Hale, "voicemenu 0 0");
    return Plugin_Continue;
}

bool OnlyScoutsLeft()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && IsPlayerAlive(client) && client != Hale && TF2_GetPlayerClass(client) != TFClass_Scout)
            return false;
    }
    return true;
}

public Action Timer_GravityCat(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client))
        SetEntityGravity(client, 1.0);
}

public Action Destroy(int client, const char[] command, int argc)
{
    if (!g_bEnabled || client == Hale)
        return Plugin_Continue;
    if (IsValidClient(client) && TF2_GetPlayerClass(client) == TFClass_Engineer && TF2_IsPlayerInCondition(client, TFCond_Taunting) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589)
        return Plugin_Handled;
    return Plugin_Continue;
}

public int TF2_OnConditionRemoved(int client, TFCond condition)
{
    if (TF2_GetPlayerClass(client) == TFClass_Scout && condition == TFCond_CritHype)
        TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
    return -1; //Temp till tf2.inc is transitionalled.
}

/*
 Call medic to rage update by Chdata

*/
public Action cdVoiceMenu(int client, const char[] command, int argc)
{
    if (argc < 2)
        return Plugin_Handled;
    char sCmd1[8], sCmd2[8];
    GetCmdArg(1, sCmd1, sizeof(sCmd1));
    GetCmdArg(2, sCmd2, sizeof(sCmd2));
    // Capture call for medic commands (represented by "voicemenu 0 0")
    if (sCmd1[0] == '0' && sCmd2[0] == '0' && IsPlayerAlive(client) && client == Hale)
    {
        if (HaleRage / RageDMG >= 1)
        {
            DoTaunt(client, "", 0);
            return Plugin_Handled;
        }
    }
    return (client == Hale && Special != VSHSpecial_CBS && Special != VSHSpecial_Bunny) ? Plugin_Handled : Plugin_Continue;
}

public Action DoTaunt(int client, const char[] command, int argc)
{
    if (!g_bEnabled || (client != Hale))
        return Plugin_Continue;
    if (bNoTaunt) // Prevent double-tap rages
        return Plugin_Handled;
    char s[PLATFORM_MAX_PATH];
    if (HaleRage/RageDMG >= 1)
    {
        float pos[3];
        GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
        pos[2] += 20.0;
        Action act = Plugin_Continue;
        Call_StartForward(OnHaleRage);
        float dist, newdist;
        switch (Special)
        {
            case VSHSpecial_Vagineer: dist = RageDist/(1.5);
            case VSHSpecial_Bunny: dist = RageDist/(1.5);
            case VSHSpecial_CBS: dist = RageDist/(2.5);
            default: dist = RageDist;
        }
        newdist = dist;
        Call_PushFloatRef(newdist);
        Call_Finish(act);
        if (act != Plugin_Continue && act != Plugin_Changed)
            return Plugin_Continue;
        else if (act == Plugin_Changed)
            dist = newdist;
        TF2_AddCondition(Hale, view_as<TFCond>(42), 4.0);
        switch (Special)
        {
            case VSHSpecial_Vagineer:
            {
                if (GetRandomInt(0, 2))
                    strcopy(s, PLATFORM_MAX_PATH, VagineerRageSound);
                else
                    Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
                TF2_AddCondition(Hale, TFCond_Ubercharged, 99.0);
                UberRageCount = 0.0;
                CreateTimer(0.6, UseRage, dist);
                CreateTimer(0.1, UseUberRage, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
            }
            case VSHSpecial_HHH:
            {
                Format(s, PLATFORM_MAX_PATH, "%s", HHHRage2);
                CreateTimer(0.6, UseRage, dist);
            }
            case VSHSpecial_Bunny:
            {
                strcopy(s, PLATFORM_MAX_PATH, BunnyRage[GetRandomInt(1, sizeof(BunnyRage)-1)]);
                EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                int weapon = SpawnWeapon(client, "tf_weapon_grenadelauncher", 19, 100, 5, "6 ; 0.1 ; 411 ; 150.0 ; 413 ; 1.0 ; 37 ; 0.0 ; 280 ; 17 ; 477 ; 1.0 ; 467 ; 1.0 ; 181 ; 2.0 ; 252 ; 0.7");
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
                SetEntProp(weapon, Prop_Send, "m_iClip1", 50);
//              new vm = CreateVM(client, ReloadEggModel);
//              SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", weapon);
//              SetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel", vm);
                SetAmmo(client, TFWeaponSlot_Primary, 0);
                //add charging?
                CreateTimer(0.6, UseRage, dist);
            }
            case VSHSpecial_CBS:
            {
                if (GetRandomInt(0, 1))
                    Format(s, PLATFORM_MAX_PATH, "%s", CBS1);
                else
                    Format(s, PLATFORM_MAX_PATH, "%s", CBS3);
                EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
                TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_compound_bow", 1005, 100, 5, "2 ; 2.1 ; 6 ; 0.5 ; 37 ; 0.0 ; 280 ; 19 ; 551 ; 1"));
                SetAmmo(client, TFWeaponSlot_Primary, ((RedAlivePlayers >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : RedAlivePlayers));
                CreateTimer(0.6, UseRage, dist);
                CreateTimer(0.1, UseBowRage);
            }
            default:
            {
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, GetRandomInt(1, 4));
                CreateTimer(0.6, UseRage, dist);
            }
        }
        EmitSoundToAll(s, client, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
        EmitSoundToAll(s, client, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && i != Hale)
            {
                EmitSoundToClient(i, s, client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
                EmitSoundToClient(i, s, client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
            }
        }
        HaleRage = 0;
        VSHFlags[Hale] &= ~VSHFLAG_BOTRAGE;
    }
    bNoTaunt = true;
    CreateTimer(1.5, Timer_NoTaunting, _, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public Action Timer_NoTaunting(Handle timer)
{
    bNoTaunt = false;
    return Plugin_Continue;
}

public Action DoSuicide(int client, const char[] command, int argc)
{
    if (g_bEnabled && (VSHRoundState == VSHRState_Waiting || VSHRoundState == VSHRState_Active))
    {
        if (client == Hale && bTenSecStart[0])
        {
            CPrintToChat(client, "Do not suicide as Hale. Use !resetq instead.");
            return Plugin_Handled;
            //KickClient(client, "Next time, please remember to !hale_resetq");
            //if (VSHRoundState == VSHRState_Waiting) return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action DoSuicide2(int client, const char[] command, int argc)
{
    if (g_bEnabled && client == Hale && bTenSecStart[0])
    {
        CPrintToChat(client, "You can't change teams this early.");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action UseRage(Handle hTimer, any dist)
{
    float pos[3], pos2[3], distance;
    int i;
    if (!IsValidClient(Hale))
        return Plugin_Continue; // IsValidClient(Hale, false)
    if (!GetEntProp(Hale, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale, Prop_Send, "m_hHighFivePartner")))
    {
        TF2_RemoveCondition(Hale, TFCond_Taunting);
        MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
    }
    GetEntPropVector(Hale, Prop_Send, "m_vecOrigin", pos);
    for (i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && (i != Hale))
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
            distance = GetVectorDistance(pos, pos2);
            if (!TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < dist)
            {
                int flags = TF_STUNFLAGS_GHOSTSCARE;
                if (Special != VSHSpecial_HHH)
                {
                    flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
                    AttachParticle(i, "yikes_fx", 5.0, {0.0,0.0,75.0}, true);
                }
                if (VSHRoundState != VSHRState_Waiting)
                    TF2_StunPlayer(i, 5.0, _, flags, (Special == VSHSpecial_HHH ? 0 : Hale));
            }
        }
    }
    i = -1;
    while ((i = FindEntityByClassname2(i, "obj_sentrygun")) != -1)
    {
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
        distance = GetVectorDistance(pos, pos2);
        if (dist <= RageDist/3)
            dist = RageDist/2;
        if (distance < dist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
        {
            SetEntProp(i, Prop_Send, "m_bDisabled", 1);
            AttachParticle(i, "yikes_fx", 3.0, {0.0,0.0,75.0}, true);
            if (newRageSentry)
            {
                SetVariantInt(GetEntProp(i, Prop_Send, "m_iHealth")/2);
                AcceptEntityInput(i, "RemoveHealth");
            }
            else
                SetEntProp(i, Prop_Send, "m_iHealth", GetEntProp(i, Prop_Send, "m_iHealth")/2);
            CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
        }
    }
    i = -1;
    while ((i = FindEntityByClassname2(i, "obj_dispenser")) != -1)
    {
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
        distance = GetVectorDistance(pos, pos2);
        if (dist <= RageDist/3)
            dist = RageDist/2;
        if (distance < dist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
        {
            SetVariantInt(1);
            AcceptEntityInput(i, "RemoveHealth");
        }
    }
    i = -1;
    while ((i = FindEntityByClassname2(i, "obj_teleporter")) != -1)
    {
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
        distance = GetVectorDistance(pos, pos2);
        if (dist <= RageDist/3)
            dist = RageDist/2;
        if (distance < dist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
        {
            SetVariantInt(1);
            AcceptEntityInput(i, "RemoveHealth");
        }
    }
    return Plugin_Continue;
}

public Action UseUberRage(Handle hTimer, any param)
{
    if (!IsValidClient(Hale))
        return Plugin_Stop;
    if (UberRageCount == 1)
    {
        if (!GetEntProp(Hale, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale, Prop_Send, "m_hHighFivePartner")))
        {
            TF2_RemoveCondition(Hale, TFCond_Taunting);
            MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
        }
//      TF2_StunPlayer(Hale, 0.0, _, TF_STUNFLAG_NOSOUNDOREFFECT);
    }
    else if (UberRageCount >= 100)
    {
        if (defaulttakedamagetype == 0)
            defaulttakedamagetype = 2;
        SetEntProp(Hale, Prop_Data, "m_takedamage", defaulttakedamagetype);
        defaulttakedamagetype = 0;
        TF2_RemoveCondition(Hale, TFCond_Ubercharged);
        return Plugin_Stop;
    }
    else if (UberRageCount >= 85 && !TF2_IsPlayerInCondition(Hale, TFCond_UberchargeFading))
        TF2_AddCondition(Hale, TFCond_UberchargeFading, 3.0);
    if (!defaulttakedamagetype)
    {
        defaulttakedamagetype = GetEntProp(Hale, Prop_Data, "m_takedamage");
        if (defaulttakedamagetype == 0)
            defaulttakedamagetype = 2;
    }
    SetEntProp(Hale, Prop_Data, "m_takedamage", 0);
    UberRageCount += 1.0;
    return Plugin_Continue;
}

public Action UseBowRage(Handle hTimer)
{
    if (!GetEntProp(Hale, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale, Prop_Send, "m_hHighFivePartner")))
    {
        TF2_RemoveCondition(Hale, TFCond_Taunting);
        MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
    }
//  TF2_StunPlayer(Hale, 0.0, _, TF_STUNFLAG_NOSOUNDOREFFECT);
//  UberRageCount = 9.0;
    SetAmmo(Hale, 0, ((RedAlivePlayers >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : RedAlivePlayers));
    return Plugin_Continue;
}

public Action event_player_death(Event event, const char[] name, bool dontBroadcast)
{
    char s[PLATFORM_MAX_PATH];
    if (!g_bEnabled)
        return Plugin_Continue;
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!client || !IsClientInGame(client))
        return Plugin_Continue;
    int attacker = GetClientOfUserId(event.GetInt("attacker")), deathflags = event.GetInt("death_flags"), customkill = event.GetInt("customkill");
    if (attacker == Hale && Special == VSHSpecial_Bunny && VSHRoundState == VSHRState_Active)
        SpawnManyAmmoPacks(client, EggModel, 1, 5, 120.0);
    if (attacker == Hale && VSHRoundState == VSHRState_Active && (deathflags & TF_DEATHFLAG_DEADRINGER))
    {
        numHaleKills++;
        if (customkill != TF_CUSTOM_BOOTS_STOMP)
        {
            if (Special == VSHSpecial_Hale)
                event.SetString("weapon", "fists");
        }
        return Plugin_Continue;
    }
    if (GetClientHealth(client) > 0)
        return Plugin_Continue;
    CreateTimer(0.1, CheckAlivePlayers);
    if (client != Hale && VSHRoundState == VSHRState_Active)
        CreateTimer(1.0, Timer_Damage, GetClientUserId(client));
    if (client == Hale && VSHRoundState == VSHRState_Active)
    {
        switch (Special)
        {
            case VSHSpecial_HHH:
            {
                Format(s, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_death0%d.wav", GetRandomInt(1, 2));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAll("ui/halloween_boss_defeated_fx.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
            }
            case VSHSpecial_Hale:
            {
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, GetRandomInt(1, 3));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
            }
            case VSHSpecial_Vagineer:
            {
                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
            }
            case VSHSpecial_Bunny:
            {
                strcopy(s, PLATFORM_MAX_PATH, BunnyFail[GetRandomInt(0, sizeof(BunnyFail)-1)]);
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
                SpawnManyAmmoPacks(client, EggModel, 1);
            }
        }
        if (HaleHealth < 0)
            HaleHealth = 0;
        ForceTeamWin(OtherTeam);
        return Plugin_Continue;
    }
    if (attacker == Hale && VSHRoundState == VSHRState_Active)
    {
        numHaleKills++;
        switch (Special)
        {
            case VSHSpecial_Hale:
            {
                if (customkill != TF_CUSTOM_BOOTS_STOMP)
                    event.SetString("weapon", "fists");
                if (!GetRandomInt(0, 2) && RedAlivePlayers != 1)
                {
                    strcopy(s, PLATFORM_MAX_PATH, "");
                    TFClassType playerclass = TF2_GetPlayerClass(client);
                    switch (playerclass)
                    {
                        case TFClass_Scout:
                            strcopy(s, PLATFORM_MAX_PATH, HaleKillScout132);
                        case TFClass_Pyro:
                            strcopy(s, PLATFORM_MAX_PATH, HaleKillPyro132);
                        case TFClass_DemoMan:
                            strcopy(s, PLATFORM_MAX_PATH, HaleKillDemo132);
                        case TFClass_Heavy:
                            strcopy(s, PLATFORM_MAX_PATH, HaleKillHeavy132);
                        case TFClass_Medic:
                            strcopy(s, PLATFORM_MAX_PATH, HaleKillMedic);
                        case TFClass_Sniper:
                        {
                            if (GetRandomInt(0, 1))
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillSniper1);
                            else
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillSniper2);
                        }
                        case TFClass_Spy:
                        {
                            int see = GetRandomInt(0, 2);
                            if (!see)
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy1);
                            else if (see == 1)
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy2);
                            else
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy132);
                        }
                        case TFClass_Engineer:
                        {
                            int see = GetRandomInt(0, 3);
                            if (!see)
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillEngie1);
                            else if (see == 1)
                                strcopy(s, PLATFORM_MAX_PATH, HaleKillEngie2);
                            else
                                Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
                        }
                    }
                    if (!StrEqual(s, ""))
                    {
                        EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                        EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                    }
                }
            }
            case VSHSpecial_Vagineer:
            {
                strcopy(s, PLATFORM_MAX_PATH, VagineerHit);
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_DissolveRagdoll, any:GetEventInt(event, "userid"));
            }
            case VSHSpecial_HHH:
            {
                Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHAttack, GetRandomInt(1, 4));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
            }
            case VSHSpecial_Bunny:
            {
                strcopy(s, PLATFORM_MAX_PATH, BunnyKill[GetRandomInt(0, sizeof(BunnyKill)-1)]);
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
            }
            case VSHSpecial_CBS:
            {
                if (!GetRandomInt(0, 3) && RedAlivePlayers != 1)
                {
                    TFClassType playerclass = TF2_GetPlayerClass(client);
                    switch (playerclass)
                    {
                        case TFClass_Spy:
                        {
                            strcopy(s, PLATFORM_MAX_PATH, "vo/sniper_dominationspy04.wav");
                            EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                            EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                        }
                    }
                }
                int weapon = GetEntPropEnt(Hale, Prop_Send, "m_hActiveWeapon");
                if (weapon == GetPlayerWeaponSlot(Hale, TFWeaponSlot_Melee))
                {
                    TF2_RemoveWeaponSlot(Hale, TFWeaponSlot_Melee);
                    int clubindex, wepswitch = GetRandomInt(0, 3);
                    switch (wepswitch)
                    {
                        case 0:
                            clubindex = 171;
                        case 1:
                            clubindex = 3;
                        case 2:
                            clubindex = 232;
                        case 3:
                            clubindex = 401;
                    }
                    weapon = SpawnWeapon(Hale, "tf_weapon_club", clubindex, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0");
                    SetEntPropEnt(Hale, Prop_Send, "m_hActiveWeapon", weapon);
                    SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex"), _, 0);
                }
            }
        }
        if (GetGameTime() <= KSpreeTimer)
            KSpreeCount++;
        else
            KSpreeCount = 1;
        if (KSpreeCount == 3 && RedAlivePlayers != 1)
        {
            switch (Special)
            {
                case VSHSpecial_Hale:
                {
                    int see = GetRandomInt(0, 7);
                    if (!see || see == 1)
                        strcopy(s, PLATFORM_MAX_PATH, HaleKSpree);
                    else if (see < 5)
                        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, GetRandomInt(1, 5));
                    else
                        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, GetRandomInt(1, 2));
                }
                case VSHSpecial_Vagineer:
                {
                    if (GetRandomInt(0, 4) == 1)
                        strcopy(s, PLATFORM_MAX_PATH, VagineerKSpree);
                    else if (GetRandomInt(0, 3) == 1)
                        strcopy(s, PLATFORM_MAX_PATH, VagineerKSpree2);
                    else
                        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
                }
                case VSHSpecial_HHH:
                    Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, GetRandomInt(1, 4));
                case VSHSpecial_CBS:
                {
                    if (!GetRandomInt(0, 3))
                        Format(s, PLATFORM_MAX_PATH, CBS0);
                    else if (!GetRandomInt(0, 3))
                        Format(s, PLATFORM_MAX_PATH, CBS1);
                    else
                        Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS2, GetRandomInt(1, 9));
                    EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                }
                case VSHSpecial_Bunny:
                    strcopy(s, PLATFORM_MAX_PATH, BunnySpree[GetRandomInt(0, sizeof(BunnySpree)-1)]);
            }
            EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
            EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
            KSpreeCount = 0;
        }
        else
            KSpreeTimer = GetGameTime() + 5.0;
    }
    if ((TF2_GetPlayerClass(client) == TFClass_Engineer) && !(deathflags & TF_DEATHFLAG_DEADRINGER))
    {
        int ent = -1;
        while ((ent = FindEntityByClassname2(ent, "obj_sentrygun")) != -1)
        {
            if (GetEntPropEnt(ent, Prop_Send, "m_hBuilder") == client)
            {
                SetVariantInt(GetEntProp(ent, Prop_Send, "m_iMaxHealth") + 8);
                AcceptEntityInput(ent, "RemoveHealth");
            }
        }
    }
    return Plugin_Continue;
}

stock void SpawnManyAmmoPacks(int client, char[] model, int skin=0, int num=14, float offsz = 30.0)
{
//  if (hSetAmmoVelocity == INVALID_HANDLE) return;
    float pos[3], vel[3], ang[3] = {90.0, 0.0, 0.0};
    GetClientAbsOrigin(client, pos);
    pos[2] += offsz;
    for (int i = 0; i < num; i++)
    {
        vel[0] = GetRandomFloat(-400.0, 400.0);
        vel[1] = GetRandomFloat(-400.0, 400.0);
        vel[2] = GetRandomFloat(300.0, 500.0);
        pos[0] += GetRandomFloat(-5.0, 5.0);
        pos[1] += GetRandomFloat(-5.0, 5.0);
        int ent = CreateEntityByName("tf_ammo_pack");
        if (!IsValidEntity(ent))
            continue;
        SetEntityModel(ent, model);
        DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); //for safety, but it shouldn't act like a normal ammopack
        SetEntProp(ent, Prop_Send, "m_nSkin", skin);
        SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
//      SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
//      SetEntProp(ent, Prop_Send, "movetype", 5);
//      SetEntProp(ent, Prop_Send, "movecollide", 0);
        SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
        SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
        SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
        SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 2);
        TeleportEntity(ent, pos, ang, vel);
        DispatchSpawn(ent);
        TeleportEntity(ent, pos, ang, vel);
//      SDKCall(hSetAmmoVelocity, ent, vel);
        SetEntProp(ent, Prop_Data, "m_iHealth", 900);
        int offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
        SetEntData(ent, offs-4, 1, _, true);    //Sets to crit candy, offs-8 sets crit candy duration (is a float, 3*float = duration)
        //1358 is offs-14, that byte is for being a sandwich with +50hp, +75 for scouts. The byte after that, 1359, is to... not give the health? I don't know.
/*      SetEntData(ent, offs-13, 0, 1, true);
        SetEntData(ent, offs-11, 1, 1, true);
        SetEntData(ent, offs-15, 1, 1, true);
        SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
        SetEntProp(ent, Prop_Data, "m_nNextThinkTick", GetEntProp(client, Prop_Send, "m_nTickBase") + 3);
        SetEntPropVector(ent, Prop_Data, "m_vecAbsVelocity", vel);
        SetEntPropVector(ent, Prop_Data, "m_vecVelocity", vel);
        SetEntPropVector(ent, Prop_Send, "m_vecInitialVelocity", vel);
        SetEntProp(ent, Prop_Send, "m_bClientSideAnimation", 1);
        PrintToChatAll("aeiou %d %d %d %d %d", GetEntData(ent, offs-16, 1), GetEntData(ent, offs-15, 1), GetEntData(ent, offs-14, 1), GetEntData(ent, offs-13, 1), GetEntData(ent, offs-12, 1));
        */
    }
}

public Action Timer_Damage(Handle hTimer, any id)
{
    int client = GetClientOfUserId(id);
    if (IsValidClient(client)) // IsValidClient(client, false)
        CPrintToChat(client, "{olive}[VSH] %t. %t %i{default}", "vsh_damage", Damage[client], "vsh_scores", RoundFloat(Damage[client] / 600.0));
    return Plugin_Continue;
}

/*public Action:Timer_DissolveRagdoll(Handle:timer, any:userid)
{
    new victim = GetClientOfUserId(userid);
    new ragdoll = (IsValidClient(victim) ? GetEntPropEnt(victim, Prop_Send, "m_hRagdoll") : -1);
    if (IsValidEntity(ragdoll))
    {
        DissolveRagdoll(ragdoll);
    }
}

DissolveRagdoll(ragdoll)
{
    new dissolver = CreateEntityByName("env_entity_dissolver");

    if (!IsValidEntity(dissolver))
    {
        return;
    }
    DispatchKeyValue(dissolver, "dissolvetype", "0");
    DispatchKeyValue(dissolver, "magnitude", "200");
    DispatchKeyValue(dissolver, "target", "!activator");
    AcceptEntityInput(dissolver, "Dissolve", ragdoll);
    AcceptEntityInput(dissolver, "Kill");
    return;
}

public Action:Timer_ChangeRagdoll(Handle:timer, any:userid)
{
    new victim = GetClientOfUserId(userid);
    new ragdoll;
    if (IsValidClient(victim)) ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
    else ragdoll = -1;
    if (IsValidEntity(ragdoll))
    {
        switch (Special)
        {
            case VSHSpecial_Hale:       SetEntityModel(ragdoll, HaleModel);
            case VSHSpecial_Vagineer:   SetEntityModel(ragdoll, VagineerModel);
            case VSHSpecial_HHH:        SetEntityModel(ragdoll, HHHModel);
            case VSHSpecial_CBS:        SetEntityModel(ragdoll, CBSModel);
            case VSHSpecial_Bunny:      SetEntityModel(ragdoll, BunnyModel);
        }
    }
}*/

public Action event_deflect(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled)
        return Plugin_Continue;
    int deflector = GetClientOfUserId(event.GetInt("userid")), owner = GetClientOfUserId(event.GetInt("ownerid")), weaponid = event.GetInt("weaponid");
    if (owner != Hale)
        return Plugin_Continue;
    if (weaponid != 0)
        return Plugin_Continue;
    float rage = 0.04*RageDMG;
    HaleRage += RoundToCeil(rage);
    if (HaleRage > RageDMG)
        HaleRage = RageDMG;
    if (Special != VSHSpecial_Vagineer)
        return Plugin_Continue;
    if (!TF2_IsPlayerInCondition(owner, TFCond_Ubercharged))
        return Plugin_Continue;
    if (UberRageCount > 11)
        UberRageCount -= 10;
    int newammo = GetAmmo(deflector, 0) - 5;
    SetAmmo(deflector, 0, newammo <= 0 ? 0 : newammo);
    return Plugin_Continue;
}

public Action event_jarate(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init)
{
    int client = bf.ReadByte(), victim = bf.ReadByte();
    if (victim != Hale)
        return Plugin_Continue;
    int jar = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
    int jindex = GetEntProp(jar, Prop_Send, "m_iItemDefinitionIndex");
    if (jar != -1 && (jindex == 58 || jindex == 1083 || jindex == 1105) && GetEntProp(jar, Prop_Send, "m_iEntityLevel") != -122)    //-122 is the Jar of Ants and should not be used in this
    {
        float rage = 0.08*RageDMG;
        HaleRage -= RoundToFloor(rage);
        if (HaleRage < 0)
            HaleRage = 0;
        if (Special == VSHSpecial_Vagineer && TF2_IsPlayerInCondition(victim, TFCond_Ubercharged) && UberRageCount < 99)
        {
            UberRageCount += 7.0;
            if (UberRageCount > 99)
                UberRageCount = 99.0;
        }
        int ammo = GetAmmo(Hale, 0);
        if (Special == VSHSpecial_CBS && ammo > 0)
            SetAmmo(Hale, 0, ammo - 1);
    }
    return Plugin_Continue;
}

public Action CheckAlivePlayers(Handle hTimer)
{
    if (VSHRoundState != VSHRState_Active) //(VSHRoundState == VSHRState_End || VSHRoundState == VSHRState_Disabled)
        return Plugin_Continue;
    RedAlivePlayers = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && (GetEntityTeamNum(i) == OtherTeam))
            RedAlivePlayers++;
    }
    if (Special == VSHSpecial_CBS && GetAmmo(Hale, 0) > RedAlivePlayers && RedAlivePlayers != 0)
        SetAmmo(Hale, 0, RedAlivePlayers);
    if (RedAlivePlayers == 0)
        ForceTeamWin(HaleTeam);
    else if (RedAlivePlayers == 1 && IsValidClient(Hale) && VSHRoundState == VSHRState_Active)
    {
        float pos[3];
        char s[PLATFORM_MAX_PATH];
        GetEntPropVector(Hale, Prop_Send, "m_vecOrigin", pos);
        if (Special != VSHSpecial_HHH)
        {
            if (Special == VSHSpecial_CBS)
            {
                if (!GetRandomInt(0, 2))
                    Format(s, PLATFORM_MAX_PATH, "%s", CBS0);
                else
                    Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS4, GetRandomInt(1, 25));
                EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
            }
            else if (Special == VSHSpecial_Bunny)
                strcopy(s, PLATFORM_MAX_PATH, BunnyLast[GetRandomInt(0, sizeof(BunnyLast)-1)]);
            else if (Special == VSHSpecial_Vagineer)
                strcopy(s, PLATFORM_MAX_PATH, VagineerLastA);
            else
            {
                int see = GetRandomInt(0, 5);
                switch (see)
                {
                    case 0:
                        strcopy(s, PLATFORM_MAX_PATH, HaleComicArmsFallSound);
                    case 1:
                        Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, GetRandomInt(1, 4));
                    case 2:
                        strcopy(s, PLATFORM_MAX_PATH, HaleKillLast132);
                    default:
                        Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, GetRandomInt(1, 5));
                }
            }
            EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
            EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
        }
    }
    if (!PointType && (RedAlivePlayers <= (AliveToEnable = GetConVarInt(cvarAliveToEnable))) && !PointReady)
    {
        PrintHintTextToAll("%t", "vsh_point_enable", RedAlivePlayers);
        if (RedAlivePlayers == AliveToEnable)
            EmitSoundToAll("vo/announcer_am_capenabled02.wav");
        else if (RedAlivePlayers < AliveToEnable)
        {
            char s[PLATFORM_MAX_PATH];
            Format(s, PLATFORM_MAX_PATH, "vo/announcer_am_capincite0%i.wav", GetRandomInt(0, 1) ? 1 : 3);
            EmitSoundToAll(s);
        }
        SetControlPoint(true);
        PointReady = true;
    }
    return Plugin_Continue;
}

public Action event_hurt(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled)
        return Plugin_Continue;
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new damage = GetEventInt(event, "damageamount");
    new custom = GetEventInt(event, "custom");
    new weapon = GetEventInt(event, "weaponid");
    if (client != Hale) // || !IsValidEdict(client) || !IsValidEdict(attacker) || (client <= 0) || (attacker <= 0) || (attacker > MaxClients))
        return Plugin_Continue;

    if (!IsValidClient(attacker) || !IsValidClient(client) || client == attacker) // || custom == TF_CUSTOM_BACKSTAB)
        return Plugin_Continue;

    if (custom == TF_CUSTOM_TELEFRAG) damage = (IsPlayerAlive(attacker) ? 9001:1);

    if (GetEventBool(event, "minicrit") && GetEventBool(event, "allseecrit")) SetEventBool(event, "allseecrit", false);

    HaleHealth -= damage;
    HaleRage += damage;

    if (custom == TF_CUSTOM_TELEFRAG) SetEventInt(event, "damageamount", damage);

    Damage[attacker] += damage;

    if (TF2_GetPlayerClass(attacker) == TFClass_Soldier && GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary) == 1104)
    {
        if (weapon == TF_WEAPON_ROCKETLAUNCHER)
        {
            AirDamage[attacker] += damage;
        }

        SetEntProp(attacker, Prop_Send, "m_iDecapitations", AirDamage[attacker]/200);
    }

    new healers[TF_MAX_PLAYERS];
    new healercount = 0;
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
        {
            healers[healercount] = i;
            healercount++;
        }
    }
    for (new i = 0; i < healercount; i++)
    {
        if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
        {
            if (damage < 10 || uberTarget[healers[i]] == attacker)
                Damage[healers[i]] += damage;
            else
                Damage[healers[i]] += damage/(healercount+1);
        }
    }

    if (HaleRage > RageDMG)
        HaleRage = RageDMG;
    return Plugin_Continue;
}
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
    if (!g_bEnabled || !IsValidEdict(attacker) || ((attacker <= 0) && (client == Hale)) || TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
        return Plugin_Continue;
    if (VSHRoundState == VSHRState_Waiting && (client == Hale || (client != attacker && attacker != Hale)))
    {
        damage *= 0.0;
        return Plugin_Changed;
    }
    decl Float:vPos[3];
    GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", vPos);
    if ((attacker == Hale) && IsValidClient(client) && (client != Hale) && !TF2_IsPlayerInCondition(client, TFCond_Bonked) && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
    {
        if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
        {
            ScaleVector(damageForce, 9.0);
            damage *= 0.3;
            return Plugin_Changed;
        }
        if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
        {
            damage *= 9;
            TF2_AddCondition(client, TFCond_Bonked, 0.1);
            return Plugin_Changed;
        }
        if (TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
        {
            damage *= 0.25;

            return Plugin_Changed;
        }

        if (RemoveDemoShield(client)) // If the demo had a shield to break
        {
            EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, 100, _, vPos, _, false);
            EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, 100, _, vPos, _, false);

            TF2_AddCondition(client, TFCond_Bonked, 0.1);
            TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
            return Plugin_Continue;
        }

        if (TF2_GetPlayerClass(client) == TFClass_Spy)  //eggs probably do melee damage to spies, then? That's not ideal, but eh.
        {
            if (GetEntProp(client, Prop_Send, "m_bFeignDeathReady") && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
            {
                if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
                damage = 620.0;
                return Plugin_Changed;
            }
            if (TF2_IsPlayerInCondition(client, TFCond_Cloaked) && TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
            {
                if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
                damage = 850.0;
                return Plugin_Changed;
            }
//          return Plugin_Changed;
        }
        new buffweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
        new buffindex = (IsValidEntity(buffweapon) && buffweapon > MaxClients ? GetEntProp(buffweapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
        if (buffindex == 226)
        {
            CreateTimer(0.25, Timer_CheckBuffRage, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        }
        if (damage <= 160.0 && !(Special == VSHSpecial_CBS && inflictor != attacker) && (Special != VSHSpecial_Bunny || weapon == -1 || weapon == GetPlayerWeaponSlot(Hale, TFWeaponSlot_Melee)))
        {
            damage *= 3;
            return Plugin_Changed;
        }
    }
    else if (attacker != Hale && client == Hale)
    {
        if (attacker <= MaxClients)
        {
            new wepindex = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
            if (inflictor == attacker || inflictor == weapon)
            {
                new iFlags = GetEntityFlags(Hale);
                new bChanged = false;

#if defined _tf2attributes_included
                if (!(damagetype & DMG_BLAST) && (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))    //If Hale is ducking on the ground, it's harder to knock him back
                {
                    TF2Attrib_SetByDefIndex(Hale, 252, 0.0);        // "damage force reduction"
                    //damagetype |= DMG_PREVENT_PHYSICS_FORCE;
                    bChanged = true;
                }
                else
                {
                    TF2Attrib_RemoveByDefIndex(Hale, 252);
                }
#else
                // Does not protect against sentries or FaN, but does against miniguns and rockets
                if ((iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))
                {
                    damagetype |= DMG_PREVENT_PHYSICS_FORCE;
                    bChanged = true;
                }
#endif

                if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
                {
                    damage = 1024.0;

                    return Plugin_Changed;
                }
                if (damagecustom == TF_CUSTOM_TELEFRAG) //if (!IsValidEntity(weapon) && (damagetype & DMG_CRUSH) == DMG_CRUSH && damage == 1000.0)    //THIS IS A TELEFRAG
                {
                    if (!IsPlayerAlive(attacker)) // Is this even possible?
                    {
                        damage = 1.0;
                        return Plugin_Changed;
                    }

                    damage = 9001.0; //(HaleHealth > 9001 ? 15.0:float(GetEntProp(Hale, Prop_Send, "m_iHealth")) + 90.0);

                    new teleowner = FindTeleOwner(attacker);

                    if (IsValidClient(teleowner) && teleowner != attacker)
                    {
                        Damage[teleowner] += 5401; //RoundFloat(9001.0 * 3 / 5);
                        PriorityCenterText(teleowner, true, "TELEFRAG ASSIST! Nice job setting up!");
                    }

                    PriorityCenterText(attacker, true, "TELEFRAG! You are a pro.");
                    PriorityCenterText(client, true, "TELEFRAG! Be careful around quantum tunneling devices!");
                    return Plugin_Changed;
                }
                switch (wepindex)
                {
                    case 593:       //Third Degree
                    {
                        new healers[TF_MAX_PLAYERS];
                        new healercount = 0;
                        for (new i = 1; i <= MaxClients; i++)
                        {
                            if (IsClientInGame(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
                            {
                                healers[healercount] = i;
                                healercount++;
                            }
                        }
                        for (new i = 0; i < healercount; i++)
                        {
                            if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
                            {
                                new medigun = GetPlayerWeaponSlot(healers[i], TFWeaponSlot_Secondary);
                                if (IsValidEntity(medigun))
                                {
                                    new String:s[64];
                                    GetEdictClassname(medigun, s, sizeof(s));
                                    if (strcmp(s, "tf_weapon_medigun", false) == 0)
                                    {
                                        new Float:uber = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") + (0.1 / healercount);
                                        new Float:max = 1.0;
                                        if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease")) max = 1.5;
                                        if (uber > max) uber = max;
                                        SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", uber);
                                    }
                                }
                            }
                        }
                    }
                    case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098:
                    {
                        switch (wepindex)   //cleaner to read than if wepindex == || wepindex == || etc
                        {
                            case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966:
                            {
                                if (VSHRoundState != VSHRState_End)
                                {
                                    new Float:chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
                                    new Float:time = (GlowTimer > 10 ? 1.0 : 2.0);
                                    time += (GlowTimer > 10 ? (GlowTimer > 20 ? 1 : 2) : 4)*(chargelevel/100);
                                    SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
                                    GlowTimer += RoundToCeil(time);
                                    if (GlowTimer > 30.0) GlowTimer = 30.0;
                                }
                            }
                        }
                        if (wepindex == 752 && VSHRoundState != VSHRState_End)
                        {
                            new Float:chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
                            new Float:add = 10 + (chargelevel / 10);
                            if (TF2_IsPlayerInCondition(attacker, TFCond:46)) add /= 3;
                            new Float:rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
                            SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
                        }
                        if (!(damagetype & DMG_CRIT))
                        {
                            new bool:ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));

                            damage *= (ministatus) ? 2.222222 : 3.0;

                            if (wepindex == 230)
                            {
                                HaleRage -= RoundFloat(damage/2.0);
                                if (HaleRage < 0) HaleRage = 0;
                            }

                            return Plugin_Changed;
                        }
                        else if (wepindex == 230)
                        {
                            HaleRage -= RoundFloat(damage*3.0/2.0);
                            if (HaleRage < 0) HaleRage = 0;
                        }
                    }
                    case 355:
                    {
                        new Float:rage = 0.05*RageDMG;
                        HaleRage -= RoundToFloor(rage);
                        if (HaleRage < 0)
                            HaleRage = 0;
                    }
                    case 132, 266, 482, 1082: IncrementHeadCount(attacker);
                    case 416:   // Chdata's Market Gardener backstab
                    {
                        if (RemoveCond(attacker, TFCond_BlastJumping)) // New way to check explosive jumping status
                        {
                            // if (Special == VSHSpecial_HHH && !(GetEntityFlags(client) & FL_ONGROUND) && IsPlayerStuck(attacker) && TR_GetEntityIndex() == client) // TFCond_Dazed
                            // {
                            //     TF2_RemoveCondition(attacker, TFCond_BlastJumping);   // Prevent HHH from being market gardened more than once in midair during a teleport
                            // }

                            damage = (Pow(float(HaleHealthMax), (0.74074)) + 512.0 - (g_flMarketed/128.0*float(HaleHealthMax)) )/3.0;    //divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
                            damagetype |= DMG_CRIT;

                            if (RemoveCond(attacker, TFCond_Parachute))   // If you parachuted to do this, remove your parachute.
                            {
                                damage *= 0.67;                       //  And nerf your damage
                            }

                            if (g_flMarketed < 5.0)
                            {
                                g_flMarketed++;
                            }

                            PriorityCenterText(attacker, true, "You market gardened him!");
                            PriorityCenterText(client, true, "You were just market gardened!");

                            EmitSoundToAll("player/doubledonk.wav", attacker);

                            return Plugin_Changed;
                        }
                    }
                    case 317: SpawnSmallHealthPackAt(client, GetEntityTeamNum(attacker));
                    case 214: // Powerjack
                    {
                        AddPlayerHealth(attacker, 25, 50);
                        RemoveCond(attacker, TFCond_OnFire);
                        return Plugin_Changed;
                    }
                    case 594: // Phlog
                    {
                        if (!TF2_IsPlayerInCondition(attacker, TFCond_CritMmmph))
                        {
                            damage /= 2.0;
                            return Plugin_Changed;
                        }
                    }
                    case 357:
                    {
                        SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
                        if (GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
                            SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);

                        AddPlayerHealth(attacker, 35, 25);
                        RemoveCond(attacker, TFCond_OnFire);
                    }
                    case 61, 1006:  //Ambassador does 2.5x damage on headshot
                    {
                        if (damagecustom == TF_CUSTOM_HEADSHOT)
                        {
                            damage = 85.0;
                            return Plugin_Changed;
                        }
                    }
                    case 525, 595:
                    {
                        new iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");

                        if (iCrits > 0) //If a revenge crit was used, give a damage bonus
                        {
                            damage = 85.0;
                            return Plugin_Changed;
                        }
                    }
                    /*case 528:
                    {
                        if (circuitStun > 0.0)
                        {
                            TF2_StunPlayer(client, circuitStun, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
                            EmitSoundToAll("weapons/barret_arm_zap.wav", client);
                            EmitSoundToClient(client, "weapons/barret_arm_zap.wav");
                        }
                    }*/
                    case 656: // Mittens
                    {
                        CreateTimer(0.1, Timer_StopTickle, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
                        RemoveCond(attacker, TFCond_Dazed);
                    }
                }
                //VoiDeD's Caber-backstab code. To be added with a few special modifications in 1.40+
                //Except maybe not because it's semi op.
/*              if ( IsValidEdict( weapon ) && GetEdictClassname( weapon, wepclassname, sizeof( wepclassname ) ) && strcmp( wepclassname, "tf_weapon_stickbomb", false ) == 0 )
                {
                    // make caber do backstab damage on explosion

                    new bool:isDetonated = GetEntProp( weapon, Prop_Send, "m_iDetonated" ) == 1;

                    if ( !isDetonated )
                    {
                        new Float:changedamage = HaleHealthMax * 0.07;

                        Damage[attacker] += RoundFloat(changedamage);

                        damage = changedamage;

                        HaleHealth -= RoundFloat(changedamage);
                        HaleRage += RoundFloat(changedamage);

                        if (HaleRage > RageDMG)
                            HaleRage = RageDMG;
                    }
                }*/
                static bool:foundDmgCustom = false;
                static bool:dmgCustomInOTD = false;
                if (!foundDmgCustom)
                {
                    dmgCustomInOTD = (GetFeatureStatus(FeatureType_Capability, "SDKHook_DmgCustomInOTD") == FeatureStatus_Available);
                    foundDmgCustom = true;
                }
                new bool:bIsBackstab = false;
                if (dmgCustomInOTD) // new way to check backstabs
                {
                    if (damagecustom == TF_CUSTOM_BACKSTAB)
                    {
                        bIsBackstab = true;
                    }
                }
                else if (weapon != 4095 && IsValidEdict(weapon) && weapon == GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) && damage > 1000.0)  //lousy way of checking backstabs
                {
                    decl String:wepclassname[32];
                    if (GetEdictClassname(weapon, wepclassname, sizeof(wepclassname)) && strcmp(wepclassname, "tf_weapon_knife", false) == 0)   //more robust knife check
                    {
                        bIsBackstab = true;
                    }
                }
                if (bIsBackstab)
                {
                    /*
                     Rebalanced backstab formula.
                     By: Chdata

                     Stronger against low HP Hale.
                     Weaker against high HP Hale (but still good).

                    */
                    new Float:changedamage = ( (Pow(float(HaleHealthMax)*0.0014, 2.0) + 899.0) - (float(HaleHealthMax)*(g_flStabbed/100.0)) );
                    //new iChangeDamage = RoundFloat(changedamage);

                    damage = changedamage/3;            // You can level "damage dealt" with backstabs
                    damagetype |= DMG_CRIT;

                    /*Damage[attacker] += iChangeDamage;
                    if (HaleHealth > iChangeDamage) damage = 0.0;
                    else damage = changedamage;
                    HaleHealth -= iChangeDamage;
                    HaleRage += iChangeDamage;
                    if (HaleRage > RageDMG)
                        HaleRage = RageDMG;*/
                    EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, vPos, NULL_VECTOR, false, 0.0);
                    EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, vPos, NULL_VECTOR, false, 0.0);
                    EmitSoundToClient(client, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, _, NULL_VECTOR, false, 0.0);
                    EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, _, NULL_VECTOR, false, 0.0);
                    SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
                    SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);
                    SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime() + 2.0);
                    new vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
                    if (vm > MaxClients && IsValidEntity(vm) && TF2_GetPlayerClass(attacker) == TFClass_Spy)
                    {
                        new melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
                        new anim = 15;
                        switch (melee)
                        {
                            case 727: anim = 41;
                            case 4, 194, 665, 794, 803, 883, 892, 901, 910: anim = 10;
                            case 638: anim = 31;
                        }
                        SetEntProp(vm, Prop_Send, "m_nSequence", anim);
                    }
                    PriorityCenterText(attacker, true, "You backstabbed him!");
                    PriorityCenterText(client, true, "You were just backstabbed!");

                    new pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);

                    if (pistol == 525) //Diamondback gives 3 crits on backstab
                    {
                        new iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
                        SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
                    }

                    /*if (wepindex == 225 || wepindex == 574)
                    {
                        CreateTimer(0.3, Timer_DisguiseBackstab, GetClientUserId(attacker));
                    }*/

                    if (wepindex == 356) // Kunai
                    {
                        AddPlayerHealth(attacker, 180, 270, true);
                    }
                    if (wepindex == 461) // Big Earner gives full cloak on backstab
                    {
                        SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);
                    }
                    decl String:s[PLATFORM_MAX_PATH];
                    switch (Special)
                    {
                        case VSHSpecial_Hale:
                        {
                            Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
                            EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                            EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                        }
                        case VSHSpecial_Vagineer:
                        {
                            EmitSoundToAll("vo/engineer_positivevocalization01.wav", _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                            EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "vo/engineer_positivevocalization01.wav", _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                        }
                        case VSHSpecial_HHH:
                        {
                            Format(s, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_pain0%d.wav", GetRandomInt(1, 3));
                            EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                            EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                        }
                        case VSHSpecial_Bunny:
                        {
                            strcopy(s, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain)-1)]);
                            EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                            EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
                        }
                    }
                    if (g_flStabbed < 4.0)
                        g_flStabbed++;
                    /*new healers[TF_MAX_PLAYERS]; // Medic assist unnecessary due to being handled in player_hurt now.
                    new healercount = 0;
                    for (new i = 1; i <= MaxClients; i++)
                    {
                        if (IsClientInGame(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
                        {
                            healers[healercount] = i;
                            healercount++;
                        }
                    }
                    for (new i = 0; i < healercount; i++)
                    {
                        if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
                        {
                            if (uberTarget[healers[i]] == attacker)
                                Damage[healers[i]] += iChangeDamage;
                            else
                                Damage[healers[i]] += RoundFloat(changedamage/(healercount+1));
                        }
                    }*/
                    return Plugin_Changed;
                }

                if (bChanged)
                {
                    return Plugin_Changed;
                }
            }
            if (TF2_GetPlayerClass(attacker) == TFClass_Scout)
            {
                if (wepindex == 45 || ((wepindex == 209 || wepindex == 294 || wepindex == 23 || wepindex == 160 || wepindex == 449) && (TF2_IsPlayerCritBuffed(client) || TF2_IsPlayerInCondition(client, TFCond_CritCola) || TF2_IsPlayerInCondition(client, TFCond_Buffed) || TF2_IsPlayerInCondition(client, TFCond_CritHype))))
                {
                    ScaleVector(damageForce, 0.38);
                    return Plugin_Changed;
                }
            }
        }
        else
        {
            decl String:s[64];
            if (GetEdictClassname(attacker, s, sizeof(s)) && strcmp(s, "trigger_hurt", false) == 0) // && damage >= 250)
            {
                if (bSpawnTeleOnTriggerHurt)
                {
                    // Teleport the boss back to one of the spawns.
                    // And during the first 30 seconds, he can only teleport to his own spawn.
                    //TeleportToSpawn(Hale, (bTenSecStart[1]) ? HaleTeam : 0);
                    TeleportToMultiMapSpawn(Hale, (bTenSecStart[1]) ? HaleTeam : 0);
                }
                else if (damage >= 250.0)
                {
                    if (Special == VSHSpecial_HHH)
                    {
                        //TeleportToSpawn(Hale, (bTenSecStart[1]) ? HaleTeam : 0);
                        TeleportToMultiMapSpawn(Hale, (bTenSecStart[1]) ? HaleTeam : 0);
                    }
                    else if (HaleCharge >= 0)
                    {
                        bEnableSuperDuperJump = true;
                    }
                }

                new Float:flMaxDmg = float(HaleHealthMax) * 0.05;
                if (flMaxDmg > 500.0)
                {
                    flMaxDmg = 500.0;
                }

                if (damage > flMaxDmg)
                {
                    damage = flMaxDmg;
                }
                HaleHealth -= RoundFloat(damage);
                HaleRage += RoundFloat(damage);
                if (HaleHealth <= 0) damage *= 5;
                if (HaleRage > RageDMG)
                    HaleRage = RageDMG;
                return Plugin_Changed;
            }
        }
    }
    else if (attacker == 0 && client != Hale && IsValidClient(client) && (damagetype & DMG_FALL) && (TF2_GetPlayerClass(client) == TFClass_Soldier || TF2_GetPlayerClass(client) == TFClass_DemoMan)) // IsValidClient(client, false)
    {
        new item = GetPlayerWeaponSlot(client, (TF2_GetPlayerClass(client) == TFClass_DemoMan ? TFWeaponSlot_Primary:TFWeaponSlot_Secondary));

        if (item <= 0 || !IsValidEntity(item))
        {
            damage /= 10.0;

            return Plugin_Changed;
        }
    }
    return Plugin_Continue;
}

/*
 Teleports a client to a random spawn location
 By: Chdata

 iClient - Client to teleport
 iTeam - Team of spawn points to use. If not specified or invalid team number, teleport to ANY spawn point.

 TODO: Make it not HHH specific

*/
/*stock TeleportToSpawn(iClient, iTeam = 0)
{
    new iEnt = -1;
    decl Float:vPos[3];
    decl Float:vAng[3];
    new Handle:hArray = CreateArray();
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (iTeam <= 1) // Not RED (2) nor BLu (3)
        {
            PushArrayCell(hArray, iEnt);
        }
        else
        {
            new iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
            if (iSpawnTeam == iTeam)
            {
                PushArrayCell(hArray, iEnt);
            }
        }
    }

    iEnt = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray) - 1));
    CloseHandle(hArray);

    // Technically you'll never find a map without a spawn point. Not a good map at least.
    GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
    GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
    TeleportEntity(iClient, vPos, vAng, NULL_VECTOR);

    if (Special == VSHSpecial_HHH)
    {
        AttachParticle(i, "ghost_appearation", 3.0);
        EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
    }
}*/


SpawnSmallHealthPackAt(client, ownerteam = 0)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return; // IsValidClient(client, false)
    new healthpack = CreateEntityByName("item_healthkit_small");
    decl Float:pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;
    if (IsValidEntity(healthpack))
    {
        DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
        DispatchSpawn(healthpack);
        SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
        SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
        new Float:vel[3];
        vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
        TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
//      CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
    }
}
/*public Action:Timer_RemoveCandycaneHealthPack(Handle:timer, any:ref)
{
    new entity = EntRefToEntIndex(ref);
    if (entity > MaxClients && IsValidEntity(entity))
    {
        AcceptEntityInput(entity, "Kill");
    }
}*/
public Action:Timer_StopTickle(Handle:timer, any:userid)
{
    new client = GetClientOfUserId(userid);
    if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner"))) TF2_RemoveCondition(client, TFCond_Taunting);
}
public Action:Timer_CheckBuffRage(Handle:timer, any:userid)
{
    new client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client) && IsPlayerAlive(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0);
    }
}

/*public Action:Timer_DisguiseBackstab(Handle:timer, any:userid)
{
    new client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client) && IsPlayerAlive(client)) // IsValidClient(client, false)
    {
        RandomlyDisguise(client);
    }
}
stock RandomlyDisguise(client)  //original code was mecha's, but the original code is broken and this uses a better method now.
{
    if (IsValidClient(client) && IsPlayerAlive(client))
    {
//      TF2_AddCondition(client, TFCond_Disguised, 99999.0);
        new disguisetarget = -1;
        new team = GetEntityTeamNum(client);
        new Handle:hArray = CreateArray();
        for (new clientcheck = 0; clientcheck <= MaxClients; clientcheck++)
        {
            if (IsValidClient(clientcheck) && GetEntityTeamNum(clientcheck) == team && clientcheck != client)
            {
//              new TFClassType:class = TF2_GetPlayerClass(clientcheck);
//              if (class == TFClass_Scout || class == TFClass_Medic || class == TFClass_Engineer || class == TFClass_Sniper || class == TFClass_Pyro)
                PushArrayCell(hArray, clientcheck);
            }
        }
        if (GetArraySize(hArray) <= 0) disguisetarget = client;
        else disguisetarget = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray)-1));
        if (!IsValidClient(disguisetarget)) disguisetarget = client;
//      new disguisehealth = GetRandomInt(75, 125);
        new class = GetRandomInt(0, 4);
        new TFClassType:classarray[] = { TFClass_Scout, TFClass_Pyro, TFClass_Medic, TFClass_Engineer, TFClass_Sniper };
//      new disguiseclass = classarray[class];
//      new disguiseclass = _:(disguisetarget != client ? (TF2_GetPlayerClass(disguisetarget)) : classarray[class]);
//      new weapon = GetEntPropEnt(disguisetarget, Prop_Send, "m_hActiveWeapon");
        CloseHandle(hArray);
        if (TF2_GetPlayerClass(client) == TFClass_Spy) TF2_DisguisePlayer(client, TFTeam:team, classarray[class], disguisetarget);
        else
        {
            TF2_AddCondition(client, TFCond_Disguised, -1.0);
            SetEntProp(client, Prop_Send, "m_nDisguiseTeam", team);
            SetEntProp(client, Prop_Send, "m_nDisguiseClass", classarray[class]);
            SetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex", disguisetarget);
            SetEntProp(client, Prop_Send, "m_iDisguiseHealth", 200);
        }
    }
}*/
public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
    if (!IsValidClient(client) || !g_bEnabled) return Plugin_Continue; // IsValidClient(client, false)

    // HHH can climb walls
    if (IsValidEntity(weapon) && Special == VSHSpecial_HHH && client == Hale && HHHClimbCount <= 9 && VSHRoundState > VSHRState_Waiting)
    {
        new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

        if (index == 266 && StrEqual(weaponname, "tf_weapon_sword", false))
        {
            SickleClimbWalls(client, weapon);
            WeighDownTimer = 0.0;
            HHHClimbCount++;
        }
    }

    if (client == Hale)
    {
        if (VSHRoundState != VSHRState_Active) return Plugin_Continue;
        if (TF2_IsPlayerCritBuffed(client)) return Plugin_Continue;
        if (!haleCrits)
        {
            result = false;
            return Plugin_Changed;
        }
    }
    else if (IsValidEntity(weapon))
    {
        new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
        if (index == 232 && StrEqual(weaponname, "tf_weapon_club", false))
        {
            SickleClimbWalls(client, weapon);
        }
    }
    return Plugin_Continue;
}
public Timer_NoAttacking(any:ref)
{
    new weapon = EntRefToEntIndex(ref);
    SetNextAttack(weapon, 1.56);
}
SickleClimbWalls(client, weapon)     //Credit to Mecha the Slag
{
    if (!IsValidClient(client) || (GetClientHealth(client)<=15) )return;

    decl String:classname[64];
    decl Float:vecClientEyePos[3];
    decl Float:vecClientEyeAng[3];
    GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
    GetClientEyeAngles(client, vecClientEyeAng);       // Get the angle the player is looking

    //Check for colliding entities
    TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

    if (!TR_DidHit(INVALID_HANDLE)) return;

    new TRIndex = TR_GetEntityIndex(INVALID_HANDLE);
    GetEdictClassname(TRIndex, classname, sizeof(classname));
    if (!StrEqual(classname, "worldspawn")) return;

    decl Float:fNormal[3];
    TR_GetPlaneNormal(INVALID_HANDLE, fNormal);
    GetVectorAngles(fNormal, fNormal);

    if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0) return;
    if (fNormal[0] <= -30.0) return;

    decl Float:pos[3];
    TR_GetEndPosition(pos);
    new Float:distance = GetVectorDistance(vecClientEyePos, pos);

    if (distance >= 100.0) return;

    new Float:fVelocity[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

    fVelocity[2] = 600.0;

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);

    SDKHooks_TakeDamage(client, client, client, 15.0, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));

    if (client != Hale) ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");

    RequestFrame(Timer_NoAttacking, EntIndexToEntRef(weapon));
}
public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
    return (entity != data);
}
FindNextHale(bool:array[])
{
    new tBoss = -1;
    new tBossPoints = -1073741824;
    //new bool:spec = GetConVarBool(cvarForceSpecToHale);
    for (new i = 1; i <= MaxClients; i++)
    {
        //if (IsClientInGame(i) && (GetEntityTeamNum(i) > _:TFTeam_Spectator || (spec && GetEntityTeamNum(i) != _:TFTeam_Unassigned)))   // GetEntityTeamNum(i) != _:TFTeam_Unassigned)
        if (IsClientInGame(i) && IsClientParticipating(i))
        {
            new points = GetClientQueuePoints(i);
            if (points >= tBossPoints && !array[i])
            {
                tBoss = i;
                tBossPoints = points;
            }
        }
    }
    return tBoss;
}
FindNextHaleEx()
{
    new bool:added[TF_MAX_PLAYERS];
    if (Hale >= 0) added[Hale] = true;
    return FindNextHale(added);
}
void ForceTeamWin(TFTeam team)
{
    new ent = FindEntityByClassname2(-1, "team_control_point_master");
    if (ent == -1)
    {
        ent = CreateEntityByName("team_control_point_master");
        DispatchSpawn(ent);
        AcceptEntityInput(ent, "Enable");
    }
    SetVariantInt(team);
    AcceptEntityInput(ent, "SetWinner");
}

public HintPanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (!IsValidClient(param1)) return;
    if (action == MenuAction_Select || (action == MenuAction_Cancel && param2 == MenuCancel_Exit)) VSHFlags[param1] |= VSHFLAG_CLASSHELPED;
    return;
}

public Action:HintPanel(client)
{
    if (IsVoteInProgress())
        return Plugin_Continue;
    new Handle:panel = CreatePanel();
    decl String:s[512];
    SetGlobalTransTarget(client);
    switch (Special)
    {
        case VSHSpecial_Hale:
            Format(s, 512, "%t", "vsh_help_hale");
        case VSHSpecial_Vagineer:
            Format(s, 512, "%t", "vsh_help_vagineer");
        case VSHSpecial_HHH:
            Format(s, 512, "%t", "vsh_help_hhh");
        case VSHSpecial_CBS:
            Format(s, 512, "%t", "vsh_help_cbs");
        case VSHSpecial_Bunny:
            Format(s, 512, "%t", "vsh_help_bunny");
    }
    DrawPanelText(panel, s);
    Format(s, 512, "%t", "vsh_menu_exit");
    DrawPanelItem(panel, s);
    SendPanelToClient(panel, client, HintPanelH, 9001);
    CloseHandle(panel);
    return Plugin_Continue;
}
public QueuePanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select && param2 == 10)
        TurnToZeroPanel(param1);
    return false;
}
public Action:QueuePanelCmd(client, Args)
{
    if (!IsValidClient(client)) return Plugin_Handled;
    QueuePanel(client);
    return Plugin_Handled;
}
public Action:QueuePanel(client)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Handled;
    new Handle:panel = CreatePanel();
    decl String:s[512];
    Format(s, 512, "%T", "vsh_thequeue", client);
    SetPanelTitle(panel, s);
    new bool:added[TF_MAX_PLAYERS];
    new tHale = Hale;
    if (Hale >= 0) added[Hale] = true;
    if (!g_bEnabled) DrawPanelItem(panel, "None");
    else if (IsValidClient(tHale))
    {
        Format(s, sizeof(s), "%N - %i", tHale, GetClientQueuePoints(tHale));
        DrawPanelItem(panel, s);
    }
    else DrawPanelItem(panel, "None");
    new i, pingas, bool:botadded;
    DrawPanelText(panel, "---");
    do
    {
        tHale = FindNextHale(added);
        if (IsValidClient(tHale))
        {
            if (client == tHale)
            {
                Format(s, 64, "%N - %i", tHale, GetClientQueuePoints(tHale));
                DrawPanelText(panel, s);
                i--;
            }
            else
            {
                if (IsFakeClient(tHale))
                {
                    if (botadded)
                    {
                        added[tHale] = true;
                        continue;
                    }
                    Format(s, 64, "BOT - %i", botqueuepoints);
                    botadded = true;
                }
                else Format(s, 64, "%N - %i", tHale, GetClientQueuePoints(tHale));
                DrawPanelItem(panel, s);
            }
            added[tHale]=true;
            i++;
        }
        pingas++;
    }
    while (i < 8 && pingas < 100);
    for (; i < 8; i++)
        DrawPanelItem(panel, "");
    Format(s, 64, "%T %i (%T)", "vsh_your_points", client, GetClientQueuePoints(client), "vsh_to0", client);
    DrawPanelItem(panel, s);
    SendPanelToClient(panel, client, QueuePanelH, 9001);
    CloseHandle(panel);
    return Plugin_Handled;
}
public TurnToZeroPanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select && param2 == 1)
    {
        SetClientQueuePoints(param1, 0);
        CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_to0_done");
        new cl = FindNextHaleEx();
        if (IsValidClient(cl)) SkipHalePanelNotify(cl);
    }
}
public Action:ResetQueuePointsCmd(client, args)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Handled;
    if (!IsValidClient(client))
        return Plugin_Handled;
    if (GetCmdReplySource() == SM_REPLY_TO_CHAT)
        TurnToZeroPanel(client);
    else
        TurnToZeroPanelH(INVALID_HANDLE, MenuAction_Select, client, 1);
    return Plugin_Handled;
}
public Action:TurnToZeroPanel(client)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Continue;
    new Handle:panel = CreatePanel();
    decl String:s[512];
    SetGlobalTransTarget(client);
    Format(s, 512, "%t", "vsh_to0_title");
    SetPanelTitle(panel, s);
    Format(s, 512, "%t", "Yes");
    DrawPanelItem(panel, s);
    Format(s, 512, "%t", "No");
    DrawPanelItem(panel, s);
    SendPanelToClient(panel, client, TurnToZeroPanelH, 9001);
    CloseHandle(panel);
    return Plugin_Continue;
}
bool:GetClientClasshelpinfoCookie(client)
{
    if (!IsValidClient(client)) return false;
    if (IsFakeClient(client)) return false;
    if (!AreClientCookiesCached(client)) return true;
    decl String:strCookie[MAX_DIGITS];
    GetClientCookie(client, ClasshelpinfoCookie, strCookie, sizeof(strCookie));
    if (strCookie[0] == 0) return true;
    else return bool:StringToInt(strCookie);
}
GetClientQueuePoints(client)
{
    if (!IsValidClient(client)) return 0;
    if (IsFakeClient(client))
    {
        return botqueuepoints;
    }
    if (!AreClientCookiesCached(client)) return 0;
    decl String:strPoints[MAX_DIGITS];
    GetClientCookie(client, PointCookie, strPoints, sizeof(strPoints));
    return StringToInt(strPoints);
}
SetClientQueuePoints(client, points)
{
    if (!IsValidClient(client)) return;
    if (IsFakeClient(client)) return;
    if (!AreClientCookiesCached(client)) return;
    decl String:strPoints[MAX_DIGITS];
    IntToString(points, strPoints, sizeof(strPoints));
    SetClientCookie(client, PointCookie, strPoints);
}
SetAuthIdQueuePoints(String:authid[], points)
{
    decl String:strPoints[MAX_DIGITS];
    IntToString(points, strPoints, sizeof(strPoints));
    SetAuthIdCookie(authid, PointCookie, strPoints);
}
public HalePanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 1:
                Command_GetHP(param1);
            case 2:
                HelpPanel(param1);
            case 3:
                HelpPanel2(param1);
            case 4:
                NewPanel(param1, maxversion);
            case 5:
                QueuePanel(param1);
            case 6:
                MusicTogglePanel(param1);
            case 7:
                VoiceTogglePanel(param1);
            case 8:
                ClasshelpinfoSetting(param1);
/*          case 9:
            {
                if (ACH_Enabled)
                    FakeClientCommandEx(param1, "haleach");
                else
                    return;
            }
            case 0:
            {
                if (ACH_Enabled)
                    FakeClientCommandEx(param1, "haleach_stats");
                else
                    return;
            }*/
            default: return;
        }
    }
}

public Action:HalePanel(client, args)
{
    if (!g_bAreEnoughPlayersPlaying || !client) // IsValidClient(client, false)
        return Plugin_Continue;
    new Handle:panel = CreatePanel();
    new size = 256;
    decl String:s[size];
    SetGlobalTransTarget(client);
    Format(s, size, "%t", "vsh_menu_1");
    SetPanelTitle(panel, s);
    Format(s, size, "%t", "vsh_menu_2");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_3");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_7");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_4");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_5");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_8");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_9");
    DrawPanelItem(panel, s);
    Format(s, size, "%t", "vsh_menu_9a");
    DrawPanelItem(panel, s);
/*  if (ACH_Enabled)
    {
        Format(s, size, "%t", "vsh_menu_10");
        DrawPanelItem(panel, s);
        Format(s, size, "%t", "vsh_menu_11");
        DrawPanelItem(panel, s);
    }*/
    Format(s, size, "%t", "vsh_menu_exit");
    DrawPanelItem(panel, s);
    SendPanelToClient(panel, client, HalePanelH, 9001);
    CloseHandle(panel);
    return Plugin_Handled;
}
public NewPanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 1:
            {
                if (curHelp[param1] <= 0)
                    NewPanel(param1, 0);
                else
                    NewPanel(param1, --curHelp[param1]);
            }
            case 2:
            {
                if (curHelp[param1] >= maxversion)
                    NewPanel(param1, maxversion);
                else
                    NewPanel(param1, ++curHelp[param1]);
            }
            default: return;
        }
    }
}
public Action:NewPanelCmd(client, args)
{
    if (!client) return Plugin_Handled;
    NewPanel(client, maxversion);
    return Plugin_Handled;
}
public Action:NewPanel(client, versionindex)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Continue;
    curHelp[client] = versionindex;
    new Handle:panel = CreatePanel();
    decl String:s[90];
    SetGlobalTransTarget(client);
    Format(s, 90, "=%t%s:=", "vsh_whatsnew", haleversiontitles[versionindex]);
    SetPanelTitle(panel, s);
    FindVersionData(panel, versionindex);

    if (versionindex > 0)
    {
        if (strcmp(haleversiontitles[versionindex], haleversiontitles[versionindex-1], false) == 0)
        {
            Format(s, 90, "Next Page");
        }
        else
        {
            Format(s, 90, "Older v%s", haleversiontitles[versionindex-1]);
        }
        DrawPanelItem(panel, s);
    }
    else
    {
        Format(s, 90, "%t", "vsh_noolder");
        DrawPanelItem(panel, s, ITEMDRAW_DISABLED);
    }

    if (versionindex < maxversion)
    {
        if (strcmp(haleversiontitles[versionindex], haleversiontitles[versionindex+1], false) == 0)
        {
            Format(s, 90, "Prev Page");
        }
        else
        {
            Format(s, 90, "Newer v%s", haleversiontitles[versionindex+1]);
        }
        DrawPanelItem(panel, s);
    }
    else
    {
        Format(s, 90, "%t", "vsh_nonewer");
        DrawPanelItem(panel, s, ITEMDRAW_DISABLED);
    }

    Format(s, 512, "%t", "vsh_menu_exit");
    DrawPanelItem(panel, s);

    SendPanelToClient(panel, client, NewPanelH, 9001);
    CloseHandle(panel);
    return Plugin_Continue;
}
FindVersionData(Handle:panel, versionindex)
{
    switch (versionindex) // DrawPanelText(panel, "1) .");
    {
        // Unnerfed the Easter Bunny's rage.
        case 70: //1.53
        {
            DrawPanelText(panel, "1) Ported VSH over to 1.7 syntax.(WildCard65)");
        }
        case 69: //1.52
        {
            DrawPanelText(panel, "1) Added the new festive/other weapons!");
            DrawPanelText(panel, "2) Check out v1.51 because we skipped a version!");
            DrawPanelText(panel, "3) Maps without health/ammo now randomly spawn some in spawn");
        }
        case 68: //1.51
        {
            DrawPanelText(panel, "1) Boss became Hale HUD no longer overlaps final score HUD.");
            DrawPanelText(panel, "2) Must touch ground again after market gardening (Can no longer screw HHH over).");
            DrawPanelText(panel, "3) Parachuting reduces market garden dmg by 33% and disables your parachute.");
        }
        case 67: // 1.50
        {
            DrawPanelText(panel, "1) Removed gamedata dependency.");
            DrawPanelText(panel, "2) Optimized some code.");
            DrawPanelText(panel, "3) Reserve shooter no longer Thriller taunts.");
            DrawPanelText(panel, "4) Fixed mantreads not giving increased jump height.");
            // Should be in sync with github now
            // Fixed SM1.7 compiler warning
            // FlaminSarge's timer/requestframe changes
            // Removed require_plugin around tryincluding tf2attributes
            // Changed RemoveWeaponSlot2 to RemoveWeaponSlot
        }
        case 66: //1.49
        {
            DrawPanelText(panel, "1) Updated again for the latest version of sourcemod (1.6.1 or higher)");
            DrawPanelText(panel, "2) Hopefully botkillers are fixed now?");
            DrawPanelText(panel, "3) Fixed wrong number of players displaying when control point is enabled.");
            DrawPanelText(panel, "4) Fixed festive GRU's stats and festive/bread jarate not removing rage.");
            DrawPanelText(panel, "5) Fixed issues with HHH teleporting to spawn.");
            DrawPanelText(panel, "6) Added configs/saxton_spawn_teleport.cfg");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 65: //1.48
        {
            DrawPanelText(panel, "1) Can call medic to rage.");
            DrawPanelText(panel, "2) Harder to double tap taunt and fail rage.");
            DrawPanelText(panel, "3) Cannot spam super duper jump as much when falling into pits.");
            DrawPanelText(panel, "4) Hale only takes 5% of his max health as damage while in pits, at a max of 500.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 64: //1.48
        {
            DrawPanelText(panel, "5) Blocked boss from using voice commands unless he's CBS or Bunny");
            DrawPanelText(panel, "6) HHH always teleports to spawn after falling off the map.");
            DrawPanelText(panel, "7) HHH takes 50 seconds to get his first teleport instead of 25.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 63: //1.47
        {
            DrawPanelText(panel, "1) Updated for the latest version of sourcemod (1.6.1)");
            DrawPanelText(panel, "2) Fixed final player disconnect not giving the remaining players mini/crits.");
            DrawPanelText(panel, "3) Fixed cap not starting enabled when the round starts with low enough players to enable it.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 62: //1.47
        {
            DrawPanelText(panel, "5) !haleclass as Hale now shows boss info instead of class info.");
            DrawPanelText(panel, "6) Fixed Hale's anchor to work against sentries. Crouch walking negates all knockback.");
            DrawPanelText(panel, "7) Being cloaked next to a dispenser now drains your cloak to prevent camping.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 61: //1.46
        {
            DrawPanelText(panel, "1) Fixed botkillers (thanks rswallen).");
            DrawPanelText(panel, "2) Fixed Tide Turner & Razorback not being unequipped/removed properly.");
            DrawPanelText(panel, "3) Hale can no longer pick up health packs.");
            DrawPanelText(panel, "4) Fixed maps like military area where BLU can't pick up ammo packs in the first arena round.");
            DrawPanelText(panel, "5) Fixed unbalanced team joining in the first arena round.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 60: //1.46
        {
            DrawPanelText(panel, "6) Can now type !resetq to reset your queue points.");
            DrawPanelText(panel, "7) !infotoggle can disable the !haleclass info popups on round start.");
            DrawPanelText(panel, "8) Easter Bunny has 40pct knockback resist in light of the crit eggs.");
            DrawPanelText(panel, "9) Phlog damage reduced by half when not under the effects of CritMmmph.");
            DrawPanelText(panel, "10) Quiet decloak moved from Letranger to Your Eternal Reward / Wanga Prick.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 59: //1.46
        {
            DrawPanelText(panel, "11) YER no longer disguises you.");
            DrawPanelText(panel, "12) Changed /halenew pagination a little.");
            DrawPanelText(panel, "13) Nerfed demo shield crits to minicrits. He was overpowered compared to other classes.");
            DrawPanelText(panel, "14) Added Cvar 'hale_shield_crits' to re-enable shield crits for servers balanced around taunt crits/goomba.");
            DrawPanelText(panel, "15) Added cvar 'hale_hp_display' to toggle displaying Hale's Health at all times on the hud.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 58: //1.45
        {
            DrawPanelText(panel, "1) Fixed equippable wearables (thanks fiagram & Powerlord).");
            DrawPanelText(panel, "2) Fixed flickering HUD text.");
            DrawPanelText(panel, "3) Implemented anti-suicide as Hale measures.");
            DrawPanelText(panel, "4) Hale cannot suicide until around 30 seconds have passed.");
            DrawPanelText(panel, "5) Hale can no longer switch teams to suicide.");
            DrawPanelText(panel, "6) Repositioned 'player became x boss' message off of your crosshair.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community."); // Blatant advertising
        }
        case 57: //1.45
        {
            DrawPanelText(panel, "7) Removed annoying no yes no no you're Hale next message.");
            DrawPanelText(panel, "8) Market Gardens do damage similar to backstabs.");
            DrawPanelText(panel, "9) Deadringer now displays its status.");
            DrawPanelText(panel, "10) Phlog is invulnerable during taunt activation.");
            DrawPanelText(panel, "11) Phlog Crit Mmmph duration has 75% damage resistance.");
            DrawPanelText(panel, "12) Phlog disables flaregun crits.");
            DrawPanelText(panel, "13) Fixed Bread Bite and Festive Eyelander.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 56: //1.45
        {
            DrawPanelText(panel, "14) Can now see uber meter with melee or syringe equipped.");
            DrawPanelText(panel, "15) Soda Popper & BFB replaced with scattergun.");
            DrawPanelText(panel, "16) Bonk replaced with crit-a-cola.");
            DrawPanelText(panel, "17) All 3 might be rebalanced in the future.");
            DrawPanelText(panel, "18) Reserve shooter crits in place of minicrits. Still 3 clip.");
            DrawPanelText(panel, "19) Re-enabled Darwin's Danger Shield. Overhealed sniper can tank a hit!");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 55: //1.45
        {
            DrawPanelText(panel, "20) Batt's Backup has 75% knockback resist.");
            DrawPanelText(panel, "21) Air Strike relaxed to 200 dmg per clip.");
            DrawPanelText(panel, "22) Fixed backstab rarely doing 1/3 damage glitch.");
            DrawPanelText(panel, "23) Big Earner gives full cloak on backstab.");
            DrawPanelText(panel, "24) Fixed SteamTools not changing gamedesc.");
            DrawPanelText(panel, "25) Reverted 3/5ths backstab assist for medics and fixed no assist glitch.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 54: //1.45
        {
            DrawPanelText(panel, "26) HHH can wallclimb.");
            DrawPanelText(panel, "27) HHH's weighdown timer is reset on wallclimb.");
            DrawPanelText(panel, "28) HHH now alerts their teleport target that he teleported to them.");
            DrawPanelText(panel, "29) HHH can get stuck in soldiers and scouts, but not other classes on teleport.");
            DrawPanelText(panel, "30) Can now charge super jump while holding space.");
            DrawPanelText(panel, "31) Nerfed Easter Bunny's rage eggs by 40% damage.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 53: //1.44
        {
            DrawPanelText(panel, "1) Fixed first round glich (thanks nergal).");
            DrawPanelText(panel, "2) Kunai starts at 65 HP instead of 60. Max 270 HP.");
            DrawPanelText(panel, "3) Kunai gives 180 HP on backstab instead of 100.");
            DrawPanelText(panel, "4) Demo boots now reduce fall damage like soldier boots and do stomp damage.");
            DrawPanelText(panel, "5) Fixed bushwacka disabling crits.");
            DrawPanelText(panel, "6) Air Strike gains ammo based on every 500 damage dealt.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 52: //1.44
        {
            DrawPanelText(panel, "7) Sydney Sleeper generates half the usual rage for Hale.");
            DrawPanelText(panel, "8) Other sniper rifles just do 3x damage as usual.");
            DrawPanelText(panel, "9) Huntsman gets 2x ammo, fortified compound fixed.");
            DrawPanelText(panel, "10) Festive flare gun now acts like mega-detonator.");
            DrawPanelText(panel, "11) Medic crossbow now gives 15pct uber instead of 10.");
            DrawPanelText(panel, "12) Festive crossbow is fixed to be like normal crossbow.");
            DrawPanelText(panel, "13) Medics now get 3/5 the damage of a backstab for assisting.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 51: //1.43
        {
            DrawPanelText(panel, "1) Backstab formula rebalanced to do better damage to lower HP Hales.");
            DrawPanelText(panel, "2) Damage Dealt now work properly with backstabs.");
            DrawPanelText(panel, "3) Slightly reworked Hale health formula.");
            DrawPanelText(panel, "4) (Anchor) Bosses take no pushback from damage while ducking on the ground.");
            DrawPanelText(panel, "5) Short circuit blocked until further notice.");
            DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
        }
        case 50: //1.43
        {
            DrawPanelText(panel, "6) Bushwacka blocks healing while in use.");
            DrawPanelText(panel, "7) Cannot wallclimb if your HP is low enough that it'll kill you.");
            DrawPanelText(panel, "8) Bushwacka doesn't disable crits.");
            DrawPanelText(panel, "9) 2013 festives and bread now get crits.");
            DrawPanelText(panel, "10) Fixed telefrag and mantread stomp damage.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 49: //1.43
        {
            DrawPanelText(panel, "11) L'etranger's 40% cloak is replaced with quiet decloak and -25% cloak regen rate.");
            DrawPanelText(panel, "12) Ambassador does 2.5x damage on headshots.");
            DrawPanelText(panel, "13) Diamondback gets 3 crits on backstab.");
            DrawPanelText(panel, "14) Diamondback crit shots do bonus damage similar to the Ambassador.");
            DrawPanelText(panel, "15) Manmelter always crits, while revenge crits do bonus damage.");
            DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
        }
        case 48: //142
        {
            DrawPanelText(panel, "1) Festive fixes");
            DrawPanelText(panel, "2) Hopefully fixed targes disappearing");
#if defined EASTER_BUNNY_ON
            DrawPanelText(panel, "3) Easter and April Fool's Day so close together... hmmm...");
#endif
        }
        case 47: //141
        {
            DrawPanelText(panel, "1) Fixed bosses disguising");
            DrawPanelText(panel, "2) Updated action slot whitelist");
            DrawPanelText(panel, "3) Updated sniper rifle list, Fest. Huntsman");
            DrawPanelText(panel, "4) Medigun speed works like Quick-Fix");
            DrawPanelText(panel, "5) Medigun+gunslinger vm fix");
            DrawPanelText(panel, "6) CBS gets Fest. Huntsman");
            DrawPanelText(panel, "7) Spies take more dmg while cloaked (normal watch)");
            DrawPanelText(panel, "8) Experimental backstab block animation");
        }
        case 46: //140
        {
            DrawPanelText(panel, "1) Dead Ringers have no cloak defense buff. Normal cloaks do.");
            DrawPanelText(panel, "2) Fixed Sniper Rifle reskin behavior");
            DrawPanelText(panel, "3) Boss has small amount of stun resistance after rage");
            DrawPanelText(panel, "4) Fixed HHH/CBS models");
        }
        case 45: //139c
        {
            DrawPanelText(panel, "1) Backstab disguising smoother/less obvious");
            DrawPanelText(panel, "2) Rage 'dings' dispenser/tele, to help locate Hale");
            DrawPanelText(panel, "3) Improved skip panel");
            DrawPanelText(panel, "4) Removed crits from sniper rifles, now do 2.9x damage");
            DrawPanelText(panel, "-- Sleeper does 2.4x damage, 2.9x if Hale's rage is >90pct");
            DrawPanelText(panel, "-- Bushwacka nerfs still apply");
            DrawPanelText(panel, "-- Minicrit- less damage, more knockback");
            DrawPanelText(panel, "5) Scaled sniper rifle glow time a bit better");
            DrawPanelText(panel, "6) Fixed Dead Ringer spy death icon");
        }
        case 44: //139c
        {
            DrawPanelText(panel, "7) BabyFaceBlaster will fill boost normally, but will hit 100 and drain+minicrits");
            DrawPanelText(panel, "8) Can't Eureka+destroy dispenser to insta-tele");
            DrawPanelText(panel, "9) Phlogger invuln during the taunt");
            DrawPanelText(panel, "10) Added !hale_resetq");
            DrawPanelText(panel, "11) Heatmaker gains Focus on hit (varies by charge)");
            DrawPanelText(panel, "12) Bosses get short defense buff after rage");
            DrawPanelText(panel, "13) Cozy Camper comes with SMG - 1.5s bleed, no random crit, -15% dmg");
            DrawPanelText(panel, "14) Valve buffed Crossbow. Balancing.");
            DrawPanelText(panel, "15) New cvars-hale_force_team, hale_enable_eureka");
        }
        case 43: //139c
        {
            DrawPanelText(panel, "16) Powerlord's Better Backstab Detection");
            DrawPanelText(panel, "17) Backburner has charged airblast");
            DrawPanelText(panel, "18) Skip Hale notification mixes things up");
            DrawPanelText(panel, "19) Bosses may or may not obey Pyrovision voice rules. Or both.");
        }
        case 42: //139
        {
            DrawPanelText(panel, "1) !hale_resetqueuepoints");
            DrawPanelText(panel, "-- From chat, asks for confirmation");
            DrawPanelText(panel, "-- From console, no confirmation!");
            DrawPanelText(panel, "2) Help panel stops repeatedly popping up");
            DrawPanelText(panel, "3) Medic is credited 100% of damage done during uber");
            DrawPanelText(panel, "4) Bushwacka changes:");
            DrawPanelText(panel, "-- Hit a wall to climb it");
            DrawPanelText(panel, "-- Slower fire rate");
            DrawPanelText(panel, "-- Disables crits on rifles (not Huntsman)");
            DrawPanelText(panel, "-- Effect does not occur during HHH round");
            DrawPanelText(panel, "...contd.");
        }

        case 41: //139
        {
            DrawPanelText(panel, "5) Late December increases chances of CBS appearing");
            DrawPanelText(panel, "6) If map changes mid-round, queue points not lost");
            DrawPanelText(panel, "7) Fixed HHH tele (again).");
            DrawPanelText(panel, "8) HHH tele removes Sniper Rifle glow");
            DrawPanelText(panel, "9) Mantread stomp deals 5x damage to Hale");
            DrawPanelText(panel, "10) Rage stun range- Vagineer increased, CBS decreased");
            DrawPanelText(panel, "11) Balanced CBS arrows");
            DrawPanelText(panel, "12) Minicrits will not play loud sound to all players");
            DrawPanelText(panel, "13) Dead Ringer will not be able to activate for 2s after backstab");
            DrawPanelText(panel, "-- Other spy watches can");
            DrawPanelText(panel, "14) Fixed crit issues");
            DrawPanelText(panel, "15) Hale queue now accepts negative points");
            DrawPanelText(panel, "...contd.");
        }
        case 40: //139
        {
            DrawPanelText(panel, "16) For server owners:");
            DrawPanelText(panel, "-- Translations updated");
            DrawPanelText(panel, "-- Added hale_spec_force_boss cvar");
            DrawPanelText(panel, "-- Now attempts to integrate tf2items config");
            DrawPanelText(panel, "-- With SteamTools, changes game desc");
            DrawPanelText(panel, "-- Plugin may warn if config is outdated");
            DrawPanelText(panel, "-- Jump/tele charge defines at top of code");
            DrawPanelText(panel, "17) For mapmakers:");
            DrawPanelText(panel, "-- Indicate that your map has music:");
            DrawPanelText(panel, "-- Add info_target with name 'hale_no_music'");
            DrawPanelText(panel, "18) Third Degree hit adds uber to healers");
            DrawPanelText(panel, "19) Knockback resistance on Hale/HHH");
        }
        case 39: //138
        {
            DrawPanelText(panel, "1) Bots will use rage.");
            DrawPanelText(panel, "2) Doors only forced open on specified maps");
            DrawPanelText(panel, "3) CBS spawns more during Winter holidays");
            DrawPanelText(panel, "4) Deathspam for teamswitch gone");
            DrawPanelText(panel, "5) More notice for next Hale");
            DrawPanelText(panel, "6) Wrap Assassin has 2 ammo");
            DrawPanelText(panel, "7) Holiday Punch slightly disorients Hale");
            DrawPanelText(panel, "-- If stunned Heavy punches Hale, removes stun");
            DrawPanelText(panel, "8) Mantreads increase rocketjump distance");
        }
        case 38: //138
        {
            DrawPanelText(panel, "9) Fixed CBS Huntsman rate of fire");
            DrawPanelText(panel, "10) Fixed permanent invuln Vagineer glitch");
            DrawPanelText(panel, "11) Jarate removes some Vagineer uber time and 1 CBS arrow");
            DrawPanelText(panel, "12) Low-end Medic assist damage now counted");
            DrawPanelText(panel, "13) Hitting Dead Ringers does more damage (as balancing)");
            DrawPanelText(panel, "14) Eureka Effect temporarily removed)");
            DrawPanelText(panel, "15) HHH won't get stuck in ceilings when teleporting");
            DrawPanelText(panel, "16) Further updates pending");
        }
        case 37:    //137
        {
            DrawPanelText(panel, "1) Fixed taunt/rage.");
            DrawPanelText(panel, "2) Fixed rage+high five.");
            DrawPanelText(panel, "3) hale_circuit_stun - Circuit Stun time (0 to disable)");
            DrawPanelText(panel, "4) Fixed coaching bug");
            DrawPanelText(panel, "5) Config file for map doors");
            DrawPanelText(panel, "6) Fixed floor-Hale");
            DrawPanelText(panel, "7) Fixed Circuit stun");
            DrawPanelText(panel, "8) Fixed negative health bug");
            DrawPanelText(panel, "9) hale_enabled isn't a dummy cvar anymore");
            DrawPanelText(panel, "10) hale_special cmd fixes");
        }
        case 36: //137
        {
            DrawPanelText(panel, "11) 1st-round cap enables after 1 min.");
            DrawPanelText(panel, "12) More invalid Hale checks.");
            DrawPanelText(panel, "13) Backstabs act like Razorbackstab (2s)");
            DrawPanelText(panel, "14) Fixed map check error");
            DrawPanelText(panel, "15) Wanga Prick -> Eternal Reward effect");
            DrawPanelText(panel, "16) Jarate removes 8% of Hale's rage meter");
            DrawPanelText(panel, "17) The Fan O' War removes 5% of the rage meter on hit");
            DrawPanelText(panel, "18) Removed Shortstop reload penalty");
            DrawPanelText(panel, "19) VSH_OnMusic forward");
        }
        case 35: //1369
        {
            DrawPanelText(panel, "1) Fixed spawn door blocking.");
            DrawPanelText(panel, "2) Cleaned up HUD text (health, etc).");
            DrawPanelText(panel, "3) VSH_OnDoJump now has a bool for superduper.");
            DrawPanelText(panel, "4) !halenoclass changed to !haleclassinfotoggle.");
            DrawPanelText(panel, "5) Fixed invalid clients becoming Hale");
            DrawPanelText(panel, "6) Removed teamscramble from first round.");
            DrawPanelText(panel, "7) Vagineer noises:");
            DrawPanelText(panel, "-- Nope for no");
            DrawPanelText(panel, "-- Gottam/mottag (same as jump but quieter) for Move Up");
            DrawPanelText(panel, "-- Hurr for everything else");
        }
        case 34: //1369
        {
            DrawPanelText(panel, "8) All map dispensers will be on the non-Hale team (fixes health bug)");
            DrawPanelText(panel, "9) Fixed command flags on overlay command");
            DrawPanelText(panel, "10) Fixed soldier shotgun not dealing midair minicrits.");
            DrawPanelText(panel, "11) Fixed invalid weapons on clients");
            DrawPanelText(panel, "12) Damage indicator (+spec damage indicator)");
            DrawPanelText(panel, "13) Hale speed remains during humiliation time");
            DrawPanelText(panel, "14) SuperDuperTele for HHH stuns for 4s instead of regular 2");
        }
        case 33: //1369
        {
            DrawPanelText(panel, "15) Battalion's Backup adds +10 max hp, but still only overheal to 300");
            DrawPanelText(panel, "-- Full rage meter when hit by Hale. Buff causes drastic defense boost.");
            DrawPanelText(panel, "16) Fixed a telefrag glitch");
            DrawPanelText(panel, "17) Powerjack is now +25hp on hit, heal up to +50 overheal");
            DrawPanelText(panel, "18) Backstab now shows the regular hit indicator (like other weapons do)");
            DrawPanelText(panel, "19) Kunai adds 100hp on backstab, up to 270");
            DrawPanelText(panel, "20) FaN/Scout crit knockback not nerfed to oblivion anymore");
            DrawPanelText(panel, "21) Removed Short Circuit stun (better effect being made)");
        }
        case 32: //1368
        {
            DrawPanelText(panel, "1) Now FaN and Scout crit knockback is REALLY lessened.");
            DrawPanelText(panel, "2) Medic says 'I'm charged' when he gets fully uber-charge with syringegun.");
            DrawPanelText(panel, "3) Team will scramble in 1st round, if 1st round is default arena.");
            DrawPanelText(panel, "4) Now client can disable info about changes of classes, displayed when round started.");
            DrawPanelText(panel, "5) Powerjack adds 50HPs per hit.");
            DrawPanelText(panel, "6) Short Circuit stuns Hale for 2.0 seconds.");
            DrawPanelText(panel, "7) Vagineer says \"hurr\"");
            //DrawPanelText(panel, "8) Added support of VSH achievements.");
        }
        case 31: //1367
        {
            DrawPanelText(panel, "1) Map-specific fixes:");
            DrawPanelText(panel, "-- Oilrig's pit no longer allows HHH to instatele");
            DrawPanelText(panel, "-- Arakawa's pit damage drastically lessened");
            DrawPanelText(panel, "2) General map fixes: disable spawn-blocking walls");
            DrawPanelText(panel, "3) Cap point now properly un/locks instead of fake-unlocking.");
            DrawPanelText(panel, "4) Tried fixing double-music playing.");
            DrawPanelText(panel, "5) Fixed Eternal Reward disguise glitch - edge case.");
            DrawPanelText(panel, "6) Help menus no longer glitch votes.");
        }
        case 30: //1366
        {
            DrawPanelText(panel, "1) Fixed superjump velocity code.");
            DrawPanelText(panel, "2) Fixed replaced Rocket Jumpers not minicritting Hale in midair.");
        }
        case 29: //1365
        {
            DrawPanelText(panel, "1) Half-Zatoichi is now allowed. Heal 35 health on hit, but must hit Hale to remove Honorbound.");
            DrawPanelText(panel, "-- Can add up to 25 overheal");
            DrawPanelText(panel, "-- Starts the round bloodied.");
            DrawPanelText(panel, "2) Fixed Hale not building rage when only Scouts remain.");
            DrawPanelText(panel, "3) Tried fixing Hale disconnect/nextround glitches (including music).");
            DrawPanelText(panel, "4) Candycane spawns healthpack on hit.");
        }
        case 28:    //1364
        {
            DrawPanelText(panel, "1) Added convar hale_first_round (default 0). If it's 0, first round will be default arena.");
            DrawPanelText(panel, "2) Added more translations.");
        }
        case 27:    //1363
        {
            DrawPanelText(panel, "1) Fixed a queue point exploit (VoiDeD is mean)");
            DrawPanelText(panel, "2) HHH has backstab/death sound now");
            DrawPanelText(panel, "3) First rounds are normal arena");
            DrawPanelText(panel, "-- Some weapon replacements still apply!");
            DrawPanelText(panel, "-- Teambalance is still off, too.");
            DrawPanelText(panel, "4) Fixed arena_ maps not switching teams occasionally");
            DrawPanelText(panel, "-- After 3 rounds with a team, has a chance to switch");
            DrawPanelText(panel, "-- Will add a cvar to keep Hale always blue/force team, soon");
            DrawPanelText(panel, "5) Fixed pit damage");
        }
        case 26:    //1361 and 2
        {
            DrawPanelText(panel, "1) CBS music");
            DrawPanelText(panel, "2) Soldiers minicrit Hale while he's in midair.");
            DrawPanelText(panel, "3) Direct Hit crits instead of minicrits");
            DrawPanelText(panel, "4) Reserve Shooter switches faster, +10% dmg");
            DrawPanelText(panel, "5) Added hale_stop_music cmd - admins stop music for all");
            DrawPanelText(panel, "6) FaN and Scout crit knockback is lessened");
            DrawPanelText(panel, "7) Your halemusic/halevoice settings are saved");
            DrawPanelText(panel, "1.362) Sounds aren't stupid .mdl files anymore");
            DrawPanelText(panel, "1.362) Fixed translations");
        }
        case 25:    //136
        {
            DrawPanelText(panel, "MEGA UPDATE by FlaminSarge! Check next few pages");
            DrawPanelText(panel, "SUGGEST MANNO-TECH WEAPON CHANGES");
            DrawPanelText(panel, "1) Updated CBS model");
            DrawPanelText(panel, "2) Fixed last man alive sound");
            DrawPanelText(panel, "3) Removed broken hale line, fixed one");
            DrawPanelText(panel, "4) New HHH rage sound");
            DrawPanelText(panel, "5) HHH music (/halemusic)");
            DrawPanelText(panel, "6) CBS jump noise");
            DrawPanelText(panel, "7) /halevoice and /halemusic to turn off voice/music");
            DrawPanelText(panel, "8) Updated natives/forwards (can change rage dist in fwd)");
        }
        case 24:    //136
        {
            DrawPanelText(panel, "9) hale_crits cvar to turn off hale random crits");
            DrawPanelText(panel, "10) Fixed sentries not repairing when raged");
            DrawPanelText(panel, "-- Set hale_ragesentrydamagemode 0 to force engineer to pick up sentry to repair");
            DrawPanelText(panel, "11) Now uses sourcemod autoconfig (tf/cfg/sourcemod/)");
            DrawPanelText(panel, "12) No longer requires saxton_hale_points.cfg file");
            DrawPanelText(panel, "-- Now using clientprefs for queue points");
            DrawPanelText(panel, "13) When on non-VSH map, team switch does not occur so often.");
            DrawPanelText(panel, "14) Should have full replay compatibility");
            DrawPanelText(panel, "15) Bots work with queue, are Hale less often");
        }
        case 23:    //136
        {
            DrawPanelText(panel, "16) Hale's health increased by 1 (in code)");
            DrawPanelText(panel, "17) Many many many many many fixes");
            DrawPanelText(panel, "18) Crossbow +150% damage +10 uber on hit");
            DrawPanelText(panel, "19) Syringegun has overdose speed boost");
            DrawPanelText(panel, "20) Sniper glow time scales with charge (2 to 8 seconds)");
            DrawPanelText(panel, "21) Eyelander/reskins add heads on hit");
            DrawPanelText(panel, "22) Axetinguisher/reskins use fire axe attributes");
            DrawPanelText(panel, "23) GRU/KGB is +50% speed but -7hp/s");
            DrawPanelText(panel, "24) Airblasting boss adds rage (no airblast reload though)");
            DrawPanelText(panel, "25) Airblasting uber vagineer adds time to uber and takes extra ammo");
        }
        case 22:    //136
        {
            DrawPanelText(panel, "26) Frontier Justice allowed, crits only when sentry sees Hale");
            DrawPanelText(panel, "27) Boss weighdown (look down + crouch) after 5 seconds in midair");
            DrawPanelText(panel, "28) FaN is back");
            DrawPanelText(panel, "29) Scout crits/minicrits do less knockback if not melee");
            DrawPanelText(panel, "30) Saxton has his own fists");
            DrawPanelText(panel, "31) Unlimited /halehp but after 3, longer cooldown");
            DrawPanelText(panel, "32) Fist kill icons");
            DrawPanelText(panel, "33) Fixed CBS arrow count (start at 9, but if less than 9 players, uses only that number of players)");
            DrawPanelText(panel, "34) Spy primary minicrits");
            DrawPanelText(panel, "35) Dead ringer fixed");
        }
        case 21:    //136
        {
            DrawPanelText(panel, "36) Flare gun replaced with detonator. Has large jump but more self-damage (like old detonator beta)");
            DrawPanelText(panel, "37) Eternal Reward backstab disguises as random faster classes");
            DrawPanelText(panel, "38) Kunai adds 60 health on backstab");
            DrawPanelText(panel, "39) Randomizer compatibility.");
            DrawPanelText(panel, "40) Medic uber works as normal with crits added (multiple targets, etc)");
            DrawPanelText(panel, "41) Crits stay when being healed, but adds minicrits too (for sentry, etc)");
            DrawPanelText(panel, "42) Fixed Sniper back weapon replacement");
        }
        case 20:    //136
        {
            DrawPanelText(panel, "43) Vagineer NOPE and Well Don't That Beat All!");
            DrawPanelText(panel, "44) Telefrags do 9001 damage");
            DrawPanelText(panel, "45) Speed boost when healing scouts (like Quick-Fix)");
            DrawPanelText(panel, "46) Rage builds (VERY slowly) if there are only Scouts left");
            DrawPanelText(panel, "47) Healing assist damage split between healers");
            DrawPanelText(panel, "48) Fixed backstab assist damage");
            DrawPanelText(panel, "49) Fixed HHH attacking during tele");
            DrawPanelText(panel, "50) Soldier boots - 1/10th fall damage");
            DrawPanelText(panel, "AND MORE! (I forget all of them)");
        }
        case 19:    //135_3
        {
            DrawPanelText(panel, "1)Added point system (/halenext).");
            DrawPanelText(panel, "2)Added [VSH] to VSH messages.");
            DrawPanelText(panel, "3)Removed native VSH_GetSaxtonHaleHealth() added native VSH_GetRoundState().");
            DrawPanelText(panel, "4)There is mini-crits for scout's pistols. Not full crits, like before.");
            DrawPanelText(panel, "5)Fixed issues associated with crits.");
            DrawPanelText(panel, "6)Added FORCE_GENERATION flag to stop errorlogs.");
            DrawPanelText(panel, "135_2 and 135_3)Bugfixes and updated translations.");
        }
        case 18:    //135
        {
            DrawPanelText(panel, "1)Special crits will not removed by Medic.");
            DrawPanelText(panel, "2)Sniper's glow is working again.");
            DrawPanelText(panel, "3)Less errors in console.");
            DrawPanelText(panel, "4)Less messages in chat.");
            DrawPanelText(panel, "5)Added more natives.");
            DrawPanelText(panel, "6)\"Over 9000\" sound returns! Thx you, FlaminSarge.");
            DrawPanelText(panel, "7)Hopefully no more errors in logs.");
        }
        case 17:    //134
        {
            DrawPanelText(panel, "1)Biohazard skin for CBS");
            DrawPanelText(panel, "2)TF2_IsPlayerInCondition() fixed");
            DrawPanelText(panel, "3)Now sniper rifle must be 100perc.charged to glow Hale.");
            DrawPanelText(panel, "4)Fixed Vagineer's model.");
            DrawPanelText(panel, "5)Added Natives.");
            DrawPanelText(panel, "6)Hunstman deals more damage.");
            DrawPanelText(panel, "7)Added reload time (5sec) for Pyro's airblast. ");
            DrawPanelText(panel, "1.34_1 1)Fixed airblast reload when VSH is disabled.");
            DrawPanelText(panel, "1.34_1 2)Fixed airblast reload after detonator's alt-fire.");
            DrawPanelText(panel, "1.34_1 3)Airblast reload time reduced to 3 seconds.");
            DrawPanelText(panel, "1.34_1 4)hale_special 3 is disabled.");
        }
        case 16:    //133
        {
            DrawPanelText(panel, "1)Fixed bugs, associated with Uber-update.");
            DrawPanelText(panel, "2)FaN replaced with Soda Popper.");
            DrawPanelText(panel, "3)Bazaar Bargain replaced with Sniper Rifle.");
            DrawPanelText(panel, "4)Sniper Rifle adding glow to Hale - anyone can see him for 5 seconds.");
            DrawPanelText(panel, "5)Crusader's Crossbow deals more damage.");
            DrawPanelText(panel, "6)Code optimizing.");
        }
        case 15:    //132
        {
            DrawPanelText(panel, "1)Added new Saxton's lines on...");
            DrawPanelText(panel, "  a)round start");
            DrawPanelText(panel, "  b)jump");
            DrawPanelText(panel, "  c)backstab");
            DrawPanelText(panel, "  d)destroy Sentry");
            DrawPanelText(panel, "  e)kill Scout, Pyro, Heavy, Engineer, Spy");
            DrawPanelText(panel, "  f)last man standing");
            DrawPanelText(panel, "  g)killing spree");
            DrawPanelText(panel, "2)Fixed bugged count of CBS' arrows.");
            DrawPanelText(panel, "3)Reduced Hale's damage versus DR by 20 HPs.");
            DrawPanelText(panel, "4)Now two specials can not be at a stretch.");
            DrawPanelText(panel, "v1.32_1 1)Fixed bug with replay.");
            DrawPanelText(panel, "v1.32_1 2)Fixed bug with help menu.");
        }
        case 14:    //131
            DrawPanelText(panel, "1)Now \"replay\" will not change team.");
        case 13:    //130
            DrawPanelText(panel, "1)Fixed bugs, associated with crushes, error logs, scores.");
        case 12:    //129
        {
            DrawPanelText(panel, "1)Fixed random crushes associated with CBS.");
            DrawPanelText(panel, "2)Now Hale's HP formula is ((760+x-1)*(x-1))^1.04");
            DrawPanelText(panel, "3)Added hale_special0. Use it to change next boss to Hale.");
            DrawPanelText(panel, "4)CBS has 9 arrows for bow-rage. Also he has stun rage, but on little distantion.");
            DrawPanelText(panel, "5)Teammates gets 2 scores per each 600 damage");
            DrawPanelText(panel, "6)Demoman with Targe has crits on his primary weapon.");
            DrawPanelText(panel, "7)Removed support of non-Arena maps, because nobody wasn't use it.");
            DrawPanelText(panel, "8)Pistol/Lugermorph has crits.");
        }
        case 11:    //128
        {
            DrawPanelText(panel, "VS Saxton Hale Mode is back!");
            DrawPanelText(panel, "1)Christian Brutal Sniper is a regular character.");
            DrawPanelText(panel, "2)CBS has 3 melee weapons ad bow-rage.");
            DrawPanelText(panel, "3)Added new lines for Vagineer.");
            DrawPanelText(panel, "4)Updated models of Vagineer and HHH jr.");
        }
        case 10:    //999
            DrawPanelText(panel, "Attachables are broken. Many \"thx\" to Valve.");
        case 9: //126
        {
            DrawPanelText(panel, "1)Added the second URL for auto-update.");
            DrawPanelText(panel, "2)Fixed problems, when auto-update was corrupt plugin.");
            DrawPanelText(panel, "3)Added a question for the next Hale, if he want to be him. (/haleme)");
            DrawPanelText(panel, "4)Eyelander and Half-Zatoichi was replaced with Claidheamh Mor.");
            DrawPanelText(panel, "5)Fan O'War replaced with Bat.");
            DrawPanelText(panel, "6)Dispenser and TP won't be destoyed after Engineer's death.");
            DrawPanelText(panel, "7)Mode uses the localization file.");
            DrawPanelText(panel, "8)Saxton Hale will be choosed randomly for the first 3 rounds (then by queue).");
        }
        case 8: //125
        {
            DrawPanelText(panel, "1)Fixed silent HHHjr's rage.");
            DrawPanelText(panel, "2)Now bots (sourcetv too) do not will be Hale");
            DrawPanelText(panel, "3)Fixed invalid uber on Vagineer's head.");
            DrawPanelText(panel, "4)Fixed other little bugs.");
        }
        case 7: //124
        {
            DrawPanelText(panel, "1)Fixed destroyed buildables associated with spy's fake death.");
            DrawPanelText(panel, "2)Syringe Gun replaced with Blutsauger.");
            DrawPanelText(panel, "3)Blutsauger, on hit: +5 to uber-charge.");
            DrawPanelText(panel, "4)Removed crits from Blutsauger.");
            DrawPanelText(panel, "5)CnD replaced with Invis Watch.");
            DrawPanelText(panel, "6)Fr.Justice replaced with shotgun");
            DrawPanelText(panel, "7)Fists of steel replaced with fists.");
            DrawPanelText(panel, "8)KGB replaced with GRU.");
            DrawPanelText(panel, "9)Added /haleclass.");
            DrawPanelText(panel, "10)Medic gets assist damage scores (1/2 from healing target's damage scores, 1/1 when uber-charged)");
        }
        case 6: //123
        {
            DrawPanelText(panel, "1)Added Super Duper Jump to rescue Hale from pit");
            DrawPanelText(panel, "2)Removed pyro's ammolimit");
            DrawPanelText(panel, "3)Fixed little bugs.");
        }
        case 5: //122
        {
            DrawPanelText(panel, "1.21)Point will be enabled when X or less players be alive.");
            DrawPanelText(panel, "1.22)Now it's working :) Also little optimize about player count.");
        }
        case 4: //120
        {
            DrawPanelText(panel, "1)Added new Hale's phrases.");
            DrawPanelText(panel, "2)More bugfixes.");
            DrawPanelText(panel, "3)Improved super-jump.");
        }
        case 3: //112
        {
            DrawPanelText(panel, "1)More bugfixes.");
            DrawPanelText(panel, "2)Now \"(Hale)<mapname>\" can be nominated for nextmap.");
            DrawPanelText(panel, "3)Medigun's uber gets uber and crits for Medic and his target.");
            DrawPanelText(panel, "4)Fixed infinite Specials.");
            DrawPanelText(panel, "5)And more bugfixes.");
        }
        case 2: //111
        {
            DrawPanelText(panel, "1)Fixed immortal spy");
            DrawPanelText(panel, "2)Fixed crashes associated with classlimits.");
        }
        case 1: //110
        {
            DrawPanelText(panel, "1)Not important changes on code.");
            DrawPanelText(panel, "2)Added hale_enabled convar.");
            DrawPanelText(panel, "3)Fixed bug, when all hats was removed...why?");
        }
        case 0: //100
        {
            DrawPanelText(panel, "Released!!!");
            DrawPanelText(panel, "On new version you will get info about changes.");
        }
        default:
        {
            DrawPanelText(panel, "-- Somehow you've managed to find a glitched version page!");
            DrawPanelText(panel, "-- Congratulations. Now go fight Hale.");
        }
    }
}//75% port mark
public HelpPanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        return;
    }
}
public Action:HelpPanelCmd(client, args)
{
    if (!client) return Plugin_Handled;
    HelpPanel(client);
    return Plugin_Handled;
}
public Action:HelpPanel(client)
{
    if (!g_bAreEnoughPlayersPlaying || IsVoteInProgress())
        return Plugin_Continue;
    new Handle:panel = CreatePanel();
    decl String:s[512];
    SetGlobalTransTarget(client);
    Format(s, 512, "%t", "vsh_help_mode");
    DrawPanelItem(panel, s);
    Format(s, 512, "%t", "vsh_menu_exit");
    DrawPanelItem(panel, s);
    SendPanelToClient(panel, client, HelpPanelH, 9001);
    CloseHandle(panel);
    return Plugin_Continue;
}
public Action:HelpPanel2Cmd(client, args)
{
    if (!client)
    {
        return Plugin_Handled;
    }

    if (client == Hale)
    {
        HintPanel(Hale);
    }
    else
    {
        HelpPanel2(client);
    }

    return Plugin_Handled;
}
public Action:HelpPanel2(client)
{
    if (!g_bAreEnoughPlayersPlaying || IsVoteInProgress())
        return Plugin_Continue;
    decl String:s[512];
    new TFClassType:class = TF2_GetPlayerClass(client);
    SetGlobalTransTarget(client);
    switch (class)
    {
        case TFClass_Scout:
            Format(s, 512, "%t", "vsh_help_scout");
        case TFClass_Soldier:
            Format(s, 512, "%t", "vsh_help_soldier");
        case TFClass_Pyro:
            Format(s, 512, "%t", "vsh_help_pyro");
        case TFClass_DemoMan:
            Format(s, 512, "%t", "vsh_help_demo");
        case TFClass_Heavy:
            Format(s, 512, "%t", "vsh_help_heavy");
        case TFClass_Engineer:
            Format(s, 512, "%t", "vsh_help_eggineer");
        case TFClass_Medic:
            Format(s, 512, "%t", "vsh_help_medic");
        case TFClass_Sniper:
            Format(s, 512, "%t", "vsh_help_sniper");
        case TFClass_Spy:
            Format(s, 512, "%t", "vsh_help_spie");
        default:
            Format(s, 512, "");
    }
    new Handle:panel = CreatePanel();
    if (class != TFClass_Sniper)
        Format(s, 512, "%t\n%s", "vsh_help_melee", s);
    SetPanelTitle(panel, s);
    DrawPanelItem(panel, "Exit");
    SendPanelToClient(panel, client, HintPanelH, 12);
    CloseHandle(panel);
    return Plugin_Continue;
}
public Action:ClasshelpinfoCmd(client, args)
{
    if (!client) return Plugin_Handled;
    ClasshelpinfoSetting(client);
    return Plugin_Handled;
}
public Action:ClasshelpinfoSetting(client)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Handled;
    new Handle:panel = CreatePanel();
    SetPanelTitle(panel, "Turn the VS Saxton Hale class info...");
    DrawPanelItem(panel, "On");
    DrawPanelItem(panel, "Off");
    SendPanelToClient(panel, client, ClasshelpinfoTogglePanelH, 9001);
    CloseHandle(panel);
    return Plugin_Handled;
}
public ClasshelpinfoTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (IsValidClient(param1))
    {
        if (action == MenuAction_Select)
        {
            if (param2 == 2)
                SetClientCookie(param1, ClasshelpinfoCookie, "0");
            else
                SetClientCookie(param1, ClasshelpinfoCookie, "1");
            CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_classinfo", param2 == 2 ? "off" : "on");
        }
    }
}
/*public HelpPanelH1(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        if (param2 == 1)
            HelpPanel(param1);
        else if (param2 == 2)
            return;
    }
}
public Action:HelpPanel1(client, Args)
{
    if (!g_bAreEnoughPlayersPlaying)
        return Plugin_Continue;
    new Handle:panel = CreatePanel();
    SetPanelTitle(panel, "Hale is unusually strong.\nBut he doesn't use weapons, because\nhe believes that problems should be\nsolved with bare hands.");
    DrawPanelItem(panel, "Back");
    DrawPanelItem(panel, "Exit");
    SendPanelToClient(panel, client, HelpPanelH1, 9001);
    CloseHandle(panel);
    return Plugin_Continue;
}*/
public Action:MusicTogglePanelCmd(client, args)
{
    if (!client) return Plugin_Handled;
    MusicTogglePanel(client);
    return Plugin_Handled;
}
public Action:MusicTogglePanel(client)
{
    if (!g_bAreEnoughPlayersPlaying || !client)
        return Plugin_Handled;
    new Handle:panel = CreatePanel();
    SetPanelTitle(panel, "Turn the VS Saxton Hale music...");
    DrawPanelItem(panel, "On");
    DrawPanelItem(panel, "Off");
    SendPanelToClient(panel, client, MusicTogglePanelH, 9001);
    CloseHandle(panel);
    return Plugin_Handled;
}
public MusicTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (IsValidClient(param1))
    {
        if (action == MenuAction_Select)
        {
            if (param2 == 2)
            {
                SetClientSoundOptions(param1, SOUNDEXCEPT_MUSIC, false);
                StopHaleMusic(param1);
            }
            else
                SetClientSoundOptions(param1, SOUNDEXCEPT_MUSIC, true);
            CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_music", param2 == 2 ? "off" : "on");
        }
    }
}
public Action:VoiceTogglePanelCmd(client, args)
{
    if (!client) return Plugin_Handled;
    VoiceTogglePanel(client);
    return Plugin_Handled;
}
public Action:VoiceTogglePanel(client)
{
    if (!g_bAreEnoughPlayersPlaying || !client)
        return Plugin_Handled;
    new Handle:panel = CreatePanel();
    SetPanelTitle(panel, "Turn the VS Saxton Hale voices...");
    DrawPanelItem(panel, "On");
    DrawPanelItem(panel, "Off");
    SendPanelToClient(panel, client, VoiceTogglePanelH, 9001);
    CloseHandle(panel);
    return Plugin_Handled;
}

public VoiceTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if (IsValidClient(param1))
    {
        if (action == MenuAction_Select)
        {
            if (param2 == 2)
                SetClientSoundOptions(param1, SOUNDEXCEPT_VOICE, false);
            else
                SetClientSoundOptions(param1, SOUNDEXCEPT_VOICE, true);
            CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_voice", param2 == 2 ? "off" : "on");
            if (param2 == 2) CPrintToChat(param1, "%t", "vsh_voice2");
        }
    }
}

public Action:HookSound(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
    if (!g_bEnabled || ((entity != Hale) && ((entity <= 0) || !IsValidClient(Hale) || (entity != GetPlayerWeaponSlot(Hale, 0)))))
        return Plugin_Continue;
    if (StrContains(sample, "saxton_hale", false) != -1)
        return Plugin_Continue;
    if (strcmp(sample, "vo/engineer_LaughLong01.wav", false) == 0)
    {
        strcopy(sample, PLATFORM_MAX_PATH, VagineerKSpree);
        return Plugin_Changed;
    }
    if (entity == Hale && Special == VSHSpecial_HHH && strncmp(sample, "vo", 2, false) == 0 && StrContains(sample, "halloween_boss") == -1)
    {
        if (GetRandomInt(0, 100) <= 10)
        {
            Format(sample, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, GetRandomInt(1, 4));
            return Plugin_Changed;
        }
    }
    if (Special != VSHSpecial_CBS && !strncmp(sample, "vo", 2, false) && StrContains(sample, "halloween_boss") == -1)
    {
        if (Special == VSHSpecial_Vagineer)
        {
            if (StrContains(sample, "engineer_moveup", false) != -1)
                Format(sample, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
            else if (StrContains(sample, "engineer_no", false) != -1 || GetRandomInt(0, 9) > 6)
                strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.wav");
            else
                strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.wav");
            return Plugin_Changed;
        }
        if (Special == VSHSpecial_Bunny)
        {
            if (StrContains(sample, "gibberish", false) == -1 && StrContains(sample, "burp", false) == -1 && !GetRandomInt(0, 2))
            {
                //Do sound things
                strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice)-1)]);
                return Plugin_Changed;
            }
            return Plugin_Continue;
        }
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
    if (g_bEnabled && VSHRoundState == VSHRState_Active && strcmp(classname, "tf_projectile_pipe", false) == 0)
        SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);
}
public OnEggBombSpawned(entity)
{
    new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
    if (IsValidClient(owner) && owner == Hale && Special == VSHSpecial_Bunny)
        RequestFrame(Timer_SetEggBomb, EntIndexToEntRef(entity));
}
public Timer_SetEggBomb(any:ref)
{
    new entity = EntRefToEntIndex(ref);
    if (FileExists(EggModel) && IsModelPrecached(EggModel) && IsValidEntity(entity))
    {
        new att = AttachProjectileModel(entity, EggModel);
        SetEntProp(att, Prop_Send, "m_nSkin", 0);
        SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
        SetEntityRenderColor(entity, 255, 255, 255, 0);
    }
}

//#define EF_BONEMERGE            (1 << 0)
//#define EF_BONEMERGE_FASTCULL   (1 << 7)
/*stock CreateVM(client, String:model[])
{
    new ent = CreateEntityByName("tf_wearable_vm");
    if (!IsValidEntity(ent)) return -1;
    SetEntProp(ent, Prop_Send, "m_nModelIndex", PrecacheModel(model));
    SetEntProp(ent, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL);
    SetEntProp(ent, Prop_Send, "m_iTeamNum", GetEntityTeamNum(client));
    SetEntProp(ent, Prop_Send, "m_usSolidFlags", 4);
    SetEntProp(ent, Prop_Send, "m_CollisionGroup", 11);
    DispatchSpawn(ent);
    SetVariantString("!activator");
    ActivateEntity(ent);
    TF2_EquipWearable(client, ent);
    return ent;
}*/
//Moved to tf2_stocks.inc
/*stock TF2_EquipWearable(client, entity)
{
    SDKCall(hEquipWearable, client, entity);
}*/

stock AttachProjectileModel(entity, String:strModel[], String:strAnim[] = "")
{
    if (!IsValidEntity(entity)) return -1;
    new model = CreateEntityByName("prop_dynamic");
    if (IsValidEdict(model))
    {
        decl Float:pos[3];
        decl Float:ang[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
        TeleportEntity(model, pos, ang, NULL_VECTOR);
        DispatchKeyValue(model, "model", strModel);
        DispatchSpawn(model);
        SetVariantString("!activator");
        AcceptEntityInput(model, "SetParent", entity, model, 0);
        if (strAnim[0] != '\0')
        {
            SetVariantString(strAnim);
            AcceptEntityInput(model, "SetDefaultAnimation");
            SetVariantString(strAnim);
            AcceptEntityInput(model, "SetAnimation");
        }
        SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
        return model;
    } else {
        LogError("(AttachProjectileModel): Could not create prop_dynamic");
    }
    return -1;
}

public Native_IsVSHMap(Handle:plugin, numParams)
{
    return IsSaxtonHaleMap();
/*  new result = IsSaxtonHaleMap();
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnIsVSHMap);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;*/
}
/*
public Native_IsEnabled(Handle:plugin, numParams)
{
    new result = g_bEnabled;
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnIsEnabled);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;
}

public Native_GetHale(Handle:plugin, numParams)
{
    new result = -1;
    if (IsValidClient(Hale))
        result = GetClientUserId(Hale);
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetHale);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;

}

public Native_GetTeam(Handle:plugin, numParams)
{
    new result = HaleTeam;
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetTeam);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;
}

public Native_GetSpecial(Handle:plugin, numParams)
{
    new result = Special;
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetSpecial);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;
}

public Native_GetHealth(Handle:plugin, numParams)
{
    new result = HaleHealth;
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetHealth);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;

    return result;
}

public Native_GetHealthMax(Handle:plugin, numParams)
{
    new result = HaleHealthMax;
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetHealthMax);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;
}

public Native_GetRoundState(Handle:plugin, numParams)
{
    new result = VSHRoundState;
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetRoundState);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;
}
public Native_GetDamage(Handle:plugin, numParams)
{
    new client = GetNativeCell(1);
    new result = 0;
    if (IsValidClient(client))
        result = Damage[client];
    new result2 = result;

    new Action:act = Plugin_Continue;
    Call_StartForward(OnGetDamage);
    Call_PushCell(client);
    Call_PushCellRef(result2);
    Call_Finish(act);
    if (act == Plugin_Changed)
        result = result2;
    return result;
}*/

public Native_IsEnabled(Handle:plugin, numParams)
{
    return g_bEnabled;
}
public Native_GetHale(Handle:plugin, numParams)
{
    if (IsValidClient(Hale))
        return GetClientUserId(Hale);
    return -1;
}
public Native_GetTeam(Handle:plugin, numParams)
{
    return HaleTeam;
}
public Native_GetSpecial(Handle:plugin, numParams)
{
    return Special;
}
public Native_GetHealth(Handle:plugin, numParams)
{
    return HaleHealth;
}
public Native_GetHealthMax(Handle:plugin, numParams)
{
    return HaleHealthMax;
}
public Native_GetRoundState(Handle:plugin, numParams)
{
    return VSHRoundState;
}
public Native_GetDamage(Handle:plugin, numParams)
{
    new client = GetNativeCell(1);
    if (!IsValidClient(client))
        return 0;
    return Damage[client];
}

// Chdata's plugin reload command
public Action:Debug_ReloadVSH(iClient, iArgc)
{
    g_bReloadVSHOnRoundEnd = true;
    switch (VSHRoundState)
    {
        case VSHRState_End, VSHRState_Disabled:
        {
            CReplyToCommand(iClient, "{olive}[VSH]{default} The plugin has been reloaded.");
            SetClientQueuePoints(Hale, 0);
            ServerCommand("sm plugins reload saxtonhale");
        }
        default:
        {
            CReplyToCommand(iClient, "{olive}[VSH]{default} The plugin is set to reload.");
            SetClientQueuePoints(Hale, 0);
        }
    }
    return Plugin_Handled;
}


/*
    chdata.inc

    AKA, stuff that could be useful in any plugin / are not specific to VSH
*/

// True if they weren't in the condition and were set to it.
stock bool:InsertCond(iClient, TFCond:iCond, Float:flDuration = TFCondDuration_Infinite)
{
    if (!TF2_IsPlayerInCondition(iClient, iCond))
    {
        TF2_AddCondition(iClient, iCond, flDuration);
        return true;
    }
    return false;
}

// True if the condition was removed.
stock bool:RemoveCond(iClient, TFCond:iCond)
{
    if (TF2_IsPlayerInCondition(iClient, iCond))
    {
        TF2_RemoveCondition(iClient, iCond);
        return true;
    }
    return false;
}

// true if removed, false if not found / etc
stock bool:RemoveDemoShield(iClient)
{
    new iEnt = MaxClients + 1;
    while ((iEnt = FindEntityByClassname2(iEnt, "tf_wearable_demoshield")) != -1)
    {
        if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == iClient && !GetEntProp(iEnt, Prop_Send, "m_bDisguiseWearable"))
        {
            TF2_RemoveWearable(iClient, iEnt);
            return true;
        }
    }
    return false;
}

// Returns true if at least one was removed
stock bool:RemovePlayerBack(client, indices[], len)
{
    if (len <= 0)
    {
        return false;
    }

    new bool:bReturn = false;

    new edict = MaxClients + 1;

    while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
    {
        decl String:netclass[32];

        if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
        {
            new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");

            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (new i = 0; i < len; i++)
                {
                    if (idx == indices[i])
                    {
                        TF2_RemoveWearable(client, edict);
                        bReturn = true;
                    }
                }
            }
        }
    }

    edict = MaxClients + 1;

    while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
    {
        decl String:netclass[32];

        if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
        {
            new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");

            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (new i = 0; i < len; i++)
                {
                    if (idx == indices[i])
                    {
                        TF2_RemoveWearable(client, edict);
                        bReturn = true;
                        //AcceptEntityInput(edict, "Kill");
                    }
                }
            }
        }
    }

    return bReturn;
}

// Returns entity index as soon as any one is found, -1 if none found
stock FindPlayerBack(client, indices[], len)
{
    if (len <= 0)
    {
        return -1;
    }

    new edict = MaxClients + 1;

    while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
    {
        decl String:netclass[32];

        if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
        {
            new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");

            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (new i = 0; i < len; i++)
                {
                    if (idx == indices[i])
                    {
                        return edict;
                    }
                }
            }
        }
    }

    edict = MaxClients + 1;

    while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
    {
        decl String:netclass[32];

        if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
        {
            new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");

            if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
            {
                for (new i = 0; i < len; i++)
                {
                    if (idx == indices[i])
                    {
                        return edict;
                    }
                }
            }
        }
    }

    return -1;
}

enum m_flNext
{
    m_flNextUnusedFeature = 0
}

enum m_flNext2
{
    m_flNextEndPriority = 0
}

static Float:g_flNext[m_flNext];
static Float:g_flNext2[m_flNext][TF_MAX_PLAYERS];

stock bool:IsNextTime(iIndex, Float:flAdditional = 0.0)
{
    return (GetEngineTime() >= g_flNext[iIndex]+flAdditional);
}

stock IncNextTime(iIndex, Float:flSeconds)
{
    g_flNext[iIndex] = GetEngineTime() + flSeconds;
}

stock SetNextTime(iIndex, Float:flTime)
{
    g_flNext[iIndex] = flTime;
}

stock GetNextTime(iIndex)
{
    return g_flNext[iIndex];
}

stock Float:GetTimeTilNextTime(iIndex, bool:bNonNegative = true)
{
    return bNonNegative ? fmax(g_flNext[iIndex] - GetEngineTime(), 0.0) : (g_flNext[iIndex] - GetEngineTime());
}

/*
    If next time occurs, we also add time on for when it is next allowed.
*/
stock bool:IfDoNextTime(iIndex, Float:flThenAdd)
{
    if (IsNextTime(iIndex))
    {
        IncNextTime(iIndex, flThenAdd);
        return true;
    }
    return false;
}

// Start of plural NextTime versions

stock bool:IsNextTime2(iClient, iIndex, Float:flAdditional = 0.0)
{
    return (GetEngineTime() >= g_flNext2[iIndex][iClient]+flAdditional);
}

stock IncNextTime2(iClient, iIndex, Float:flSeconds)
{
    g_flNext2[iIndex][iClient] = GetEngineTime() + flSeconds;
}

stock SetNextTime2(iClient, iIndex, Float:flTime)
{
    g_flNext2[iIndex][iClient] = flTime;
}

stock GetNextTime2(iClient, iIndex)
{
    return g_flNext2[iIndex][iClient];
}

/*
    If next time occurs, we also add time on for when it is next allowed.
*/
stock bool:IfDoNextTime2(iClient, iIndex, Float:flThenAdd)
{
    if (IsNextTime2(iClient, iIndex))
    {
        IncNextTime2(iClient, iIndex, flThenAdd);
        return true;
    }
    return false;
}

/*
    PriorityCenterText (Version 0x05)

    Only one message can be shown in center text at a time.
    These stocks allow that space to be given different priority levels that prevent new messages from overwriting what's there.

    By: Chdata

*/
static s_iLastPriority[TF_MAX_PLAYERS] = {MIN_INT,...};
//static Handle:s_hPCTTimer[TF_MAX_PLAYERS] = {INVALID_HANDLE,...};

/*
    An example of how to use this:

    PriorityCenterText(iClient, GetClientImmunityLevel(iClient), "My message's priority depends on my immunity level.");

    IF old priority == new priority THEN old message is overwritten by new message.

*/
stock PriorityCenterText(iClient, iPriority = MIN_INT, const String:szFormat[], any:...)
{
    if (!IsValidClient(iClient))
    {
        ThrowError("Client index %i is invalid or not in game.", iClient);
    }

    if (s_iLastPriority[iClient] > iPriority)
    {
        if (IsNextTime2(iClient, m_flNextEndPriority))
        {
            s_iLastPriority[iClient] = MIN_INT;
        }
        else
        {
            return;
        }
    }

    if (iPriority > s_iLastPriority[iClient])
    {
        IncNextTime2(iClient, m_flNextEndPriority, 5.0);
        s_iLastPriority[iClient] = iPriority;
    }

    decl String:szBuffer[MAX_CENTER_TEXT];
    SetGlobalTransTarget(iClient);
    VFormat(szBuffer, sizeof(szBuffer), szFormat, 4);
    PrintCenterText(iClient, "%s", szBuffer);
}

/*
    Send priority center text to everyone.
    This will obey priority sent to via PriorityCenterText() and not overwrite if it's lower priority
*/
stock PriorityCenterTextAll(iPriority = MIN_INT, const String:szFormat[], any:...)
{
    decl String:szBuffer[MAX_CENTER_TEXT];

    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            SetGlobalTransTarget(i);
            VFormat(szBuffer, sizeof(szBuffer), szFormat, 3);
            PriorityCenterText(i, iPriority, "%s", szBuffer);
        }
    }
}

/*
    Send priority center text to everyone.
    This version bypasses the priority in PriorityCenterText() with its own internal counter.

    This version will ALWAYS have higher priority than the functions above, so long as it has higher priority than 'itself'

    The priority of all players will be completely maxed out to achieve this.
*/
stock PriorityCenterTextAllEx(iPriority = -2147483647, const String:szFormat[], any:...) // -2147483647 == MIN_INT+1
{
    if (iPriority == MIN_INT)
    {
        iPriority++;
    }

    if (s_iLastPriority[0] > iPriority)
    {
        if (IsNextTime2(0, m_flNextEndPriority))
        {
            s_iLastPriority[0] = MIN_INT;

            for (new i = 1; i <= MaxClients; i++)
            {
                s_iLastPriority[i] = MIN_INT;
            }
        }
        else
        {
            return;
        }
    }

    if (iPriority > s_iLastPriority[0])
    {
        IncNextTime2(0, m_flNextEndPriority, 5.0);

        s_iLastPriority[0] = iPriority;

        for (new i = 1; i <= MaxClients; i++)
        {
            s_iLastPriority[i] = MAX_INT;
        }
    }

    decl String:szBuffer[MAX_CENTER_TEXT];

    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            SetGlobalTransTarget(i);
            VFormat(szBuffer, sizeof(szBuffer), szFormat, 3);
            PrintCenterText(i, "%s", szBuffer);
        }
    }
}

/*
    Returns true if the current date is within bounds.

    Omit StartDay = Check if month matches

    If end values are ommited, it'll go from the start date to the end of the month.

    OnMapStart,
    IsDate(.bForceRecalc = true);
    to recalculate the date

    IsDate(Month_Mar, 25, Month_Apr, 20) == IsEasterHoliday()
    IsDate(Month_Oct, 15) == IsHalloweenHoliday()
    IsDate(Month_Dec, 15) == IsDecemberHoliday()

*/
stock bool:IsDate(StartMonth = Month_None, StartDay = 0, EndMonth = Month_None, EndDay = 0, bool:bForceRecalc = false)
{
    static iMonth;
    static iDate;
    static bool:bFound = false;

    if (bForceRecalc)
    {
        bFound = false;
        iMonth = 0;
        iDate = 0;
    }

    if (!bFound)
    {
        new iTimeStamp = GetTime();
        decl String:szMonth[MAX_DIGITS], String:szDate[MAX_DIGITS];

        FormatTime(szMonth, sizeof(szMonth), "%m", iTimeStamp);
        FormatTime(szDate, sizeof(szDate),   "%d", iTimeStamp);

        iMonth = StringToInt(szMonth);
        iDate = StringToInt(szDate);
        bFound = true;
    }

    return (StartMonth == iMonth && StartDay <= iDate) || (EndMonth && EndDay && (StartMonth < iMonth && iMonth <= EndMonth) && (iDate <= EndDay));
}

stock SetArenaCapEnableTime(Float:time)
{
    new ent = -1;
    decl String:strTime[32];
    FloatToString(time, strTime, sizeof(strTime));
    if ((ent = FindEntityByClassname2(-1, "tf_logic_arena")) != -1 && IsValidEdict(ent))
    {
        DispatchKeyValue(ent, "CapEnableDelay", strTime);
    }
}

stock bool:IsNearSpencer(client)
{
    new bool:dispenserheal, medics = 0;
    new healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
    if (healers > 0)
    {
        for (new i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client)
                medics++;
        }
    }
    dispenserheal = (healers > medics) ? true : false;
    return dispenserheal;
}

stock FindSentry(client)
{
    new i=-1;
    while ((i = FindEntityByClassname2(i, "obj_sentrygun")) != -1)
    {
        if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client) return i;
    }
    return -1;
}

stock GetIndexOfWeaponSlot(client, slot)
{
    new weapon = GetPlayerWeaponSlot(client, slot);
    return (weapon > MaxClients && IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
}

stock GetClientCloakIndex(iClient)
{
    return GetWeaponIndex(GetPlayerWeaponSlot(iClient, TFWeaponSlot_Watch));
}

stock GetWeaponIndex(iWeapon)
{
    return IsValidEnt(iWeapon) ? GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex"):-1;
}

stock bool:IsValidEnt(iEnt)
{
    return iEnt > MaxClients && IsValidEntity(iEnt);
}

/*stock GetClientCloakIndex(client)
{
    if (!IsValidClient(client, false)) return -1; // IsValidClient(client, false)
    new wep = GetPlayerWeaponSlot(client, 4);
    if (!IsValidEntity(wep)) return -1;
    new String:classname[64];
    GetEntityClassname(wep, classname, sizeof(classname));
    if (strncmp(classname, "tf_wea", 6, false) != 0) return -1;
    return GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
}*/

stock IncrementHeadCount(iClient)
{
    InsertCond(iClient, TFCond_DemoBuff);
    SetEntProp(iClient, Prop_Send, "m_iDecapitations", GetEntProp(iClient, Prop_Send, "m_iDecapitations") + 1);
    AddPlayerHealth(iClient, 15, 300, true);             //  The old version of this allowed infinite health gain... so ;v
    TF2_AddCondition(iClient, TFCond_SpeedBuffAlly, 0.01);  //  Recalculate their speed
}

stock SwitchToOtherWeapon(client)
{
    new ammo = GetAmmo(client, 0);
    new weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
    new clip = (IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iClip1") : -1);
    if (!(ammo == 0 && clip <= 0)) SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
    else SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary));
}

stock FindTeleOwner(client)
{
    if (!IsValidClient(client)) return -1;
    if (!IsPlayerAlive(client)) return -1;
    new tele = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
    decl String:classname[32];
    if (IsValidEntity(tele) && GetEdictClassname(tele, classname, sizeof(classname)) && strcmp(classname, "obj_teleporter", false) == 0)
    {
        new owner = GetEntPropEnt(tele, Prop_Send, "m_hBuilder");
        if (IsValidClient(owner)) return owner; // IsValidClient(owner, false)
    }
    return -1;
}

stock TF2_IsPlayerCritBuffed(client)
{
    return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
            || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
            || TF2_IsPlayerInCondition(client, TFCond:34)
            || TF2_IsPlayerInCondition(client, TFCond:35)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
            || TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
            );
}

stock SetNextAttack(weapon, Float:duration = 0.0)
{
    if (weapon <= MaxClients) return;
    if (!IsValidEntity(weapon)) return;
    new Float:next = GetGameTime() + duration;
    SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
    SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}

#if defined _tf2items_included
stock SpawnWeapon(client, String:name[], index, level, qual, String:att[])
{
    new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
    if (hWeapon == INVALID_HANDLE)
        return -1;
    TF2Items_SetClassname(hWeapon, name);
    TF2Items_SetItemIndex(hWeapon, index);
    TF2Items_SetLevel(hWeapon, level);
    TF2Items_SetQuality(hWeapon, qual);
    new String:atts[32][32];
    new count = ExplodeString(att, " ; ", atts, 32, 32);
    if (count > 1)
    {
        TF2Items_SetNumAttributes(hWeapon, count/2);
        new i2 = 0;
        for (new i = 0; i < count; i += 2)
        {
            TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
            i2++;
        }
    }
    else
        TF2Items_SetNumAttributes(hWeapon, 0);

    new entity = TF2Items_GiveNamedItem(client, hWeapon);
    CloseHandle(hWeapon);
    EquipPlayerWeapon(client, entity);
    return entity;
}
#endif


stock SetAmmo(client, wepslot, newAmmo)
{
    new weapon = GetPlayerWeaponSlot(client, wepslot);
    if (!IsValidEntity(weapon)) return;
    new type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (type < 0 || type > 31) return;
    SetEntProp(client, Prop_Send, "m_iAmmo", newAmmo, _, type);
}

stock GetAmmo(client, wepslot)
{
    if (!IsValidClient(client)) return 0;
    new weapon = GetPlayerWeaponSlot(client, wepslot);
    if (!IsValidEntity(weapon)) return 0;
    new type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (type < 0 || type > 31) return 0;
    return GetEntProp(client, Prop_Send, "m_iAmmo", _, type);
}

stock TF2_GetMetal(client)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return 0;
    return GetEntProp(client, Prop_Send, "m_iAmmo", _, 3);
}

stock TF2_SetMetal(client, metal)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
    SetEntProp(client, Prop_Send, "m_iAmmo", metal, _, 3);
}

stock GetHealingTarget(client)
{
    new String:s[64];
    new medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
    if (medigun <= MaxClients || !IsValidEdict(medigun))
        return -1;
    GetEdictClassname(medigun, s, sizeof(s));
    if (strcmp(s, "tf_weapon_medigun", false) == 0)
    {
        if (GetEntProp(medigun, Prop_Send, "m_bHealing"))
            return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
    }
    return -1;
}

/*stock bool:IsValidClient(client, bool:replaycheck = true)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
    if (replaycheck)
    {
        if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
    }
    return true;
}*/

stock FindEntityByClassname2(startEnt, const String:classname[])
{
    /* If startEnt isn't valid shifting it back to the nearest valid one */
    while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
    return FindEntityByClassname(startEnt, classname);
}

/*
    @summary
        Changes a living player's team without killing/moving them
        I think it respawns them at spawn though.

    @params
        iClient should be validated before using this
        iTeam should be either 2 or 3

    @return
        false if not changed
        true if changed

        TODO: -1 not changed, 0 if changed with no respawn, 1 if changed with respawn

*/
stock void ChangeTeam(int iClient, TFTeam iTeam) // iTeam should never be less than 2
{
    int iOldTeam = GetEntityTeamNum(iClient);
    if (iOldTeam != view_as<int>(iTeam) && iOldTeam >= view_as<int>(TFTeam_Red))
    {
        SetEntProp(iClient, Prop_Send, "m_lifeState", LifeState_Dead);
        TF2_ChangeClientTeam(iClient, iTeam);
        SetEntProp(iClient, Prop_Send, "m_lifeState", LifeState_Alive);
        TF2_RespawnPlayer(iClient);
    }
}

stock any:min(any:a,any:b) { return (a < b) ? a : b; }

/*
    Player health adder
    By: Chdata
*/
stock AddPlayerHealth(iClient, iAdd, iOverheal = 0, bStaticMax = false)
{
    new iHealth = GetClientHealth(iClient);
    new iNewHealth = iHealth + iAdd;
    new iMax = bStaticMax ? iOverheal : GetEntProp(iClient, Prop_Data, "m_iMaxHealth") + iOverheal;
    if (iHealth < iMax)
    {
        iNewHealth = min(iNewHealth, iMax);
        SetEntityHealth(iClient, iNewHealth);
    }
}

stock PrepareSound(const String:szSoundPath[])
{
    PrecacheSound(szSoundPath, true);
    decl String:s[PLATFORM_MAX_PATH];
    Format(s, sizeof(s), "sound/%s", szSoundPath);
    AddFileToDownloadsTable(s);
}

stock DownloadSoundList(const String:szFileList[][], iSize)
{
    for (new i = 0; i < iSize; i++)
    {
        PrepareSound(szFileList[i]);
    }
}

stock PrecacheSoundList(const String:szFileList[][], iSize)
{
    for (new i = 0; i < iSize; i++)
    {
        PrecacheSound(szFileList[i], true);
    }
}

// Adds both a .vmt and .vtf to downloads - must exclude extension
stock PrepareMaterial(const String:szMaterialPath[])
{
    decl String:s[PLATFORM_MAX_PATH];
    Format(s, sizeof(s), "%s%s", szMaterialPath, ".vtf");
    AddFileToDownloadsTable(s);
    Format(s, sizeof(s), "%s%s", szMaterialPath, ".vmt");
    AddFileToDownloadsTable(s);
}

stock DownloadMaterialList(const String:szFileList[][], iSize)
{
    decl String:s[PLATFORM_MAX_PATH];
    for (new i = 0; i < iSize; i++)
    {
        strcopy(s, sizeof(s), szFileList[i]);
        AddFileToDownloadsTable(s); // if (FileExists(s, true))
    }
}

stock PrepareModel(const String:szModelPath[], bool:bMdlOnly = false)
{
    decl String:szBase[PLATFORM_MAX_PATH];
    decl String:szPath[PLATFORM_MAX_PATH];
    strcopy(szBase, sizeof(szBase), szModelPath);
    SplitString(szBase, ".mdl", szBase, sizeof(szBase));

    if (!bMdlOnly)
    {
        Format(szPath, sizeof(szPath), "%s.phy", szBase);
        if (FileExists(szPath))
        {
            AddFileToDownloadsTable(szPath);
        }

        Format(szPath, sizeof(szPath), "%s.sw.vtx", szBase);
        if (FileExists(szPath))
        {
            AddFileToDownloadsTable(szPath);
        }

        Format(szPath, sizeof(szPath), "%s.vvd", szBase);
        if (FileExists(szPath))
        {
            AddFileToDownloadsTable(szPath);
        }

        Format(szPath, sizeof(szPath), "%s.dx80.vtx", szBase);
        if (FileExists(szPath))
        {
            AddFileToDownloadsTable(szPath);
        }

        Format(szPath, sizeof(szPath), "%s.dx90.vtx", szBase);
        if (FileExists(szPath))
        {
            AddFileToDownloadsTable(szPath);
        }
    }

    AddFileToDownloadsTable(szModelPath);

    return PrecacheModel(szModelPath, true);
}

/*
    Returns the the TeamNum of an entity.
    Works for both clients and things like healthpacks.
    Returns -1 if the entity doesn't have the m_iTeamNum prop.

    GetEntityTeamNum() doesn't always return properly when tf_arena_use_queue is set to 0
*/
stock TFTeam GetEntityTeamNum(int iEnt)
{
    // if (GetEntSendPropOffs(iEnt, "m_iTeamNum") <= 0)
    // {
    //     return -1;
    // }
    return view_as<TFTeam>(GetEntProp(iEnt, Prop_Send, "m_iTeamNum"));
}

// TODO: Implement this stuff

/*
    Common check that says whether or not a client index is occupied.
*/
stock bool:IsValidClient(iClient)
{
    return (0 < iClient && iClient <= MaxClients && IsClientInGame(iClient));
}

/*
    Common checks that says "this player can safely be selected from a queue of players"
*/
stock bool:IsClientParticipating(iClient)
{
    if (IsSpectator(iClient) || IsReplayClient(iClient))
    {
        return false;
    }

    if (bool:GetEntProp(iClient, Prop_Send, "m_bIsCoaching"))
    {
        return false;
    }

    if (TF2_GetPlayerClass(iClient) == TFClass_Unknown)
    {
        return false;
    }

    return true;
}

stock bool IsSpectator(int iClient)
{
    return GetEntityTeamNum(iClient) <= TFTeam_Spectator;
}

stock bool IsReplayClient(int iClient)
{
    return IsClientReplay(iClient) || IsClientSourceTV(iClient);
}

/*
    Returns the number of times any team has won a round.
*/
stock int TF2_GetRoundWinCount()
{
    return GetTeamScore(view_as<int>(TFTeam_Red)) + GetTeamScore(view_as<int>(TFTeam_Blue));
}

stock ClearTimer(&Handle:hTimer)
{
    if (hTimer != INVALID_HANDLE)
    {
        KillTimer(hTimer);
        hTimer = INVALID_HANDLE;
    }
}

/*
    TeleportToMultiMapSpawn()

    [X][2]
       [0] = RED spawnpoint entref
       [1] = BLU spawnpoint entref
*/
static Handle:s_hSpawnArray = INVALID_HANDLE;

stock OnPluginStart_TeleportToMultiMapSpawn()
{
    s_hSpawnArray = CreateArray(2);
}

stock teamplay_round_start_TeleportToMultiMapSpawn()
{
    ClearArray(s_hSpawnArray);

    new iInt = 0;
    new iSkip[TF_MAX_PLAYERS] = {0,...};

    new iEnt = MaxClients + 1;
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        // if (FindValueInArrayAnyEx(s_hSpawnArray, iEnt) != -1) // If already in the array, don't add it again
        // {
        //     //CPrintToChdata("not added spawn %i", iEnt);
        //     continue;
        // }

        new iTeam = GetEntityTeamNum(iEnt);
        new iClient = GetClosestPlayerTo(iEnt, iTeam);

        if (iClient)
        {
            new bool:bSkip = false;
            for (new i = 0; i < TF_MAX_PLAYERS; i++)
            {
                if (iSkip[i] == iClient)
                {
                    bSkip = true;
                    break;
                }
            }
            if (bSkip)
            {
                continue;
            }
            iSkip[iInt++] = iClient;
            new iIndex = PushArrayCell(s_hSpawnArray, EntIndexToEntRef(iEnt));
            SetArrayCell(s_hSpawnArray, iIndex, iTeam, 1);       // Opposite team becomes an invalid ent
            //CPrintToChdata("spawn %i near %N added to team %i", iEnt, iClient, iTeam);
        }
    }
}

/*
    Teleports a client to spawn, but only if it's a spawn that someone spawned in at the start of the round.

    Useful for multi-stage maps like vsh_megaman
*/
stock TeleportToMultiMapSpawn(iClient, iTeam = 0)
{
    decl iSpawn, iTeleTeam, iIndex;
    if (iTeam <= 1)
    {
        iSpawn = EntRefToEntIndex(GetRandBlockCellEx(s_hSpawnArray));
    }
    else
    {
        do
        {
            iTeleTeam = GetRandBlockCell(s_hSpawnArray, iIndex, 1);
        }
        while (iTeleTeam != iTeam);

        iSpawn = EntRefToEntIndex(GetArrayCell(s_hSpawnArray, iIndex, 0));
    }
    TeleMeToYou(iClient, iSpawn);
    return iSpawn;
}

/*
    Returns 0 if no client was found.
*/
stock GetClosestPlayerTo(iEnt, iTeam = 0)
{
    new iBest;
    decl Float:flDist, Float:flTemp;
    decl Float:vLoc[3], Float:vPos[3];
    GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vLoc);
    for(new iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
        {
            if (iTeam && GetEntityTeamNum(iClient) != iTeam)
            {
                continue;
            }

            GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", vPos);
            flTemp = GetVectorDistance(vLoc, vPos);
            if (!iBest || flTemp < flDist)
            {
                flDist = flTemp;
                iBest = iClient;
            }
        }
    }
    return iBest;
}

/*
    Teleports one entity to another.
    Doesn't necessarily have to be players.

    Returns true if a player teleported to a ducking player
*/
stock bool:TeleMeToYou(iMe, iYou, bool:bAngles = false)
{
    decl Float:vPos[3], Float:vAng[3];
    GetEntPropVector(iYou, Prop_Send, "m_vecOrigin", vPos);

    if (bAngles)
    {
        GetEntPropVector(iYou, Prop_Send, "m_angRotation", vAng);
    }

    new bool:bDucked = false;

    if (IsValidClient(iMe) && IsValidClient(iYou) && GetEntProp(iYou, Prop_Send, "m_bDucked"))
    {
        decl Float:vCollisionVec[3];
        vCollisionVec[0] = 24.0;
        vCollisionVec[1] = 24.0;
        vCollisionVec[2] = 62.0;
        SetEntPropVector(iMe, Prop_Send, "m_vecMaxs", vCollisionVec);
        SetEntProp(iMe, Prop_Send, "m_bDucked", 1);
        SetEntityFlags(iMe, GetEntityFlags(iMe) | FL_DUCKING);
        bDucked = true;
    }

    TeleportEntity(iMe, vPos, bAngles ? vAng : NULL_VECTOR, NULL_VECTOR);

    return bDucked;
}

stock GetRandBlockCell(Handle:hArray, &iSaveIndex, iBlock = 0, bool:bAsChar = false, iDefault = 0)
{
    new iSize = GetArraySize(hArray);
    if (iSize > 0)
    {
        iSaveIndex = GetRandomInt(0, iSize - 1);
        return GetArrayCell(hArray, iSaveIndex, iBlock, bAsChar);
    }
    iSaveIndex = -1;
    return iDefault;
}

// Get a random value while ignoring the save index.
stock GetRandBlockCellEx(Handle:hArray, iBlock = 0, bool:bAsChar = false, iDefault = 0)
{
    decl iIndex;
    return GetRandBlockCell(hArray, iIndex, iBlock, bAsChar, iDefault);
}

/*
    Chdata's reworked attachparticle
*/
stock AttachParticle(iEnt, const String:szParticleType[], Float:flTimeToDie = -1.0, Float:vOffsets[3] = {0.0,0.0,0.0}, bool:bAttach = false, Float:flTimeToStart = -1.0)
{
    new iParti = CreateEntityByName("info_particle_system");
    if (IsValidEntity(iParti))
    {
        decl Float:vPos[3];
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        AddVectors(vPos, vOffsets, vPos);
        TeleportEntity(iParti, vPos, NULL_VECTOR, NULL_VECTOR);

        DispatchKeyValue(iParti, "effect_name", szParticleType);
        DispatchSpawn(iParti);

        if (bAttach)
        {
            SetParent(iEnt, iParti);
            SetEntPropEnt(iParti, Prop_Send, "m_hOwnerEntity", iEnt);
        }

        ActivateEntity(iParti);

        if (flTimeToStart > 0.0)
        {
            decl String:szAddOutput[32];
            Format(szAddOutput, sizeof(szAddOutput), "OnUser1 !self,Start,,%0.2f,1", flTimeToStart);
            SetVariantString(szAddOutput);
            AcceptEntityInput(iParti, "AddOutput");
            AcceptEntityInput(iParti, "FireUser1");

            if (flTimeToDie > 0.0)
            {
                flTimeToDie += flTimeToStart;
            }
        }
        else
        {
            AcceptEntityInput(iParti, "Start");
        }

        if (flTimeToDie > 0.0)
        {
            killEntityIn(iParti, flTimeToDie); // Interestingly, OnUser1 can be used multiple times, as the code above won't conflict with this.
        }

        return iParti;
    }
    return -1;
}

stock void SetParent(int iParent, int iChild)
{
    SetVariantString("!activator");
    AcceptEntityInput(iChild, "SetParent", iParent, iChild);
}

stock void killEntityIn(int iEnt, float flSeconds)
{
    char szAddOutput[32];
    Format(szAddOutput, sizeof(szAddOutput), "OnUser1 !self,Kill,,%0.2f,1", flSeconds);
    SetVariantString(szAddOutput);
    AcceptEntityInput(iEnt, "AddOutput");
    AcceptEntityInput(iEnt, "FireUser1");
}

/*
    Start of smlib functions
*/
#if !defined _smlib_included
/* SMLIB
 * Precaches the given particle system.
 * It's best to call this OnMapStart().
 * Code based on Rochellecrab's, thanks.
 *
 * @param particleSystem    Name of the particle system to precache.
 * @return                  Returns the particle system index, INVALID_STRING_INDEX on error.
 */
stock int PrecacheParticleSystem(const char[] particleSystem)
{
    static int particleEffectNames = INVALID_STRING_TABLE;
    if (particleEffectNames == INVALID_STRING_TABLE) {
        if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
            return INVALID_STRING_INDEX;
        }
    }
    int index = FindStringIndex2(particleEffectNames, particleSystem);
    if (index == INVALID_STRING_INDEX) {
        int numStrings = GetStringTableNumStrings(particleEffectNames);
        if (numStrings >= GetStringTableMaxStrings(particleEffectNames)) {
            return INVALID_STRING_INDEX;
        }
        AddToStringTable(particleEffectNames, particleSystem);
        index = numStrings;
    }
    return index;
}

/* SMLIB
 * Rewrite of FindStringIndex, because in my tests
 * FindStringIndex failed to work correctly.
 * Searches for the index of a given string in a string table.
 *
 * @param tableidx      A string table index.
 * @param str           String to find.
 * @return              String index if found, INVALID_STRING_INDEX otherwise.
 */
stock int FindStringIndex2(int tableidx, const char[] str)
{
    char buf[1024];
    int numStrings = GetStringTableNumStrings(tableidx);
    for (int i=0; i < numStrings; i++) {
        ReadStringTable(tableidx, i, buf, sizeof(buf));
        if (StrEqual(buf, str)) {
            return i;
        }
    }
    return INVALID_STRING_INDEX;
}
#endif
