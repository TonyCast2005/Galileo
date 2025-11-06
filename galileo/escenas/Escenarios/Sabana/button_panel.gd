extends Button
@export var panel: PanelContainer

func _pressed():
    if panel:
        panel.toggle_panel()
