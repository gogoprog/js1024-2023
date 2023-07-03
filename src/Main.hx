import hgsl.Source;
import sys.io.File;
import basic.*;
import phong.*;
import hgsl.Global.*;
import hgsl.Types;
import hgsl.ShaderMain;
import hgsl.ShaderModule;
import hgsl.ShaderStruct;

class MyShader extends ShaderMain {
    @varying var vTexCoord:Vec2;
    @color var oColor:Vec4;

    @uniform var iTime:Float;
    @uniform var iTimeDelta:Float;
    @uniform var iFrame:Int;
    @uniform var iDate:Float;
    @uniform var iMouse:Vec4;
    @uniform var iResolution:Vec2;

    function vertex():Void {
    }

    function fragment():Void {
        mainImage(oColor, vTexCoord);
    }

    function mainImage(fragColor:Vec4, fragCoord:Vec2):Void {
        fragColor = vec4(iMouse.x / iResolution.x, 1.0, sin(iTime * 0.1), 1.0);
    }
}

class Main {
    static function main() {
        File.saveContent("temp/out.frag", MyShader.source.fragment);
    }
}
