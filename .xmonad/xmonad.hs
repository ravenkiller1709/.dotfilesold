import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import XMonad.ManageHook
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
import XMonad.Hooks.ManageHelpers
import XMonad.Util.NamedScratchpad
import XMonad.Util.ClickableWorkspaces
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.MultiColumns

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , className =? "st-256color" --> doFloat
    , isDialog            --> doFloat
    ]

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " . "
    , ppTitleSanitize   = xmobarStrip
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
    , workspaces  = myWorkspaces
    , borderWidth = myBorderWidth
    , focusedBorderColor = myBorderColor
    , normalBorderColor = myNormalColor
    , layoutHook = myLayout
    , manageHook = myManageHook
    }
    `additionalKeysP`
    [ ("M-S-z", spawn "betterlockscreen -l")
    , ("M-S-<Left>", unGrab *> spawn "scrot -s"        )
    , ("M-w"  , spawn "brave-browser-nightly"                   )
    , ("M-a"  , spawn "alacritty"                   )
    , ("M-m"  , spawn "alacritty -e neomutt")
    , ("M-n"  , spawn "st -g 70x30+600-200 -e ~/.scripts/notetaker -t notetaker_window")
    , ("M-S-n", spawn "~/.scripts/mostRecentNote")
    , ("M-x"  , spawn "/home/kim/.local/bin/sysact"                   )
    , ("M-S-t", namedScratchpadAction myScratchPads "terminal")
    , ("M-S-m", namedScratchpadAction myScratchPads "musik")
    , ("M-C-c", namedScratchpadAction myScratchPads "lommeregner")
    , ("<XF86AudioRaiseVolume>"  , spawn "amixer -q sset Master 5%+") 
    , ("<XF86AudioLowerVolume>"  , spawn "amixer -q sset Master 5%-") 
    , ("<XF86AudioMute>"         , spawn "amixer set Master toggle") 
    , ("<XF86MonBrightnessUp>"   , spawn "xbacklight -inc 5%") 
    , ("<XF86MonBrightnessDown>" , spawn "xbacklight -dec 5%") 
    ]

myTerminal    = "alacritty"
myModMask     = mod4Mask -- Win key or Super_L
myBorderWidth = 3
myBorderColor = "#ffffff"
myNormalColor = "#696969"
myWorkspaces  = ["term","www","cod","gfx","vid","mus"] 
myLayout      = tiled ||| Mirror tiled ||| Full ||| threeCol ||| spiral (6/7) ||| Grid ||| multiCol [1] 1 0.01 (-0.5)
  where
    threeCol  = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    tiled     = Tall nmaster delta ratio
    nmaster   = 1        -- Default number of windows in the master pane
    ratio     = 1/2      -- Default proportion of screen occupied by master pane
    delta     = 3/100    -- Percent of screen to increment by when resizing panes

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "musik" spawnNcmpcpp findNcmpcpp manageNcmpcpp
                , NS "lommeregner" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnNcmpcpp  =  "urxvt -e ncmpcpp"
    findNcmpcpp   = className =? "URxvt"
    manageNcmpcpp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

