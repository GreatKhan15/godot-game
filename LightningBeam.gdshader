shader_type spatial;
render_mode blend_add, unshaded;

uniform vec4 color = vec4(0.0, 0.4, 1.0, 1.0);
uniform float fade_alpha = 1.0;

void fragment() {
    ALBEDO = color.rgb;
    ALPHA = color.a * fade_alpha;
    EMISSION = color.rgb * fade_alpha * 5.0;
}
