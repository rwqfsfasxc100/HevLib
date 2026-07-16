extends PanelContainer

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

var link_button = preload("res://HevLib/ui/mod_menu/urls/URL_BUTTON.tscn")

var MOD_INFO : Dictionary = {}

var pointers = ModLoader._savedObjects[0]

func update():
	var b : Node = $VBoxContainer/ScrollContainer/VBoxContainer
	for object in b.get_children():
		Tool.remove(object)
	var manifestData = MOD_INFO["manifest"]["manifest_data"]
	var links : Dictionary = {}
	if manifestData:
		links = manifestData["links"]
	var nodes : Array = []
	if links:
		for link in links:
			
			var URL : String = links[link].get("URL","")
			if URL and pointers.DataFormat.__is_valid_url(URL):
				var node : Object = link_button.instance()
				node.url = URL
				node.name = link
				node.icon_path = match_builtin_icon(link,links[link].get("ICON","res://HevLib/ui/themes/icons/alias.stex"))
				node.tooltip = match_builtin_tooltip(link,links[link].get("TOOLTIP",""))
				node.text = link
				nodes.append(node)
#	breakpoint
	for node in nodes:
		b.add_child(node)


func match_builtin_icon(link_name : String,icon : String = "res://HevLib/ui/themes/icons/alias.stex") -> String:
	
	match link_name:
		"HEVLIB_GITHUB":
			return "res://HevLib/ui/themes/icons/github.stex"
		"HEVLIB_DISCORD":
			return "res://HevLib/ui/themes/icons/discord.stex"
		"HEVLIB_NEXUS":
			return "res://HevLib/ui/themes/icons/nexus.stex"
		"HEVLIB_DONATIONS":
			return "res://HevLib/ui/themes/icons/donations.stex"
		"HEVLIB_WIKI":
			return "res://HevLib/ui/themes/icons/wiki.stex"
		"HEVLIB_BUGREPORTS":
			return "res://HevLib/ui/themes/icons/bug.stex"
		_:
			return icon
			
func match_builtin_tooltip(link_name : String,tooltip : String) -> String:
	
	match link_name:
		"HEVLIB_GITHUB":
			return "HEVLIB_GITHUB_TOOLTIP"
		"HEVLIB_DISCORD":
			return "HEVLIB_DISCORD_TOOLTIP"
		"HEVLIB_NEXUS":
			return "HEVLIB_NEXUS_TOOLTIP"
		"HEVLIB_DONATIONS":
			return "HEVLIB_DONATIONS_TOOLTIP"
		"HEVLIB_WIKI":
			return "HEVLIB_WIKI_TOOLTIP"
		"HEVLIB_BUGREPORTS":
			return "HEVLIB_BUGREPORTS_TOOLTIP"
		_:
			return tooltip
