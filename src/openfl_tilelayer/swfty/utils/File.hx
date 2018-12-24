package openfl.swfty.utils;

import openfl.Assets;

import haxe.io.Bytes;

class File {
    public static function loadBytes(path:String, onComplete:Bytes->Void, ?onError:Dynamic->Void) {
        Assets
		.loadBytes(path)
		.onError(function(error) {
			trace('Error loadBytes', error);
            if (onError != null) onError(error);
		})
		.onComplete(function(bytes) {
			trace('Complete loadBytes ${bytes.length}');
			onComplete(bytes);
		});
    }
}