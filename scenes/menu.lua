-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"
local json = require "json"


--------------------------------------------

local function getMoneyFromFile()
	local file = io.open( MONEY_SAVEFILE, "r" )
	local money

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		money = json.decode( contents )
	end

	if money==nil or money==0 then
		return 420 -- the default value in the beginning of the game or when
		-- the player runs out of money
	else
		return money
	end
end



-- forward declarations and other locals
local playBtn
local earnBtn
local highscoresBtn

local moneyLabel
local moneyIcon

local lowestY = display.contentHeight - 35


local function updateMoneyAmount()
	composer.setVariable( "money", getMoneyFromFile() )
	moneyLabel.text = composer.getVariable( "money" )
end

local function onPlayBtnRelease()

	composer.gotoScene( BAFTENE_SCENE, "fade", 500 )

	return true	-- indicates successful touch
end

-- 'onRelease' event listener for earnBtn
local function onEarnBtnRelease()

	composer.gotoScene( TREPANE_SCENE, "crossFade", 500 )

	return true
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- set money variable
	composer.setVariable( "money", getMoneyFromFile() )

	-- display a background image
	local background = display.newImageRect( MENU_BACKGROUND_IMG, display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( TITLE_IMG, 420, 50 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 69

	-- create a widget button (which will loads baftene.lua on release)
	playBtn = widget.newButton{
		label = "Бафтене",
		labelColor = { default={255}, over={128} },
		defaultFile = BTN_DEFAULT_IMG,
		overFile = BTN_PRESSED_IMG,
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX -175
	playBtn.y = lowestY - 90

	-- another widget button that loads trepane.lua
	earnBtn = widget.newButton{
		label = "Трепане",
		labelColor = {default={255}, over={128}},
		defaultFile = BTN_DEFAULT_IMG,
		overFile = BTN_PRESSED_IMG,
		width = 154, height = 40,
		onRelease = onEarnBtnRelease
	}
	earnBtn.x = display.contentCenterX -175
	earnBtn.y = lowestY - 45

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( earnBtn )

	-- create the label with the present money amount
	moneyLabel = display.newText( sceneGroup, "5?", display.contentCenterX + 160, lowestY, GAMING_FONT, 28 )
	moneyLabel.anchorX = 0
	-- left to it, put the icon of the Landcoins
	moneyIcon = display.newImageRect( MONEY_IMG, 36, 36 )
	moneyIcon.x = display.contentCenterX + 150
	moneyIcon.y = lowestY
	moneyIcon.anchorX = 1

	sceneGroup:insert( moneyIcon )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen

		updateMoneyAmount()

	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end

	if earnBtn then
		earnBtn:removeSelf()
		earnBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
