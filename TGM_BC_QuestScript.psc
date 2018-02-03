Scriptname TGM_BC_QuestScript extends Quest
{ It just works. }

;/

Fallout 4 Papyrus script by ThoraldGM | https://modforge.net | Updated 20180203
Beer Chops mod: url pending
Mod is a proof of concept for flexible cooking recipes. Ersatz ingredients are robust and immersive.

The entire point of the mod is to demonstrate: Any Beer + Any Meat = Beer Chops (craft in cooking stations)

/;

; ------------------------------------------------------------------------------------------------------------
; PROPERTIES
; ------------------------------------------------------------------------------------------------------------

Group FoodGenerics
    Potion Property BC_Generic_Beer Auto Const Mandatory
    { Generic Beer }
    Potion Property BC_Generic_Meat Auto Const Mandatory
    { Generic Meat }
EndGroup

Group FoodVariants
    FormList Property BC_Variants_Beer Auto Const Mandatory
    { List of Beer Variants }
    FormList Property BC_Variants_Meat Auto Const Mandatory
    { List of Meat Variants }
EndGroup

Actor Player

Bool BC_OptionDevTracking Conditional

Int BeerGenericStartCount
Int BeerGenericEndCount
Int BeerVariantStartCount
Int BeerVariantEndCount

Int MeatGenericStartCount
Int MeatGenericEndCount
Int MeatVariantStartCount
Int MeatVariantEndCount

; ------------------------------------------------------------------------------------------------------------
; EVENT: ON QUEST INIT
; ------------------------------------------------------------------------------------------------------------

Event OnQuestInit()
    Player = Game.GetPlayer()
    BC_OptionDevTracking = True
    RegisterForMenuOpenCloseEvent("CookingMenu")                                        ; Hook into cooking menu events
    
    BC_DebugTraceBox("Beer Chops: OnQuestInit done!")
EndEvent

; ------------------------------------------------------------------------------------------------------------
; EVENT: ON MENU OPEN CLOSE EVENT
;
; Note that code does not stop player from crafting multiple recipes in one cooking station use!
; (Player could exploit this to double beer and meat in inventory. Solutions welcome.)
;
; Also note that "generic" beer and meat are forms in this mod, not the vanilla generics.
; Thus I can get away with using them as temporary "recipe currency" that only exist inside cooking station (IMPORTANT!)
;
; Beer Chops recipe: 1 generic beer + 1 generic meat
;
; ------------------------------------------------------------------------------------------------------------

Event OnMenuOpenCloseEvent(String asMenuName, Bool abOpening)
    Bool PlayerHasBC = Game.IsPluginInstalled("BeerChops.esp")                          ; Is Beer Chops mod installed?
    
    If PlayerHasBC                                                                      ; If Beer Chops mod is active...
        If asMenuName == "CookingMenu"                                                  ; If cooking menu
            If abOpening                                                                ; IS OPENING...
            
                BC_DebugTraceBox("Beer Chops: Cook hook!")
                
                ; ********************************************************************************************
                ; Add the temporary generics
                ; ********************************************************************************************

                BeerVariantStartCount = Player.GetItemCount(BC_Variants_Beer)           ; Count variant beer in inventory
                MeatVariantStartCount = Player.GetItemCount(BC_Variants_Meat)           ; Count variant meat in inventory
                
                BeerGenericStartCount = BeerVariantStartCount                           ; Beer generic inv = beer variant inv
                MeatGenericStartCount = MeatVariantStartCount                           ; Meat generic inv = meat variant inv
                
                Player.AddItem(BC_Generic_Beer, BeerGenericStartCount, true)            ; Silently add generic beer to inv
                Player.Additem(BC_Generic_Meat, MeatVariantStartCount, true)            ; Silently add generic meat to inv
                
                BC_DebugTraceBox("Beer Chops\nBVS: "+BeerVariantStartCount+" BGS: "+BeerGenericStartCount+" MVS: "+MeatVariantStartCount+" MGS: "+MeatGenericStartCount)
                
            Else                                                                        ; ELSE COOKING MENU IS CLOSING...
            
                ; ********************************************************************************************
                ; Remove the temporary generics
                ; ********************************************************************************************
                
                BeerGenericEndCount = Player.GetItemCount(BC_Generic_Beer)              ; Count generic beer left in inventory
                MeatGenericEndCount = Player.GetItemCount(BC_Generic_Meat)              ; Count generic meat left in inventory
                
                Player.RemoveItem(BC_Generic_Beer, BeerGenericEndCount, true)           ; Silently remove remaining generic beer
                Player.RemoveItem(BC_Generic_Meat, MeatGenericEndCount, true)           ; Silently remove remaining generic meat
            
                ; ********************************************************************************************
                ; Remove the variants that were "consumed" in crafting (if variants are still available!)
                ; ********************************************************************************************

                BeerVariantEndCount = Player.GetItemCount(BC_Variants_Beer)             ; Count variant beer left in inventory
                MeatVariantEndCount = Player.GetItemCount(BC_Variants_Meat)             ; Count variant meat left in inventory
                
                Int BeerVariantUsed = BeerVariantStartCount - BeerVariantEndCount       ; Calculate variant beer used
                Int MeatVariantUsed = MeatVariantStartCount - MeatVariantEndCount       ; Calculate variant meat used
                
                If BeerVariantEndCount > 0                                              ; If player has any beer left in inv...
                    If BeerVariantEndCount >= BeerVariantUsed                           ; If remainder is greater than consumed,
                        Player.RemoveItem(BC_Variants_Beer, BeerVariantUsed, true)      ; remove the consumed amount from inv.
                    Else                                                                ; Else player used more variants than generics,
                        Player.RemoveItem(BC_Variants_Beer, BeerVariantEndCount, true)  ; so just take away the remaining variants.
                    EndIf
                EndIf
                
                If MeatVariantEndCount > 0                                              ; If player has any meat left in inv...
                    If MeatVariantEndCount >= MeatVariantUsed                           ; If remainder is greater than consumed,
                        Player.RemoveItem(BC_Variants_Meat, MeatVariantUsed, true)      ; remove the consumed amount from inv.
                    Else                                                                ; Else player used more variants than generics,
                        Player.RemoveItem(BC_Variants_Meat, MeatVariantEndCount, true)  ; so just take away the remaining variants.
                    EndIf
                EndIf
                
            EndIf                                                                       ; End of close condition
        EndIf                                                                           ; End of cooking menu condition

    Else                                                                                ; Else Beer Chops mod is NOT installed...
        UnregisterForMenuOpenCloseEvent("CookingMenu")                                  ; so unhook from cooking menu events
    EndIf
EndEvent

; ------------------------------------------------------------------------------------------------------------
; CUSTOM FUNCTION: BC DEBUG TRACE BOX
; ------------------------------------------------------------------------------------------------------------

Function BC_DebugTraceBox(String TraceString)
    If BC_OptionDevTracking
        Debug.TraceAndBox(TraceString)
    EndIf
EndFunction
