import D "mo:base/Debug";
import N "mo:base/Nat";
import I "mo:base/Int";

actor {

  type Tile = (Text, Nat);

  type Location = {#empty; #tile : Tile; #mob : Mob;};
  type ZoneMatrix = [var Location];

  public type Coordinate = (Nat, Nat, Nat);

  func getCoordinateIndex(coordinate : Coordinate, width : Nat, depth : Nat) : Nat {
    let index = coordinate.0 + coordinate.1 * width * depth + coordinate.2 * width;
    return index;
  }; 

  type Health = {#alive : Nat; #dead;};

  class Mob(name : Text) {
  
    var health : Health = #alive(5);
    var coords : Coordinate = (0, 0, 0);
  
    public func getName() : Text {
      return name;
    };

    public func getCoords() : Coordinate {
      return coords;
    };

    public func setCoords(newCoords : Coordinate) : () {
      coords := newCoords;
    };

    public func recieveDamage(damage : Nat) : Health {

      switch health {
        case (#alive hp) {
          let tempHealth : Int = hp;
          let newHealth = tempHealth - damage;
          if (newHealth <= 0) {
            health := #dead;
          } else { health := #alive(I.abs(newHealth)); };
        };
        case (#dead) {
          D.trap("THAT UNIT IS DEAD");
        };
      };

      return health;

    };
  };

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
    
    #empty, #empty, sampleLocation, #empty, #empty,
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

      var mob = Mob("PLACEHOLDER");

      switch loc {
        case (#mob m) { mob := m; };
        case (#tile t) { D.trap("THAT IS NOT A MOB"); };
        case (#empty) { D.trap("THAT IS NOT A MOB"); };
      };

      loc := zoneMatrix[targetIndex];

      switch loc {
        case (#empty) { zoneMatrix[targetIndex] := #mob(mob); zoneMatrix[currentIndex] := #empty; };
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

  type Team = [var Mob];  

  // TEST VERSION - NOTE REDUNDANCIES
  func setTeam(team : Team, zone : Zone, teamNo : Nat) : () {
    type PlacementStatus = {#first; #second; #third; #fourth; #done;};
    var n = true;
    var count : PlacementStatus = #first;
    var teamPlacement = 0;
    if (teamNo == 1) { teamPlacement := 4; };
    while (n == true) {
      switch count {
        case (#first) {
          let coords : Coordinate = (teamPlacement, 1, 0);
          zone.setMob(team[0], coords); count := #second;
          team[0].setCoords(coords);
        };
        case (#second) {
          let coords : Coordinate = (teamPlacement, 1, 1);
          zone.setMob(team[1], coords); count := #third;
          team[1].setCoords(coords);
        };
        case (#third) {
          let coords : Coordinate = (teamPlacement, 1, 2);
          zone.setMob(team[2], coords); count := #fourth;
          team[2].setCoords(coords);
        };
        case (#fourth) {
          let coords : Coordinate = (teamPlacement, 1, 3);
          zone.setMob(team[3], coords); count := #done;
          team[3].setCoords(coords);
        };
        case (#done) {
          D.print("Team placed successfully!");
          n := false;
        };
      };
    };
  };

  public type Direction = {#north; #south; #east; #west;};

  class TestCommands() {
    // TEST VERSION - SIMPLIFIED
    public func move(actingMob : Mob, zone : Zone, dX : Nat, dZ : Nat) : () {

      let destination : Coordinate = (dX, 1, dZ);

      // check the start location of the mob
      let startLocation = actingMob.getCoords();
    
      let index = getCoordinateIndex(startLocation, 5, 5);
      let loc = zone.getIndexItem(index);
      switch loc {
        case ( #mob m ) { zone.moveMob(startLocation, destination); actingMob.setCoords(destination); };
        case ( #tile t ) { D.trap("MOB NOT LOCATED AT INTERNAL COORDINATES"); };
        case ( #empty ) { D.trap("MOB NOT LOCATED AT INTERNAL COORDINATES"); };
      };

    };

    // TEST VERSION - SIMPLIFIED
    public func attack(actingMob : Mob, zone : Zone, targetDirection : Direction, damageAmount : Nat) : () {

      // check the mob's location
      let mobCoordinate : Coordinate = actingMob.getCoords();
  
      // Determine N, S, E, W
      let north : Coordinate = (mobCoordinate.0, mobCoordinate.1, mobCoordinate.2 + 1);
      let south : Coordinate = (mobCoordinate.0, mobCoordinate.1, mobCoordinate.2 - 1);
      let east : Coordinate = (mobCoordinate.0 + 1, mobCoordinate.1, mobCoordinate.2);
      let west : Coordinate = (mobCoordinate.0 - 1, mobCoordinate.1, mobCoordinate.2);

      // Determine where the mob is aiming
      var targetCoord : Coordinate = (0, 0, 0);
      switch targetDirection {
        case (#north) { targetCoord := north; };
        case (#south) { targetCoord := south; };
        case (#east) { targetCoord := east; };
        case (#west) { targetCoord := west; };
      }; 

      // Check to see if the target is empty
      var target = Mob("PLACEHOLDER");
      
      let index = getCoordinateIndex(targetCoord, 5, 5);
      let loc = zone.getIndexItem(index);

      switch loc {
        case (#mob m) { target := m; };
        case (#tile t) { D.trap("THAT IS NOT A MOB"); };
        case (#empty) { D.trap("THAT IS NOT A MOB"); };
      };

      let h = target.recieveDamage(damageAmount);
      
      switch h {
        case (#dead) { zone.emptyCoord(index); D.print("The target was killed."); };
        case (#alive hp) { D.print("The target has " # I.toText(hp) # " health remaining.") }
      };

    };

  };

  // Test Commands class object
  let tc = TestCommands();
  
  // Test function to make TestCommand functions accessible to end users
  public func userMove(mobNo : Nat, cX : Nat, cZ : Nat) {
    if (mobNo == 0) { tc.move(mob1A, testZone, cX, cZ); 
    } else if (mobNo == 1) { tc.move(mob2A, testZone, cX, cZ);
    } else if (mobNo == 2) { tc.move(mob3A, testZone, cX, cZ);
    } else if (mobNo == 3) { tc.move(mob4A, testZone, cX, cZ);
    } else if (mobNo == 4) { tc.move(mob1B, testZone, cX, cZ);
    } else if (mobNo == 5) { tc.move(mob2B, testZone, cX, cZ);
    } else if (mobNo == 6) { tc.move(mob3B, testZone, cX, cZ);
    } else if (mobNo == 7) { tc.move(mob4B, testZone, cX, cZ);};
    D.print("Mob moved successfully.")
  };

  public func userAttack(mobNo : Nat, direction : Text, damageAmount : Nat) : () {
    
    var targetDirection : Direction = #north;

    if (direction == "North") { targetDirection := #north; 
    } else if (direction == "South") { targetDirection := #south; 
    } else if (direction == "East") { targetDirection := #east; 
    } else if (direction == "West") { targetDirection := #west; 
    } else {D.trap("INVALID DIRECTIONAL INPUT")};

    if (mobNo == 0) { tc.attack(mob1A, testZone, targetDirection, damageAmount);
    } else if (mobNo == 1) { tc.attack(mob2A, testZone, targetDirection, damageAmount);
    } else if (mobNo == 2) { tc.attack(mob3A, testZone, targetDirection, damageAmount);
    } else if (mobNo == 3) { tc.attack(mob4A, testZone, targetDirection, damageAmount);
    } else if (mobNo == 4) { tc.attack(mob1B, testZone, targetDirection, damageAmount);
    } else if (mobNo == 5) { tc.attack(mob2B, testZone, targetDirection, damageAmount);
    } else if (mobNo == 6) { tc.attack(mob3B, testZone, targetDirection, damageAmount);
    } else if (mobNo == 7) { tc.attack(mob4B, testZone, targetDirection, damageAmount);};
    D.print("Mob attacked successfully.")
  };

  // Test mobs. 3 for 'Team A', and 3 for 'Team B'
  let mob1A = Mob("mob1A"); let mob2A = Mob("mob2A"); let mob3A = Mob("mob3A"); let mob4A = Mob("mob4A");
  let mob1B = Mob("mob1B"); let mob2B = Mob("mob2B"); let mob3B = Mob("mob3B"); let mob4B = Mob("mob4B");

  // Test mobs sorted into two teams
  let teamA : Team = [var mob1A, mob2A, mob3A, mob4A];
  let teamB : Team = [var mob1B, mob2B, mob3B, mob4A];

  // Test zone which, by default, initializes our simple test zone
  let testZone = Zone(); 

  // Places each team within our testZone
  // Each should return a 'Team placed successfully' message in the terminal
  setTeam(teamA, testZone, 0);
  setTeam(teamB, testZone, 1);
};
