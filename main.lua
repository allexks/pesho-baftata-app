-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() )

-- Global Variables
MONEY_SAVEFILE = system.pathForFile( "money.json", system.ApplicationSupportDirectory )

SCENES_DIR = "scenes."
MENU_SCENE = SCENES_DIR.."menu"
BAFTENE_SCENE = SCENES_DIR.."baftene"
TREPANE_SCENE = SCENES_DIR.."trepane"

ASSET_DIR = "assets/"

MENU_BACKGROUND_IMG = ASSET_DIR.."background.jpg"
TITLE_IMG = ASSET_DIR.."logo.png"
BTN_DEFAULT_IMG = ASSET_DIR.."button.png"
BTN_PRESSED_IMG = ASSET_DIR.."button-over.png"
MONEY_IMG = ASSET_DIR.."garageband.png"
JOINT_IMG = ASSET_DIR.."joint.png"
GRASS_IMG = ASSET_DIR.."grass.png"
PESHO_IMG =ASSET_DIR.."bafta3.png"

GAMING_FONT = "fonts/emulogic.ttf"

local composer = require "composer"

composer.gotoScene( MENU_SCENE )
