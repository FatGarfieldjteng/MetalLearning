//
//  shaders.metal
//  MetalLearning
//
//  Created by Tengjun on 12/15/23.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float4 posiiton [[attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertexIn [[stage_in]])
{
    return vertexIn.posiiton;
}

fragment float4 fragment_main()
{
    return float4(1, 0, 0, 1);
}
