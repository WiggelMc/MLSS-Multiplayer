---@class ConfigPresetClass
local config_preset = {}

---@type string
config_preset.text =
[[
; Mario & Luigi: Superstar Saga - Multiplayer Script for BizHawk
; Configuration



; Most Settings can be either `true` or `false`, if you want to change them, replace the existing value (eg. replace `false` with `true` or vice versa).
; Anything following a Semicolon (;) is a Comment and will be ignored
; You need to save this file and then reload the Script to apply changes to the Configuration.
; If the Script is running, you can use the Menu `Script > Refresh` or F5 in the Console
; If the Script is stopped, you have to double-click on the Script in the List (or Right Click > Toggle)
; You can delete, rename or move this file to have another Config generated on the next start



; Settings that change the gameplay
[Gameplay]

; Allow the Rear Player to Swap.
allow_lead_take = true

; Allow the Front Player to Swap.
allow_lead_give = true



; Settings providing the User with information
[Debug]

; Log all Buttons from Input Devices to the Console (useful for input configuration).
; They are displayed in the format `DeviceName InputName` (eg. `X1 DpadLeft` for the Button `DpadLeft` on Controller `X1`).
log_inputs = false

; Show the HUD, displaying the current input assignment.
show_hud = true

; Scale the size of the HUD (must be a number).
hud_size = 1.0

; Determine, in which corner of the Screen the HUD is displayed (must be any of [top_left, top_right, bottom_left, bottom_right]).
hud_position = bottom_left



; Configure Controls for either Player.
;
; The sections containing the controls are `[Mario]` and `[Luigi]`.
; All other sections (eg. those named `[Unused]`) are ignored.
;
; Layouts are defined and explained below, you can modify those or define your own by copying an existing one.
; If you need multiple devices for a single Player, leave the device blank
; and prepend the Inputs manually with the Device Name (eg. `left = X1 DpadLeft`) (see Layout `SplitXInputs`).
;
; If you need to find the Device Name or names for Buttons on your Controller, refer to the `log_inputs` Setting.
;
; If a Setting contains any one of Backslash (\), Equals (=), Semicolon (;) or a Bracket ([) (]), escape them by prepending a Backslash
; (eg. `Key\\\=\;` will evaluate to `Key\=;` ).
; Any Spaces and Tabs at the beginning and end of values are trimmed, if you need one of them, use `\s` for Space and
; `\t` for Tab (eg. `left = \sL E F T\t` will assign the value ` L E F T    ` to left)



[Mario] ; RecommendedXInputs
device = X1

left = DpadLeft
right = DpadRight
up = DpadUp
down = DpadDown
menu = Back
menu_confirm = A
menu_cancel = X
menu_start = Start
menu_L = LeftShoulder
menu_R = RightShoulder
action_perform = A
action_cycle = X
lead_take = B
lead_give = Y


[Luigi] ; RecommendedXInputs
device = X2

left = DpadLeft
right = DpadRight
up = DpadUp
down = DpadDown
menu = Back
menu_confirm = A
menu_cancel = X
menu_start = Start
menu_L = LeftShoulder
menu_R = RightShoulder
action_perform = A
action_cycle = X
lead_take = B
lead_give = Y



; An Example Layout listing the Controls.
[Unused] ; ExampleInputs

; Name of Input Device (Obtain using `log_inputs` Setting).
device =

; Directional Inputs (Dpad) (only for the Front Player or the current Player in Battle).
left =
right =
up =
down =

; Open the Menu (Select).
menu =

; Confirm (A) Button inside of Menus (this includes Dialog Boxes).
menu_confirm =

; Cancel (B) Button inside of Menus (this includes Dialog Boxes).
menu_cancel =

; More info (Start) inside of Menus (used mainly to see Controls in Minigames).
menu_start =

; Scroll Left (L) inside of Menus (this includes the difficulty selection in Battle).
menu_L =

; Scroll Right (R) inside of Menus (this includes the difficulty selection in Battle).
menu_R =

; Perform the current Action in the Overworld (A / B) (Also used as the Attack and Confirm button in Battle).
action_perform =

; Cycle through the available Actions in the Overworld (R / L).
action_cycle =

; Swap with the Front Player, if you are in the back (Start) (can be disabled in Settings).
lead_take =

; Swap with the Rear Player, if you are in the Front (Start) (can be disabled in Settings).
lead_give =



; The Recommended Input Layout for X-Input compatible Controllers.
[Unused] ; RecommendedXInputs
device = X1

left = DpadLeft
right = DpadRight
up = DpadUp
down = DpadDown
menu = Back
menu_confirm = A
menu_cancel = X
menu_start = Start
menu_L = LeftShoulder
menu_R = RightShoulder
action_perform = A
action_cycle = X
lead_take = B
lead_give = Y


; An alternative Input Layout for X-Input compatible Controllers,
; which is closer to the original controls of the game.
[Unused] ; ClassicXInputs
device = X1

left = DpadLeft
right = DpadRight
up = DpadUp
down = DpadDown
menu = Back
menu_confirm = A
menu_cancel = X
menu_start = Start
menu_L = LeftShoulder
menu_R = RightShoulder
action_perform = A
action_cycle = RightShoulder
lead_take = Start
lead_give = Start



; The Recommended Input Layout for the Mayflash N64 Controller Adapter for PC.
[Unused] ; RecommendedN64Inputs
device = J2

left = POV1L           ; Dpad Left
right = POV1R          ; Dpad Right
up = POV1U             ; Dpad Up
down = POV1D           ; Dpad Down
menu = B9              ; Start
menu_confirm = B2      ; A
menu_cancel = B3       ; B
menu_start = Z-        ; C Up
menu_L = B7            ; L
menu_R = B8            ; R
action_perform = B2    ; A
action_cycle = B3      ; B
lead_take = Z+         ; C Down
lead_give = RotationZ+ ; C Left


; An alternative Input Layout for the Mayflash N64 Controller Adapter for PC,
; which is closer to the original controls of the game.
[Unused] ; ClassicN64Inputs
device = J2

left = POV1L           ; Dpad Left
right = POV1R          ; Dpad Right
up = POV1U             ; Dpad Up
down = POV1D           ; Dpad Down
menu = Z-              ; C Up
menu_confirm = B2      ; A
menu_cancel = B3       ; B
menu_start = B9        ; Start
menu_L = B7            ; L
menu_R = B8            ; R
action_perform = B2    ; A
action_cycle = B8      ; R
lead_take = B9         ; Start
lead_give = B9         ; Start


; An Input Layout for X-Input compatible Controllers, split between a different Device for each hand.
; This is mostly intended as a demonstration of the Configuration Syntax.
[Unused] ; SplitXInputs
device =

left = X1 DpadLeft
right = X1 DpadRight
up = X1 DpadUp
down = X1 DpadDown
menu = X1 Back
menu_confirm = X2 A
menu_cancel = X2 X
menu_start = X2 Start
menu_L = X2 LeftShoulder
menu_R = X2 RightShoulder
action_perform = X2 A
action_cycle = X2 X
lead_take = X2 B
lead_give = X2 Y
]]

return config_preset
