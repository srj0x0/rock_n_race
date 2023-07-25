#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[ attribute(0) ]];
    float2 textureCood [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCood;
};

vertex VertexOut vertexFunction(const VertexIn vertexIn [[ stage_in ]]) {
    VertexOut output;
    output.position = vector_float4(vertexIn.position, 0, 1);
    output.textureCood = vertexIn.textureCood;
    return output;
}

fragment float4 fragmentFunction(VertexOut interpolated [[ stage_in ]],
                                 texture2d<float> texture [[ texture(1) ]]) {

    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    return texture.sample(s, interpolated.textureCood);
}
