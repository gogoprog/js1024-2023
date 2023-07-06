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

    function mainImage(fragColor:Vec4, fragCoord:Vec2):Void {


        var spherePositions:Array<Vec3, 22>;
        final d = 1.0;
        final z = -18.0;

        spherePositions[0] = vec3(d * 0, d * 2, z);
        spherePositions[1] = vec3(d * 0, d * 1, z);
        spherePositions[2] = vec3(d * 0, d * 0, z);
        spherePositions[3] = vec3(d * 1, d * 0, z);

        spherePositions[4] = vec3(d * 3, d * 2, z);
        spherePositions[5] = vec3(d * 3, d * 1, z);
        spherePositions[6] = vec3(d * 3, d * 0, z);
        spherePositions[7] = vec3(d * 4, d * 0, z);
        spherePositions[8] = vec3(d * 5, d * 0, z);
        spherePositions[9] = vec3(d * 5, d * 1, z);
        spherePositions[10] = vec3(d * 5, d * 2, z);

        spherePositions[11] = vec3(d * 7, d * 2, z);
        spherePositions[12] = vec3(d * 8, d * 2, z);
        spherePositions[13] = vec3(d * 7, d * 1, z);
        spherePositions[14] = vec3(d * 7, d * 0, z);
        spherePositions[15] = vec3(d * 8, d * 0, z);

        spherePositions[16] = vec3(d * 10, d * 2, z);
        spherePositions[17] = vec3(d * 12, d * 2, z);
        spherePositions[18] = vec3(d * 10, d * 1, z);
        spherePositions[19] = vec3(d * 11, d * 1, z);
        spherePositions[20] = vec3(d * 10, d * 0, z);
        spherePositions[21] = vec3(d * 12, d * 0, z);

        var uv = (fragCoord - 0.5 * iResolution) / iResolution.y;

        var cameraPosition = vec3(6.0, 4.0, 0.0);
        var cameraDirection = normalize(vec3(uv, -1.0));
        var sphere_radius = 0.45;

        var col:Vec3 = vec3(0, 0, 0);
        var origin = cameraPosition;
        var direction = cameraDirection;
        var t = 1.0;
        var collides = false;

        for(i in 0...10) {
            for(i in 0...22) {
                var sphere_position = spherePositions[i];
                sphere_position.z = z + sin((iTime + i*0.1)* 5) * 1.0;
                var t = intersectSphere(origin, direction, sphere_position, sphere_radius);

                if(t > 0.01) {
                    origin = origin + direction * t;
                    var normal = normalize(origin - sphere_position);
                    direction = reflect(direction, normal);
                    var d = dot(cameraDirection, normal) * -1.0;
                    col.x += 0.4 * d;
                    collides = true;
                    break;
                }
            }

            if(t > 0.01) {
            } else {
                break;
            }
        }

        if(collides) {
            fragColor = vec4(col, 1.0);
            return;
        }

        // for(i in 0...22) {
        //     var sphere_position = spherePositions[i];
        //     sphere_position.z += sin((iTime + i*0.1)* 5) * 1.0;
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

        fragColor = vec4(0.1, 0.2 + uv.y * 0.2, 0.3 + uv.x * 0.2, 1.0);
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
