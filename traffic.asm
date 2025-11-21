;=====================================================================
; AT89C51 Traffic Light Controller -
; Features:
;   - Day Mode (6:00 to 22:00): Specified flow with pedestrian logic (comp)
;   - Night Mode (22:00 to 6:00): Flash E,W,N,S yellow on (rest off) (comp)
;   - Internal Timer Interrupt for timekeeping  (wip)
;   - Pedestrian LEDs controlled as specified (comp)
;   - Vehicle Buttons on P3.0-P3.3: Extend green time if pressed (Active-High) (comp)

;=====================================================================

; Bit Definitions (Updated per pin assignments)
PED_NS_WALK_BIT    BIT P3.6      ; NS Pedestrian walk LED (Active-Low: 0=Walk, 1=Don't Walk)
PED_EW_WALK_BIT    BIT P3.7      ; EW Pedestrian walk LED (Active-Low: 0=Walk, 1=Don't Walk)

PED_NS			   BIT P3.4
PED_EW			   BIT P3.5

; Vehicle Button Definitions (Active-High: 1=Pressed, 0=Not Pressed)
VEH_BTN_N          BIT P3.0      ; Vehicle Button North (Active-High)
VEH_BTN_S          BIT P3.1      ; Vehicle Button South (Active-High)
VEH_BTN_E          BIT P3.2      ; Vehicle Button East (Active-High)
VEH_BTN_W          BIT P3.3      ; Vehicle Button West (Active-High)

E_RED              BIT P2.0      ; East Red Light
E_YELLOW           BIT P2.1      ; East Yellow Light
E_GREEN_STRAIGHT   BIT P2.2      ; East Green-Straight Light
E_GREEN_RIGHT      BIT P2.3      ; East Green-Right Light

W_RED              BIT P2.4      ; West Red Light
W_YELLOW           BIT P2.5      ; West Yellow Light
W_GREEN_STRAIGHT   BIT P2.6      ; West Green-Straight Light
W_GREEN_RIGHT      BIT P2.7      ; West Green-Right Light

N_RED              BIT P1.0      ; North Red Light
N_YELLOW           BIT P1.1      ; North Yellow Light
N_GREEN_STRAIGHT   BIT P1.2      ; North Green-Straight Light
N_GREEN_RIGHT      BIT P1.3      ; North Green-Right Light

S_RED              BIT P1.4      ; South Red Light
S_YELLOW           BIT P1.5      ; South Yellow Light
S_GREEN_STRAIGHT   BIT P1.6      ; South Green-Straight Light
S_GREEN_RIGHT      BIT P1.7      ; South Green-Right Light

; RAM Variables
Hour            EQU 30H
Minutes         EQU 31H
Seconds         EQU 32H
Tenths_Counter  EQU 33H

; Startup
ORG 0000H
START:
; Initialize all red LEDs ON; green & yellow OFF (red: 1 =ON, 0= off)
    SETB N_RED
    SETB S_RED
    SETB E_RED
    SETB W_RED

    CLR N_YELLOW    ;yellow o=off,1=on
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    CLR N_GREEN_STRAIGHT ;GREEN 0=off,1=on
    CLR N_GREEN_RIGHT
    CLR S_GREEN_STRAIGHT
    CLR S_GREEN_RIGHT
    CLR E_GREEN_STRAIGHT
    CLR E_GREEN_RIGHT
    CLR W_GREEN_STRAIGHT
    CLR W_GREEN_RIGHT

    ; clear pedestrian led
    CLR PED_NS_WALK_BIT   ;1=on,0=off
    CLR PED_EW_WALK_BIT
	
	MOV P3, 00H

    ; Initialize time 
    MOV Hour, #04H
    MOV Minutes, #00H
    MOV Seconds, #00H
    MOV Tenths_Counter, #100 
	
	
; Configure Timer 0 for 10ms interrupts
    MOV TMOD, #01H ;gate1 c/t, tm1, tm0
    MOV TH0, #0D8H
    MOV TL0, #0F0H
    MOV IE, #82H
	SETB TR0 ;in tcon, 4
MAIN_LOOP:

; Day/Night mode selection based on Hour
CHECK_MODE:
    MOV A, Hour
    ; Check if Hour >= 22 (i.e., 22, 23)
    CLR C          ; Clear Carry before subtraction
    SUBB A, #22H   ; A = A - 22
    ; If original A was >= 22, Carry will be clear (C=0)
    JNC NIGHT_MODE ; Jump if A >= 22 (i.e., Carry was NOT set by SUBB)

    ; Hour was < 22 (i.e., 0-21)
    ; Check if Hour < 6 (i.e., 0, 1, 2, 3, 4, 5)
    MOV A, Hour    ; Reload A with Hour value
    CLR C          ; Clear Carry before subtraction
    SUBB A, #06H   ; A = A - 6H - Carry(0) => A - 6
    ; If original A was < 6, Carry will be set (C=1)
    JC NIGHT_MODE  ; Jump if A < 6 (i.e., Carry was set by SUBB)

    ; If we reach here, Hour was >= 6 and < 22 (i.e., 6-21) -> Day Mode
    LJMP DAY_MODE

;----------------------------------------------------------------
; NIGHT MODE (22:00 to 6:00): Flash E,W,N,S yellow on (rest off)
;----------------------------------------------------------------
NIGHT_MODE:
    ; Turn all red LEDs OFF, green OFF, yellow OFF initially
    CLR N_RED
    CLR S_RED
    CLR E_RED
    CLR W_RED

    CLR N_YELLOW
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    CLR N_GREEN_STRAIGHT
    CLR N_GREEN_RIGHT
    CLR S_GREEN_STRAIGHT
    CLR S_GREEN_RIGHT
    CLR E_GREEN_STRAIGHT
    CLR E_GREEN_RIGHT
    CLR W_GREEN_STRAIGHT
    CLR W_GREEN_RIGHT

    ; Pedestrian LEDs OFF (Don't Walk)
    CLR PED_NS_WALK_BIT
    CLR PED_EW_WALK_BIT

    ; Flash yellow lights on/off
    SETB N_YELLOW
    SETB S_YELLOW
    SETB E_YELLOW
    SETB W_YELLOW

    LCALL DELAY_FLASH

    CLR N_YELLOW
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    LCALL DELAY_FLASH

    LJMP MAIN_LOOP

;------------------------------------------
; DAY MODE (6:00 to 22:00):
;------------------------------------------

DAY_MODE:
;--- NORTH GREEN STRAIGHT AND GREEN RIGHT ON, S W E RED ON, SHORT DELAY ---
    CLR N_RED
    SETB S_RED
    SETB E_RED
    SETB W_RED

    CLR N_YELLOW
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    SETB N_GREEN_STRAIGHT
    SETB N_GREEN_RIGHT
    CLR S_GREEN_STRAIGHT
    CLR S_GREEN_RIGHT
    CLR E_GREEN_STRAIGHT
    CLR E_GREEN_RIGHT
    CLR W_GREEN_STRAIGHT
    CLR W_GREEN_RIGHT
	
	SETB PED_NS_WALK_BIT
    SETB PED_EW_WALK_BIT

	MOV R5, #5  ; Short delay counter (e.g., 5 seconds base time)
NS_PHASE1_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for North Vehicle (Active-High: Pin is 1 if pressed)
    ; If button is pressed, reload R5 to extend time for this iteration
    JB VEH_BTN_N, NS_PHASE1_RELOAD_COUNTER_N
    
    ; If neither button is pressed, decrement the counter normally
    DJNZ R5, NS_PHASE1_DELAY_LOOP
    SJMP NS_PHASE2_START ; Exit loop when R5 reaches 0

NS_PHASE1_RELOAD_COUNTER_N:
    ; North button pressed, extend time
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP NS_PHASE1_DELAY_LOOP ; Continue loop


NS_PHASE2_START:
;--- N GREEN STRAIGHT ON (GREEN RIGHT OFF), S GREEN STRAIGHT ON RED OFF, W E RED ON ---
    CLR N_GREEN_RIGHT
    SETB S_GREEN_STRAIGHT
	CLR S_RED

    ; Pedestrian NS ON, EW OFF
	CLR PED_NS_WALK_BIT
    SETB PED_EW_WALK_BIT

    MOV R5, #5 ; Delay counter for Phase 2
NS_PHASE2_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for North Vehicle during Phase 2
    JB VEH_BTN_N, NS_PHASE2_RELOAD_COUNTER_N
    JB VEH_BTN_S, NS_PHASE2_RELOAD_COUNTER_S
    DJNZ R5, NS_PHASE2_DELAY_LOOP
    SJMP NS_YELLOW_START

NS_PHASE2_RELOAD_COUNTER_N:
    MOV R5, #5
    SJMP NS_PHASE2_DELAY_LOOP

NS_PHASE2_RELOAD_COUNTER_S:
    MOV R5, #5
    SJMP NS_PHASE2_DELAY_LOOP

NS_YELLOW_START:
;--- N S YELLOW ON THEN TRANSITION TO RED ---
    SETB N_YELLOW
	SETB S_YELLOW
    CLR N_GREEN_STRAIGHT
    CLR S_GREEN_STRAIGHT

	
    MOV R5, #5  ; Short delay
PHASE_YELLOW_DELAY:
    LCALL DELAY_1SEC
    DJNZ R5, PHASE_YELLOW_DELAY

    SETB S_RED
	SETB N_RED
	CLR S_YELLOW
    CLR N_YELLOW

	LCALL PED_NS_CHECK
	
;--- EAST GREEN STRAIGHT AND GREEN RIGHT ON, S W E RED ON, SHORT DELAY ---
    CLR E_RED
    SETB S_RED
    SETB N_RED
    SETB W_RED

    CLR N_YELLOW
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    SETB E_GREEN_STRAIGHT
    SETB E_GREEN_RIGHT
    CLR S_GREEN_STRAIGHT
    CLR S_GREEN_RIGHT
    CLR N_GREEN_STRAIGHT
    CLR N_GREEN_RIGHT
    CLR W_GREEN_STRAIGHT
    CLR W_GREEN_RIGHT
	
	SETB PED_NS_WALK_BIT
    SETB PED_EW_WALK_BIT

	MOV R5, #5  ; Short delay counter (e.g., 5 seconds base time)
EW_PHASE1_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for East Vehicle (Active-High: Pin is 1 if pressed)
    JB VEH_BTN_E, EW_PHASE1_RELOAD_COUNTER_E
    ; If no button is pressed, decrement the counter normally
    DJNZ R5, EW_PHASE1_DELAY_LOOP
    SJMP EW_PHASE2_START ; Exit loop when R5 reaches 0

EW_PHASE1_RELOAD_COUNTER_E:
    ; East button pressed, extend time
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP EW_PHASE1_DELAY_LOOP ; Continue loop

EW_PHASE1_RELOAD_COUNTER_W:
    ; West button pressed, extend time for East phase
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP EW_PHASE1_DELAY_LOOP ; Continue loop

EW_PHASE2_START:
;--- E GREEN STRAIGHT ON (GREEN RIGHT OFF), S GREEN STRAIGHT ON RED OFF, W E RED ON ---
    CLR E_GREEN_RIGHT
    SETB W_GREEN_STRAIGHT
	CLR W_RED

    ; Pedestrian NS ON, EW OFF
	SETB PED_NS_WALK_BIT
    CLR PED_EW_WALK_BIT

    MOV R5, #5 ; Delay counter for Phase 2
EW_PHASE2_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for East Vehicle during Phase 2
    JB VEH_BTN_E, EW_PHASE2_RELOAD_COUNTER_E
    JB VEH_BTN_W, EW_PHASE2_RELOAD_COUNTER_W
    DJNZ R5, EW_PHASE2_DELAY_LOOP
    SJMP EW_YELLOW_START

EW_PHASE2_RELOAD_COUNTER_E:
    MOV R5, #5
    SJMP EW_PHASE2_DELAY_LOOP

EW_PHASE2_RELOAD_COUNTER_W:
    MOV R5, #5
    SJMP EW_PHASE2_DELAY_LOOP

EW_YELLOW_START:
;--- E ONLY YELLOW ON THEN TRANSITION TO RED ---
    SETB E_YELLOW
	SETB W_YELLOW
    CLR E_GREEN_STRAIGHT
    CLR W_GREEN_STRAIGHT
	
    MOV R5, #5  ; Short delay
PHASE_YELLOW2_DELAY:
    LCALL DELAY_1SEC
    DJNZ R5, PHASE_YELLOW2_DELAY

    SETB E_RED
	SETB W_RED
    CLR E_YELLOW
	CLR W_YELLOW
	
	LCALL PED_NS_CHECK
	LCALL PED_EW_CHECK
;--- SOUTH GREEN STRAIGHT AND GREEN RIGHT ON, S W E RED ON, SHORT DELAY ---
    CLR S_RED
    SETB E_RED
    SETB N_RED
    SETB W_RED

    CLR N_YELLOW
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    SETB S_GREEN_STRAIGHT
    SETB S_GREEN_RIGHT
    CLR E_GREEN_STRAIGHT
    CLR E_GREEN_RIGHT
    CLR N_GREEN_STRAIGHT
    CLR N_GREEN_RIGHT
    CLR W_GREEN_STRAIGHT
    CLR W_GREEN_RIGHT
	
	SETB PED_NS_WALK_BIT
    SETB PED_EW_WALK_BIT

	MOV R5, #5  ; Short delay counter (e.g., 5 seconds base time)
SW_PHASE1_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for South Vehicle (Active-High: Pin is 1 if pressed)
    JB VEH_BTN_S, SW_PHASE1_RELOAD_COUNTER_S
    ; If no button is pressed, decrement the counter normally
    DJNZ R5, SW_PHASE1_DELAY_LOOP
    SJMP SW_PHASE2_START ; Exit loop when R5 reaches 0

SW_PHASE1_RELOAD_COUNTER_S:
    ; South button pressed, extend time
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP SW_PHASE1_DELAY_LOOP ; Continue loop

SW_PHASE1_RELOAD_COUNTER_N:
    ; North button pressed, extend time for South phase
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP SW_PHASE1_DELAY_LOOP ; Continue loop

SW_PHASE2_START:
;--- S GREEN STRAIGHT ON (GREEN RIGHT OFF), S GREEN STRAIGHT ON RED OFF, W E RED ON ---
    CLR S_GREEN_RIGHT
    SETB N_GREEN_STRAIGHT
	CLR N_RED

    ; Pedestrian NS ON, EW OFF
	CLR PED_NS_WALK_BIT
    SETB PED_EW_WALK_BIT

    MOV R5, #5 ; Delay counter for Phase 2
SW_PHASE2_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for South Vehicle during Phase 2
    JB VEH_BTN_S, SW_PHASE2_RELOAD_COUNTER_S
    JB VEH_BTN_N, SW_PHASE2_RELOAD_COUNTER_N
    DJNZ R5, SW_PHASE2_DELAY_LOOP
    SJMP SW_YELLOW_START

SW_PHASE2_RELOAD_COUNTER_S:
    MOV R5, #5
    SJMP SW_PHASE2_DELAY_LOOP

SW_PHASE2_RELOAD_COUNTER_N:
    MOV R5, #5
    SJMP SW_PHASE2_DELAY_LOOP

SW_YELLOW_START:
;--- E ONLY YELLOW ON THEN TRANSITION TO RED ---
    SETB N_YELLOW
	SETB S_YELLOW
    CLR N_GREEN_STRAIGHT
    CLR S_GREEN_STRAIGHT
	
    MOV R5, #5  ; Short delay
PHASE_YELLOW3_DELAY:
    LCALL DELAY_1SEC
    DJNZ R5, PHASE_YELLOW3_DELAY

    SETB N_RED
	SETB S_RED
    CLR N_YELLOW
	CLR S_YELLOW

	LCALL PED_NS_CHECK
	LCALL PED_EW_CHECK
;--- WEST GREEN STRAIGHT AND GREEN RIGHT ON, S W E RED ON, SHORT DELAY ---
    CLR W_RED
    SETB S_RED
    SETB N_RED
    SETB E_RED

    CLR N_YELLOW
    CLR S_YELLOW
    CLR E_YELLOW
    CLR W_YELLOW

    SETB W_GREEN_STRAIGHT
    SETB W_GREEN_RIGHT
    CLR S_GREEN_STRAIGHT
    CLR S_GREEN_RIGHT
    CLR N_GREEN_STRAIGHT
    CLR N_GREEN_RIGHT
    CLR E_GREEN_STRAIGHT
    CLR E_GREEN_RIGHT
	
	SETB PED_NS_WALK_BIT
    SETB PED_EW_WALK_BIT

	MOV R5, #5  ; Short delay counter (e.g., 5 seconds base time)
WE_PHASE1_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for West Vehicle (Active-High: Pin is 1 if pressed)
    JB VEH_BTN_W, WE_PHASE1_RELOAD_COUNTER_W
    ; If neither button is pressed, decrement the counter normally
    DJNZ R5, WE_PHASE1_DELAY_LOOP
    SJMP WE_PHASE2_START ; Exit loop when R5 reaches 0

WE_PHASE1_RELOAD_COUNTER_W:
    ; West button pressed, extend time
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP WE_PHASE1_DELAY_LOOP ; Continue loop

WE_PHASE1_RELOAD_COUNTER_E:
    ; East button pressed, extend time for West phase
    MOV R5, #5 ; Reload with desired extension value (or base value)
    SJMP WE_PHASE1_DELAY_LOOP ; Continue loop

WE_PHASE2_START:
;--- W GREEN STRAIGHT ON (GREEN RIGHT OFF), E GREEN STRAIGHT ON RED OFF, S N RED ON ---
    CLR W_GREEN_RIGHT
    SETB E_GREEN_STRAIGHT
	CLR E_RED

    ; Pedestrian NS ON, EW OFF
	SETB PED_NS_WALK_BIT
    CLR PED_EW_WALK_BIT

    MOV R5, #5 ; Delay counter for Phase 2
WE_PHASE2_DELAY_LOOP:
    LCALL DELAY_1SEC
    ; Check for West Vehicle during Phase 2
    JB VEH_BTN_W, WE_PHASE2_RELOAD_COUNTER_W
    JB VEH_BTN_E, WE_PHASE2_RELOAD_COUNTER_E
    DJNZ R5, WE_PHASE2_DELAY_LOOP
    SJMP WE_YELLOW_START

WE_PHASE2_RELOAD_COUNTER_W:
    MOV R5, #5
    SJMP WE_PHASE2_DELAY_LOOP

WE_PHASE2_RELOAD_COUNTER_E:
    MOV R5, #5
    SJMP WE_PHASE2_DELAY_LOOP

WE_YELLOW_START:
;--- W ONLY YELLOW ON THEN TRANSITION TO RED ---
    SETB E_YELLOW
	SETB W_YELLOW
    CLR E_GREEN_STRAIGHT
    CLR W_GREEN_STRAIGHT
	
    MOV R5, #5  ; Short delay
PHASE_YELLOW4_DELAY:
    LCALL DELAY_1SEC
    DJNZ R5, PHASE_YELLOW4_DELAY

    SETB E_RED
	SETB W_RED
    CLR E_YELLOW
	CLR W_YELLOW

	LCALL PED_NS_CHECK
	LCALL PED_EW_CHECK
	
	LJMP MAIN_LOOP
	
;--------------------------------------------------------------------
;Pedestrian subroutine
;--------------------------------------------------------------------
PED_NS_CHECK:
	JNB PED_EW, PED_NS_END  ;IF NOT SET (0) GO TO END
	SETB E_RED
	SETB W_RED
	SETB N_RED
	SETB S_RED
	
	SETB PED_EW_WALK_BIT
	CLR PED_NS_WALK_BIT
	MOV R5, #3
PED_NS_DELAY:	
	LCALL DELAY_1SEC
	DJNZ R5, PED_NS_DELAY

PED_NS_END:
	SETB PED_NS_WALK_BIT
	RET

PED_EW_CHECK:
	JNB PED_NS, PED_EW_END  ;IF NOT SET (0) GO TO END
	SETB E_RED
	SETB W_RED
	SETB N_RED
	SETB S_RED
	
	CLR PED_EW_WALK_BIT
	SETB PED_NS_WALK_BIT
	MOV R5, #3
PED_EW_DELAY:	
	LCALL DELAY_1SEC
	DJNZ R5, PED_EW_DELAY

PED_EW_END:
	SETB PED_EW_WALK_BIT
	RET
;--------------------------------------------------------------------
; Delay ~1 second subroutine
;--------------------------------------------------------------------
DELAY_1SEC:
    MOV R7, #20
D1S_LOOP:
    MOV R6, #250
D2S_LOOP:
    MOV R4, #250
D3S_LOOP:
    DJNZ R4, D3S_LOOP
    DJNZ R6, D2S_LOOP
    DJNZ R7, D1S_LOOP
    RET

;--------------------------------------------------------------------
; Delay flash subroutine
;--------------------------------------------------------------------
DELAY_FLASH:
    MOV R5, #10
FLS_LP1:
    MOV R4, #100
FLS_LP2:
    MOV R3, #100
FLS_LP3:
    DJNZ R3, FLS_LP3
    DJNZ R4, FLS_LP2
    DJNZ R5, FLS_LP1
    RET


;--------------------------------------------------------------------
; Timer0 interrupt for 10 ms tick and timekeeping
;--------------------------------------------------------------------
TIMER0_ISR:
    PUSH ACC
    PUSH PSW

    MOV TH0, #0D8H
    MOV TL0, #0F0H

    DEC Tenths_Counter
    JNZ TIMER0_EXIT

    MOV Tenths_Counter, #100
    INC Seconds
    MOV A, Seconds
    CJNE A, #60, TIMER0_EXIT
    CLR Seconds
    INC Minutes
    MOV A, Minutes
    CJNE A, #60, TIMER0_EXIT
    CLR Minutes
    INC Hour
    MOV A, Hour
    CJNE A, #24, TIMER0_EXIT
    CLR Hour

TIMER0_EXIT:
    POP PSW
    POP ACC
    RETI

END