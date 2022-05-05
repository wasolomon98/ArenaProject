import T "Tile"

module {
    public func buildTile(name : Text, difficulty : Nat) : T.Tile {
        let tile = T.Tile(name, difficulty);
        return tile;
    };


};