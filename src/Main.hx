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

    function v(x:Int, y:Int):Vec3 {
        return vec3(x, y, 0);
    }

    function mainImage(fragColor:Vec4, fragCoord:Vec2):Void {
        var tt = iTime;
        var ix = iResolution.x;

        var spherePositions:Array<Vec3, 22>;
        final d = 1;

        spherePositions[0] = v(d * 0, d * 2);
        spherePositions[1] = v(d * 0, d * 1);
        spherePositions[2] = v(d * 0, d * 0);
        spherePositions[3] = v(d * 1, d * 0);

        spherePositions[4] = v(d * 3, d * 2);
        spherePositions[5] = v(d * 3, d * 1);
        spherePositions[6] = v(d * 3, d * 0);
        spherePositions[7] = v(d * 4, d * 0);
        spherePositions[8] = v(d * 5, d * 0);
        spherePositions[9] = v(d * 5, d * 1);
        spherePositions[10] = v(d * 5, d * 2);

        spherePositions[11] = v(d * 7, d * 2);
        spherePositions[12] = v(d * 8, d * 2);
        spherePositions[13] = v(d * 7, d * 1);
        spherePositions[14] = v(d * 7, d * 0);
        spherePositions[15] = v(d * 8, d * 0);

        spherePositions[16] = v(d * 10, d * 2);
        spherePositions[17] = v(d * 12, d * 2);
        spherePositions[18] = v(d * 10, d * 1);
        spherePositions[19] = v(d * 11, d * 1);
        spherePositions[20] = v(d * 10, d * 0);
        spherePositions[21] = v(d * 12, d * 0);

        var uv:Vec2;
        uv.x = (fragCoord.x - ix * 0.5) / ix;
        var h = ix * 0.56; // iResolution.y is not correct.
        uv.y = ((fragCoord.y - h * 0.5) / h) * 0.6;

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
                sphere_position.z = -15 + sin((tt + i/9)* 5) * 1;
                var sphere_color = vec3(0.5, 0.2, sphere_position.y / 3);
                var t = intersectSphere(origin, direction, sphere_position, sphere_radius);

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

        if(collides == 1) {
            fragColor = vec4(col, 1.0);
            return;
        }

        // for(i in 0...22) {
        //     var sphere_position = spherePositions[i];
        //     sphere_position.z += sin((tt + i*0.1)* 5) * 1.0;
        //     var t = intersectSphere(cameraPosition, cameraDirection, sphere_position, sphere_radius);
        //     if(t > 0.0) {
        //         var pos = cameraPosition + cameraDirection * t;
        //         var normal = normalize(pos - sphere_position);
        //         var d = dot(cameraDirection, normal) * -1.0;
        //         // fragColor = vec4(0.1 + (0.5 + normal.z), 0.0, 0.0, 1.0);
        //         var color = normal * 0.5 + vec3(0.5, 0.5, 0.5);
        //         // fragColor = vec4(color.x,color.y, color.z , 1.0);
        //         fragColor = vec4(d, d, d, 1.0);
        //         return;
        //     }
        // }

        var c = uv.xy * uv.xy * sin(uv.x * 5 + tt) * sin(uv.y * 7 + tt) + uv.x * sin(tt) * 0.3 + uv.y * sin(tt) * 0.2;
        var b = sqrt(abs(c.x + c.y) * 9) * 3;
        fragColor = vec4(0.01, abs(sin(b)-sin(d)) /30, 0.1 + abs(sin(b)) /9, 1.0);

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
