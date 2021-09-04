extends Panel

onready var button_edsm_downloads : MenuButton = $MarginContainer/VBoxContainer/GridContainer/BtEDSMDownloads
onready var edsm_downloads_popup : PopupMenu = button_edsm_downloads.get_popup()

func _ready():
	edsm_downloads_popup.clear()
	for d_type in data_reader.edsm_manager.files_download_urls.keys():
		edsm_downloads_popup.add_item(d_type)
	if !edsm_downloads_popup.is_connected("id_pressed", self, "_on_download_selected"):
		edsm_downloads_popup.connect("id_pressed",self,"_on_download_selected")

func _on_download_selected(_index):
	var download_url : String = ""
	var file_name : String = ""
	if data_reader.edsm_manager.files_download_urls.has(edsm_downloads_popup.get_item_text(_index)):
		download_url = data_reader.edsm_manager.files_download_urls[edsm_downloads_popup.get_item_text(_index)]
		file_name = download_url.get_file()
		data_reader.edsm_manager.download_edsm_file(file_name, download_url)
		logger.log_event("Downloading %s" % file_name)

func _on_BtResetDB_pressed():
	data_reader.dbm.clean_database()

func _on_Lbl7zPath_meta_clicked(meta):
	OS.shell_open(meta)
