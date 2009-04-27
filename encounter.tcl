###################################
# Run the design through Encounter
###################################

# Setup design and create floorplan
loadConfig ./encounter.conf 
commitConfig
setCteReport

# Create Floorplan
floorplan -r 1.0 0.6 40.05 40.8 40.05 42

# Add supply rings around core
addRing -spacing_bottom 9.9 -width_left 9.9 -width_bottom 9.9 -width_top 9.9 -spacing_top 9.9 -layer_bottom metal1 -width_right 9.9 -around core -center 1 -layer_top metal1 -spacing_right 9.9 -spacing_left 9.9 -layer_right metal2 -layer_left metal2 -offset_top 9.9 -offset_bottom 9.9 -offset_left 9.9 -offset_right 9.9 -nets { gnd vdd }

# Place standard cells
amoebaPlace

# Route power nets
sroute -noBlockPins -noPadRings

puts "!!!!!!!!!! 1"

# Perform trial route and get initial timing results
trialroute
#uncomment below if you want to perform timing analysis
#setAnalysisMode -setup -async -skew -autoDetectClockTree
#buildTimingGraph
#reportTA -nworst  10 -net > timing.rep.1.placed

puts "!!!!!!!!!! 2"

# Run in-place optimization
# to fix setup problems
setIPOMode -mediumEffort -fixDRC -addPortAsNeeded
initECO ./ipo1.txt
fixSetupViolation
endECO

puts "!!!!!!!!!!!!!! 3"

#uncomment below if you want to perform timing analysis
#setAnalysisMode -setup -async -skew -autoDetectClockTree
#buildTimingGraph
#reportTA -nworst  10 -net > timing.rep.2.ipo1

puts "!!!!!!!!!!!!!! 4"

# Run Clock Tree Synthesis
createClockTreeSpec -output encounter.cts -bufFootprint buf -invFootprint inv
specifyClockTree -clkfile encounter.cts
ckSynthesis -rguide cts.rguide -report report.ctsrpt -macromodel report.ctsmdl -fix_added_buffers

# Output Results of CTS
trialRoute -highEffort -guide cts.rguide
extractRC
reportClockTree -postRoute -localSkew -report skew.post_troute_local.ctsrpt
reportClockTree -postRoute -report report.post_troute.ctsrpt

# Run Post-CTS Timing analysis
#uncomment below if you want to perform timing analysis
#setAnalysisMode -setup -async -skew -autoDetectClockTree
#buildTimingGraph
#reportTA -nworst  10 -net > timing.rep.3.cts

# Perform post-CTS IPO
setIPOMode -highEffort -fixDrc -addPortAsNeeded -incrTrialRoute  -restruct -topomap
initECO ipo2.txt
setExtractRCMode -default -assumeMetFill
extractRC
fixSetupViolation -guide cts.rguide

# Fix all remaining violations
setExtractRCMode -detail -assumeMetFill
extractRC
if {[isDRVClean -maxTran -maxCap -maxFanout] != 1} {
fixDRCViolation -maxTran -maxCap -maxFanout
}

endECO
cleanupECO

# Run Post IPO-2 timing analysis
#uncomment below if you want to perform timing analysis
#setAnalysisMode -setup -async -skew -autoDetectClockTree
#buildTimingGraph
#reportTA -nworst  10 -net > timing.rep.4.ipo2

# Add filler cells
addFiller -cell FILL -prefix FILL -fillBoundary

# Connect all new cells to VDD/GND
globalNetConnect vdd -type tiehi
globalNetConnect vdd -type pgpin -pin vdd -override

globalNetConnect gnd -type tielo
globalNetConnect gnd -type pgpin -pin gnd -override

# Run global Routing
globalDetailRouteBatch

# Do metal fill
addMetalFill -nets {VDD GND} 

# Get final timing results
setExtractRCMode -detail -noReduce
extractRC
#uncomment below if you want to perform timing analysis
#buildTimingGraph
#reportTA -nworst  10 -net > timing.rep.5.final

# Output GDSII
streamOut final.gds2 -mapFile gds2_encounter.map -outputMacros -stripes 1 -units 1000 -mode ALL
#streamOut final.gds2
saveNetlist -excludeLeafCell final.v

# Output DSPF RC Data
rcout -spf final.dspf

# Run DRC and Connection checks
verifyGeometry
verifyConnectivity -type all

puts "**************************************"
puts "* Encounter script finished          *"
puts "*                                    *"
puts "* Results:                           *"
puts "* --------                           *"
puts "* Layout:  final.gds2                *"
puts "* Netlist: final.v                   *"
puts "* Timing:  timing.rep.5.final        *"
puts "*                                    *"
puts "* Type 'win' to get the Main Window  *"
puts "* or type 'exit' to quit             *"
puts "*                                    *"
puts "**************************************"
