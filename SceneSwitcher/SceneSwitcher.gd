#written by: Gabrielle Geppet
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

#modified from https://www.nightquestgames.com/changing-scenes-in-godot-4-is-easy/

extends Node
class_name NSceneSwitch

# A collection of scenes in the game. Scenes are added through the Inspector panel
@export var Scenes : Dictionary = {}

# Alias of the currently selected scene
var m_CurrentSceneAlias : String = ""

# Description: Add a new scene to the scene collection
# Parameter sceneAlias: The alias used for finding the scene in the collection
# Parameter scenePath: The full path to the scene file in the file system
func AddScene(sceneAlias : String, scenePath : String) -> void:
	Scenes[sceneAlias] = scenePath
	
# Description: Remove an existing scene from the scene collection
# Parameter sceneAlias: The scene alias of the scene to remove from the collection
func RemoveScene(sceneAlias : String) -> void:
	Scenes.erase(sceneAlias)
	
# Description: Switch to the requested scene based on its alias
# Parameter sceneAlias: The scene alias of the scene to switch to
func SwitchScene(sceneAlias : String) -> void:
	get_tree().change_scene_to_file(Scenes[sceneAlias])


# Description: Restart the current scene
func RestartScene() -> void:
	get_tree().reload_current_scene()
	
# Description: Quit the game
func QuitGame() -> void:
	get_tree().quit()
	
# Description: Return the number of scenes in the collection
func GetSceneCount() -> int:
	return Scenes.size()
# Description: Returns the alias of the current scene
func GetCurrentSceneAlias() -> String:
	return m_CurrentSceneAlias
	
# Description: Find the initial scene as defined in the project settings
func _ready() -> void:
	var mainScene : StringName = "res://SceneSwitcher/GameScreens/HomeScreen.tscn"
	m_CurrentSceneAlias = Scenes.find_key(mainScene)
