//
//  GPUFaceDetectionDrawPointFilter.m
//  Photic
//
//  Created by LJP on 2023/7/20.
//

#import "GPUFaceDetectionDrawPointFilter.h"


NSString *const kGPUImageDrawFacePointVertexShaderString = SHADER_STRING
    (
    attribute vec4 position;
    uniform float sizeScale;

    void main(void)
{
    gl_Position = position;
    gl_PointSize = sizeScale;
}

    );

NSString *const kGPUImageDrawFacePointFragmentShaderString = SHADER_STRING
    (
    void main()
{
    gl_FragColor = vec4(0.2, 0.709803922, 0.898039216, 1.0);
}

    );

@implementation GPUFaceDetectionDrawPointFilter
{
    GLint sizeScaleUniform;
}

- (instancetype)init {
    self = [super initWithVertexShaderFromString:kGPUImageDrawFacePointVertexShaderString fragmentShaderFromString:kGPUImageDrawFacePointFragmentShaderString];
    if (self) {
        sizeScaleUniform = [filterProgram uniformIndex:@"sizeScale"];
    }
    return self;
}

- (GPUImageFramebuffer *)framebufferForOutput {
    return firstInputFramebuffer;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }

    [firstInputFramebuffer activateFramebuffer];
    [GPUImageContext setActiveShaderProgram:filterProgram];
    if (usingNextFrameForImageCapture) {
        [firstInputFramebuffer lock];
    }

    [self setUniformsForProgramAtIndex:0];

    const GLsizei pointCount = (GLsizei)self.points.count;
    GLfloat tempPoint[pointCount * 3];
    GLubyte indices[pointCount];

    for (int i = 0; i < self.points.count; i++) {
        CGPoint pointer = [self.points[i] CGPointValue];
        GLfloat x = pointer.x * 2 - 1;
        GLfloat y = pointer.y * 2 - 1;

        tempPoint[i * 3 + 0] = x;
        tempPoint[i * 3 + 1] = y;
        tempPoint[i * 3 + 2] = 0.0f;
        indices[i] = i;
    }
    glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, GL_TRUE, 0, tempPoint);
    glEnableVertexAttribArray(filterPositionAttribute);

    const GLfloat lineWidth = 4;
    glUniform1f(sizeScaleUniform, lineWidth);

    glDrawElements(GL_POINTS, (GLsizei)sizeof(indices) / sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);

    [self informTargetsAboutNewFrameAtTime:frameTime];
}


@end
