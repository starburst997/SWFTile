package openfl_tilelayer.swfty.renderer;

import haxe.io.Bytes;
import haxe.ds.IntMap;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Tileset;

typedef EngineLayer = aze.display.TileLayer;
typedef DisplayTile = String;

class FinalLayer extends BaseLayer {

    public static inline function create(?width:Int, ?height:Int) {
        return new FinalLayer(width, height);
    }    

    public function new(?width:Int, ?height:Int) {
        super(new TilesheetEx(null, 1.0), width, height, true, false);
    }

    public override function addSprite(sprite:Sprite) {
        super.addSprite(sprite);
        addChild(sprite);
    }

    public override function removeSprite(sprite:Sprite) {
        super.removeSprite(sprite);
        removeChild(sprite);
    }

    public override function emptyTile():DisplayTile {
        return new TileBase(this);
    }

    public override function loadTexture(bytes:Bytes, swfty:SWFTYType, ?onComplete:Void->Void, ?onError:Dynamic->Void) {
        function complete(bmpd:BitmapData) {
            // Create tileset
            var i = 0;
            var rects = [];
            tiles = new IntMap();
            for (tile in swfty.tiles) {
                tiles.set(tile.id, '$i');

                // TODO: Should probably just use tile.id ...
                tilesheet.addDefinition(
                    '${i++}', 
                    new Rectangle(0, 0, tile.width, tile.height), 
                    new Rectangle(tile.x, tile.y, tile.width, tile.height), 
                    new Point(0, 0)
                );
            }

            tilesheet.bitmapData = bmpd;

            trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

            if (onComplete != null) onComplete();
        }

        #if sync
        complete(BitmapData.fromBytes(bytes));
        #else
        BitmapData.loadFromBytes(bytes).onComplete(complete).onError(onError);
        #end
    }
}