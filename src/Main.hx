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

    final lightPosition = vec3(0.0, 1.0, -5.0);

    final spherePositions:Array<Vec3, 4> = [
            vec3(0.0, 5.0, -10.0),
            vec3(0.0, 0.0, -10.0),
            vec3(7.0, -7.0, -10.0),
            vec3(0.0, 8.0, -10.0)
                                           ];

    function mainImage(fragColor:Vec4, fragCoord:Vec2):Void {
        // fragColor = vec4(iMouse.x / iResolution.x, 1.0, sin(iTime * 0.1), 1.0);

        var uv = (2.0 * fragCoord - iResolution) / min(iResolution.x, iResolution.y);

        // Camera setup
        var cameraPosition = vec3(0.0, 0.0, 0.0);
        var cameraDirection = vec3(uv, -1.0);

        // Ray tracing
        var sphere_radius = 1.0;

        for(i in 0...4) {
            var sphere_position = spherePositions[i];
            var t = intersectSphere(cameraPosition, cameraDirection, sphere_position, sphere_radius);

            if(t > 0.0) {
                // Sphere intersection, set pixel color to red
                fragColor = vec4(1.0, 0.0, 0.0, 1.0);
                return;
            }
        }

        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

    function intersectSphere(ray_origin:Vec3, ray_direction:Vec3, sphere_position:Vec3, sphere_radius:Float):Float {
        var oc = vec3(ray_origin - sphere_position);
        var a = dot(ray_direction, ray_direction);
        var b = 2.0 * dot(oc, ray_direction);
        var c = dot(oc, oc) - (sphere_radius * sphere_radius);
        var discriminant = b * b - 4.0 * a * c;
        var t = -1.0;

        if(discriminant < 0.0) {
            t = -1.0;
        }

        var sqrtDiscriminant = sqrt(discriminant);
        var t0 = (-b - sqrtDiscriminant) / (2.0 * a);
        var t1 = (-b + sqrtDiscriminant) / (2.0 * a);

        if(t0 > t1) {
            var temp = t0;
            t0 = t1;
            t1 = temp;
        }

        if(t1 < 0.0) {
            t = -1.0;
        }

        if(t0 < 0.0) {
            t = t1;
        } else {
            t = t0;
        }

        return t;
    }
}

class Main {
    static function main() {
        File.saveContent("temp/out.frag", MyShader.source.fragment);
    }
}
