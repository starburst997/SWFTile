package openfl.swfty.renderer;

import swfty.renderer.Font;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

import zip.Zip;
import zip.ZipReader;

import openfl.geom.Rectangle;
import openfl.display.Tileset;
import openfl.display.BitmapData;
import openfl.display.Tilemap;
import openfl.events.Event;

class Layer extends Tilemap {

    public var json:SWFTYJson;

    var ids:IntMap<MovieClipDefinition>;
    var fonts:IntMap<Font>;
    var mcs:StringMap<MovieClipDefinition>;

    var tiles:IntMap<Int>;
    
    public static inline function create(width:Int, height:Int, ?tileset) {
        return new Layer(width, height, tileset);
    }

    public static inline function createAsync(width:Int, height:Int, bytes:Bytes, onComplete:Layer->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tileset, json) -> {
            var layer = create(width, height, tileset);
            layer.loadJson(json);
            onComplete(layer);
        }, onError);
    }

    public function new(width:Int, height:Int, ?tileset) {
        super(width, height, tileset);

        tiles = new IntMap();
        ids = new IntMap();
        fonts = new IntMap();
        mcs = new StringMap();
    }

    public inline function getTile(id:Int):Int {
        return if (tiles.exists(id)) {
            tiles.get(id);
        } else {
            Log.warn('Missing shape: $id');
            -1;
        } 
    }

    public inline function getFont(id:Int) {
        return fonts.get(id);
    }

    public inline function hasFont(id:Int) {
        return fonts.exists(id);
    }

    public inline function getDefinition(id:Int):MovieClipDefinition {
        return ids.get(id);
    }

    public inline function hasDefinition(id:Int):Bool {
        return ids.exists(id);
    }

    public inline function getAllNames() {
        return [for (key in mcs.keys()) key];
    }

    public function resize(width:Int, height:Int) {

    }

    public function get(linkage:String):Sprite {
        return if (!mcs.exists(linkage)) {
            Log.warn('Linkage: $linkage does not exists!');
            Sprite.create(this);
        } else {
            var sprite = Sprite.create(this, mcs.get(linkage));
            sprite;
        }
    }

    public function load(bytes:Bytes, onComplete:Void->Void, onError:Dynamic->Void) {
        loadBytes(bytes, (tileset, json) -> {
            this.tileset = tileset;
            loadJson(json);
            onComplete();
        }, onError);
    }

    public function loadJson(json:SWFTYJson) {
        this.json = json;

        for (i in 0...json.tiles.length) {
            var tile = json.tiles[i];
            tiles.set(tile.id, i);
        }

        for (definition in json.definitions) {
            if (definition.name != null && definition.name != '') mcs.set(definition.name, definition);
            ids.set(definition.id, definition);
        }

        for (font in json.fonts) {
            var obj = Font.create(this, font);
            fonts.set(font.id, obj);
        }
    }

    public static function loadBytes(bytes:Bytes, onComplete:Tileset->SWFTYJson->Void, onError:Dynamic->Void) {
        var entries = ZipReader.getEntries(bytes);

        var tilemapBytes = Zip.getBytes(entries.get('tilemap.png'));
        var jsonString = Zip.getString(entries.get('definitions.json'));

        function complete(bmpd:BitmapData) {
            #if release
            try {
            #end
                var json:SWFTYJson = haxe.Json.parse(jsonString);

                // Create tileset
                var i = 0;
                var rects = [];
                var map = new IntMap();
                for (tile in json.tiles) {
                    map.set(tile.id, i++);
                    rects.push(new Rectangle(tile.x, tile.y, tile.width, tile.height));
                }

                var tileset = new Tileset(bmpd, rects);

                trace('Tilemap: ${bmpd.width}, ${bmpd.height}');

                onComplete(tileset, json);
            #if release
            } catch(e:Dynamic) {
                onError(e);
            }
            #end
        }

        #if sync
        complete(BitmapData.fromBytes(tilemapBytes));
        #else
        BitmapData.loadFromBytes(tilemapBytes).onComplete(complete).onError(e -> onError(e));
        #end
    } 
}