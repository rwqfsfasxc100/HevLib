extends Node

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

const SHIP_MODIFY = {
	"SHIP_AT225":{
		"middleLeft":{
			"SYSTEM_SCOOP-L":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 80 )"
				},
				{
					"property":"rotation",
					"value":"0.174533"
				}
			],
			"SYSTEM_PDT-L":[
				{
					"property":"position",
					"value":"Vector2( -69, -71 )"
				}
			]
		},
		"middleRight":{
			"SYSTEM_SCOOP-R":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 80 )"
				},
				{
					"property":"rotation",
					"value":"0.174533"
				}
			],
			"SYSTEM_PDT-R":[
				{
					"property":"position",
					"value":"Vector2( 69, -71 )"
				}
			]
		},
		"leftBay1":{
			"SYSTEM_PDMWG-L":[
				{
					"property":"position",
					"value":"Vector2( -200, 81 )"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-L":[
				{
					"property":"rotation",
					"value":"-0.174533"
				}
			],
			"SYSTEM_PDT-L":[
				{
					"property":"position",
					"value":"Vector2( -190, 0 )"
				},
				{
					"property":"rotation",
					"value":"-1.0472"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
		},
		"rightBay1":{
			"SYSTEM_PDMWG-R":[
				{
					"property":"position",
					"value":"Vector2( 200, 81 )"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-R":[
				{
					"property":"rotation",
					"value":"0.174533"
				}
			],
			"SYSTEM_PDT-R":[
				{
					"property":"position",
					"value":"Vector2( 190, 0 )"
				},
				{
					"property":"rotation",
					"value":"1.0472"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
		},
		"leftBay2":{
			"SYSTEM_PDMWG-L":[
				{
					"property":"position",
					"value":"Vector2( -200, 81 )"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-L":[
				{
					"property":"rotation",
					"value":"-0.174533"
				}
			],
			"SYSTEM_PDT-L":[
				{
					"property":"position",
					"value":"Vector2( -190, 0 )"
				},
				{
					"property":"rotation",
					"value":"-1.0472"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
		},
		"rightBay2":{
			"SYSTEM_PDMWG-R":[
				{
					"property":"position",
					"value":"Vector2( 200, 81 )"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-R":[
				{
					"property":"rotation",
					"value":"0.174533"
				}
			],
			"SYSTEM_PDT-R":[
				{
					"property":"position",
					"value":"Vector2( 190, 0 )"
				},
				{
					"property":"rotation",
					"value":"1.0472"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
		},
		"leftBay3":{
			"SYSTEM_PDMWG-L":[
				{
					"property":"position",
					"value":"Vector2( -200, 81 )"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-L":[
				{
					"property":"rotation",
					"value":"-0.174533"
				}
			],
			"SYSTEM_PDT-L":[
				{
					"property":"position",
					"value":"Vector2( -190, 0 )"
				},
				{
					"property":"rotation",
					"value":"-1.0472"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
		},
		"rightBay3":{
			"SYSTEM_PDMWG-R":[
				{
					"property":"position",
					"value":"Vector2( 200, 81 )"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-R":[
				{
					"property":"rotation",
					"value":"0.174533"
				}
			],
			"SYSTEM_PDT-R":[
				{
					"property":"position",
					"value":"Vector2( 190, 0 )"
				},
				{
					"property":"rotation",
					"value":"1.0472"
				},
				{
					"property":"z_index",
					"value":"27"
				}
			],
		}
	},
	"SHIP_COTHON":{
		"left":{
			"SYSTEM_HUNK-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 80 )"
				},
				{
					"property":"rotation",
					"value":"0.174533"
				}
			]
		},
		"right":{
			"SYSTEM_HUNK-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 80 )"
				},
				{
					"property":"rotation",
					"value":"-0.174533"
				}
			]
		},
		"leftBack":{
			"SYSTEM_PDMWG-L":[
				{
					"property":"position",
					"value":"Vector2( -150, 180 )"
				},
				{
					"property":"rotation",
					"value":"-2.0944"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-L":[
				{
					"property":"rotation",
					"value":"-0.174533"
				}
			],
			"SYSTEM_PDT-L":[
				{
					"property":"position",
					"value":"Vector2( -146, 165 )"
				},
				{
					"property":"rotation",
					"value":"-2.0944"
				},
				{
					"property":"z_index",
					"value":"18"
				}
			]
		},
		"rightBack":{
			"SYSTEM_PDMWG-R":[
				{
					"property":"position",
					"value":"Vector2( 150, 180 )"
				},
				{
					"property":"rotation",
					"value":"2.0944"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"command",
					"value":"\"\""
				},
				{
					"property":"passFireAsCommand",
					"value":"\"\""
				}
			],
			"SYSTEM_HUNK-R":[
				{
					"property":"rotation",
					"value":"0.174533"
				}
			],
			"SYSTEM_PDT-R":[
				{
					"property":"position",
					"value":"Vector2( 146, 165 )"
				},
				{
					"property":"rotation",
					"value":"2.0944"
				},
				{
					"property":"z_index",
					"value":"18"
				}
			]
		}
	},
	"SHIP_PROSPECTOR":{
		"left":{
			"SYSTEM_EXSTORAGE-L":[
				{
					"property":"position",
					"value":"Vector2( 48, -86 )"
				},
				{
					"property":"z_index",
					"value":"-10"
				}
			],
			"SYSTEM_CLAIM-L":[
				{
					"property":"position",
					"value":"Vector2( 60, 60 )"
				}
			],
			"SYSTEM_ACTEMD14":[
				{
					"property":"position",
					"value":"Vector2( -15, 0 )"
				},
				{
					"property":"rotation",
					"value":"-0.0174533"
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"position",
					"value":"Vector2( 52, -100 )"
				}
			],
			"SYSTEM_HUNK-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 176 )"
				}
			],
			"SYSTEM_EXMONO-L":[
				{
					"property":"position",
					"value":"Vector2( 48, -86 )"
				},
				{
					"property":"z_index",
					"value":"-10"
				}
			]
		},
		"right":{
			"SYSTEM_EXSTORAGE-R":[
				{
					"property":"position",
					"value":"Vector2( -48, -86 )"
				},
				{
					"property":"z_index",
					"value":"-10"
				}
			],
			"SYSTEM_CLAIM-R":[
				{
					"property":"position",
					"value":"Vector2( -60, 60 )"
				}
			],
			"SYSTEM_ACTEMD14":[
				{
					"property":"position",
					"value":"Vector2( 15, 0 )"
				},
				{
					"property":"rotation",
					"value":"0.0174533"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"position",
					"value":"Vector2( -52, -100 )"
				}
			],
			"SYSTEM_HUNK-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 176 )"
				}
			],
			"SYSTEM_EXMONO-R":[
				{
					"property":"position",
					"value":"Vector2( -48, -86 )"
				},
				{
					"property":"z_index",
					"value":"-10"
				}
			]
		}
	},
	"SHIP_PROSPECTOR_VP":{
		"left":{
			"SYSTEM_CLAIM-L":[
				{
					"property":"position",
					"value":"Vector2( 50, 60 )"
				}
			],
		},
		"right":{
			"SYSTEM_CLAIM-R":[
				{
					"property":"position",
					"value":"Vector2( -50, 60 )"
				}
			],
		},
	},
	"SHIP_EIME":{
		"left":{
			"SYSTEM_EXSTORAGE-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
			"SYSTEM_CLAIM-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
			"SYSTEM_SCOOP-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
			"SYSTEM_EXMONO-L":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
		},
		"right":{
			"SYSTEM_EXSTORAGE-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
			"SYSTEM_CLAIM-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
			"SYSTEM_SCOOP-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
			"SYSTEM_EXMONO-R":[
				{
					"property":"position",
					"value":"Vector2( 0, 64 )"
				}
			],
		},
	},
#	"SHIP_OCP209":{
#		"mainLeft":{
#			"SYSTEM_SALVAGE_ARM":[
#				{
#					"property":"flip",
#					"value":"true"
#				},
#				{
#					"property":"feedVelocity",
#					"value":"Vector2( -140, -280 )"
#				},
#			]
#		},
#		"mainRight":{
#			"SYSTEM_SALVAGE_ARM":[
#				{
#					"property":"feedVelocity",
#					"value":"Vector2( 140, -280 )"
#				},
#			]
#		},
#	},
	"SHIP_TRTL_K44":{
		"leftBack":{
			"SYSTEM_HUNK-L":[
				{
					"property":"position",
					"value":"Vector2( -40, 222 )"
				},
				{
					"property":"rotation",
					"value":"-0.523599"
				}
			],
			"SYSTEM_PDT-L":[
				{
					"property":"position",
					"value":"Vector2( -124, 211 )"
				},
				{
					"property":"rotation",
					"value":"-2.0944"
				},
			]
		},
		"rightBack":{
			"SYSTEM_HUNK-R":[
				{
					"property":"position",
					"value":"Vector2( 40, 222 )"
				},
				{
					"property":"rotation",
					"value":"0.523599"
				}
			],
			"SYSTEM_PDT-R":[
				{
					"property":"position",
					"value":"Vector2( 124, 211 )"
				},
				{
					"property":"rotation",
					"value":"2.0944"
				}
			]
		}
	}
}
