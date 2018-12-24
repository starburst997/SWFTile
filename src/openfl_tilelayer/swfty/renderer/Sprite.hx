package openfl_tilelayer.swfty.renderer;

import openfl_tilelayer.swfty.renderer.Layer;

typedef EngineSprite = aze.display.TileGroup;
typedef EngineBitmap = aze.display.TileSprite;

class FinalSprite extends BaseSprite {

    public static inline function create(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        return new FinalSprite(layer, definition, linkage);
    }    

    public function new(layer:BaseLayer, ?definition:MovieClipType, ?linkage:String) {
        this.tileset = layer.tileset;

        super(layer, definition, linkage);
    }

    public override function getSize() {
        return {
            width: this.width,
            height: this.height
        }
    }

    public override function top() {
        if (this.parent != null) parent.setTileIndex(this, parent.numTiles - 1);
    }

    public override function bottom() {
        if (this.parent != null) parent.setTileIndex(this, 0);
    }

    public override function addSprite(sprite:FinalSprite) {
        sprite._parent = this;
        super.addSprite(sprite);
        addTile(sprite);
    }

    public override function removeSprite(sprite:FinalSprite) {
        super.removeSprite(sprite);
        removeTile(sprite);
    }

    public override function addBitmap(bitmap:EngineBitmap) {
        addTile(bitmap);
    }

    public override function removeBitmap(bitmap:EngineBitmap) {
        removeTile(bitmap);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplayBitmap(EngineBitmap) from EngineBitmap to EngineBitmap {

    public static inline function create(layer:BaseLayer, id:Int, og:Bool = false):DisplayBitmap {
        return new EngineBitmap(layer, layer.getTile(id));
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(b, c, d);
    }

    public inline function color(r:Int, g:Int, b:Int) {
        this.r = r / 255.0;
        this.g = g / 255.0;
        this.b = b / 255.0;
    }
}

@:forward(x, y, scaleX, scaleY, rotation, alpha)
abstract DisplaySprite(BaseSprite) from BaseSprite to BaseSprite {

    public inline function removeAll() {
        while(this.numTiles > 0) this.removeTileAt(0);
    }

    public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
        this.x = MathUtils.x(tx);
        this.y = MathUtils.y(ty);
        this.scaleX = MathUtils.scaleX(a, b, c, d);
        this.scaleY = MathUtils.scaleY(a, b, c, d);
        this.rotation = MathUtils.rotation(b, c, d);
    }

    public inline function color(r:Float, g:Float, b:Float, rAdd:Float, gAdd:Float, bAdd:Float) {
        this.r = r / 255.0;
        this.g = g / 255.0;
        this.b = b / 255.0;
    }

    public inline function resetColor() {
        this.r = 0.0;
        this.g = 0.0;
        this.b = 0.0;
    }

    public inline function blend(mode:BlendMode) {
        // TODO: Not supported
    }

    public inline function resetBlend() {
        // TODO: Not supported
    }
}