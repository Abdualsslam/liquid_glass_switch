#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform sampler2D u_texture;

uniform float u_distortion;   // 0: refraction strength
uniform float u_edgeBoost;    // 1: Fresnel edge intensity
uniform float u_lightX;       // 2: specular light X (0-1)
uniform float u_lightY;       // 3: specular light Y (0-1)
uniform vec4 u_tint;          // 4-7: RGBA tint

out vec4 fragColor;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / u_size;

  // ── Sphere geometry ──
  vec2 center = vec2(0.5, 0.5);
  vec2 delta  = uv - center;

  // Circular distance for a sphere
  float aspect = u_size.x / u_size.y;
  vec2 corrected = vec2(delta.x, delta.y * aspect);
  float dist = length(corrected);

  // Normalised radius 0..1 (edge at 0.5)
  float r = dist / 0.5;

  // Smooth sphere mask
  float sphereMask = 1.0 - smoothstep(0.85, 1.0, r);

  // ── Spherical refraction (Snell's law approximation) ──
  // Compute sphere surface normal
  float z = sqrt(max(1.0 - r * r, 0.0));           // z component of sphere normal
  vec3 normal = normalize(vec3(corrected / 0.5, z)); // surface normal

  // View ray (straight into screen)
  vec3 viewDir = vec3(0.0, 0.0, 1.0);

  // Refraction through glass sphere (IOR ≈ 1.4)
  float ior = 1.4;
  vec3 refracted = refract(-viewDir, normal, 1.0 / ior);

  // Offset UV based on refracted ray
  float strength = u_distortion / max(u_size.x, 1.0);
  vec2 refrUV = uv + refracted.xy * strength * 90.0;

  // ── Chromatic aberration ──
  float caStrength = 0.0018 * (1.0 + r * 2.5);      // stronger at edges
  vec2 caOffset = normalize(delta + 0.0001) * caStrength;

  float sR = texture(u_texture, refrUV + caOffset).r;
  float sG = texture(u_texture, refrUV).g;
  float sB = texture(u_texture, refrUV - caOffset).b;
  vec3 sampled = vec3(sR, sG, sB);

  // ── Fresnel edge darkening ──
  float fresnel = pow(1.0 - z, 3.0);                // strong at edges
  float edgeDarken = mix(1.0, 0.25, fresnel * u_edgeBoost);

  // ── Specular highlight ──
  vec2 lightPos = vec2(u_lightX, u_lightY);
  vec2 specUV = (uv - lightPos) * vec2(1.6, 2.8);
  float specDist = length(specUV);
  float spec = pow(max(1.0 - specDist, 0.0), 5.5);  // sharp highlight

  // Secondary broader glow
  float specGlow = pow(max(1.0 - specDist * 0.7, 0.0), 2.5) * 0.3;

  // ── Inner shadow (bottom of sphere) ──
  float innerShadow = smoothstep(-0.1, 0.45, delta.y) * 0.35;

  // ── Caustic ring (light gathering at inner rim) ──
  float caustic = smoothstep(0.75, 0.88, r) * smoothstep(1.0, 0.92, r);
  caustic *= 0.18;

  // ── Compose ──
  vec3 color = sampled * edgeDarken;

  // Apply subtle tint
  color = mix(color, color + u_tint.rgb * 0.6, 0.15);

  // Add lighting
  color += vec3(spec) * 0.35;
  color += vec3(specGlow) * 0.15;
  color += vec3(caustic) * 0.12;

  // Inner shadow darkening
  color *= (1.0 - innerShadow);

  // Alpha: glass visible where sphere mask is active
  float alpha = sphereMask * (0.35 + fresnel * 0.45 + spec * 0.2);
  alpha = clamp(alpha, 0.0, 0.95);

  fragColor = vec4(color * alpha, alpha);
}
