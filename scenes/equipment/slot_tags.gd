extends Node
const ADDITIVES = [
"HARDPOINT", # - Any hardpoint
"HARDPOINT_LOW_STRESS", # - Any low-stress hardpoint
"HARDPOINT_HIGH_STRESS", # - Any high-stress hardpoint
"HARDPOINT_SPINAL", # - Any hardpoint w/o side access
"HARDPOINT_LEFT", # - Any left hardpoint
"HARDPOINT_RIGHT", # - Any right hardpoint
"HARDPOINT_CENTER", # - Any central hardpoint
"HARDPOINT_SIDE", # - Any hardpoint with side access
"HARDPOINT_REAR", # - Any rear hardpoint
"HARDPOINT_DOCKING_BAY", # - A docking-bay type hardpoint
"HARDPOINT_DRONE_POINT", # - A drone hardpoint
"HARDPOINT_DRONE_EMITTER", # - Any drone equipment
"HARDPOINT_TURRET", # - Any turreted equipment
"HARDPOINT_CRADLE", # - Any cradled equipment
"HARDPOINT_CARGO_CONTAINER", # - Any cargo container like equipment
"HARDPOINT_MINING_COMPANION", # - Any mining companion like equipment
"HARDPOINT_IMPACT_ABSORBER", # - Any impact absorber like equipment
"HARDPOINT_FRONT_FACING_WEAPON", # - Any front-facing equipment
"HARDPOINT_PLASMA_THROWER", # - Any plasma thrower equipment
"HARDPOINT_MANIPULATION_ARM", #- Any manipulator
"HARDPOINT_MASS_DRIVER", # - Any mass driver equipment
"HARDPOINT_RAILGUN", # - Any railgun like equipment
"HARDPOINT_COILGUN", # - Any coilgun like equipment
"HARDPOINT_IRON_THROWER", # - Any iron thrower like equipment
"HARDPOINT_MINING_LASER", # - Any mining laser like equipment
"HARDPOINT_MICROWAVE", # - Any microwave emitter like equipment
"HARDPOINT_SYNCHROTRON", # - Any synchrotron like equipment
"HARDPOINT_BEACON", # - Any beacon like equipment
]
const SUBTRACTIVES = [
"NOT_HARDPOINT_LEFT", # - Any left hardpoint
"NOT_HARDPOINT_RIGHT", # - Any right hardpoint
"NOT_HARDPOINT_CENTER", # - Any central hardpoint
"NOT_HARDPOINT_SIDE", # - Any hardpoint with side access
"NOT_HARDPOINT_REAR", # - Any rear hardpoint
"NOT_HARDPOINT_DRONE_EMITTER", # - Any drone equipment
"NOT_HARDPOINT_TURRET", # - Any turreted equipment
"NOT_HARDPOINT_CRADLE", # - Any cradled equipment
"NOT_HARDPOINT_CARGO_CONTAINER", # - Any cargo container like equipment
"NOT_HARDPOINT_MINING_COMPANION", # - Any mining companion like equipment
"NOT_HARDPOINT_IMPACT_ABSORBER", # - Any impact absorber like equipment
"NOT_HARDPOINT_FRONT_FACING_WEAPON", # - Any front-facing equipment
"NOT_HARDPOINT_PLASMA_THROWER", # - Any plasma thrower equipment
"NOT_HARDPOINT_MANIPULATION_ARM", # - Any manipulator
"NOT_HARDPOINT_MASS_DRIVER", # - Any mass driver equipment
"NOT_HARDPOINT_RAILGUN", # - Any railgun like equipment
"NOT_HARDPOINT_COILGUN", # - Any coilgun like equipment
"NOT_HARDPOINT_IRON_THROWER", # - Any iron thrower like equipment
"NOT_HARDPOINT_MINING_LASER", # - Any mining laser like equipment
"NOT_HARDPOINT_MICROWAVE", # - Any microwave emitter like equipment
"NOT_HARDPOINT_SYNCHROTRON", # - Any synchrotron like equipment
"NOT_HARDPOINT_BEACON", # - Any beacon like equipment
]
