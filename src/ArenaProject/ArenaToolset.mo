module {

    public func containsNullCoord(coords : (?Nat, ?Nat, ?Nat)) : Bool {
        if (coords.0 == null) {
            return true;
        } else if (coords.1 == null) {
            return true;
        } else if (coords.2 == null) {
            return true;
        } else {
            return false;
        };
    };

};