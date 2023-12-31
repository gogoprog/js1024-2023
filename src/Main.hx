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

    function v2(x:Int):Vec3 {
        return vec3(floor(x / 10), mod(x, 10), 0);
    }

    function mainImage(fragColor:Vec4, fragCoord:Vec2):Void {
        var tt = iTime;
        var ix = iResolution.x;

        var spherePositions:Array<Vec3, 22>;

        spherePositions[0] = v2(2);
        spherePositions[1] = v2(1);
        spherePositions[2] = v2(0);
        spherePositions[3] = v2(10);

        spherePositions[4] = v2(32);
        spherePositions[5] = v2(31);
        spherePositions[6] = v2(30);
        spherePositions[7] = v2(40);
        spherePositions[8] = v2(50);
        spherePositions[9] = v2(51);
        spherePositions[10] = v2(52);

        spherePositions[11] = v2(72);
        spherePositions[12] = v2(82);
        spherePositions[13] = v2(71);
        spherePositions[14] = v2(70);
        spherePositions[15] = v2(80);

        spherePositions[16] = v2(102);
        spherePositions[17] = v2(122);
        spherePositions[18] = v2(101);
        spherePositions[19] = v2(111);
        spherePositions[20] = v2(100);
        spherePositions[21] = v2(120);

        var h = ix * 0.56; // iResolution.y is not correct.
        var uv:Vec2 = vec2((fragCoord.x - ix * 0.5) / ix, ((fragCoord.y - h * 0.5) / h) * 0.6);

        var cameraPosition = vec3(0, 0, 0.0);
        var cameraDirection = normalize(vec3(uv, -1.0));
        var sphere_radius = 0.4;

        var col:Vec3 = vec3(1, 1, 1);
        var origin = cameraPosition;
        var direction = cameraDirection;
        var t = 1.0;
        var collides = 0;

        for(i in 0...9) {
            for(i in 0...22) {
                var sphere_position = spherePositions[i];
                sphere_position.x -= 6;
                sphere_position.z = -15 + sin((tt + i*0.1)* 5) * 1;
                var sphere_color = vec3(0.5, 0.2, sphere_position.y / 3);
                // var t = intersectSphere(origin, direction, sphere_position, sphere_radius);
                var oc = vec3(origin - sphere_position);
                var a = dot(direction, direction);
                var b = 2.0 * dot(oc, direction);
                var c = dot(oc, oc) - (sphere_radius * sphere_radius);
                var discriminant = b * b - 4.0 * a * c;
                var sqrtDiscriminant = sqrt(discriminant);
                var t = (-b - sqrtDiscriminant) / (2.0 * a);

                if(t > 0.1) {
                    origin = origin + direction * t;
                    var normal = normalize(origin - sphere_position);
                    direction = reflect(direction, normal);

                    if(col.x == 1) {
                        var d = dot(cameraDirection, normal);
                        col = sphere_color / 3 - sphere_color * d /2;
                    } else {
                        col = mix(col, sphere_color, 0.3);
                    }

                    collides = 1;
                    break;
                }
            }

            if(collides == 0) {
                break;
            }
        }

        if(collides == 0) {
            var c = uv.xy * uv.xy * sin(uv.x * 5 + tt) * sin(uv.y * 7 + tt) + uv.x * sin(tt) * 0.3 + uv.y * sin(tt) * 0.2;
            var b = sqrt(abs(c.x + c.y) * 9) * 3;
            col = vec3(0.01, abs(sin(b)) /30, 0.1 + abs(sin(b)) /9);
        }

        fragColor = vec4(col, 1.0);

        // if(uv.y > 0.5) {
        //     fragColor = vec4(1, 0, 0, 1);
        // }
    }

    function intersectSphere(ray_origin:Vec3, ray_direction:Vec3, sphere_position:Vec3, sphere_radius:Float):Float {
        var oc = vec3(ray_origin - sphere_position);
        var a = dot(ray_direction, ray_direction);
        var b = 2.0 * dot(oc, ray_direction);
        var c = dot(oc, oc) - (sphere_radius * sphere_radius);
        var discriminant = b * b - 4.0 * a * c;
        var sqrtDiscriminant = sqrt(discriminant);
        var t = (-b - sqrtDiscriminant) / (2.0 * a);

        return t;
    }
}

class Main {
    static function main() {
        File.saveContent("temp/out.frag", MyShader.source.fragment);
    }
}
