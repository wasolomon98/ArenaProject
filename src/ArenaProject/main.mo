import D "mo:base/Debug";
import N "mo:base/Nat";
import I "mo:base/Int";
import L "mo:base/List";
import R "mo:base/Random";
import B "mo:base/Buffer";
 
actor {

  type Tile = (Text, Nat);

  type Location = {#empty; #tile : Tile; #mob : Mob;};
  type ZoneMatrix = [var Location];

  public type Coordinate = (Nat, Nat, Nat);

  func getCoordinateIndex(coordinate : Coordinate, width : Nat, depth : Nat) : Nat {
    let index = coordinate.0 + coordinate.1 * width * depth + coordinate.2 * width;
    return index;
  }; 

  // DOESN'T HANDLE TIES CORRECTLY, SHARED VALUES ARE ASSIGNED IN THEIR LIST ORDER
  // Could also more generally inherit more data from the Session's getTurnOrder() to reduce redundancy.
  // Name is misleading, returns an in-place list of what position 
  func rankNatArray(l : [var Nat], length : Nat) : [var Nat]{
    let ranks : B.Buffer<Nat> = B.Buffer(0); // Array to be returned
    // MAGIC NUMBER USED TO SET UP RANKED, PLEASE FIX WHEN YOU CAN
    let ranked : [var Bool] = [var false, false, false, false, false, false]; // Array tracking which units have already recieved a rank

    // Varriables used to navigate the imported index
    var count : Nat = 0; 
    var current : Nat = 0;
    var storedPos : Nat = 0; 
    var storedVal : Nat = 0; 

    // While not every rank has been assigned
    while (count < length) {
      // look at each index
      while (current < length){
      // compare it to the stored val, make sure it's not smaller or already stored
        if (l[current] > storedVal) {
          if (ranked[current] == false) {
            storedVal := l[current];
            storedPos := current;
          };
          current += 1;
        } else { current += 1; };
      };

      // Stored which index of the original array should be used for each position
      ranks.add(storedPos); 
      ranked[current - 1] := true;
      
      // Upkeep and Value resets
      current := 0;
      storedVal := 0; 
      storedPos := 0;
      count += 1;

    };

    D.print("Nat Array sorted successfully.");
    return ranks.toVarArray();

  };

  type Health = {#alive : Nat; #dead;};

  type Attributes = [var Nat];
  type Stats = [var Nat];

  type AncestryData = (name : Text, description : Text, attributeModifiers : Attributes);
  type JobData = (name : Text, description : Text, favoredAttribute : Attributes, statModifiers : Stats);

  let human : AncestryData = ("Human", "A versatile species.", [var 0,0,0,0,0,0]); 
  let elf : AncestryData = ("Elf", "An agile and proud species.", [var 0,2,0,0,0,2]);
  let dwarf : AncestryData = ("Human", "A hardy and resourceful species.", [var 0,0,2,0,2,0]);

  let knight : JobData = ("Knight", "A brave warrior.", [var 2,0,0,0,0,0], [var 10,5,10,0,0]);
  let mage : JobData = ("Wizard", "A knowledgeable spellcaster.", [var 0,0,0,2,0,0], [var 6,0,0,15,5]);
  let rogue : JobData = ("Rogue", "A brave warrior.", [var 0,2,0,0,0,0], [var 8,10,5,0,5]);

  var ancestryIndex : [var AncestryData] = [var human, elf, dwarf];
  var jobIndex : [var JobData] = [var knight, mage, rogue];

  type ChampionData = (name : Text, description : Text, attributes : Attributes, stats : Stats, ancestry : AncestryData, job : JobData);

  func getAncestryData(ancestryID : Nat) : AncestryData {
    let ancestryData : AncestryData = ancestryIndex[ancestryID];
    D.print("Ancestry Data successfully loaded.");
    return ancestryData;
  };

  func getJobData(jobID : Nat) : JobData {
    let jobData : JobData = jobIndex[jobID];
    D.print("Job Data successfully loaded.");
    return jobData;
  };

  func buildChampionAttributes(ancestryAttributes : Attributes, classAttribute : Attributes) : Attributes {
    let championAttributes : Attributes = [var 0,0,0,0,0,0];
    var i = 0;
    while (i <= 5) {
      let n : Nat = 10 + ancestryAttributes[i] + classAttribute[i];
      championAttributes[i] := n;
      i += 1;
    };
    D.print("Champion Attributes successfully generated.");
    return championAttributes;
  };

  // CAN THIS BE MADE LESS REPETITIVE? SEE ABOUT ITERATION
  func buildChampionStats(attributes : Attributes, jobStats : Stats) : Stats {
    let championStats : Stats = [var 0,0,0,0,0];
    var i = 0;
    while (i <= 4) {
      if (i == 0) {championStats[i] := 10 + attributes[2] + jobStats[0]
      } else if (i == 1) {championStats[i] := 10 + attributes[0] + jobStats[1]
      } else if (i == 2) {championStats[i] := 10 + attributes[1] + attributes[2] + jobStats[2]
      } else if (i == 3) {championStats[i] := 10 + attributes[3] + jobStats[3]
      } else if (i == 4) {championStats[i] := 10 + attributes[4]
      } else {D.trap("ERROR WHILE ASSEMBLING CHAMPION STATS")};
      i += 1;
    };
    D.print("Champion Stats successfully generated.");
    return championStats;
  };

  class Champion(name : Text, description : Text, ancestryID : Nat, jobID : Nat) {

    func buildChampionData() : ChampionData {
    
      let ancestryData : AncestryData = getAncestryData(ancestryID);
      let jobData : JobData = getJobData(jobID);
      let attributes : Attributes = buildChampionAttributes(ancestryData.2, jobData.2);
      let stats : Stats = buildChampionStats(attributes, jobData.3);

      let championData : ChampionData = (name, description, attributes, stats, ancestryData, jobData);
      D.print("Champion Data assembled successfully.");
      return championData;
    };

    let championData : ChampionData = buildChampionData();

    public func getChampionData() : ChampionData {
      D.print("Champion Data delivered successfully.");
      return championData;
    };

  };

  type MobData = (name : Text, attributes : Attributes, stats : Stats);

  type MobType = {#champion : ChampionData;};

  class Mob(mobType : MobType) {
  
    // REMOVE REDUNDANCY AND STREAMLINE WITH ITERATION ASAP
    // Constructs MobData type containing Mob's static readable data. 
    func buildMobData() : MobData {
      switch (mobType) {
        case (#champion championData) { 
          let m : MobData = (championData.0, championData.2, championData.3);
          D.print("Mob Data assembled successfully.");
          return m;
        };
      };
    };

    // Sets Mob's Health according to the stats generated in buildMobData()
    func buildMobHealth() : Health {
      let h : Health = #alive(mobData.2[0]);
      D.print("Mob Health generated successfully.");
      return h;
    };

    // NEED A BETTER BLOB GENERATION METHOD; PLACEHOLDER BLOB
    public func generateMobInitiative() : Nat {
      let i : Nat = mobData.2[1] - 9 + R.rangeFrom(8, "ISTHISABLOB?");
      D.print("Mob Initiative generated successfully");
      return i;
    };

    let mobData : MobData = buildMobData();
    var mobHealth : Health = buildMobHealth();  
    var localCoordinates : Coordinate = (0,0,0);
    let mobInitiative : Nat = generateMobInitiative();

    D.print("Mob fully initialized.");

    public func getName() : Text {
      return mobData.0;
    };

    public func getCoords() : Coordinate {
      return localCoordinates;
    };

    public func getInitiative() : Nat {
      return mobInitiative;
    };

    public func setCoords(newCoords : Coordinate) : () {
      localCoordinates := newCoords;
      D.print("New Coordinates assigned to Mob successfully.");
    };

    public func recieveDamage(damage : Nat) : () {
      switch (mobHealth) {
        case (#alive hp) {
          let currentHealth : Int = hp;
          let newHealth = currentHealth - damage;
          if (newHealth <= 0) {
            mobHealth := #dead;
          } else { mobHealth := #alive(I.abs(newHealth)); };
        };
        case (#dead) {
          D.trap("ERROR: Target is recorded as dead.");
        };
      };
    };

  };

  type Shape = {#line : (length : Nat);};

  func getCoord(coordinate : Coordinate) : Coordinate {
    return coordinate;
  };

  type Dimensions = (Nat, Nat, Nat);
  type ZoneTemplate = (Text, Dimensions, ZoneMatrix);

  class ZoneContstructor() {
    let sampleTile : Tile = ("Sample Tile", 0);
    let sampleLocation : Location = #tile(sampleTile);

    let testZone : ZoneTemplate = ("Test Zone", (5, 2, 5), 

    [var sampleLocation, sampleLocation, sampleLocation, sampleLocation, sampleLocation,
    sampleLocation, sampleLocation, sampleLocation, sampleLocation, sampleLocation,
    sampleLocation, sampleLocation, sampleLocation, sampleLocation, sampleLocation,
    sampleLocation, sampleLocation, sampleLocation, sampleLocation, sampleLocation,
    sampleLocation, sampleLocation, sampleLocation, sampleLocation, sampleLocation,
    
    #empty, #empty, #empty, #empty, #empty,
    #empty, #empty, #empty, #empty, #empty,
    #empty, #empty, #empty, #empty, #empty,
    #empty, #empty, #empty, #empty, #empty,
    #empty, #empty, #empty, #empty, #empty]);
  
    public func setZoneName() : Text {
      return testZone.0;
    };

    public func setZoneDimensions() : Dimensions {
      return testZone.1;
    };

    public func setZoneMatrix() : ZoneMatrix {
      return testZone.2; 
    };

  };

  let zc = ZoneContstructor();

  class Zone() {

    let name : Text = zc.setZoneName();
    let dimensions : Dimensions = zc.setZoneDimensions();
    let zoneMatrix : ZoneMatrix = zc.setZoneMatrix();

    public func getName() : Text {
      return name;
    };

    public func getDimension() : Dimensions {
      return dimensions;
    };

    public func getIndexItem(index : Nat) : Location {
      return zoneMatrix[index];
    };

    func checkFull(coordinate : Coordinate) : Bool {
      let index = getCoordinateIndex(coordinate, dimensions.0, dimensions.2);
      let loc : Location = zoneMatrix[index];
      switch loc { 
        case (#empty) { return false; }; 
        case (#mob m) { return true; };
        case (#tile t) { return true; };
      };
    };

    public func setMob(mob : Mob, coordinate : Coordinate) : () {
      let index : Nat = getCoordinateIndex(coordinate, dimensions.0, dimensions.2);
      zoneMatrix[index] := #mob(mob);
    };

    public func emptyCoord(index : Nat) : () {
      zoneMatrix[index] := #empty;
    };

    public func moveMob(current : Coordinate, destination : Coordinate) : () {

      let currentIndex = getCoordinateIndex(current, dimensions.0, dimensions.2);
      let targetIndex = getCoordinateIndex(destination, dimensions.0, dimensions.2);

      var loc : Location = zoneMatrix[currentIndex];

      let mobBuffer : B.Buffer<Mob> = B.Buffer(0);

      switch loc {
        case (#mob m) { mobBuffer.add(m); };
        case (#tile t) { D.trap("THAT IS NOT A MOB"); };
        case (#empty) { D.trap("THAT IS NOT A MOB"); };
      };

      loc := zoneMatrix[targetIndex];

      switch loc {
        case (#empty) { zoneMatrix[targetIndex] := #mob(mobBuffer.get(0)); zoneMatrix[currentIndex] := #empty; };
        case (#mob m) { D.trap("INVALID MOVE DESTINATION"); };
        case (#tile t) { D.trap("INVALID MOVE DESTINATION"); };
      };
    };
    
    public func debugDisplayIndex(index : Nat) : () {
      var returnText : Text = "";
      let loc : Location = getIndexItem(index);
      switch loc {
        case (#empty) {returnText := "EMPTY";};
        case (#tile t) {returnText := t.0};
        case (#mob m) {returnText := m.getName();};
      };
      D.print(returnText);
    };

  };


  // TEST VERSION - NOTE REDUNDANCIES
  

  public type Direction = {#north; #south; #east; #west;};

  func move(actingMob : Mob, zone : Zone, dX : Nat, dZ : Nat) : () {

    let destination : Coordinate = (dX, 1, dZ);

    // check the start location of the mob
    let startLocation = actingMob.getCoords();
    
    let index = getCoordinateIndex(startLocation, 5, 5);
    zone.debugDisplayIndex(index);
    let loc = zone.getIndexItem(index);

    switch loc {
      case ( #mob m ) { zone.moveMob(startLocation, destination); actingMob.setCoords(destination); };
      case ( #tile t ) { D.trap("MOB NOT LOCATED AT INTERNAL COORDINATES"); };
      case ( #empty ) { D.trap("MOB NOT LOCATED AT INTERNAL COORDINATES"); };
    };

  };

  // TEST VERSION - SIMPLIFIED
  func attack(actingMob : Mob, zone : Zone, targetDirection : Direction, damageAmount : Nat) : () {

    // check the mob's location
    let mobCoordinate : Coordinate = actingMob.getCoords();
    zone.debugDisplayIndex(getCoordinateIndex(mobCoordinate, 5, 5));

    // Determine N, S, E, W
    let north : Coordinate = (mobCoordinate.0, mobCoordinate.1, mobCoordinate.2 + 1);
    zone.debugDisplayIndex(getCoordinateIndex(north, 5, 5));
    let south : Coordinate = (mobCoordinate.0, mobCoordinate.1, mobCoordinate.2 - 1);
    zone.debugDisplayIndex(getCoordinateIndex(south, 5, 5));
    let east : Coordinate = (mobCoordinate.0 + 1, mobCoordinate.1, mobCoordinate.2);
    zone.debugDisplayIndex(getCoordinateIndex(east, 5, 5));
    let west : Coordinate = (mobCoordinate.0 - 1, mobCoordinate.1, mobCoordinate.2);
    zone.debugDisplayIndex(getCoordinateIndex(west, 5, 5));

    // Determine where the mob is aiming
    var targetCoord : Coordinate = (0, 0, 0);
    switch targetDirection {
      case (#north) { targetCoord := north; };
      case (#south) { targetCoord := south; };
      case (#east) { targetCoord := east; };
      case (#west) { targetCoord := west; };
    }; 

    // Check to see if the target is empty
    let buffer : B.Buffer<Mob> = B.Buffer(0);
      
    let index = getCoordinateIndex(targetCoord, 5, 5);
    let loc = zone.getIndexItem(index);

    switch loc {
      case (#mob m) { buffer.add(m); };
      case (#tile t) { D.trap("THAT IS NOT A MOB"); };
      case (#empty) { D.trap("THAT IS NOT A MOB"); };
    };

    let target : [Mob] = buffer.toArray();
    target[0].recieveDamage(damageAmount);

  };

 

  // Test Commands class object
  
  class RoundManager() {

    var currentRound = 0;

    // Get Next Mob in Turn order 

    func roundUpkeep() : Nat {
      // Read current acting Mob

      // Give Action Points (AP)
      // Take Action
      // Reduce AP
      // Check if AP > 0, if NO continue
      return 0;

    };

  };
  
  type SessionData = (turnNumber : Nat);
  type TeamCount = {#two; #three; #four;};

  class Session(numTeams : TeamCount, mobsPerTeam : Nat, championData : [ChampionData], zoneID : Nat) {

    func buildSessionData() : SessionData {
      var sessionData : SessionData = (0);
      D.print("Session Data assembled successfully.");
      return sessionData;
    };

    func buildPlayerMobs() : [var Mob] {
      let n : Nat = 2 * mobsPerTeam; var i : Nat = 0;
      let mobList : B.Buffer<Mob> = B.Buffer(0);
      while (i < n) { 
        let m : Mob = Mob(#champion(championData[i]));
        mobList.add(m);
        i += 1; 
      };
      let r = mobList.toVarArray();
      D.print("Mobs assembled from Champion Data successfully.");
      return r;
    };
  
    // Create Data Structures
    var sessionData : SessionData = buildSessionData(); // Session data like turn order. Maybe total damage dealt and other metrics?
    let mobList : [var Mob] = buildPlayerMobs(); //

    // Build teams and bind players to each
    func createTeam(start : Nat, stop : Nat) : [var Mob] {
      let team : B.Buffer<Mob> = B.Buffer(0);
      var i : Nat = start; var j : Nat = 0;
      while (i < stop){
        team.add(mobList[i]);
        i += 1;
      };
      let r : [var Mob] = team.toVarArray();
      D.print("Team successfully assigned from Mob List.");
      return r;
    };
    
    // TEMPORARY IMPLEMENT FOR TWO TEAMS; NEEDS AUTOMATING FOR DISTRIBUTION OF UP TO FOUR UNITS
    // Won't actually be fully functional until we start working with principal IDs...
    // As it works now, the game assumes that the mobs arrive ordered to be split into two teams (of semi-variable length...)
    // Technically, they aren't especially versa
    let teamA : [var Mob] = createTeam(0, mobsPerTeam); 
    let teamB : [var Mob] = createTeam(mobsPerTeam, mobsPerTeam * 2);

    // Get Mob Turn Order
    func getTurnOrder() : [var Mob] {
      let temp : B.Buffer<Nat> = B.Buffer(0);
      let n : Nat = 2 * mobsPerTeam; var i : Nat = 0; // NOTE: USES CONSTANT 2 INSTEAD OF READING THE ACTUAL NUMBER OF TEAMS
      
      // Record Mob initiatives      
      while (i < n) { 
        temp.add(mobList[i].generateMobInitiative()); 
        i += 1; 
      };
      let initiativeList : [var Nat] = temp.toVarArray();
      D.print("Initiatives recorded successfully");
      
      
      let initialInitiativePosition : [var Nat] = rankNatArray(initiativeList, n);

      // Rank their initiatives, also build a second list tracking placement on the original list
      // take first item in list
      
      let turnOrder : B.Buffer<Mob> = B.Buffer(0);
      i := 0; // Reset loop counter
      while (i < n) {
        let t = initialInitiativePosition[i];
        turnOrder.add(mobList[t]);
        i += 1;
      };
       
      D.print("Turn Order successfully assigned.");
      return turnOrder.toVarArray();
    };

    var turnOrder : [var Mob] = getTurnOrder();
    D.print(turnOrder[3].getName());

    // build zone
    // Test zone which, by default, initializes our simple test zone
    // See the Zone class for information on how this functions.
    // In the future, more complex Zone selection will make use of the Session's passed zoneID param
    let testZone : Zone = Zone(); 

    func setTeam(team : [var Mob], zone : Zone, teamNo : Nat) : () {
      type PlacementStatus = {#first; #second; #third; #done;};
      var n = true;
      var count : PlacementStatus = #first;
      var teamPlacement = 1;
      if (teamNo == 1) { teamPlacement := 3; };
      while (n == true) {
        switch count {
          case (#first) {
            let coords : Coordinate = (teamPlacement, 1, 1);
            zone.setMob(team[0], coords); count := #second;
            team[0].setCoords(coords);
          };
          case (#second) {
            let coords : Coordinate = (teamPlacement, 1, 2);
            zone.setMob(team[1], coords); count := #third;
            team[1].setCoords(coords);
          };
          case (#third) {
            let coords : Coordinate = (teamPlacement, 1, 3);
            zone.setMob(team[2], coords); count := #done;
            team[2].setCoords(coords);
          };
          case (#done) {
            D.print("Team placed successfully!");
            n := false;
          };
        };
      };
    };

    // place mobs
    // Uses previous build's test function
    // Assumes both teams use 3 Mobs each
    // Team num should be taken alongside the number of teams
    // Would 
    // Takes TEAM, ZONE, TEAM NUM
    setTeam(teamA, testZone, 0);
    setTeam(teamB, testZone, 1);

    // MAGIC NUMBER USED; PRESUPPOSED TOTAL UNIT COUNT IS 6
    // FIX AFTER HACKATHON DEMO
    func setActingMob() : Mob {
      let actingMob : Mob = turnOrder[0];
      var i : Nat = 1;
      while (i < 6) {
        turnOrder[i-1] := turnOrder[i];
        i += 1;
      };
      turnOrder[5] := actingMob;
      return actingMob;
    };

    var actingMob = setActingMob();
    D.print("Current Acting Mob is: " # actingMob.getName());

    // Start Turn 1
    var actionPoints = 3;

    type ActionType = {#none; #attack; #move;};

    // Switch-readable format for the incoming actionType
    // Should eventually take a nat that pulls from a sequential index of possible actions
    // This index can also return a check to see whether a given mob is whitelisted for a certain action
    func getActionType(actionType : Text) : ActionType {
        var a : ActionType = #none;
        if (actionType == "Attack") {
          a := #attack;
        } else if (actionType == "Move") {
          a := #move;
        };
        D.print("Action interpreted as type: " # actionType);
        return a;
    };

    public func performAction(actionType : Text, dX : Nat, dZ : Nat, targetDirection : Direction) : () {
      

      // Stores the action being berformed by action
      var action : ActionType = getActionType(actionType);


      func processAction(action : ActionType) : () {
        // actions
        switch (action) {
          case (#none){
            D.trap("INVALID ACTION REQUEST");
          };
          case (#move) {
            move(actingMob, testZone, dX, dZ);
            D.print("Mob moved successfully.");
          };
          case (#attack) {
            attack(actingMob, testZone, targetDirection, 5);
            D.print("Mob attacked successfully");
          };
        };
      };


      processAction(action);

      actingMob := setActingMob();
      D.print("Current Acting Mob is: " # actingMob.getName());
      
    };
    

      // check victory conditions

      // loop until victory conditions are met

  };

/*------------------------------------------------------------------------
| DEBUG AND TESTING BELOW THIS LINE
| Data below this header constructs samples of Champion NFTs
| And instantiates the Session itself
------------------------------------------------------------------------*/

  // SAMPLE CODE 
  // Our band of sample Champions. These are the precursors to Mobs.
  // These will eventually exist as player-customized NFTs

  // Team A
  let mercenary : Champion = Champion("Mercenary", "A sellsword.", 0, 0);
  let wizard : Champion = Champion("Wizard", "An arcane practicioner.", 0, 1);
  let thief : Champion = Champion("Thief", "A treacherous scoundrel.", 0, 2);

  // Team B
  let elfWarrior : Champion = Champion("Elven Warrior", "An elf trained as a knight.", 1, 0);
  let elfMageA : Champion = Champion("Elven Mage", "An elf trained in the mystic arts.", 1, 1);
  let elfMageB : Champion = Champion("Elven Mage", "An elf trained in the mystic arts.", 1, 1);

  // Sample assembly of Champion Data, packaged data collected from player NFTs at session initialization (a necessary paramater to )
  let sampleChampionData: [ChampionData] = [
    mercenary.getChampionData(), wizard.getChampionData(), thief.getChampionData(), 
    elfWarrior.getChampionData(), elfMageA.getChampionData(), elfMageB.getChampionData()
  ];

  // Our sample session! Everything in the game happens here!
  let sampleSession : Session = Session(#two, 3, sampleChampionData, 0);
  
  
  public func takeAction(action : Text, dX : Nat, dZ : Nat, direction : Text) : () {
    var temp : Direction = #north;
    if (direction == "South") {
      temp := #south;
    } else if (direction == "East") {
      temp := #east;
    } else if (direction == "West") {
      temp := #west;
    };
  
    sampleSession.performAction(action, dX, dZ, temp);
  };
  D.print("TEST");

};