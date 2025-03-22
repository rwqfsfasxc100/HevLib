extends Node
const MOD_PRIORITY = 0
const MOD_NAME = "HevLib"
const MOD_VERSION = "1.1.0"
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

var modConfig = {}
func _ready():
	l("Readying")
	updateTL("i18n/en.txt", "|")
	l("Ready")
	
func updateTL(path:String, delim:String = ","):
	path = str(modPath + path)
	l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)

	var translations := []

	var csvLine := tlFile.get_line().split(delim)
	l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)

	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)

		if csvLine.size() > 1:
			var translationID := csvLine[0]
			for i in range(1, csvLine.size()):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			l("Added translation: %s" % csvLine)

	tlFile.close()

	for translationObject in translations:
		TranslationServer.add_translation(translationObject)

	l("Translations Updated")

func l(msg:String, title:String = MOD_NAME):
	Debug.l("[%s]: %s" % [title, msg])
	
