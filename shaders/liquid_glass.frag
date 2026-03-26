#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_size;
uniform sampler2D u_texture;

uniform float u_refraction;
uniform float u_depth;
uniform float u_dispersion;
uniform float u_frost;
uniform float u_lightAngle;
uniform float u_lightIntensity;
uniform vec4 u_tint;

out vec4 fragColor;

float sat(float value) {
  return clamp(value, 0.0, 1.0);
}

vec3 sampleScene(vec2 uv) {
  vec2 safeUv = clamp(uv, vec2(0.001), vec2(0.999));
  return texture(u_texture, safeUv).rgb;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / u_size;

  vec2 center = vec2(0.5);
  vec2 delta = uv - center;
  float aspect = u_size.x / max(u_size.y, 1.0);
  vec2 corrected = vec2(delta.x, delta.y * aspect);

  float radius = length(corrected) / 0.5;
  float sphereMask = 1.0 - smoothstep(0.92, 1.0, radius);

  float refraction = sat(u_refraction / 100.0);
  float depth = sat(u_depth / 100.0);
  float dispersion = sat(u_dispersion / 100.0);
  float frost = sat(u_frost / 100.0);
  float lightIntensity = sat(u_lightIntensity / 100.0);

  float z = sqrt(max(1.0 - radius * radius, 0.0));
  vec3 normal = normalize(vec3(corrected / 0.5, z));
  vec3 viewDir = vec3(0.0, 0.0, 1.0);

  float ior = mix(1.02, 1.52, refraction);
  vec3 refracted = refract(-viewDir, normal, 1.0 / ior);

  float distortion = mix(0.01, 0.08, refraction) * (0.5 + depth);
  vec2 refrUv = uv + refracted.xy * distortion;

  vec2 dispersionDir = normalize(delta + vec2(0.0001));
  vec2 dispersionOffset = dispersionDir * (0.0008 + (dispersion * 0.0035)) *
      (0.2 + radius * 0.8);

  float sampleR = sampleScene(refrUv + dispersionOffset).r;
  float sampleG = sampleScene(refrUv).g;
  float sampleB = sampleScene(refrUv - dispersionOffset).b;
  vec3 color = vec3(sampleR, sampleG, sampleB);

  if (frost > 0.0001) {
    vec2 texel = vec2(1.0 / max(u_size.x, 1.0), 1.0 / max(u_size.y, 1.0));
    vec2 blurStep = texel * (1.0 + frost * 7.0);
    vec3 blurSample = color;
    blurSample += sampleScene(refrUv + vec2(blurStep.x, 0.0));
    blurSample += sampleScene(refrUv + vec2(-blurStep.x, 0.0));
    blurSample += sampleScene(refrUv + vec2(0.0, blurStep.y));
    blurSample += sampleScene(refrUv + vec2(0.0, -blurStep.y));
    blurSample *= 0.2;
    color = mix(color, blurSample, frost * 0.85);
  }

  float fresnel = pow(1.0 - z, 3.2);
  float edgeDarken = mix(1.0, 0.25, fresnel * (0.35 + depth * 0.65));
  color *= edgeDarken;

  vec2 lightDir2 = normalize(vec2(cos(u_lightAngle), sin(u_lightAngle)));
  vec3 lightDir = normalize(vec3(lightDir2.x, lightDir2.y * aspect, 0.85));
  float specular = pow(max(dot(normal, lightDir), 0.0), mix(36.0, 10.0, depth));
  float rim = pow(1.0 - max(dot(normal, viewDir), 0.0), 2.0);
  float highlight = specular * (0.35 + lightIntensity * 0.85) +
      rim * (0.08 + lightIntensity * 0.2);

  color = mix(color, color + (u_tint.rgb * 0.55), 0.16);
  color += vec3(highlight);

  float alpha = sphereMask * (0.32 + fresnel * 0.42 + specular * 0.18);
  alpha = clamp(alpha, 0.0, 0.98);

  fragColor = vec4(color * alpha, alpha * u_tint.a);
}
