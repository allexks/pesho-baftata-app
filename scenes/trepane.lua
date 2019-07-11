-----------------------------------------------------------------------------------------
--
-- trepane.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"
local physics = require "physics"
local json = require "json"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH = display.actualContentWidth, display.actualContentHeight
local safeW, safeH = display.safeActualContentWidth, display.safeActualContentHeight
local halfW = display.contentCenterX
local originX, originY = display.screenOriginX, display.screenOriginY
local safeOriginX, safeOriginY = display.safeScreenOriginX, display.safeScreenOriginY
local backgroundGroup, mainGroup, uiGroup
local pesho
local characterHP = 420
local coinsTable = {}
local moneyLabel, moneyIcon
local jointButton


local function spawnCoin()
	local coin = display.newImageRect( mainGroup, MONEY_IMG, 42, 42 )

	table.insert( coinsTable, coin )

	physics.addBody( coin, { radius=20, friction=0.8, bounce=0.69 } )
	coin.x, coin.y = math.random( 160, screenW+30 ), -100
	coin.myName = "coin"
	coin:setLinearVelocity( math.random( -42, -5 ), 0 )
	coin:applyTorque( math.random( -4, -2 ) )
end

local function dragPesho( event )

	local pesho = event.target
	local phase = event.phase

	if phase=="began" then
		display.currentStage:setFocus( pesho )
		pesho.touchOffsetY = event.y - pesho.y

	elseif phase=="moved" then
		pesho.y = event.y - pesho.touchOffsetY

	elseif phase=="ended" or phase=="cancelled" then
		display.currentStage:setFocus( nil )
	end
end

local function fireBlunt()
	local newBlunt = display.newImageRect( mainGroup, JOINT_IMG, 50, 12 )
	physics.addBody( newBlunt, "dynamic", {isSensor = true} )
	newBlunt.isBullet = true
	newBlunt.myName = "blunt"

	newBlunt.x, newBlunt.y = pesho.x, pesho.y

	newBlunt:toBack()

	transition.to(newBlunt, {
		x=2000,
		time=500,
		onComplete = function( ) display.remove(newBlunt ) end
	})
end

local function saveMoneyAmount()
	local money = composer.getVariable( "money" )

	local file = io.open( MONEY_SAVEFILE, "w" )

	if file then
		file:write( json.encode( money ) )
		io.close( file )
	end
end

local function endGame()
	saveMoneyAmount()
	composer.gotoScene( MENU_SCENE, {effect="crossFade"} )
end

local function addMoney( number )
	local money = composer.getVariable( "money" )

	money = money + number

	composer.setVariable( "money", money )

	if money <= 0 then
		composer.setVariable( "money", 0 )
		money = 0
		endGame()
	end

	moneyLabel.text = money
end

local function addHP( number )
	characterHP = characterHP + number
	hpLabel.text = characterHP.."HP"

	if characterHP <= 0 then
		endGame()
	end
end

local function onCollision( event )
	local obj1 = event.object1
	local obj2 = event.object2

	if (obj1.myName == "coin" and obj2.myName == "blunt") or
		( obj1.myName == "blunt" and obj2.myName == "coin" )
	then
		display.remove( obj1 )
		display.remove( obj2 )

		for i=#coinsTable, 1, -1 do
			if coinsTable[i]==obj1 or coinsTable[i]==obj2 then
				table.remove( coinsTable, i )
				break
			end
		end

		addMoney(1)

	elseif (obj1.myName == "Pesho Baftata" and obj2.myName == "coin") or
		( obj1.myName == "coin" and obj2.myName == "Pesho Baftata" )
	then
		local coin, pesho
		if obj1.myName=="coin" then
			coin = obj1
			pesho = obj2
		else
			coin = obj2
			pesho = obj1
		end

		display.remove( coin )

		for i=#coinsTable, 1, -1 do
			if coinsTable[i]==coin then
				table.remove( coinsTable, i )
				break
			end
		end

		addHP( -42 )
	end
end

local function gameLoop()

	spawnCoin()

	for i = #coinsTable, 1, -1 do
		local thisCoin = coinsTable[i]

		if (thisCoin.x > (display.contentWidth + 200) or
			thisCoin.x < -100 or
			thisCoin.y < -100 or
			thisCoin.y > display.contentHeight)
		then
			display.remove( thisCoin )
			table.remove( coinsTable, i )
		end
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()

	-- add display groups to scene group
	backgroundGroup = display.newGroup() -- for the background
	sceneGroup:insert( backgroundGroup )

	mainGroup = display.newGroup() -- for the Pesho, and coins
	sceneGroup:insert( mainGroup )

	uiGroup = display.newGroup() -- for the UI elements, such as money, etc.
	sceneGroup:insert( uiGroup )

	-- draw background
	local background = display.newRect( backgroundGroup, originX, originY, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( 0.3, 0.3, 0.9 ) -- blueish

	-- create Pesho Baftata
	--local peshoOutline = graphics.newOutline( 5, "bafta3.png" )
	pesho = display.newImageRect( mainGroup, PESHO_IMG, 200, 130 )
	local peshoShape = { -55,35, -5,35, -5,0, 33,-5, -20,-65, -40,-65 }
	physics.addBody( pesho, "static", { shape = peshoShape } )
	pesho.x, pesho.y = 10, originY + 150
	pesho.myName = "Pesho Baftata" -- hahaa


	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( mainGroup, GRASS_IMG, screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	grass.x, grass.y = originX, display.actualContentHeight + originY
	physics.addBody( grass, "static", { friction=0.3 } )

	local uiPosY = screenH - 36 -- Y coordinate of the center of the botton UI elements

	-- create HP label
	hpLabel = display.newText( uiGroup, characterHP.."HP", 10, uiPosY, GAMING_FONT, 26)

	-- create the label with the present money amount
	moneyLabel = display.newText( uiGroup, composer.getVariable( "money" ), display.contentCenterX - 15, uiPosY , GAMING_FONT, 32 )
	moneyLabel.anchorX = 0
	-- left to it, put the icon of the Landcoins
	moneyIcon = display.newImageRect( uiGroup, MONEY_IMG, 50, 50 )
	moneyIcon.x = display.contentCenterX - 25
	moneyIcon.y = uiPosY
	moneyIcon.anchorX = 1

	-- create first weapon button (joint)
	jointButton = widget.newButton {
		defaultFile = JOINT_IMG,
		overFile = JOINT_IMG,
		width = 65, height = 18,
		onPress = fireBlunt
	}
	jointButton.x = safeW - 88
	jointButton.y = uiPosY
	mainGroup:insert( jointButton )

	-- add event listeners
	pesho:addEventListener( "touch", dragPesho )
	pesho:addEventListener( "tap", fireBlunt )
	Runtime:addEventListener( "collision", onCollision )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
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

		timer.cancel( gameLoopTimer )

	elseif phase == "did" then
		-- Called when the scene is now off screen

		physics.stop()

		--pesho:removeEventListener( "touch", dragPesho )
		--pesho:removeEventListener( "tap", fireBlunt )
		Runtime:removeEventListener( "collision", onCollision )

		composer.removeScene( TREPANE_SCENE )
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	if jointButton then
		jointButton:removeSelf()
		jointButton = nil
	end

	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
