import TM "mo:base/TrieMap";
import N "mo:base/Nat";
import M "../Mob";
import T "../Tile/Tile";
import TD "../Tile/TileDirectory";

module {
    /*
    class Zone (zoneWidth : Nat, zoneHeight : Nat, zoneDepth : Nat){
        let zoneArea = zoneWidth * zoneHeight * zoneDepth;
        var zoneName : Text = "";
        let zoneTileContents : TM.TrieMap<C.Coords, T.Tile> = TM.TrieMap<C.Coords, T.Tile>(zoneArea, (C.Coords, C.Coords), C.Coords);
        func setName(newName : Text) {
            zoneName := newName;
        };

        public func getZoneDimension(keyword : ?Text) : ?Nat{
            if (keyword == null){
                return null;
            } else if (keyword == ?"w"){
                return ?zoneWidth;
            } else if (keyword == ?"h"){
                return ?zoneHeight;
            } else if (keyword == ?"d"){
                return ?zoneDepth;
            } else {
                return null;
            };
        };

    };

*/
/*
    public func ZoneConstructor (name : Text) : Zone {

        // Check name against an index of valid map options
        // Load tiles from the list of valid map options

    };
*/
};