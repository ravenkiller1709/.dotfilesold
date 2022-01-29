import XMonad
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Hooks.ManageDocks
import XMonad.Actions.TagWindows
import XMonad.Hooks.DynamicLog
import Data.Char
import XMonad.Actions.WorkspaceNames
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Magnifier
import XMonad.Util.Loggers

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " . "
    , ppTitleSanitize    = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused    = wrap (white      "[") (white      "]") . magenta . ppWindow
    formatUnfocused  = wrap (lowWhite   "[") (lowWhite   "]") . blue    . ppWindow
    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""

main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey 
     $ myConfig
  where
    toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
    toggleStrutsKey XConfig{ modMask = m } = (m, xK_b)

myConfig = def
    { terminal    = myTerminal
    , modMask     = myModMask
    , workspaces = myWorkspaces
    , borderWidth = myBorderWidth
    , focusedBorderColor = myBorderColor
    , normalBorderColor = myNormalColor
    , layoutHook= myLayout
    }
    `additionalKeysP`
    [ ("M-S-z", spawn "xscreensaver-command -lock")
    , ("M-S-=", unGrab *> spawn "scrot -s"        )
    , ("M-w"  , spawn "firefox"                   )
    ]

myTerminal    = "st"
myModMask     = mod4Mask -- Win key or Super_L
myBorderWidth = 3
myBorderColor = "#ffffff"
myNormalColor = "#696969"
myWorkspaces  = ["term","www","cod","gfx","vid","mus"] 
myLayout      = tiled ||| Mirror tiled ||| Full ||| threeCol
  where
    threeCol  = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    tiled     = Tall nmaster delta ratio
    nmaster   = 1        -- Default number of windows in the master pane
    ratio     = 1/2      -- Default proportion of screen occupied by master pane
    delta     = 3/100    -- Percent of screen to increment by when resizing panes
