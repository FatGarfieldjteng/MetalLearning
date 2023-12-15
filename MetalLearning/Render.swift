//
//  Render.swift
//  MetalLearning
//
//  Created by Tengjun on 12/15/23.
//

import MetalKit

class Renderer: NSObject{
    
    static var _device: MTLDevice!
    static var _commandQueue: MTLCommandQueue!
    static var _library: MTLLibrary!
    var _vertexBuffer: MTLBuffer!
    var _pipelineState: MTLRenderPipelineState!
    
    
    var _mesh: MTKMesh!
    
    init(metalView: MTKView){
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else{
            fatalError("GPU not available")
        }
        Renderer._device = device;
        Renderer._commandQueue = commandQueue
        metalView.device = device
        
        // create mesh
        let allocator = MTKMeshBufferAllocator(device: device)
        let size: Float = 0.8
        let mdlMesh = MDLMesh(boxWithExtent: [size, size, size], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        
        do{
            _mesh = try MTKMesh(mesh: mdlMesh, device: device)
        }
        catch let error{
            print(error.localizedDescription)
        }
        
        // create VB
        _vertexBuffer = _mesh.vertexBuffers[0].buffer
        
        // create shaders
        let library = device.makeDefaultLibrary()
        Renderer._library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        // create PSO
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        
        do{
            _pipelineState =
            try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch let error{
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(
            red: 1.0,
            green: 1.0,
            blue: 0.8,
            alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate{
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange: CGSize
    )
    {
        
    }
    
    func draw(in view: MTKView){
        guard
            let commandBuffer = Renderer._commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else{
            return
        }
        
        //drawing
        renderEncoder.setRenderPipelineState(_pipelineState)
        renderEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
        for submesh in _mesh.submeshes{
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable
        else{
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
