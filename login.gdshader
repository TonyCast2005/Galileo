shader_type canvas_item;

uniform float time;
uniform vec2 resolution;

void fragment() {
    vec2 uv = UV * resolution / 100.0;

    // Patrón de color animado
    float r = 0.5 + 0.5 * sin(uv.x * 3.0 + time);
    float g = 0.5 + 0.5 * sin(uv.y * 3.0 + time * 1.3);
    float b = 0.5 + 0.5 * sin((uv.x + uv.y) * 2.0 + time * 0.7);

    COLOR = vec4(r, g, b, 1.0);
}
