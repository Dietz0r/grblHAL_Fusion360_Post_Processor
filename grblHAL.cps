/**
  Copyright (C) 2012-2021 by Autodesk, Inc.
  All rights reserved.

  Grbl post processor configuration.

  $Revision: 43194 08c79bb5b30997ccb5fb33ab8e7c8c26981be334 $
  $Date: 2021-05-17 12:25:13 $
  
  FORKID {154F7C00-6549-4c77-ADE0-79375FE5F2AA}
*/

/*
Add change notes here!!!! DO NOT FORGET OR YOU WILL FORGET
20.20.25
1. Added option to use canned drilling cycles (or not use)

12.08.25
1. Added Option to enable/disable arc generation

18.02.25
1. Improved return position behaviour and code generation
2. Added initial positioning move option

30.09.24
1. Added sanitycheck for Air while misting
2. Improved SpindleDelay code

25.09.2024
1. Added optional after job return position

02.09.2024
1. Fixed SpindleDelay property call to not use the default value.

12.01.2024
1. Added initial retract to clearance height for SafePosition:Clearance height method.
*/

description = "GrblHAL";
vendor = "GrblHAL";
vendorUrl = "https://github.com/grblHAL";
longDescription = "GrblHAL PostProcessor with added features";

// >>>>> INCLUDED FROM ../common/grbl.cps
legal = "Copyright (C) 2012-2021 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

extension = "nc";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = 0; // (1 << PLANE_XY) | (1 << PLANE_ZX) | (1 << PLANE_YZ) - allow any circular motion

// user-defined properties
properties = {
  writeMachine: {
    title: "Write machine",
    description: "Output the machine settings in the header of the code.",
    group: "formats",
    type: "boolean",
    value: true,
    scope: "post"
  },
  writeTools: {
    title: "Write tool list",
    description: "Output a tool list in the header of the code.",
    group: "formats",
    type: "boolean",
    value: true,
    scope: "post"
  },
  safePositionMethod: {
    title: "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    group: "Safety",
    type: "enum",
    values: [
      {title: "G28", id: "G28"},
      {title: "G53", id: "G53"},
      {title: "Clearance Height", id: "clearanceHeight"}
    ],
    value: "G28",
    scope: "post"
  },
  initPositioning: {
    title: "Initial positioning in G28",
    description: "Always use G28 for the first toolpath positioning.",
    group: "Safety",
    type: "boolean",
    value: true,
    scope: "post"
  },
  returnPosition: {
    title: "Return Position",
    description: "Select the desired position the machine returns to after a job is finished.",
    group: "Safety",
    type: "enum",
    values: [
      {title: "Disabled", id: "none"},
      {title: "Current WCS X0Y0", id: "WCS"},
      {title: "G28 Z0", id: "G28Z"},
      {title: "G28 Z0, then X0Y0", id: "G28XYZ"},
      {title: "G30 Z0", id: "G30Z"},
      {title: "G30 Z0, then X0Y0", id: "G30XYZ"},
    ],
    value: "none",
    scope: "post"
  },
  showSequenceNumbers: {
    title: "Use sequence numbers",
    description: "Use sequence numbers for each block of outputted code.",
    group: "formats",
    type: "boolean",
    value: false,
    scope: "post"
  },
  sequenceNumberStart: {
    title: "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group: "formats",
    type: "integer",
    value: 10,
    scope: "post"
  },
  sequenceNumberIncrement: {
    title: "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group: "formats",
    type: "integer",
    value: 1,
    scope: "post"
  },
  separateWordsWithSpace: {
    title: "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group: "formats",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useToolChanger: {
    title: "Output tool number",
    description: "Outputs Toolnumber code for tool changes when enabled. (Txx).",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useM06: {
    title: "Output M6",
    description: "Outputs M6 code for tool changes when enabled.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useToolMSG: {
    title: "Output Tool Message",
    description: "Enable output of tool info message on tool changes.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  splitFile: {
    title: "Split file",
    description: "Select your desired file splitting option.",
    group: "formats",
    type: "enum",
    values: [
      {title: "No splitting", id: "none"},
      {title: "Split by tool", id: "tool"},
      {title: "Split by toolpath", id: "toolpath"}
    ],
    value: "none",
    scope: "post"
  },
  spindleDelay: {
    title: "Spindle On Delay (Seconds)",
    description: "Set desired time to spin up spindle",
    group: "Safety",
    type: "integer",
    value: 2,
    scope: "post"
  },
  fourthAxisAround: {
    title: "Fourth axis mounted along",
    description: "Specifies which axis the fourth axis is mounted on.",
    group: "multiAxis",
    type: "enum",
    values: [
      {id: "none", title: "None"},
      {id: "x", title: "Along X"},
      {id: "y", title: "Along Y"}
    ],
    value: "none",
    scope: "post"
  },
  fourthAxisIsTable: {
    title: "4th Axis is a table",
    description: "True - table, false - rotary",
    group: "multiAxis",
    type: "boolean",
    value: false,
    scope: "post"
  },
  floodOn: {
    title: "Floodcoolant On:",
    description: "M-Command for floodcoolant",
    group: "Coolant",
    type: "enum",
    values: [
      {id: "", title: "None"},
      {id: "7", title: "M7"},
      {id: "8", title: "M8"},
      {id: "64", title: "Aux Pin0"},
    ],
    value: "",
    scope: "post"
  },
  airOn: {
    title: "Airblast On:",
    description: "M-Command for Airblast",
    group: "Coolant",
    type: "enum",
    values: [
      {id: "", title: "None"},
      {id: "7", title: "M7"},
      {id: "8", title: "M8"},
      {id: "64", title: "Aux Pin0"},
    ],
    value: "7",
    scope: "post"
  },
  mistOn: {
    title: "Misting On:",
    description: "M-Command for Mistcooling",
    group: "Coolant",
    type: "enum",
    values: [
      {id: "", title: "None"},
      {id: "7", title: "M7"},
      {id: "8", title: "M8"},
      {id: "64", title: "Aux Pin0"},
    ],
    value: "8",
    scope: "post"
  },
  VacOn: {
    title: "Dustcollection On:",
    description: "M-Command for Dustcollection",
    group: "Coolant",
    type: "enum",
    values: [
      {id: "", title: "None"},
      {id: "7", title: "M7"},
      {id: "8", title: "M8"},
      {id: "64", title: "Aux Pin0"},
    ],
    value: "64",
    scope: "post"
  },
  CoolOff: {
    title: "Turn coolants off with:",
    description: "To include Aux Pins in coolant off behaviour",
    group: "Coolant",
    type: "enum",
    values: [
      {id: "9", title: "M9"},
      {id: "both", title: "M9 + Aux Pin0"},
      {id: "65", title: "Aux Pin0"},
    ],
    value: "9",
    scope: "post"
  },
  AirWhileMist: {
    title: "Airblast while Misting.",
    description: "To turn on the Airblast supply while Mistcooling is Enabled",
    group: "Coolant",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useCircularInterpolation: {
    title      : "Enable G2/G3 Arcs",
    description: "Enable output of G2 and G3 Arc commands.\nUses linear circular interpolation instead.",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useCannedCycles: {
    title      : "Use canned drilling cycles",
    description: "Enable output of canned drilling cycle G-codes (G81, G83, etc.).\nWhen disabled, drilling operations are expanded into individual movement commands.",
    type       : "boolean",
    value      : false,
    scope      : "post"
  }
};

groupDefinitions = {
 Safety: {title: "Safety Settings", description: "Settings for safe operation", collapsed: false, order:5},
 Coolant: {title: "Coolant Mapping", description: "Define Machinecodes for Coolant", collapsed: true, order:25}
};

var numberOfToolSlots = 9999;
var subprograms = new Array();

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines

// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
/*
Included usersettings to map coolant behaviour to different M-commands and output pins.
M64/M65 codes are used for Aux Pin0 on Teensy driven boards (e.g. Phil's and grblHAL2000). 
Here set as dustcollection default - Enable with Fusion "Suction" cooling. {id: COOLANT_SUCTION}
The M64/65 are handled around line 1344 in "function setCoolant(coolant)"" section.
*/

var coolants = [
  {id: COOLANT_FLOOD, 
    get on() {return Number(getProperty("floodOn"))},
    get off() {if (getProperty("CoolOff") == 9) { return 9} else if (getProperty("CoolOff") == 65) {return number(65) } else {return [9, 65]}}
  },
  {id: COOLANT_MIST,
    get on() {if (getProperty("AirWhileMist") == true) {return [Number(getProperty("airOn")), Number(getProperty("mistOn"))]} else {return Number(getProperty("mistOn"))}},
    get off() {if (getProperty("CoolOff") == 9) { return 9} else if (getProperty("CoolOff") == 65) {return number(65) } else {return [9, 65]}}
  },
  {id: COOLANT_THROUGH_TOOL},
  {id: COOLANT_AIR,
    get on() {return Number(getProperty("airOn"))},
    get off() {if (getProperty("CoolOff") == 9) { return 9} else if (getProperty("CoolOff") == 65) {return number(65) } else {return [9, 65]}}
  },
  {id: COOLANT_AIR_THROUGH_TOOL},
  {id: COOLANT_SUCTION,
    get on() {return Number(getProperty("VacOn"))},
    get off() {if (getProperty("CoolOff") == 9) { return 9} else if (getProperty("CoolOff") == 65) {return number(65) } else {return [9, 65]}}
  },
  {id: COOLANT_FLOOD_MIST,
    get on() {return [Number(getProperty("floodOn")), Number(getProperty("mistOn"))]},
    get off() {if (getProperty("CoolOff") == 9) { return 9} else if (getProperty("CoolOff") == 65) {return number(65) } else {return [9, 65]}}
  },
  {id: COOLANT_FLOOD_THROUGH_TOOL},
  {id: COOLANT_OFF,
    get off() {if (getProperty("CoolOff") == 9) { return 9} else if (getProperty("CoolOff") == 65) {return number(65) } else {return [9, 65]}}
  },
];

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 1 : 2)});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:false}); // seconds - range 0.001-1000
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);

// circular output
var iOutput = createVariable({prefix:"I"}, xyzFormat);
var jOutput = createVariable({prefix:"J"}, xyzFormat);
var kOutput = createVariable({prefix:"K"}, xyzFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99

var WARNING_WORK_OFFSET = 0;

// collected state
var sequenceNumber;
var currentWorkOffset;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var retracted = false; // specifies that the tool has been retracted to the safe plane
var now = new Date();

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  if (getProperty("showSequenceNumbers")) {
    writeWords2("N" + sequenceNumber, arguments);
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return "(" + String(text).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function onOpen() {

  /*if (getProperty("has4thAxis")) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:false, axis:[1, 0, 0], range:[-360, 360], preference:1});
    //var cAxis = createAxis({coordinate:2, table:false, axis:[0, 0, 1], range:[-360, 360], preference:1});
    machineConfiguration = new MachineConfiguration(aAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(1); // TCP mode
  }*/
  if (getProperty("useCircularInterpolation")) {
    allowedCircularPlanes = undefined; // Allow circular interpolation in all three planes
  }
  if (getProperty("fourthAxisAround") != "none") {
    var aAxis = createAxis({
      coordinate:0,
      table:getProperty("fourthAxisIsTable"),
      axis:[(getProperty("fourthAxisAround") == "x" ? 1 : 0), (getProperty("fourthAxisAround") == "y" ? 1 : 0), 0],
      cyclic:true,
      range: [0,360],
      preference:0
    });
    machineConfiguration = new MachineConfiguration(aAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(1); // map tip mode
  }

  if (getProperty("AirWhileMist") && getProperty("airOn") == "") {
    error(localize("Cant use 'Airblast while Misting' if no Airblast is configured."));
    return;
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2)) {
    cOutput.disable();
  }

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  sequenceNumber = getProperty("sequenceNumberStart");

  if (programName) {
    writeComment(programName);
  }
  if (programComment) {
    writeComment(programComment);
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }

  // dump tool information
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = "T" + toolFormat.format(tool.number) + "  " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  if ((getProperty("fourthAxisAround") != "none") && !is3D()) {
    warning(localize("4th axis operations detected. Make sure that your WCS origin is placed on the rotary axis."));
  }

  if (getProperty("splitFile") != "none") {
    writeComment(localize("***THIS FILE DOES NOT CONTAIN NC CODE***"));
    return;
  }

  // absolute coordinates and feed per min
  writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94));
  writeBlock(gPlaneModal.format(17));

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(20));
    break;
  case MM:
    writeBlock(gUnitModal.format(21));
    break;
  }
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  
  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }
  
  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), Math.max(getParameter("operation:tool_feedCutting"), getParameter("operation:tool_feedEntry"), getParameter("operation:tool_feedExit")));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }
  
  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }
  
  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

function isProbeOperation() {
  return hasParameter("operation-strategy") &&
    (getParameter("operation-strategy") == "probe");
}

function onSection() {
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);

  var splitHere = getProperty("splitFile") == "toolpath" || (getProperty("splitFile") == "tool" && insertToolCall);
  
  retracted = false; // specifies that the tool has been retracted to the safe plane

  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset) ||
    splitHere; // work offset changes

  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()) ||
      splitHere; // force newWorkPlane between indexing and simultaneous operations

  if (insertToolCall || newWorkOffset || newWorkPlane) {
    if (insertToolCall && !isFirstSection()) {
      onCommand(COMMAND_STOP_SPINDLE);    // stop spindle before retract during tool change
    }
    if (getProperty("splitFile") == "none" || isRedirecting()) {
      if (isFirstSection() && getProperty("initPositioning")) {
        writeBlock(gFormat.format(28), gAbsIncModal.format(91), "Z0");
        writeBlock(gAbsIncModal.format(90));
      } else {
      writeRetract(Z);
      }
    }
  }

  writeln("");

  if (splitHere) {
    if (!isFirstSection()) {
      setCoolant(COOLANT_OFF);

      writeRetract(X, Y);
    
      onImpliedCommand(COMMAND_END);
      onCommand(COMMAND_STOP_SPINDLE);
      writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
      if (isRedirecting()) {
        closeRedirection();
      }
    }

    var subprogram;
    if (getProperty("splitFile") == "toolpath") {
      var comment;
      if (hasParameter("operation-comment")) {
        comment = getParameter("operation-comment");
        
      } else {
        comment = getCurrentSectionId();
      }
      subprogram = programName + "_" + (subprograms.length + 1) + "_" + comment + "_" + "T" + tool.number;
    } else {
      subprogram = programName + "_" + (subprograms.length + 1) + "_" + "T" + tool.number;
    }

    // var index = 0;
    // var _subprogram = subprogram;
    // while (subprograms.indexOf(_subprogram) !== -1) {
    //   index++;
    //   _subprogram = subprogram + "_" + index;
    // }
    // subprogram = _subprogram;
    subprograms.push(subprogram);
    
    var path = FileSystem.getCombinedPath(FileSystem.getFolderPath(getOutputPath()), String(subprogram).replace(/[<>:"/\\|?*]/g, "") + "." + extension);
    
    writeComment(localize("Load tool number " + tool.number + " and subprogram " + subprogram));

    redirectToFile(path);

    if (programName) {
      writeComment(programName);
    }
    if (programComment) {
      writeComment(programComment);
    }

    // absolute coordinates and feed per min
    writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94));
    writeBlock(gPlaneModal.format(17));

    switch (unit) {
    case IN:
      writeBlock(gUnitModal.format(20));
      break;
    case MM:
      writeBlock(gUnitModal.format(21));
      break;
    }

  }
  
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }

  if (insertToolCall) {
    setCoolant(COOLANT_OFF);

    if (tool.number > numberOfToolSlots) {
      warning(localize("Tool number exceeds maximum value."));
    }

    if (getProperty("useToolChanger")) {
      writeBlock("T" + toolFormat.format(tool.number), 
        conditional(getProperty("useM06"), mFormat.format(6)), 
        conditional(getProperty("useToolMSG"), formatComment(
          "MSG,T" + xyzFormat.format(tool.number) + 
          " " + xyzFormat.format(tool.diameter) + conditional(unit==MM,"mm") + conditional(unit==IN,"in") +
          " " + xyzFormat.format(tool.numberOfFlutes) + 
          "flute " + getToolTypeName(tool.type))));
      if (!isFirstSection() && !getProperty("useM06")) {
        writeComment(localize("CHANGE TO T") + tool.number);
      }
    } else if (getProperty("useM06")) {
      writeBlock(mFormat.format(6));
    }
    if (tool.comment) {
      writeComment(tool.comment);
    }
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }
  }
  
  if (insertToolCall ||
      isFirstSection() ||
      (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise)) {
    if (spindleSpeed < 1) {
      error(localize("Spindle speed out of range."));
    }
    if (spindleSpeed > 99999) {
      warning(localize("Spindle speed exceeds maximum value."));
    }
    writeBlock(
      sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4)
    );
    if (getProperty("spindleDelay") > 0) {  // Add dwell time if SpindleDelay is not 0
      onDwell(getProperty("spindleDelay")); 
    }
  }

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  if (workOffset > 0) {
    if (workOffset > 6) {
      error(localize("Work offset out of range."));
      return;
    } else {
      if (workOffset != currentWorkOffset) {
        writeBlock(gFormat.format(53 + workOffset)); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }

  forceXYZ();

  { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  // set coolant after we have positioned at Z
  setCoolant(tool.coolant);

  forceAny();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    }
  }

  if (insertToolCall || retracted) {
    var lengthOffset = tool.lengthOffset;
    if (lengthOffset > numberOfToolSlots) {
      error(localize("Length offset out of range."));
      return;
    }

    gMotionModal.reset();
    writeBlock(gPlaneModal.format(17));

    if (!machineConfiguration.isHeadConfiguration()) {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
      );
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z)
      );
    }
  } else {
    writeBlock(
      gAbsIncModal.format(90),
      gMotionModal.format(0),
      xOutput.format(initialPosition.x),
      yOutput.format(initialPosition.y)
    );
  }
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  seconds = clamp(0.001, seconds, 99999.999);
  writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}
/* ADD CANNED CYCLES */
function onCycle() {
    writeBlock(gPlaneModal.format(17));
    if (!getProperty("useCannedCycles")) {
      cycleExpanded = true;
    }
}

function getCommonCycle(x, y, z, r) {
    forceXYZ(); // force xyz on first drill hole of any cycle
    return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R" + xyzFormat.format(r)];
}

function onCyclePoint(x, y, z) {
    if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
    }
    switch (cycleType) {
    case "tapping":
    case "left-tapping":
    case "right-tapping":
    cycleExpanded = true;
    repositionToCycleClearance(cycle, x, y, z);
    writeBlock(
        gAbsIncModal.format(90), gMotionModal.format(0),
        conditional(gPlaneModal.getCurrent() == 17, zOutput.format(cycle.retract)),
        conditional(gPlaneModal.getCurrent() == 18, yOutput.format(cycle.retract)),
        conditional(gPlaneModal.getCurrent() == 19, xOutput.format(cycle.retract))
    );
    writeBlock(
        gAbsIncModal.format(90), gFormat.format(33.1),
        conditional(gPlaneModal.getCurrent() == 17, zOutput.format(z)),
        conditional(gPlaneModal.getCurrent() == 18, yOutput.format(y)),
        conditional(gPlaneModal.getCurrent() == 19, xOutput.format(x)),
        "K" + pitchFormat.format(tool.threadPitch)
    );
    gMotionModal.reset();
    writeBlock(
        gAbsIncModal.format(90), gMotionModal.format(0),
        conditional(gPlaneModal.getCurrent() == 17, zOutput.format(cycle.clearance)),
        conditional(gPlaneModal.getCurrent() == 18, yOutput.format(cycle.clearance)),
        conditional(gPlaneModal.getCurrent() == 19, xOutput.format(cycle.clearance))
    );
    return;
    /*
    case "tapping-with-chip-breaking":
    case "left-tapping-with-chip-breaking":
    case "right-tapping-with-chip-breaking":
    */
    }

    if (isFirstCyclePoint()) {
    repositionToCycleClearance(cycle, x, y, z);
    
    // return to initial Z which is clearance plane and set absolute mode

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(0.001, cycle.dwell, 99999999); // in seconds

    switch (cycleType) {
    case "drilling":
        writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract),
        feedOutput.format(F)
        );
        break;
    case "counter-boring":
        if (P > 0) {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
            getCommonCycle(x, y, z, cycle.retract),
            "P" + secFormat.format(P),
            feedOutput.format(F)
        );
        } else {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
            getCommonCycle(x, y, z, cycle.retract),
            feedOutput.format(F)
        );
        }
        break;
    case "chip-breaking":
      if ((cycle.accumulatedDepth < cycle.depth) || (P > 0)) {
        expandCyclePoint(x, y, z);
        break;
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(73),
          getCommonCycle(x, y, z, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          feedOutput.format(F)
        );
      }
      break;
    case "deep-drilling":
        if (P > 0) {
        expandCyclePoint(x, y, z);
        } else {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
            getCommonCycle(x, y, z, cycle.retract),
            "Q" + xyzFormat.format(cycle.incrementalDepth),
            // conditional(P > 0, "P" + secFormat.format(P)),
            feedOutput.format(F)
        );
        }
        break;
    case "fine-boring":
        expandCyclePoint(x, y, z);
        break;
    /* // not supported
    case "back-boring":
        var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
        var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
        var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
        writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(87),
        getCommonCycle(x - dx, y - dy, z - dz, cycle.bottom),
        "Q" + xyzFormat.format(cycle.shift),
        "P" + secFormat.format(P), // not optional
        feedOutput.format(F)
        );
        break;
    */
    /*case "reaming":
        if (P > 0) {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
            getCommonCycle(x, y, z, cycle.retract),
            "P" + secFormat.format(P),
            feedOutput.format(F)
        );
        } else {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
            getCommonCycle(x, y, z, cycle.retract),
            feedOutput.format(F)
        );
        }
        break;
    case "stop-boring":
        writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(86),
        getCommonCycle(x, y, z, cycle.retract),
        conditional(P > 0, "P" + secFormat.format(P)),
        feedOutput.format(F)
        );
        break;
    case "manual-boring":
        writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P), // not optional
        feedOutput.format(F)
        );
        break;
    case "boring":
        if (P > 0) {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
            getCommonCycle(x, y, z, cycle.retract),
            "P" + secFormat.format(P), // not optional
            feedOutput.format(F)
        );
        } else {
        writeBlock(
            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
            getCommonCycle(x, y, z, cycle.retract),
            feedOutput.format(F)
        );
        }
        break;*/
    default:
        expandCyclePoint(x, y, z);
    }
    } else {
    if (cycleExpanded) {
        expandCyclePoint(x, y, z);
    } else {
        var _x = xOutput.format(x);
        var _y = yOutput.format(y);
        var _z = zOutput.format(z);
        if (!_x && !_y && !_z) {
        switch (gPlaneModal.getCurrent()) {
        case 17: // XY
            xOutput.reset(); // at least one axis is required
            _x = xOutput.format(x);
            break;
        case 18: // ZX
            zOutput.reset(); // at least one axis is required
            _z = zOutput.format(z);
            break;
        case 19: // YZ
            yOutput.reset(); // at least one axis is required
            _y = yOutput.format(y);
            break;
        }
        }
        writeBlock(_x, _y, _z);
    }
    }
}

function onCycleEnd() {
    if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    gMotionModal.reset();
    }
}
/* ADD CANNED CYCLES END */

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    feedOutput.reset();
  }
}

function onLinear(_x, _y, _z, feed) {
  // at least one axis is required
  if (pendingRadiusCompensation >= 0) {
    // ensure that we end at desired position when compensation is turned off
    xOutput.reset();
    yOutput.reset();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = feedOutput.format(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode is not supported."));
      return;
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      feedOutput.reset(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
    forceFeed();
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  var f = getFeed(feed);

  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(1), x, y, z, a, b, c, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRewindMachine(_a, _b, _c) {
  /*dummy function so that the post processor does not
produce an error when the specified range of the axis is exceeded
see CAM Post Processor Guide 6/12/20, 7-153 */
}


function forceCircular(plane) {
  switch (plane) {
  case PLANE_XY:
    xOutput.reset();
    yOutput.reset();
    iOutput.reset();
    jOutput.reset();
    break;
  case PLANE_ZX:
    zOutput.reset();
    xOutput.reset();
    kOutput.reset();
    iOutput.reset();
    break;
  case PLANE_YZ:
    yOutput.reset();
    zOutput.reset();
    jOutput.reset();
    kOutput.reset();
    break;
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  // one of X/Y and I/J are required and likewise
  
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), iOutput.format(cx - start.x), jOutput.format(cy - start.y), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), zOutput.format(z), iOutput.format(cx - start.x), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), jOutput.format(cy - start.y), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_XY:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x), jOutput.format(cy - start.y), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var mapCommand = {
  COMMAND_STOP:0,
  COMMAND_END:2,
  COMMAND_SPINDLE_CLOCKWISE:3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE:4,
  COMMAND_STOP_SPINDLE:5
};

function onCommand(command) {
  switch (command) {
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  }

  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  writeBlock(gPlaneModal.format(17));
  if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
    setCoolant(COOLANT_OFF);
  }
  forceAny();
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty("safePositionMethod");
  if (method == "clearanceHeight") {
    if (!is3D()) {
      error(localize("Retract option 'Clearance Height' is not supported for multi-axis machining."));
    }
    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    return;
  }
  validate(arguments.length != 0, "No axis specified for writeRetract().");

  for (i in arguments) {
    retractAxes[arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !retracted) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  // special conditions
  if (retractAxes[2]) { // Z doesn't use G53
    method = "G28";
  }

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      words.push("X" + xyzFormat.format(_xHome));
      xOutput.reset();
      break;
    case Y:
      words.push("Y" + xyzFormat.format(_yHome));
      yOutput.reset();
      break;
    case Z:
      words.push("Z" + xyzFormat.format(_zHome));
      zOutput.reset();
      retracted = true;
      break;
    default:
      error(localize("Unsupported axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    switch (method) {
    case "G28":
      gMotionModal.reset();
      gAbsIncModal.reset();
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
      writeBlock(gAbsIncModal.format(90));
      break;
    case "G53":
      gMotionModal.reset();
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), words);
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
  }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    if (singleLineCoolant) {
      writeBlock(coolantCodes.join(getWordSeparator()));
    }else {
      for (var c in coolantCodes) {
        if ((coolantCodes[c] == "M64") || (coolantCodes[c] == "M65")) writeBlock(coolantCodes[c], "P0");
        else writeBlock(coolantCodes[c]);//writeBlock(coolantCodes[c], "not64");
      }      
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (isProbeOperation()) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    return undefined; // coolant is already active
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined)) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(mFormat.format(coolantOff[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(coolantOff));
    }
  }

  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      coolantCodes.on = coolants[c].on;
      if (coolants[c].off != undefined) {
        coolantCodes.off = coolants[c].off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = coolants[i].off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(mFormat.format(m[i]));
      }
    } else {
      multipleCoolantBlocks.push(mFormat.format(m));
    }
    currentCoolantMode = coolant;
    return multipleCoolantBlocks; // return the single formatted coolant value
  }
  return undefined;
}

function onClose() {
  var RetractPosition = getProperty("safePositionMethod");
  writeRetract(Z);
  setCoolant(COOLANT_OFF);
  onCommand(COMMAND_STOP_SPINDLE);

  switch (getProperty("returnPosition")) {
    case "G28Z":
      if (!(RetractPosition == "G28" || RetractPosition == "G53")) {
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), "Z0");
      writeBlock(gAbsIncModal.format(90));
      }
      break;
    case "G28XYZ":
      if (!(RetractPosition == "G28" || RetractPosition == "G53")) {
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), "Z0");
      }
      writeBlock(gFormat.format(28), gAbsIncModal.format(91), "X0 Y0");
      writeBlock(gAbsIncModal.format(90));
      break;
    case "G30Z":
      writeBlock(gFormat.format(30), gAbsIncModal.format(91), "Z0");
      writeBlock(gAbsIncModal.format(90));
      break;
    case "G30XYZ":
      writeBlock(gFormat.format(30), gAbsIncModal.format(91), "Z0");
      writeBlock(gFormat.format(30), gAbsIncModal.format(91), "X0 Y0");
      writeBlock(gAbsIncModal.format(90));
      break;
    case "WCS":
      writeBlock(gMotionModal.format(0), gAbsIncModal.format(90), "X0 Y0");
      break;
  }
  onImpliedCommand(COMMAND_END);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  if (isRedirecting()) {
    closeRedirection();
  }
}

function setProperty(property, value) {
  properties[property].current = value;
}

// Start of machine configuration logic
var compensateToolLength = false; // add the tool length to the pivot distance for nonTCP rotary heads
var virtualTooltip = false; // translate the pivot point to the virtual tool tip for nonTCP rotary heads
// internal variables, do not change
var receivedMachineConfiguration;
var tcpIsSupported;

function activateMachine() {
  // determine if TCP is supported by the machine
  tcpIsSupported = false;
  var axes = [machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW()];
  for (var i in axes) {
    if (axes[i].isEnabled() && axes[i].isTCPEnabled()) {
      tcpIsSupported = true;
      break;
    }
  }

  // setup usage of multiAxisFeatures
  useMultiAxisFeatures = getProperty("useMultiAxisFeatures") != undefined ? getProperty("useMultiAxisFeatures") :
    (typeof useMultiAxisFeatures != "undefined" ? useMultiAxisFeatures : false);
  useABCPrepositioning = getProperty("useABCPrepositioning") != undefined ? getProperty("useABCPrepositioning") :
    (typeof useABCPrepositioning != "undefined" ? useABCPrepositioning : false);

  if (!machineConfiguration.isMachineCoordinate(0) && (typeof aOutput != "undefined")) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1) && (typeof bOutput != "undefined")) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2) && (typeof cOutput != "undefined")) {
    cOutput.disable();
  }

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // don't need to modify any settings for 3-axis machines
  }

  // retract/reconfigure
  safeRetractDistance = getProperty("safeRetractDistance") != undefined ? getProperty("safeRetractDistance") :
    (typeof safeRetractDistance == "number" ? safeRetractDistance : 0);
  if (machineConfiguration.performRewinds() || (typeof performRewinds == "undefined" ? false : performRewinds)) {
    machineConfiguration.enableMachineRewinds(); // enables the rewind/reconfigure logic
    if (typeof stockExpansion != "undefined") {
      machineConfiguration.setRewindStockExpansion(stockExpansion);
      if (!receivedMachineConfiguration) {
        setMachineConfiguration(machineConfiguration);
      }
    }
  }

  if (machineConfiguration.isHeadConfiguration()) {
    compensateToolLength = typeof compensateToolLength == "undefined" ? false : compensateToolLength;
    virtualTooltip = typeof virtualTooltip == "undefined" ? false : virtualTooltip;
    machineConfiguration.setVirtualTooltip(virtualTooltip);
  }
  setFeedrateMode();

  if (machineConfiguration.isHeadConfiguration() && compensateToolLength) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      if (section.isMultiAxis()) {
        machineConfiguration.setToolLength(section.getTool().getBodyLength()); // define the tool length for head adjustments
        section.optimizeMachineAnglesByMachine(machineConfiguration, OPTIMIZE_AXIS);
      }
    }
  } else {
    optimizeMachineAngles2(OPTIMIZE_AXIS);
  }
}

function setFeedrateMode(reset) {
  if ((tcpIsSupported && !reset) || !machineConfiguration.isMultiAxisConfiguration()) {
    return;
  }
  machineConfiguration.setMultiAxisFeedrate(
    tcpIsSupported ? FEED_FPM : FEED_INVERSE_TIME,
    9999.99, // maximum output value for inverse time feed rates
    INVERSE_MINUTES, // can be INVERSE_SECONDS or DPM_COMBINATION for DPM feeds
    0.5, // tolerance to determine when the DPM feed has changed
    1.0 // ratio of rotary accuracy to linear accuracy for DPM calculations
  );
  if (!receivedMachineConfiguration || (revision < 45765)) {
    setMachineConfiguration(machineConfiguration);
  }
}

function defineMachine() {
  if (false) { // note: setup your machine here
    var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-120, 120], preference:1, tcp:true});
    var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], range:[-360, 360], preference:0, tcp:true});
    machineConfiguration = new MachineConfiguration(aAxis, cAxis);

    setMachineConfiguration(machineConfiguration);
    if (receivedMachineConfiguration) {
      warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
      receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
    }
  }
  /* home positions */
  // machineConfiguration.setHomePositionX(toPreciseUnit(0, IN));
  // machineConfiguration.setHomePositionY(toPreciseUnit(0, IN));
  // machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
}
// End of machine configuration logic

function setWorkPlane(abc) {
  // setCurrentABC() does send back the calculated ABC angles for indexing operations to the simulation.
  setCurrentABC(abc); // required for machine simulation
}
// <<<<< INCLUDED FROM ../common/grbl.cps







