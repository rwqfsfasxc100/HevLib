extends Node


static func dynamic_crew_expander(folder_path: String, max_crew:int = 24) -> String:
	
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	
	var log_header = "TSCN Writer for dynamic crew handler: "
	
	var base = 24
	
	var static_line_1 = "[gd_scene load_steps=3 format=2]"
	var static_line_3 = "[ext_resource path=\"res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn\" type=\"PackedScene\" id=1]"
	var static_line_4 = "[ext_resource path=\"res://comms/ConversationPlayer.gd\" type=\"Script\" id=2]"
	var static_line_6 = "[node name=\"DIALOG_DERELICT_RANDOM_1\" instance=ExtResource( 1 )]"

	var dynamic_line_1 = "[node name=\"DIALOG_DERELICT_SWITCH_CREW|%s\" type=\"Node\" parent=\".\" index=\"%s\"]"
	var dynamic_line_2 = "script = ExtResource( 2 )"
	var dynamic_line_3 = "myLine = false"
	var dynamic_line_4 = "faceless = true"
	var dynamic_line_5 = "importChildren = NodePath(\"../DIALOG_DERELICT_GO_AND_BRING_IT\")"
	var dynamic_line_6 = "agenda = \"CREW/%s\""
	var dynamic_line_7 = "agendaNotSame = true"
	
	
	if max_crew <= base:
		Debug.l(log_header + "desired expansion to [%s] is less than or equal to the base expansion of [24]" % max_crew)
		return ""
	else:
		var header = static_line_1 + "\n\n" + static_line_3 + "\n" + static_line_4 + "\n\n" + static_line_6 + "\n\n"
		
		var compacted_string = header
		
		while max_crew > base:
			base += 1
			
			var compact = dynamic_line_1 % [base,base + 4] + "\n" + dynamic_line_2 + "\n" + dynamic_line_3 + "\n" + dynamic_line_4 + "\n" + dynamic_line_5 + "\n" + dynamic_line_6 % base + "\n" + dynamic_line_7 + "\n\n"
			
			compacted_string = compacted_string + compact
		if not folder_path.ends_with("/"):
			folder_path = folder_path + "/"
		var save_file_path = folder_path + "/dynamic_crew_x%s.tscn" % base
		FolderAccess.__check_folder_exists(folder_path)
		var file = File.new()
		file.open(save_file_path,File.WRITE)
		file.store_string(compacted_string)
		file.close()
		
		return save_file_path
