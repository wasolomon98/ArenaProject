import AT "ArenaToolset";
import D "mo:base/Debug";

module {

    public class Mob() {   
        var name : Text = "";
        var self_coords : (?Nat, ?Nat, ?Nat) = (null, null, null);

        public func setName(newName : Text) {
            name := newName
        };

        // Private for a reason. Should eventually function as part of a more accessible 'Move' func
        func setNewCoords(new_coords : (?Nat, ?Nat, ?Nat)) : (?Nat, ?Nat, ?Nat) {
            if (AT.containsNullCoord(new_coords) == true){
                D.print("Input coordinates contained one or more null values");
                self_coords := (null, null, null);
            } else {    var self_coords = new_coords;  };  
            return self_coords;
            };

        public func getName() : Text {
            D.print("The mob's name is " # name);
            return name;
        };

        public func getCoords() : (?Nat, ?Nat, ?Nat) {
            return self_coords;
        };

    };

    public func buildMob(name : Text) : Mob {
        var mob = Mob();
        mob.setName(name);
        D.print("Mob created with name " # mob.getName() # ".");
        return mob;
    };

};