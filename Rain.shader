shader_type canvas_item;

uniform sampler2D rain;

uniform float DropletSize = .7;
uniform float DropletVisibility = 0.0001;
uniform float RainSpeed = 0.75;
uniform float WiggleAmount = .5;
uniform float Streakiness = 10.0;

vec3 N13(float p)
{
    vec3 p3 = fract(vec3(p) * vec3(.1031, .11369, .13787));
    p3 += dot(p3, p3.yzx + vec3(19.19));
    return fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

vec4 N14(float t)
{
    return fract(sin(t * vec4(123.0, 1024.0, 1456.0, 264.0)) * vec4(6547.0, 345.0, 8799.0, 1564.0));
}

float N(float t)
{
    return fract(sin(t * 12345.564) * 7658.76);
}

float Saw(float b, float t)
{
    return smoothstep(0.0, b, t) * smoothstep(1.0, b, t);
}

vec2 DropLayer2(vec2 uv, float t)
{
    vec2 uv2 = uv;
    uv.y += t * RainSpeed;
    vec2 a = vec2(6.0, 1.0);
    vec2 grid = a * 2.0;
    vec2 id = floor(uv * grid);
    float colShift = N(id.x);
    uv.y += colShift;
    id = floor(uv * grid);
    vec3 n = N13(id.x * 35.2 + id.y * 2376.1);
    vec2 st = fract(uv * grid) - vec2(.5, 0);
    float x = n.x - .5;
    float y = uv2.y * 20.0;
    float wiggle = sin(y+sin(y));
    x += wiggle * (WiggleAmount - abs(x)) * (n.z - .5);
    x *= .7;
    float ti = fract(t + n.z);
    y = (Saw(.85, ti) - .5) * .9 + .5;
    vec2 p = vec2(x, y);
    float d = length((st - p) * a.yx);
    float mainDrop = smoothstep(.4, .0, d);
    float r = sqrt(smoothstep(1.0, y, st.y));
    float cd = abs(st.x - x);
    float trail = smoothstep(.23 * r, .15 * r * r, cd);
    float trailFront = smoothstep(-.02, .02, st.y - y);
    trail *= trailFront * r * r;
    y = uv2.y;
    float trail2 = smoothstep(.2 * r, 1.0, cd);
    float droplets = max(0.0, (sin(y * (1.0 - y) * 120.0) - st.y)) * trail2 * trailFront * n.z;
    y = fract(y * Streakiness) + (st.y - .5);
    float dd = length(st - vec2(x, y));
    droplets = smoothstep(.3, 0.0, dd);
    float m = mainDrop + droplets * r * trailFront;
    return vec2(m, trail);
}

float StaticDrops(vec2 uv, float t)
{
    uv *= 40.0;
    vec2 id = floor(uv);
    uv = fract(uv) - vec2(.5);
    vec3 n = N13(id.x * 107.45 + id.y * 3543.654);
    vec2 p = (n.xy - vec2(.5)) * .7;
    float d = length(uv - p);
    float fade = Saw(.025, fract(t + n.z));
    float c = smoothstep(.3, 0.0, d) * fract(n.z * 10.0) * fade;
    return c;
}

vec2 Drops(vec2 uv, float t, float l0, float l1, float l2)
{
    float s = StaticDrops(uv, t) * l0;
    vec2 m1 = DropLayer2(uv, t) * l1;
    vec2 m2 = DropLayer2(uv * 1.85, t) * l2;
    float c = s + m1.x + m2.x;
    c = smoothstep(.3, 1.0, c);
    return vec2(c, max(m1.y * l0, m2.y * l1));
}

void fragment()
{ // from https://www.shadertoy.com/view/ltffzl
    vec2 uv = vec2(UV.x, 1.0 - UV.y) - vec2(0.5);
    float T = TIME;
    float t = T * .2;
    float rainAmount = sin(T * .05) * .03  + DropletSize;
    float maxBlur = mix(3.0, 6.0, rainAmount);
    float minBlur = 2.0;

    float story = 0.2;
    float zoom = mix(.3, 1.2, story);
    uv *= zoom;
    uv *= 2.5;
    float staticDrops = smoothstep(-.5, 1.0, rainAmount) * 2.0;
    float layer1 = smoothstep(.25, .75, rainAmount);
    float layer2 = smoothstep(.0, .5, rainAmount);
    vec2 c = Drops(uv, t, staticDrops, layer1, layer2);
    vec2 e = vec2(DropletVisibility, 0.0);
    float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
    float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
    vec2 n = vec2(cx - c.x, cy - c.x);
    if (texture(rain, UV).rgb != vec3(0, 0, 0))
    {
        vec4 col1 = vec4(texture(SCREEN_TEXTURE, SCREEN_UV + n));
        COLOR = col1;
    }
}