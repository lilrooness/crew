uniform float random;
uniform bool goalRoom;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * random * 43758.5453);
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
  float randomNumber = rand(screen_coords);

if (goalRoom && randomNumber > 0.98) {
   return vec4(vec3(1.0, 0.0, 0.0), 1.0);
}
if(randomNumber > 0.95) {
          return vec4(vec3(randomNumber, 1.0, 1.0), randomNumber);
}
  return vec4(vec3(0.0, 0.0, 0.0), 0.0);
}

