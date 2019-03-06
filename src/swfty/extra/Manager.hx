package swfty.extra;

import swfty.renderer.Mouse;
import swfty.extra.Interaction;

// Manager all layers, usefull for some multi-layer logics like exclusive clicks
// Provide a main render loop to call
// TODO: Maybe this should be an extra?

class Manager {

    public static inline function create() {
        return new Manager();
    }

    public var layers:Array<Layer> = [];
    public var dt = 0.0;

    public var mouse(default, null) = new Mouse(true);

    var renders:Array<Void->Void> = [];
    var preRenders:Array<Void->Void> = [];
    var timer = 0.0;

    var pruneLayers:Array<Layer> = [];
    var pruneRenders:Array<Void->Void> = [];
    var prunePreRenders:Array<Void->Void> = [];

    var onRemoves:Array<Layer->Void> = [];
    var pruneOnRemoves:Array<Layer->Void> = [];

    var clicks:Array<Sprite->Void> = [];

    public function new(interaction = true) {
        @:privateAccess if (interaction) Interactions.manage(this);
    }

    public function interactAll() {
        for (layer in layers) layer.shared.canInteract = true;
        return this;
    }

    public inline function add(layer:Layer) {
        layer.mouse = mouse;
        layers.push(layer);
        return this;
    }

    public inline function remove(layer:Layer) {
        layers.remove(layer);
        for (f in onRemoves) f(layer);
        return this;
    }

    public inline function addOnRemove(f:Layer->Void) {
        onRemoves.push(f);
        return this;
    }

    public inline function removeOnRemove(f:Layer->Void) {
        pruneOnRemoves.push(f);
        return this;
    }

    public inline function addRender(f:Void->Void) {
        renders.push(f);
        return this;
    }

    public inline function addPreRender(f:Void->Void) {
        preRenders.push(f);
        return this;
    }

    public inline function removeRender(f:Void->Void) {
        pruneRenders.push(f);
        return this;
    }

    public inline function removePreRender(f:Void->Void) {
        prunePreRenders.push(f);
        return this;
    }

    function click(sprite:Sprite) {
        for (f in clicks) f(sprite);
    }

    public function addClick(f:Sprite->Void) {
        clicks.push(f);
        return this;
    }

    public function removeClick(f:Sprite->Void) {
        clicks.remove(f);
        return this;
    }

    public function update() {
        dt = (haxe.Timer.stamp() - timer); 
        timer = haxe.Timer.stamp();

        if (dt > 1/10.0) dt = 1/10.0;

        for (f in preRenders) f();

        for (layer in layers) {
            if (layer.disposed) {
                remove(layer);
            } else {
                layer.update(dt);
            }
        }

        for (f in renders) f();

        if (pruneLayers.length > 0) {
            for (layer in pruneLayers) layers.remove(layer);
            pruneLayers = [];
        }

        if (pruneRenders.length > 0) {
            for (f in pruneRenders) renders.remove(f);
            pruneRenders = [];
        }

        if (prunePreRenders.length > 0) {
            for (f in prunePreRenders) preRenders.remove(f);
            prunePreRenders = [];
        }

        if (pruneOnRemoves.length > 0) {
            for (f in pruneOnRemoves) onRemoves.remove(f);
            pruneOnRemoves = [];
        }

        mouse.reset(true);
    }
}