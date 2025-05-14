extends Node

const HUNK_L = {
	"system":"SYSTEM_HUNK-L",
	"name_override":"SYSTEM_HUNK",
	"price":4000,
	"test_protocol":"takeoff",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_IMPACT_ABSORBER"
}
const HUNK_R = {
	"system":"SYSTEM_HUNK-R",
	"name_override":"SYSTEM_HUNK",
	"price":4000,
	"test_protocol":"takeoff",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_IMPACT_ABSORBER"
}
const EMD14 = {
	"system":"SYSTEM_EMD14",
	"manual":"SYSTEM_MD_MANUAL",
	"price":10000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MASS_DRIVERS"
}
const RAILTOR = {
	"system":"SYSTEM_RAILTOR",
	"manual":"SYSTEM_MD_MANUAL",
	"price":20000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":150,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MASS_DRIVERS"
}
const EMD17RF = {
	"system":"SYSTEM_EMD17RF",
	"manual":"SYSTEM_MD_MANUAL",
	"price":30000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":150,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MASS_DRIVERS"
}
const ACTEMD14 = {
	"system":"SYSTEM_ACTEMD14",
	"manual":"SYSTEM_AMD_MANUAL",
	"price":32000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MASS_DRIVERS"
}
const CLAIM_L = {
	"system":"SYSTEM_CLAIM-L",
	"name_override":"SYSTEM_CLAIM",
	"price":43000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_BEACON"
}
const CLAIM_R = {
	"system":"SYSTEM_CLAIM-R",
	"name_override":"SYSTEM_CLAIM",
	"price":43000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_BEACON"
}
const SALVAGE = {
	"system":"SYSTEM_SALVAGE_ARM",
	"price":56000,
	"test_protocol":"arm",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MANIPULATION_ARMS"
}
const MWG = {
	"system":"SYSTEM_MWG",
	"price":70000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MICROWAVES"
}
const EXOSTORAGE_L = {
	"system":"SYSTEM_EXSTORAGE-L",
	"name_override":"SYSTEM_EXSTORAGE",
	"price":74000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER"
}
const EXOSTORAGE_R = {
	"system":"SYSTEM_EXSTORAGE-R",
	"name_override":"SYSTEM_EXSTORAGE",
	"price":74000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER"
}
const EINAT = {
	"system":"SYSTEM_EINAT",
	"price":100000,
	"control":"ship_weapon_fire",
	"warn_if_thermal_below":20,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_PLASMA_THROWERS"
}
const EXMONO_L = {
	"system":"SYSTEM_EXMONO-L",
	"name_override":"SYSTEM_EXMONO",
	"price":111000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER"
}
const EXMONO_R = {
	"system":"SYSTEM_EXMONO-R",
	"name_override":"SYSTEM_EXMONO",
	"price":111000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER"
}
const SCOOP_L = {
	"system":"SYSTEM_SCOOP-L",
	"name_override":"SYSTEM_SCOOP",
	"price":115000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_MINING_COMPANION"
}
const SCOOP_R = {
	"system":"SYSTEM_SCOOP-R",
	"name_override":"SYSTEM_SCOOP",
	"price":115000,
	"test_protocol":"detach",
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_MINING_COMPANION"
}
const PDT = {
	"system":"SYSTEM_PDT",
	"name_override":"SYSTEM_PDT",
	"price":135000,
	"test_protocol":"pdt",
	"control":"ship_weapon_fire",
	"story_flag":"hardware.nakamura",
	"story_flag_min":5,
	"warn_if_electric_below":100,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_CENTER",
	"equipment_type":"EQUIPMENT_TURRETS"
}
const PDT_L = {
	"system":"SYSTEM_PDT-L",
	"name_override":"SYSTEM_PDT",
	"price":135000,
	"test_protocol":"pdt",
	"control":"ship_weapon_fire",
	"story_flag":"hardware.nakamura",
	"story_flag_min":5,
	"warn_if_electric_below":100,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_TURRETS"
}
const PDT_R = {
	"system":"SYSTEM_PDT-R",
	"name_override":"SYSTEM_PDT",
	"price":135000,
	"test_protocol":"pdt",
	"control":"ship_weapon_fire",
	"story_flag":"hardware.nakamura",
	"story_flag_min":5,
	"warn_if_electric_below":100,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_TURRETS"
}
const CL150 = {
	"system":"SYSTEM_CL150",
	"price":150000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":200,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MINING_LASERS"
}
const IROH = {
	"system":"SYSTEM_IROH",
	"price":160000,
	"control":"ship_weapon_fire",
	"warn_if_thermal_below":20,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_IRON_THROWERS"
}
const PDMWG = {
	"system":"SYSTEM_PDMWG",
	"name_override":"SYSTEM_PDMWG",
	"price":180000,
	"test_protocol":"pdt",
	"warn_if_electric_below":100,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_CENTER",
	"equipment_type":"EQUIPMENT_TURRETS"
}
const PDMWG_L = {
	"system":"SYSTEM_PDMWG-L",
	"name_override":"SYSTEM_PDMWG",
	"price":180000,
	"test_protocol":"pdt",
	"warn_if_electric_below":100,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_TURRETS"
}
const PDMWG_R = {
	"system":"SYSTEM_PDMWG-R",
	"name_override":"SYSTEM_PDMWG",
	"price":180000,
	"test_protocol":"pdt",
	"warn_if_electric_below":100,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_RIGHT",
	"equipment_type":"EQUIPMENT_TURRETS"
}
const ACL200P = {
	"system":"SYSTEM_ACL200P",
	"price":220000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":200,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MINING_LASERS"
}
const DND_TS = {
	"system":"SYSTEM_DND_TS",
	"price":250000,
	"test_protocol":"drone",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_NANODRONES"
}
const SYNCHRO_L = {
	"system":"SYSTEM_SYNCHRO-L",
	"name_override":"SYSTEM_SYNCHRO",
	"price":270000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":400,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_SYNCHROTRONS"
}
const SYNCHRO_R = {
	"system":"SYSTEM_SYNCHRO-R",
	"name_override":"SYSTEM_SYNCHRO",
	"price":270000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":400,
	"slot_type":"HARDPOINT",
	"alignment":"ALIGNMENT_LEFT",
	"equipment_type":"EQUIPMENT_SYNCHROTRONS"
}
const NANI = {
	"system":"SYSTEM_NANI",
	"price":300000,
	"control":"ship_weapon_fire",
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_PLASMA_THROWERS_HEAVY"
}
const CL600P = {
	"system":"SYSTEM_CL600P",
	"price":320000,
	"control":"ship_weapon_fire",
	"warn_if_electric_below":600,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_MINING_LASERS"
}
const DND_HAUL = {
	"system":"SYSTEM_DND_HAUL",
	"price":350000,
	"test_protocol":"drone",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_NANODRONES"
}
const DND_FIX = {
	"system":"SYSTEM_DND_FIX",
	"price":400000,
	"test_protocol":"damage",
	"warn_if_electric_below":50,
	"slot_type":"HARDPOINT",
	"equipment_type":"EQUIPMENT_NANODRONES"
}
const AMMO_0 = {
	"num_val":0,
	"system":"SYSTEM_AMMO_0",
	"manual":"SYSTEM_NONE_MANUAL",
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const AMMO_1000 = {
	"num_val":1000,
	"system":"SYSTEM_AMMO_1000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":5000,
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const AMMO_2000 = {
	"num_val":2000,
	"system":"SYSTEM_AMMO_2000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":10000,
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const AMMO_5000 = {
	"num_val":5000,
	"system":"SYSTEM_AMMO_5000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":25000,
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const AMMO_10000 = {
	"num_val":10000,
	"system":"SYSTEM_AMMO_10000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":50000,
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const AMMO_20000 = {
	"num_val":20000,
	"system":"SYSTEM_AMMO_20000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":100000,
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const AMMO_50000 = {
	"num_val":50000,
	"system":"SYSTEM_AMMO_50000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":250000,
	"test_protocol":"takeoff",
	"slot_type":"MASS_DRIVER_AMMUNITION",
	"equipment_type":"CONSUMABLE_MASS_DRIVER_AMMUNITION"
}
const DND_NONE = {
	"num_val":0,
	"system":"SYSTEM_NONE",
	"test_protocol":"drone",
	"default":true,
	"slot_type":"NANODRONE_STORAGE",
	"equipment_type":"CONSUMABLE_NANODRONES"
}
const DND_1000 = {
	"num_val":1000,
	"system":"SYSTEM_DND_1000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":20000,
	"test_protocol":"drone",
	"slot_type":"NANODRONE_STORAGE",
	"equipment_type":"CONSUMABLE_NANODRONES"
}
const DND_5000 = {
	"num_val":5000,
	"system":"SYSTEM_DND_5000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":120000,
	"test_protocol":"drone",
	"slot_type":"NANODRONE_STORAGE",
	"equipment_type":"CONSUMABLE_NANODRONES"
}
const DND_10000 = {
	"num_val":10000,
	"system":"SYSTEM_DND_10000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":250000,
	"test_protocol":"drone",
	"slot_type":"NANODRONE_STORAGE",
	"equipment_type":"CONSUMABLE_NANODRONES"
}
const DND_20000 = {
	"num_val":20000,
	"system":"SYSTEM_DND_20000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":500000,
	"test_protocol":"drone",
	"slot_type":"NANODRONE_STORAGE",
	"equipment_type":"CONSUMABLE_NANODRONES"
}
const DND_50000 = {
	"num_val":50000,
	"system":"SYSTEM_DND_50000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":1250000,
	"test_protocol":"drone",
	"slot_type":"NANODRONE_STORAGE",
	"equipment_type":"CONSUMABLE_NANODRONES"
}
const PROPELLANT_15000 = {
	"num_val":15000,
	"system":"SYSTEM_FUEL_15000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":6000,
	"test_protocol":"takeoff",
	"slot_type":"PROPELLANT_TANK",
	"equipment_type":"CONSUMABLE_PROPELLANT"
}
const PROPELLANT_30000 = {
	"num_val":30000,
	"system":"SYSTEM_FUEL_30000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":12000,
	"test_protocol":"takeoff",
	"slot_type":"PROPELLANT_TANK",
	"equipment_type":"CONSUMABLE_PROPELLANT"
}
const PROPELLANT_50000 = {
	"num_val":50000,
	"system":"SYSTEM_FUEL_50000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":20000,
	"test_protocol":"takeoff",
	"slot_type":"PROPELLANT_TANK",
	"equipment_type":"CONSUMABLE_PROPELLANT"
}
const PROPELLANT_80000 = {
	"num_val":80000,
	"system":"SYSTEM_FUEL_80000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":32000,
	"test_protocol":"takeoff",
	"slot_type":"PROPELLANT_TANK",
	"equipment_type":"CONSUMABLE_PROPELLANT"
}
const PROPELLANT_200000 = {
	"num_val":200000,
	"system":"SYSTEM_FUEL_200000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":160000,
	"test_protocol":"takeoff",
	"slot_type":"PROPELLANT_TANK",
	"equipment_type":"CONSUMABLE_PROPELLANT"
}
const PROPELLANT_500000 = {
	"num_val":500000,
	"system":"SYSTEM_FUEL_500000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":400000,
	"test_protocol":"takeoff",
	"slot_type":"PROPELLANT_TANK",
	"equipment_type":"CONSUMABLE_PROPELLANT"
}
const RCS_NDSTR = {
	"system":"SYSTEM_THRUSTER_NDSTR",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":1250,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":1.1,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_NDVTT = {
	"system":"SYSTEM_THRUSTER_NDVTT",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":2500,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":0.9,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_K37 = {
	"system":"SYSTEM_THRUSTER_K37",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":3125,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":0.8,
	"warn_if_electric_below":5,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_MA150HO = {
	"system":"SYSTEM_THRUSTER_MA150HO",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":4375,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":1.2,
	"warn_if_electric_below":20,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_K44 = {
	"system":"SYSTEM_THRUSTER_K44",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":6250,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":1.5,
	"warn_if_electric_below":10,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_ION = {
	"system":"SYSTEM_THRUSTER_EIT",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":8000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":1.5,
	"warn_if_electric_below":20,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_NAGHET = {
	"system":"SYSTEM_THRUSTER_GHET",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":8500,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":1.4,
	"warn_if_electric_below":25,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_MA350HO = {
	"system":"SYSTEM_THRUSTER_MA350HO",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":10000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":2.2,
	"warn_if_electric_below":30,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_AGILE = {
	"system":"SYSTEM_THRUSTER_AGILE",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":12000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":1.3,
	"warn_if_electric_below":30,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const RCS_K69V = {
	"system":"SYSTEM_THRUSTER_K69V",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":18600,
	"test_protocol":"autopilot",
	"story_flag":"ringrace",
	"story_flag_min":1,
	"warn_if_thermal_below":1.8,
	"warn_if_electric_below":15,
	"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS",
	"equipment_type":"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"
}
const TORCH_PNTR = {
	"system":"SYSTEM_MAIN_ENGINE_PNTR",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":7000,
	"test_protocol":"autopilot",
	"default":true,
	"warn_if_thermal_below":5.6,
	"warn_if_electric_below":200,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_K37 = {
	"system":"SYSTEM_MAIN_ENGINE_K37",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":15000,
	"test_protocol":"autopilot",
	"default":true,
	"warn_if_thermal_below":5.6,
	"warn_if_electric_below":100,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_NDNTTR = {
	"system":"SYSTEM_MAIN_ENGINE_NDNTR",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":30000,
	"test_protocol":"autopilot",
	"default":true,
	"warn_if_thermal_below":12.2,
	"warn_if_electric_below":20,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_K44 = {
	"system":"SYSTEM_MAIN_ENGINE_K44",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":40000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":13.5,
	"warn_if_electric_below":100,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_BWM = {
	"system":"SYSTEM_MAIN_ENGINE_BWMT535",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":120000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":8.2,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_DFMPD2205 = {
	"system":"SYSTEM_MAIN_ENGINE_DFMPD2205",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":175000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":15.4,
	"warn_if_electric_below":120,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_NMPD = {
	"system":"SYSTEM_MAIN_ENGINE_NMPD",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":300000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":18.4,
	"warn_if_electric_below":150,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_NPMP = {
	"system":"SYSTEM_MAIN_ENGINE_NPMP",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":700000,
	"test_protocol":"autopilot",
	"warn_if_thermal_below":24.7,
	"warn_if_electric_below":200,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const TORCH_ZAP = {
	"system":"SYSTEM_MAIN_ENGINE_EIZAP",
	"price":1000000,
	"test_protocol":"autopilot",
	"warn_if_electric_below":150,
	"slot_type":"STANDARD_MAIN_ENGINE",
	"equipment_type":"THRUSTER_STANDARD_MAIN_ENGINE"
}
const FISSION_RODS_4 = {
	"num_val":4,
	"system":"SYSTEM_RODS_4",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":80000,
	"test_protocol":"takeoff",
	"default":true,
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_8 = {
	"num_val":8,
	"system":"SYSTEM_RODS_8",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":160000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_12 = {
	"num_val":12,
	"system":"SYSTEM_RODS_12",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":240000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_16 = {
	"num_val":16,
	"system":"SYSTEM_RODS_16",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":320000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_20 = {
	"num_val":20,
	"system":"SYSTEM_RODS_20",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":400000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_30 = {
	"num_val":30,
	"system":"SYSTEM_CORE_LIQUID_30",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":750000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_40 = {
	"num_val":40,
	"system":"SYSTEM_CORE_LIQUID_40",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":1000000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const FISSION_RODS_50 = {
	"num_val":50,
	"system":"SYSTEM_CORE_LIQUID_50",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":1500000,
	"test_protocol":"takeoff",
	"slot_type":"FISSION_RODS",
	"equipment_type":"POWER_FISSION_RODS"
}
const ULTRACAPACITOR_500 = {
	"num_val":500,
	"system":"SYSTEM_CAPACITOR_500",
	"manual":"SYSTEM_CAPACITOR_MANUAL",
	"price":25000,
	"test_protocol":"bootup",
	"slot_type":"ULTRACAPACITOR",
	"equipment_type":"POWER_ULTRACAPACITOR"
}
const ULTRACAPACITOR_1000 = {
	"num_val":1000,
	"system":"SYSTEM_CAPACITOR_1000",
	"manual":"SYSTEM_CAPACITOR_MANUAL",
	"price":55000,
	"test_protocol":"bootup",
	"slot_type":"ULTRACAPACITOR",
	"equipment_type":"POWER_ULTRACAPACITOR"
}
const ULTRACAPACITOR_1500 = {
	"num_val":1500,
	"system":"SYSTEM_CAPACITOR_1500",
	"manual":"SYSTEM_CAPACITOR_MANUAL",
	"price":90000,
	"test_protocol":"bootup",
	"slot_type":"ULTRACAPACITOR",
	"equipment_type":"POWER_ULTRACAPACITOR"
}
const TURBINE_100 = {
	"num_val":100,
	"system":"SYSTEM_TURBINE_100",
	"manual":"SYSTEM_TURBINE_MANUAL",
	"price":30000,
	"test_protocol":"bootup",
	"slot_type":"FISSION_TURBINE",
	"equipment_type":"POWER_FISSION_TURBINE"
}
const TURBINE_200 = {
	"num_val":200,
	"system":"SYSTEM_TURBINE_200",
	"manual":"SYSTEM_TURBINE_MANUAL",
	"price":60000,
	"test_protocol":"bootup",
	"slot_type":"FISSION_TURBINE",
	"equipment_type":"POWER_FISSION_TURBINE"
}
const TURBINE_500 = {
	"num_val":500,
	"system":"SYSTEM_TURBINE_500",
	"manual":"SYSTEM_TURBINE_MANUAL",
	"price":150000,
	"test_protocol":"bootup",
	"slot_type":"FISSION_TURBINE",
	"equipment_type":"POWER_FISSION_TURBINE"
}
const AUX_NONE = {
	"system":"SYSTEM_NONE",
	"test_protocol":"bootup",
	"default":true,
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const AUX_MPD_1 = {
	"system":"SYSTEM_AUX_MPD",
	"manual":"SYSTEM_AUX_MPD_MANUAL",
	"price":300000,
	"test_protocol":"bootup",
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const AUX_MPD_2 = {
	"system":"SYSTEM_AUX_MPD_MK2",
	"manual":"SYSTEM_AUX_MPD_MANUAL",
	"price":500000,
	"test_protocol":"bootup",
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const AUX_MPD_3 = {
	"system":"SYSTEM_AUX_MPD_MK3",
	"manual":"SYSTEM_AUX_MPD_MANUAL",
	"price":800000,
	"test_protocol":"bootup",
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const AUX_SMES_1 = {
	"system":"SYSTEM_AUX_SMES",
	"manual":"SYSTEM_AUX_SMES_MANUAL",
	"price":400000,
	"test_protocol":"bootup",
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const AUX_SMES_2 = {
	"system":"SYSTEM_AUX_SMES_MK2",
	"manual":"SYSTEM_AUX_SMES_MANUAL",
	"price":800000,
	"test_protocol":"bootup",
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const AUX_SMES_3 = {
	"system":"SYSTEM_AUX_SMES_MK3",
	"manual":"SYSTEM_AUX_SMES_MANUAL",
	"price":1200000,
	"test_protocol":"bootup",
	"slot_type":"AUX_POWER_SLOT",
	"equipment_type":"POWER_AUX_POWER_SLOT"
}
const CARGOBAY_STANDARD = {
	"system":"SYSTEM_CARGO_STANDARD",
	"manual":"SYSTEM_NONE_MANUAL",
	"test_protocol":"cargo",
	"default":true,
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const CARGOBAY_BAFFLES = {
	"system":"SYSTEM_CARGO_BAFFLES",
	"capability_lock":true,
	"manual":"SYSTEM_CARGO_BAFFLES_MANUAL",
	"price":2000,
	"test_protocol":"cargo",
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const CARGOBAY_OREPURIFIER = {
	"system":"SYSTEM_CARGO_MPUDRY",
	"capability_lock":true,
	"manual":"SYSTEM_CARGO_DRY_MANUAL",
	"price":120000,
	"test_protocol":"cargo",
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const CARGOBAY_RUSATOMMPU = {
	"system":"SYSTEM_CARGO_MPUFSO",
	"capability_lock":true,
	"manual":"SYSTEM_CARGO_MPU_MANUAL",
	"price":350000,
	"test_protocol":"cargo",
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const CARGOBAY_NAKAMURAMPU = {
	"system":"SYSTEM_CARGO_MPU",
	"capability_lock":true,
	"manual":"SYSTEM_CARGO_MPU_MANUAL",
	"price":500000,
	"test_protocol":"cargo",
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const CARGOBAY_STARBUSMSU = {
	"system":"SYSTEM_CARGO_MPUSML",
	"capability_lock":true,
	"manual":"SYSTEM_CARGO_MPUSML_MANUAL",
	"price":900000,
	"test_protocol":"cargo",
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const CARGOBAY_VOYAGERMPU = {
	"system":"SYSTEM_CARGO_MPU_FAB",
	"capability_lock":true,
	"manual":"SYSTEM_CARGO_MPU_FAB_MANUAL",
	"price":1500000,
	"test_protocol":"cargo",
	"slot_type":"CARGO_BAY",
	"equipment_type":"CARGO_BAY"
}
const AUTOPILOT_NONE = {
	"system":"SYSTEM_AUTOPILOT_NONE",
	"test_protocol":"autopilot",
	"slot_type":"AUTOPILOT",
	"equipment_type":"COMPUTER_AUTOPILOT"
}
const AUTOPILOT_MLF = {
	"system":"SYSTEM_AUTOPILOT_MK1",
	"price":10000,
	"test_protocol":"autopilot",
	"slot_type":"AUTOPILOT",
	"equipment_type":"COMPUTER_AUTOPILOT"
}
const AUTOPILOT_337 = {
	"system":"SYSTEM_AUTOPILOT_MK2",
	"price":27000,
	"test_protocol":"autopilot",
	"slot_type":"AUTOPILOT",
	"equipment_type":"COMPUTER_AUTOPILOT"
}
const AUTOPILOT_NDCI = {
	"system":"SYSTEM_AUTOPILOT_MK3",
	"price":60000,
	"test_protocol":"autopilot",
	"slot_type":"AUTOPILOT",
	"equipment_type":"COMPUTER_AUTOPILOT"
}
const AUTOPILOT_RACING = {
	"system":"SYSTEM_AUTOPILOT_RTYPE",
	"price":100000,
	"test_protocol":"autopilot",
	"story_flag":"ringrace",
	"story_flag_min":1,
	"slot_type":"AUTOPILOT",
	"equipment_type":"COMPUTER_AUTOPILOT"
}
const AUTOPILOT_EIAA = {
	"system":"SYSTEM_AUTOPILOT_MK4",
	"price":150000,
	"test_protocol":"autopilot",
	"slot_type":"AUTOPILOT",
	"equipment_type":"COMPUTER_AUTOPILOT"
}
const HUD_DUMMY = {
	"system":"SYSTEM_NONE",
	"specs":"",
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_HAL = {
	"system":"SYSTEM_HUD_HAL",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":500,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_PROSPECTOR = {
	"system":"SYSTEM_HUD_PROSPECTOR",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":3000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_K37 = {
	"system":"SYSTEM_HUD_TNTRL",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":4000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_K225 = {
	"system":"SYSTEM_HUD_AT225",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":6000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_PROSPECTOR_METRIC = {
	"system":"SYSTEM_HUD_PROSPECTOR_METRIC",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":10000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_OCP = {
	"system":"SYSTEM_HUD_OCP209",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":15000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_EIME = {
	"system":"SYSTEM_HUD_EIME",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":25000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_KITSUNE = {
	"system":"SYSTEM_HUD_KITSUNE",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":31000,
	"test_protocol":"hud",
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const HUD_RACING = {
	"system":"SYSTEM_HUD_PROSPECTOR_BALD",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":31000,
	"test_protocol":"hud",
	"story_flag":"ringrace",
	"story_flag_min":1,
	"slot_type":"HUD",
	"equipment_type":"COMPUTER_HUD"
}
const LIDAR_RADAR = {
	"system":"SYSTEM_LIDAR_RADAR",
	"price":5000,
	"test_protocol":"lidar",
	"slot_type":"LIDAR",
	"equipment_type":"SENSOR_LIDAR"
}
const LIDAR_IRL360 = {
	"system":"SYSTEM_LIDAR_DOPPLER",
	"price":15000,
	"test_protocol":"lidar",
	"slot_type":"LIDAR",
	"equipment_type":""
}
const LIDAR_IRL30 = {
	"system":"SYSTEM_LIDAR_DOPPLER_CONE",
	"price":25000,
	"test_protocol":"lidar",
	"slot_type":"LIDAR",
	"equipment_type":"SENSOR_LIDAR"
}
const LIDAR_HIGH_RES = {
	"system":"SYSTEM_LIDAR_DOPPLER_HIRES",
	"price":90000,
	"test_protocol":"lidar",
	"slot_type":"LIDAR",
	"equipment_type":"SENSOR_LIDAR"
}
const LIDAR_PHASED = {
	"system":"SYSTEM_LIDAR_OPA",
	"price":120000,
	"test_protocol":"lidar",
	"slot_type":"LIDAR",
	"equipment_type":"SENSOR_LIDAR"
}
const RECON_STANDARD = {
	"system":"SYSTEM_RD_STANDARD",
	"price":10000,
	"test_protocol":"cargo",
	"default":true,
	"slot_type":"RECON_DRONE",
	"equipment_type":"SENSOR_RECON_DRONE"
}
const RECON_GRAVIMETRIC = {
	"system":"SYSTEM_RD_GRAVIMETRIC",
	"price":40000,
	"test_protocol":"drone",
	"slot_type":"RECON_DRONE",
	"equipment_type":"SENSOR_RECON_DRONE"
}
const RECON_MICROSEISMIC = {
	"system":"SYSTEM_RD_SPECTROMETER",
	"price":60000,
	"test_protocol":"remotecargo",
	"slot_type":"RECON_DRONE",
	"equipment_type":"SENSOR_RECON_DRONE"
}
const RECON_GUIDING = {
	"system":"SYSTEM_RD_GUIDING",
	"price":200000,
	"test_protocol":"drone",
	"control":"autopilot_guide_target",
	"slot_type":"RECON_DRONE",
	"equipment_type":"SENSOR_RECON_DRONE"
}
