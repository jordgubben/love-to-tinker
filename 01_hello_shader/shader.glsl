#pragma language glsl3

uniform vec4 tint;

varying vec4 vpos;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    vpos = vertex_position;
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    texture_coords += vec2(cos(vpos.x), sin(vpos.y));
    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor * color + tint;
}
#endif
