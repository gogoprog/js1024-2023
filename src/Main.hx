@:native("")
extern class Shim {
    @:native("a") static var canvas:js.html.CanvasElement;
    @:native("c") static var context:js.html.CanvasRenderingContext2D;
}

typedef Point = {
    var x:Float;
    var y:Float;
}

class Main {
    static inline var screenSize = 512;
    static function main() {
        function loop(t:Float) {
            untyped requestAnimationFrame(loop);
        }
        loop(0);
    }
}
