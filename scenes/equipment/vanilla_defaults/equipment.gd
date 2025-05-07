extends Node

var HUNK_L = {
	"system":"SYSTEM_HUNK-L",
	"nameOverride":"SYSTEM_HUNK",
	"price":4000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_IMPACT_ABSORBER"}
}
var HUNK_R = {
	"system":"SYSTEM_HUNK-R",
	"nameOverride":"SYSTEM_HUNK",
	"price":4000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_IMPACT_ABSORBER"}
}
var EMD14 = {
	"system":"SYSTEM_EMD14",
	"manual":"SYSTEM_MD_MANUAL",
	"price":10000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MASS_DRIVERS"}
}
var RAILTOR = {
	"system":"SYSTEM_RAILTOR",
	"manual":"SYSTEM_MD_MANUAL",
	"price":20000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":150,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MASS_DRIVERS"}
}
var EMD17RF = {
	"system":"SYSTEM_EMD17RF",
	"manual":"SYSTEM_MD_MANUAL",
	"price":30000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":150,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MASS_DRIVERS"}
}
var ACTEMD14 = {
	"system":"SYSTEM_ACTEMD14",
	"manual":"SYSTEM_AMD_MANUAL",
	"price":32000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MASS_DRIVERS"}
}
var CLAIM_L = {
	"system":"SYSTEM_CLAIM-L",
	"nameOverride":"SYSTEM_CLAIM",
	"price":43000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_BEACON"}
}
var CLAIM_R = {
	"system":"SYSTEM_CLAIM-R",
	"nameOverride":"SYSTEM_CLAIM",
	"price":43000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_BEACON"}
}
var SALVAGE = {
	"system":"SYSTEM_SALVAGE_ARM",
	"price":56000,
	"testProtocol":"arm",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MANIPULATION_ARMS"}
}
var MWG = {
	"system":"SYSTEM_MWG",
	"price":70000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MICROWAVES"}
}
var EXOSTORAGE_L = {
	"system":"SYSTEM_EXSTORAGE-L",
	"nameOverride":"SYSTEM_EXSTORAGE",
	"price":74000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_CARGO_CONTAINER"}
}
var EXOSTORAGE_R = {
	"system":"SYSTEM_EXSTORAGE-R",
	"nameOverride":"SYSTEM_EXSTORAGE",
	"price":74000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_CARGO_CONTAINER"}
}
var EINAT = {
	"system":"SYSTEM_EINAT",
	"price":100000,
	"control":"ship_weapon_fire",
	"warnIfThermalBelow":20,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_PLASMA_THROWERS"}
}
var EXMONO_L = {
	"system":"SYSTEM_EXMONO-L",
	"nameOverride":"SYSTEM_EXMONO",
	"price":111000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_CARGO_CONTAINER"}
}
var EXMONO_R = {
	"system":"SYSTEM_EXMONO-R",
	"nameOverride":"SYSTEM_EXMONO",
	"price":111000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_CARGO_CONTAINER"}
}
var SCOOP_L = {
	"system":"SYSTEM_SCOOP-L",
	"nameOverride":"SYSTEM_SCOOP",
	"price":115000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_MINING_COMPANION"}
}
var SCOOP_R = {
	"system":"SYSTEM_SCOOP-R",
	"nameOverride":"SYSTEM_SCOOP",
	"price":115000,
	"testProtocol":"detach",
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_MINING_COMPANION"}
}
var PDT = {
	"system":"SYSTEM_PDT",
	"nameOverride":"SYSTEM_PDT",
	"price":135000,
	"testProtocol":"pdt",
	"control":"ship_weapon_fire",
	"storyFlag":"hardware.nakamura",
	"storyFlagMin":5,
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_CENTER","tags":"EQUIPMENT_TURRETS"}
}
var PDT_L = {
	"system":"SYSTEM_PDT-L",
	"nameOverride":"SYSTEM_PDT",
	"price":135000,
	"testProtocol":"pdt",
	"control":"ship_weapon_fire",
	"storyFlag":"hardware.nakamura",
	"storyFlagMin":5,
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_TURRETS"}
}
var PDT_R = {
	"system":"SYSTEM_PDT-R",
	"nameOverride":"SYSTEM_PDT",
	"price":135000,
	"testProtocol":"pdt",
	"control":"ship_weapon_fire",
	"storyFlag":"hardware.nakamura",
	"storyFlagMin":5,
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_TURRETS"}
}
var CL150 = {
	"system":"SYSTEM_CL150",
	"price":150000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":200,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MINING_LASERS"}
}
var IROH = {
	"system":"SYSTEM_IROH",
	"price":160000,
	"control":"ship_weapon_fire",
	"warnIfThermalBelow":20,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_IRON_THROWERS"}
}
var PDMWG = {
	"system":"SYSTEM_PDMWG",
	"nameOverride":"SYSTEM_PDMWG",
	"price":180000,
	"testProtocol":"pdt",
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_CENTER","tags":"EQUIPMENT_TURRETS"}
}
var PDMWG_L = {
	"system":"SYSTEM_PDMWG-L",
	"nameOverride":"SYSTEM_PDMWG",
	"price":180000,
	"testProtocol":"pdt",
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_TURRETS"}
}
var PDMWG_R = {
	"system":"SYSTEM_PDMWG-R",
	"nameOverride":"SYSTEM_PDMWG",
	"price":180000,
	"testProtocol":"pdt",
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_RIGHT","tags":"EQUIPMENT_TURRETS"}
}
var ACL200P = {
	"system":"SYSTEM_ACL200P",
	"price":220000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":200,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MINING_LASERS"}
}
var DND_TS = {
	"system":"SYSTEM_DND_TS",
	"price":250000,
	"testProtocol":"drone",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_NANODRONES"}
}
var SYNCHRO_L = {
	"system":"SYSTEM_SYNCHRO-L",
	"nameOverride":"SYSTEM_SYNCHRO",
	"price":270000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":400,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_SYNCHROTRONS"}
}
var SYNCHRO_R = {
	"system":"SYSTEM_SYNCHRO-R",
	"nameOverride":"SYSTEM_SYNCHRO",
	"price":270000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":400,
	"slot_groups":{"slot_type":"HARDPOINT","alignment":"ALIGNMENT_LEFT","tags":"EQUIPMENT_SYNCHROTRONS"}
}
var NANI = {
	"system":"SYSTEM_NANI",
	"price":300000,
	"control":"ship_weapon_fire",
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_PLASMA_THROWERS_HEAVY"}
}
var CL600P = {
	"system":"SYSTEM_CL600P",
	"price":320000,
	"control":"ship_weapon_fire",
	"warnIfElectricBelow":600,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_MINING_LASERS"}
}
var DND_HAUL = {
	"system":"SYSTEM_DND_HAUL",
	"price":350000,
	"testProtocol":"drone",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_NANODRONES"}
}
var DND_FIX = {
	"system":"SYSTEM_DND_FIX",
	"price":400000,
	"testProtocol":"damage",
	"warnIfElectricBelow":50,
	"slot_groups":{"slot_type":"HARDPOINT","tags":"EQUIPMENT_NANODRONES"}
}
var AMMO_0 = {
	"numVal":0,
	"system":"SYSTEM_AMMO_0",
	"manual":"SYSTEM_NONE_MANUAL",
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var AMMO_1000 = {
	"numVal":1000,
	"system":"SYSTEM_AMMO_1000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":5000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var AMMO_2000 = {
	"numVal":2000,
	"system":"SYSTEM_AMMO_2000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":10000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var AMMO_5000 = {
	"numVal":5000,
	"system":"SYSTEM_AMMO_5000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":25000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var AMMO_10000 = {
	"numVal":10000,
	"system":"SYSTEM_AMMO_10000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":50000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var AMMO_20000 = {
	"numVal":20000,
	"system":"SYSTEM_AMMO_20000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":100000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var AMMO_50000 = {
	"numVal":50000,
	"system":"SYSTEM_AMMO_50000",
	"manual":"SYSTEM_AMMO_MANUAL",
	"price":250000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"MASS_DRIVER_AMMUNITION"}
}
var DND_NONE = {
	"numVal":0,
	"system":"SYSTEM_NONE",
	"testProtocol":"drone",
	"default":true,
	"slot_groups":{"slot_type":"NANODRONE_STORAGE"}
}
var DND_1000 = {
	"numVal":1000,
	"system":"SYSTEM_DND_1000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":20000,
	"testProtocol":"drone",
	"slot_groups":{"slot_type":"NANODRONE_STORAGE"}
}
var DND_5000 = {
	"numVal":5000,
	"system":"SYSTEM_DND_5000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":120000,
	"testProtocol":"drone",
	"slot_groups":{"slot_type":"NANODRONE_STORAGE"}
}
var DND_10000 = {
	"numVal":10000,
	"system":"SYSTEM_DND_10000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":250000,
	"testProtocol":"drone",
	"slot_groups":{"slot_type":"NANODRONE_STORAGE"}
}
var DND_20000 = {
	"numVal":20000,
	"system":"SYSTEM_DND_20000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":500000,
	"testProtocol":"drone",
	"slot_groups":{"slot_type":"NANODRONE_STORAGE"}
}
var DND_50000 = {
	"numVal":50000,
	"system":"SYSTEM_DND_50000",
	"manual":"SYSTEM_DND_MANUAL",
	"price":1250000,
	"testProtocol":"drone",
	"slot_groups":{"slot_type":"NANODRONE_STORAGE"}
}
var PROPELLANT_15000 = {
	"numVal":15000,
	"system":"SYSTEM_FUEL_15000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":6000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"PROPELLANT_TANK"}
}
var PROPELLANT_30000 = {
	"numVal":30000,
	"system":"SYSTEM_FUEL_30000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":12000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"PROPELLANT_TANK"}
}
var PROPELLANT_50000 = {
	"numVal":50000,
	"system":"SYSTEM_FUEL_50000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":20000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"PROPELLANT_TANK"}
}
var PROPELLANT_80000 = {
	"numVal":80000,
	"system":"SYSTEM_FUEL_80000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":32000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"PROPELLANT_TANK"}
}
var PROPELLANT_200000 = {
	"numVal":200000,
	"system":"SYSTEM_FUEL_200000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":160000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"PROPELLANT_TANK"}
}
var PROPELLANT_500000 = {
	"numVal":500000,
	"system":"SYSTEM_FUEL_500000",
	"manual":"SYSTEM_FUEL_MANUAL",
	"price":400000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"PROPELLANT_TANK"}
}
var RCS_NDSTR = {
	"system":"SYSTEM_THRUSTER_NDSTR",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":1250,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":1.1,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_NDVTT = {
	"system":"SYSTEM_THRUSTER_NDVTT",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":2500,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":0.9,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_K37 = {
	"system":"SYSTEM_THRUSTER_K37",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":3125,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":0.8,
	"warnIfElectricBelow":5,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_MA150HO = {
	"system":"SYSTEM_THRUSTER_MA150HO",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":4375,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":1.2,
	"warnIfElectricBelow":20,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_K44 = {
	"system":"SYSTEM_THRUSTER_K44",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":6250,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":1.5,
	"warnIfElectricBelow":10,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_ION = {
	"system":"SYSTEM_THRUSTER_EIT",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":8000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":1.5,
	"warnIfElectricBelow":20,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_NAGHET = {
	"system":"SYSTEM_THRUSTER_GHET",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":8500,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":1.4,
	"warnIfElectricBelow":25,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_MA350HO = {
	"system":"SYSTEM_THRUSTER_MA350HO",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":10000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":2.2,
	"warnIfElectricBelow":30,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_AGILE = {
	"system":"SYSTEM_THRUSTER_AGILE",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":12000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":1.3,
	"warnIfElectricBelow":30,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var RCS_K69V = {
	"system":"SYSTEM_THRUSTER_K69V",
	"manual":"SYSTEM_THRUSTER_MANUAL",
	"price":18600,
	"testProtocol":"autopilot",
	"storyFlag":"ringrace",
	"storyFlagMin":1,
	"warnIfThermalBelow":1.8,
	"warnIfElectricBelow":15,
	"slot_groups":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"}
}
var TORCH_PNTR = {
	"system":"SYSTEM_MAIN_ENGINE_PNTR",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":7000,
	"testProtocol":"autopilot",
	"default":true,
	"warnIfThermalBelow":5.6,
	"warnIfElectricBelow":200,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_K37 = {
	"system":"SYSTEM_MAIN_ENGINE_K37",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":15000,
	"testProtocol":"autopilot",
	"default":true,
	"warnIfThermalBelow":5.6,
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_NDNTTR = {
	"system":"SYSTEM_MAIN_ENGINE_NDNTR",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":30000,
	"testProtocol":"autopilot",
	"default":true,
	"warnIfThermalBelow":12.2,
	"warnIfElectricBelow":20,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_K44 = {
	"system":"SYSTEM_MAIN_ENGINE_K44",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":40000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":13.5,
	"warnIfElectricBelow":100,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_BWM = {
	"system":"SYSTEM_MAIN_ENGINE_BWMT535",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":120000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":8.2,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_DFMPD2205 = {
	"system":"SYSTEM_MAIN_ENGINE_DFMPD2205",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":175000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":15.4,
	"warnIfElectricBelow":120,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_NMPD = {
	"system":"SYSTEM_MAIN_ENGINE_NMPD",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":300000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":18.4,
	"warnIfElectricBelow":150,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_NPMP = {
	"system":"SYSTEM_MAIN_ENGINE_NPMP",
	"manual":"SYSTEM_MAIN_ENGINE_MANUAL",
	"price":700000,
	"testProtocol":"autopilot",
	"warnIfThermalBelow":24.7,
	"warnIfElectricBelow":200,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var TORCH_ZAP = {
	"system":"SYSTEM_MAIN_ENGINE_EIZAP",
	"price":1000000,
	"testProtocol":"autopilot",
	"warnIfElectricBelow":150,
	"slot_groups":{"slot_type":"STANDARD_MAIN_ENGINE"}
}
var FISSION_RODS_4 = {
	"numVal":4,
	"system":"SYSTEM_RODS_4",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":80000,
	"testProtocol":"takeoff",
	"default":true,
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_8 = {
	"numVal":8,
	"system":"SYSTEM_RODS_8",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":160000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_12 = {
	"numVal":12,
	"system":"SYSTEM_RODS_12",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":240000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_16 = {
	"numVal":16,
	"system":"SYSTEM_RODS_16",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":320000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_20 = {
	"numVal":20,
	"system":"SYSTEM_RODS_20",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":400000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_30 = {
	"numVal":30,
	"system":"SYSTEM_CORE_LIQUID_30",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":750000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_40 = {
	"numVal":40,
	"system":"SYSTEM_CORE_LIQUID_40",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":1000000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var FISSION_RODS_50 = {
	"numVal":50,
	"system":"SYSTEM_CORE_LIQUID_50",
	"manual":"SYSTEM_RODS_MANUAL",
	"price":1500000,
	"testProtocol":"takeoff",
	"slot_groups":{"slot_type":"FISSION_RODS"}
}
var ULTRACAPACITOR_500 = {
	"numVal":500,
	"system":"SYSTEM_CAPACITOR_500",
	"manual":"SYSTEM_CAPACITOR_MANUAL",
	"price":25000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"ULTRACAPACITOR"}
}
var ULTRACAPACITOR_1000 = {
	"numVal":1000,
	"system":"SYSTEM_CAPACITOR_1000",
	"manual":"SYSTEM_CAPACITOR_MANUAL",
	"price":55000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"ULTRACAPACITOR"}
}
var ULTRACAPACITOR_1500 = {
	"numVal":1500,
	"system":"SYSTEM_CAPACITOR_1500",
	"manual":"SYSTEM_CAPACITOR_MANUAL",
	"price":90000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"ULTRACAPACITOR"}
}
var TURBINE_100 = {
	"numVal":100,
	"system":"SYSTEM_TURBINE_100",
	"manual":"SYSTEM_TURBINE_MANUAL",
	"price":30000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"FISSION_TURBINE"}
}
var TURBINE_200 = {
	"numVal":200,
	"system":"SYSTEM_TURBINE_200",
	"manual":"SYSTEM_TURBINE_MANUAL",
	"price":60000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"FISSION_TURBINE"}
}
var TURBINE_500 = {
	"numVal":500,
	"system":"SYSTEM_TURBINE_500",
	"manual":"SYSTEM_TURBINE_MANUAL",
	"price":150000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"FISSION_TURBINE"}
}
var AUX_NONE = {
	"system":"SYSTEM_NONE",
	"testProtocol":"bootup",
	"default":true,
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var AUX_MPD_1 = {
	"system":"SYSTEM_AUX_MPD",
	"manual":"SYSTEM_AUX_MPD_MANUAL",
	"price":300000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var AUX_MPD_2 = {
	"system":"SYSTEM_AUX_MPD_MK2",
	"manual":"SYSTEM_AUX_MPD_MANUAL",
	"price":500000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var AUX_MPD_3 = {
	"system":"SYSTEM_AUX_MPD_MK3",
	"manual":"SYSTEM_AUX_MPD_MANUAL",
	"price":800000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var AUX_SMES_1 = {
	"system":"SYSTEM_AUX_SMES",
	"manual":"SYSTEM_AUX_SMES_MANUAL",
	"price":400000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var AUX_SMES_2 = {
	"system":"SYSTEM_AUX_SMES_MK2",
	"manual":"SYSTEM_AUX_SMES_MANUAL",
	"price":800000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var AUX_SMES_3 = {
	"system":"SYSTEM_AUX_SMES_MK3",
	"manual":"SYSTEM_AUX_SMES_MANUAL",
	"price":1200000,
	"testProtocol":"bootup",
	"slot_groups":{"slot_type":"AUX_POWER_SLOT"}
}
var CARGOBAY_STANDARD = {
	"system":"SYSTEM_CARGO_STANDARD",
	"manual":"SYSTEM_NONE_MANUAL",
	"testProtocol":"cargo",
	"default":true,
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var CARGOBAY_BAFFLES = {
	"system":"SYSTEM_CARGO_BAFFLES",
	"capabilityLock":true,
	"manual":"SYSTEM_CARGO_BAFFLES_MANUAL",
	"price":2000,
	"testProtocol":"cargo",
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var CARGOBAY_OREPURIFIER = {
	"system":"SYSTEM_CARGO_MPUDRY",
	"capabilityLock":true,
	"manual":"SYSTEM_CARGO_DRY_MANUAL",
	"price":120000,
	"testProtocol":"cargo",
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var CARGOBAY_RUSATOMMPU = {
	"system":"SYSTEM_CARGO_MPUFSO",
	"capabilityLock":true,
	"manual":"SYSTEM_CARGO_MPU_MANUAL",
	"price":350000,
	"testProtocol":"cargo",
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var CARGOBAY_NAKAMURAMPU = {
	"system":"SYSTEM_CARGO_MPU",
	"capabilityLock":true,
	"manual":"SYSTEM_CARGO_MPU_MANUAL",
	"price":500000,
	"testProtocol":"cargo",
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var CARGOBAY_STARBUSMSU = {
	"system":"SYSTEM_CARGO_MPUSML",
	"capabilityLock":true,
	"manual":"SYSTEM_CARGO_MPUSML_MANUAL",
	"price":900000,
	"testProtocol":"cargo",
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var CARGOBAY_VOYAGERMPU = {
	"system":"SYSTEM_CARGO_MPU_FAB",
	"capabilityLock":true,
	"manual":"SYSTEM_CARGO_MPU_FAB_MANUAL",
	"price":1500000,
	"testProtocol":"cargo",
	"slot_groups":{"slot_type":"CARGO_BAY"}
}
var AUTOPILOT_NONE = {
	"system":"SYSTEM_AUTOPILOT_NONE",
	"testProtocol":"autopilot",
	"slot_groups":{"slot_type":"AUTOPILOT"}
}
var AUTOPILOT_MLF = {
	"system":"SYSTEM_AUTOPILOT_MK1",
	"price":10000,
	"testProtocol":"autopilot",
	"slot_groups":{"slot_type":"AUTOPILOT"}
}
var AUTOPILOT_337 = {
	"system":"SYSTEM_AUTOPILOT_MK2",
	"price":27000,
	"testProtocol":"autopilot",
	"slot_groups":{"slot_type":"AUTOPILOT"}
}
var AUTOPILOT_NDCI = {
	"system":"SYSTEM_AUTOPILOT_MK3",
	"price":60000,
	"testProtocol":"autopilot",
	"slot_groups":{"slot_type":"AUTOPILOT"}
}
var AUTOPILOT_RACING = {
	"system":"SYSTEM_AUTOPILOT_RTYPE",
	"price":100000,
	"testProtocol":"autopilot",
	"storyFlag":"ringrace",
	"storyFlagMin":1,
	"slot_groups":{"slot_type":"AUTOPILOT"}
}
var AUTOPILOT_EIAA = {
	"system":"SYSTEM_AUTOPILOT_MK4",
	"price":150000,
	"testProtocol":"autopilot",
	"slot_groups":{"slot_type":"AUTOPILOT"}
}
var HUD_DUMMY = {
	"system":"SYSTEM_NONE",
	"specs":"",
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_HAL = {
	"system":"SYSTEM_HUD_HAL",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":500,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_PROSPECTOR = {
	"system":"SYSTEM_HUD_PROSPECTOR",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":3000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_K37 = {
	"system":"SYSTEM_HUD_TNTRL",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":4000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_K225 = {
	"system":"SYSTEM_HUD_AT225",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":6000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_PROSPECTOR_METRIC = {
	"system":"SYSTEM_HUD_PROSPECTOR_METRIC",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":10000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_OCP = {
	"system":"SYSTEM_HUD_OCP209",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":15000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_EIME = {
	"system":"SYSTEM_HUD_EIME",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":25000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_KITSUNE = {
	"system":"SYSTEM_HUD_KITSUNE",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":31000,
	"testProtocol":"hud",
	"slot_groups":{"slot_type":"HUD"}
}
var HUD_RACING = {
	"system":"SYSTEM_HUD_PROSPECTOR_BALD",
	"manual":"SYSTEM_HUD_MANUAL",
	"specs":"",
	"price":31000,
	"testProtocol":"hud",
	"storyFlag":"ringrace",
	"storyFlagMin":1,
	"slot_groups":{"slot_type":"HUD"}
}
var LIDAR_RADAR = {
	"system":"SYSTEM_LIDAR_RADAR",
	"price":5000,
	"testProtocol":"lidar",
	"slot_groups":{"slot_type":"LIDAR"}
}
var LIDAR_IRL360 = {
	"system":"SYSTEM_LIDAR_DOPPLER",
	"price":15000,
	"testProtocol":"lidar",
	"slot_groups":{"slot_type":"LIDAR"}
}
var LIDAR_IRL30 = {
	"system":"SYSTEM_LIDAR_DOPPLER_CONE",
	"price":25000,
	"testProtocol":"lidar",
	"slot_groups":{"slot_type":"LIDAR"}
}
var LIDAR_HIGH_RES = {
	"system":"SYSTEM_LIDAR_DOPPLER_HIRES",
	"price":90000,
	"testProtocol":"lidar",
	"slot_groups":{"slot_type":"LIDAR"}
}
var LIDAR_PHASED = {
	"system":"SYSTEM_LIDAR_OPA",
	"price":120000,
	"testProtocol":"lidar",
	"slot_groups":{"slot_type":"LIDAR"}
}
var RECON_STANDARD = {
	"system":"SYSTEM_RD_STANDARD",
	"price":10000,
	"testProtocol":"cargo",
	"default":true,
	"slot_groups":{"slot_type":"RECON_DRONE"}
}
var RECON_GRAVIMETRIC = {
	"system":"SYSTEM_RD_GRAVIMETRIC",
	"price":40000,
	"testProtocol":"drone",
	"slot_groups":{"slot_type":"RECON_DRONE"}
}
var RECON_MICROSEISMIC = {
	"system":"SYSTEM_RD_SPECTROMETER",
	"price":60000,
	"testProtocol":"remotecargo",
	"slot_groups":{"slot_type":"RECON_DRONE"}
}
var RECON_GUIDING = {
	"system":"SYSTEM_RD_GUIDING",
	"price":200000,
	"testProtocol":"drone",
	"control":"autopilot_guide_target",
	"slot_groups":{"slot_type":"RECON_DRONE"}
}
