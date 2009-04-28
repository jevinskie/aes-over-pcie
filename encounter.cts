#
# FirstEncounter(TM) Clock Synthesis Technology File Format
#

#-- MacroModel --
#MacroModel pin <pin> <maxRiseDelay> <minRiseDelay> <maxFallDelay> <minFallDelay> <inputCap>

#-- Special Route Type --
#RouteTypeName specialRoute
#TopPreferredLayer 4
#BottomPreferredLayer 3
#PreferredExtraSpace 1
#End

#-- Regular Route Type --
#RouteTypeName regularRoute
#TopPreferredLayer 4
#BottomPreferredLayer 3
#PreferredExtraSpace 1
#End

#-- Clock Group --
#ClkGroup
#+ <clockName>

#------------------------------------------------------------
# Clock Root   : clk
# Clock Name   : clk
# Clock Period : 4ns
#------------------------------------------------------------
AutoCTSRootPin clk
MaxDelay       4ns # default value
MinDelay       0ns   # default value
MaxSkew        300ps # default value
SinkMaxTran    400ps # default value
BufMaxTran     400ps # default value
Buffer         BUFX2 BUFX4 CLKBUF3 CLKBUF1 CLKBUF2 INVX1 INVX2 INVX4 INVX8 
NoGating       NO
DetailReport   YES
SetDPinAsSync  NO
#RouteClkNet    NO
#PostOpt        YES
#OptAddBuffer   NO
#RouteType      specialRoute
#LeafRouteType  regularRoute
ThroughPin
END

