
package swfty.renderer;

#if openfl
typedef DisplayTile = openfl.swfty.renderer.Layer.DisplayTile;
typedef EngineLayer = openfl.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = openfl.swfty.renderer.Layer.FinalLayer;

#elseif heaps
typedef DisplayTile = heaps.swfty.renderer.Layer.DisplayTile;
typedef EngineLayer = heaps.swfty.renderer.Layer.EngineLayer;
typedef FinalLayer = heaps.swfty.renderer.Layer.FinalLayer;

#else
#error 'Unsupported framework (please use OpenFL or Heaps)'
#end

@:forward(x, y, scaleX, scaleY, rotation, alpha, dispose, pause, addRender, removeRender, addMouseDown, removeMouseDown, addMouseUp, removeMouseUp, mouse, base, loadBytes, reload, update, getAllNames, width, height)
abstract Layer(BaseLayer) from BaseLayer to BaseLayer {
    public static inline function load(path:String, ?width:Int, ?height:Int, ?onComplete:Layer->Void, ?onError:Dynamic->Void):Layer {
        var layer = FinalLayer.create(width, height);
        File.loadBytes(path, function(bytes) {
            layer.loadBytes(bytes, function() {
                if (onComplete != null) onComplete(layer);
            }, onError);
        }, onError);
        return layer;
    }

    public static inline function empty(?width:Int, ?height:Int):Layer {
        return FinalLayer.create(width, height);
    }

    public function layout(targetWidth:Float, targetHeight:Float) {
        // First layout by height, if offset is negative, then we layout by width
        // Ideally you make your UI to fit vertically, if the device is larger in width it will simply offset
        var scale = this.height / targetHeight;
        this.base.scaleX = this.base.scaleY = scale;
        this.base.x = (this.width - (targetWidth * scale)) / 2.0;

        // But if the screen is narrower than you anticipated (like iPhone X), it is best to then offset vertically
        if (this.base.x < 0) {
            this.base.x = 0;

            var scale = this.width / targetWidth;
            this.base.scaleX = this.base.scaleY = scale;
            this.base.y = (this.height - (targetHeight * scale)) / 2.0;
        }

        return this;
    }

    public inline function add(sprite:Sprite) {
        this.addSprite(sprite);
        return this;
    }

    public inline function remove(sprite:Sprite) {
        this.removeSprite(sprite);
        return this;
    }

    public inline function create(linkage:String):Sprite {
        return this.get(linkage);
    }
}