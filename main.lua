display.setStatusBar( display.HiddenStatusBar )

local composer = require( "composer" )
composer.recycleOnSceneChange = true

composer.gotoScene( "Scenes.game", { time=500, effect="crossFade" } )

-- TODO: Add more scenes
