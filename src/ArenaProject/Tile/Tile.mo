import D "mo:base/Debug";
import N "mo:base/Nat";

module {

    public class Tile(name : Text, difficulty : Nat) {
        /*      
            The base Tile class is the building block of Zones.
        */

        public func getTileName() : Text {
            D.print(name);
            return name;
        };

        public func getTileDifficulty() : Nat {
            D.print(N.toText(difficulty));
            return difficulty;
        };
    };

    public func buildTile(name : Text, difficulty : Nat) : Tile {
        let tile = Tile(name, difficulty);
        return tile;
    };

};