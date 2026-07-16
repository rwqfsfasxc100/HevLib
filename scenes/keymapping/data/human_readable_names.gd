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

const bind_names = {
	"Mouse 1":"Mouse Left",
	"Mouse 2":"Mouse Right",
	"Mouse 3":"Mouse Middle",
	"Mouse 8":"Mouse Side1",
	"Mouse 9":"Mouse Side2",
	"Mouse 4":"Mouse WheelUp",
	"Mouse 5":"Mouse WheelDown",
	"Mouse 6":"Mouse WheelLeft",
	"Mouse 7":"Mouse WheelRight",
	"JoyButton 0":"JoyButton A",
	"JoyButton 1":"JoyButton B",
	"JoyButton 2":"JoyButton X",
	"JoyButton 3":"JoyButton Y",
	"JoyButton 12":"JoyButton DpadUp",
	"JoyButton 13":"JoyButton DpadDown",
	"JoyButton 14":"JoyButton DpadLeft",
	"JoyButton 15":"JoyButton DpadRight",
	"JoyButton 4":"JoyButton BumperLeft",
	"JoyButton 5":"JoyButton BumperRight",
	"JoyButton 6":"JoyButton TriggerLeft",
	"JoyButton 7":"JoyButton TriggerRight",
	"JoyButton 10":"JoyButton Select",
	"JoyButton 11":"JoyButton Menu",
	"JoyButton 8":"JoyButton StickLeft",
	"JoyButton 9":"JoyButton StickRight",
	"JoyAxis 0":"JoyAxis LeftHorizontal",
	"JoyAxis 1":"JoyAxis LeftVertical",
	"JoyAxis 2":"JoyAxis RightHorizontal",
	"JoyAxis 3":"JoyAxis RightVertical",
	"JoyAxis 6":"JoyAxis LeftTrigger",
	"JoyAxis 7":"JoyAxis RightTrigger",
}

const bind_names_inverted = {
	"Mouse Left":"Mouse 1",
	"Mouse Right":"Mouse 2",
	"Mouse Middle":"Mouse 3",
	"Mouse Side1":"Mouse 8",
	"Mouse Side2":"Mouse 9",
	"Mouse WheelUp":"Mouse 4",
	"Mouse WheelDown":"Mouse 5",
	"Mouse WheelLeft":"Mouse 6",
	"Mouse WheelRight":"Mouse 7",
	"JoyButton A":"JoyButton 0",
	"JoyButton B":"JoyButton 1",
	"JoyButton X":"JoyButton 2",
	"JoyButton Y":"JoyButton 3",
	"JoyButton DpadUp":"JoyButton 12",
	"JoyButton DpadDown":"JoyButton 13",
	"JoyButton DpadLeft":"JoyButton 14",
	"JoyButton DpadRight":"JoyButton 15",
	"JoyButton BumperLeft":"JoyButton 4",
	"JoyButton BumperRight":"JoyButton 5",
	"JoyButton TriggerLeft":"JoyButton 6",
	"JoyButton TriggerRight":"JoyButton 7",
	"JoyButton Select":"JoyButton 10",
	"JoyButton Menu":"JoyButton 11",
	"JoyButton StickLeft":"JoyButton 8",
	"JoyButton StickRight":"JoyButton 9",
	"JoyAxis LeftHorizontal":"JoyAxis 0",
	"JoyAxis LeftVertical":"JoyAxis 1",
	"JoyAxis RightHorizontal":"JoyAxis 2",
	"JoyAxis RightVertical":"JoyAxis 3",
	"JoyAxis LeftTrigger":"JoyAxis 6",
	"JoyAxis RightTrigger":"JoyAxis 7",
}
