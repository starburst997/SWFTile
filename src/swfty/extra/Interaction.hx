package swfty.extra;

import swfty.renderer.Sprite;

using swfty.extra.Tween;

class Interactions {

    static inline var RENDER_ID = 'interaction';

    static var useManager = false;

    // Keep track of all interactions for this layer
    static var interactions:Map<Layer, Array<Interaction>> = new Map();
    static var nInteractions = 0;
    static var lastInteraction:Interaction = null;

    // Inject the layer resolver interaction
    static inline function manage(manager:Manager) {
        // TODO: Basically the individual "addRender" add the interactions to this static array
        //       We determine which get the "exclusive" click (it doesn't make sense that more than one gets a click, unless we're in a mutli-touch environment... but then we'll get one exclusive click per "touch id")
        //       The top-most interaction of the layer gets the click, every other layers will ignore interactions

        // We switch to manager mode
        useManager = true;

        manager.addOnRemove(function(layer) {
            interactions.remove(layer);
        });

        manager.addRender(function() {
            // Look interactions in all layers and resolve it, if there was only one we can skip all this
            if (nInteractions == 1) {
                if (lastInteraction != null) {
                    if (interactions.exists(lastInteraction.sprite.layer)) {
                        interactions.set(lastInteraction.sprite.layer, []);
                    }
                    
                    lastInteraction.handler();
                    @:privateAccess manager.click(lastInteraction.sprite);
                }

                nInteractions = 0;
                lastInteraction = null;

            } else if (nInteractions > 1) {
                // TODO: The order *SHOULD* be from Top to Bottom, so first interaction wins
                var found = false;
                for (i in 0...manager.layers.length) {
                    var layer = manager.layers[manager.layers.length - i - 1];
                    if (layer.disposed) {
                        interactions.remove(layer);
                    } else if (interactions.exists(layer)) {
                        var sprites = interactions.get(layer);
                        if (found) {
                            if (sprites.length > 0) interactions.set(layer, []);
                        } else if (sprites.length > 0) {
                            // Count the number of parents, the lowest should be on top
                            found = true;
                            var n = 9999999;
                            var interaction = null;
                            for (sprite in sprites) {
                                var parents = 0;
                                var parent = sprite.sprite;
                                while (parent != null) {
                                    parent = parent.parent;
                                    parents++;
                                }

                                if (parents < n) {
                                    interaction = sprite;
                                } else if (parents == n) {
                                    // Check child index
                                    if (interaction == null || sprite.sprite.getIndex() > interaction.sprite.getIndex()) {
                                        interaction = sprite;
                                    }
                                }
                            }

                            if (interaction != null) {
                                interaction.handler();
                                @:privateAccess manager.click(interaction.sprite);
                            }

                            interactions.set(layer, []);
                        }
                    }
                }

                nInteractions = 0;
                lastInteraction = null;
            }
        });
    }

    static inline function addInteraction(sprite:Sprite, f:Void->Void) {
        lastInteraction = {sprite: sprite, handler: f};
        nInteractions++;

        if (!interactions.exists(sprite.layer)) {
            interactions.set(sprite.layer, [lastInteraction]);
        } else {
            interactions.get(sprite.layer).push(lastInteraction);
        }
    } 

    public static function click(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        child.interactive = true;

        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds:Rectangle = null;
        inline function getBounds() {
            if (!cache || bounds == null) bounds = child.calcBounds(child.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                var y = mouse.y;
                var x = mouse.x;

                switch(mouse.left) {
                    case Down : 
                        if (getBounds().inside(x, y)) {
                            wasInside = true;
                        }
                    case Up : 
                        if (wasInside && getBounds().inside(x, y)) {
                            if (useManager) {
                                addInteraction(child, f);
                            } else {
                                f();
                            }
                        }
                        wasInside = false;
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static function mouseDown(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        child.interactive = true;

        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds:Rectangle = null;
        inline function getBounds() {
            if (!cache || bounds == null) bounds = child.calcBounds(child.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                var y = mouse.y;
                var x = mouse.x;

                switch(mouse.left) {
                    case Down : 
                        if (getBounds().inside(x, y)) {
                            if (!wasInside) f();
                            wasInside = true;
                        }
                    case Up : 
                        wasInside = false;
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static function mouseUp(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        child.interactive = true;

        // Cache bounds with transform to stage coordinate
        // TODO: 99% of case the bounds doesn't change, but maybe we shouldn't cache it? We still take into account local x / y
        var bounds:Rectangle = null;
        inline function getBounds() {
            if (!cache || bounds == null) bounds = child.calcBounds(child.layer.base);
            return bounds;
        }

        // Detect left click inside and wait for mouse up inside to trigger handler
        var wasInside = false;
        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                var y = mouse.y;
                var x = mouse.x;

                switch(mouse.left) {
                    case Down : 
                    case Up : 
                        if (getBounds().inside(x, y)) {
                            f();
                        }
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static function mouseUpAnywhere(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                switch(mouse.left) {
                    case Down : 
                    case Up : f();
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static function mouseDownAnywhere(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        child.addRender(RENDER_ID, function render(dt) {
            if (child.layer == null || !child.loaded) return;

            var mouse = child.layer.mouse;
            if (mouse.leftChanged) {
                switch(mouse.left) {
                    case Down : f();
                    case Up : 
                    case _ : 
                }
            }
        });

        return sprite;
    }

    public static inline function clickOnce(sprite:Sprite, ?name:String, ?cache = true, f:Void->Void) {
        click(sprite, name, cache, function() {
            removeClick(sprite, name);
            f();
        });
    }

    public static function fancyClick(sprite:Sprite, ?name:String, f:Void->Void) {
        var child = name == null ? sprite : sprite.get(name);

        // TODO: Add a quick tween on "down" and when "up", like scale down a bit with a bounce then scale back up

        return sprite;
    }

    // TODO: Should we specify the function?
    public static inline function removeClick(sprite:Sprite, ?name:String) {
        var child = name == null ? sprite : sprite.get(name);

        child.removeRender(RENDER_ID);
        return sprite;
    }
}

@:structInit
class Interaction {
    public var sprite:Sprite;
    public var handler:Void->Void;

    public function new(sprite:Sprite, handler:Void->Void) {
        this.sprite = sprite;
        this.handler = handler;
    }
}