//
//  shaders.metal
//  MetalExample
//
//  Created by Joshua Homann on 3/4/23.
//

#include <metal_stdlib>
using namespace metal;

#include "common.h"

struct Fragment {
    float4 position [[position]];
    float4 color;
};

vertex auto vertexShader(const device Vertex *vertices [[buffer(0)]], unsigned int index [[vertex_id]]) -> Fragment {
    Vertex input = vertices[index];
    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1);
    output.color = input.color;
    return output;
}

fragment float4 fragmentShader(Fragment input [[stage_in]]) {
    return input.color;
}
