import D "mo:base/Debug";
import N "mo:base/Nat";
import T "Tile/Tile";
import M "Mob";
import Z "Zone/Zone";

actor {
  
  let testFloor = T.buildTile("Floor", 0);
  let testWall = T.buildTile("Wall", 0);

  let testMob = M.buildMob("Test Mob");

  public func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

};
