//
//  GPUThinFaceAndLargeEyeFilter.m
//  Photic
//
//  Created by LJP on 2023/7/20.
//

#import "GPUThinFaceAndBigEyeFilter.h"

NSString *const kGPUImageThinFaceAndBigEyeFragmentShaderString = SHADER_STRING
    (

    precision highp float;
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;

    uniform int hasFace;
    uniform float facePoints[106 * 2];

    uniform highp float aspectRatio;
    uniform float thinFaceValue;
    uniform float bigEyeValue;

    vec2 enlargeEye(vec2 textureCoord, vec2 originPosition, float radius, float delta)
{
    float weight = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;

    weight = 1.0 - (1.0 - weight * weight) * delta;
    weight = clamp(weight, 0.0, 1.0);
    textureCoord = originPosition + (textureCoord - originPosition) * weight;
    return textureCoord;
}

    vec2 curveWarp(vec2 textureCoord, vec2 originPosition, vec2 targetPosition, float delta)
{
    vec2 offset = vec2(0.0);
    vec2 result = vec2(0.0);
    vec2 direction = (targetPosition - originPosition) * delta;

    float radius = distance(vec2(targetPosition.x, targetPosition.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio));
    float ratio = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;

    ratio = 1.0 - ratio;
    ratio = clamp(ratio, 0.0, 1.0);
    offset = direction * ratio;

    result = textureCoord - offset;

    return result;
}

    vec2 thinFace(vec2 currentCoordinate)
{
    vec2 faceIndexs[9];
    faceIndexs[0] = vec2(3., 44.);
    faceIndexs[1] = vec2(29., 44.);
    faceIndexs[2] = vec2(7., 45.);
    faceIndexs[3] = vec2(25., 45.);
    faceIndexs[4] = vec2(10., 46.);
    faceIndexs[5] = vec2(22., 46.);
    faceIndexs[6] = vec2(14., 49.);
    faceIndexs[7] = vec2(18., 49.);
    faceIndexs[8] = vec2(16., 49.);

    for (int i = 0; i < 9; i++) {
        int originIndex = int(faceIndexs[i].x);
        int targetIndex = int(faceIndexs[i].y);
        vec2 originPoint = vec2(facePoints[originIndex * 2], facePoints[originIndex * 2 + 1]);
        vec2 targetPoint = vec2(facePoints[targetIndex * 2], facePoints[targetIndex * 2 + 1]);
        currentCoordinate = curveWarp(currentCoordinate, originPoint, targetPoint, thinFaceValue);
    }
    return currentCoordinate;
}

    vec2 bigEye(vec2 currentCoordinate)
{
    vec2 faceIndexs[2];
    faceIndexs[0] = vec2(74., 72.);
    faceIndexs[1] = vec2(77., 75.);

    for (int i = 0; i < 2; i++) {
        int originIndex = int(faceIndexs[i].x);
        int targetIndex = int(faceIndexs[i].y);

        vec2 originPoint = vec2(facePoints[originIndex * 2], facePoints[originIndex * 2 + 1]);
        vec2 targetPoint = vec2(facePoints[targetIndex * 2], facePoints[targetIndex * 2 + 1]);

        float radius = distance(vec2(targetPoint.x, targetPoint.y / aspectRatio), vec2(originPoint.x, originPoint.y / aspectRatio));
        radius = radius * 5.;
        currentCoordinate = enlargeEye(currentCoordinate, originPoint, radius, bigEyeValue);
    }
    return currentCoordinate;
}

    void main()
{
    vec2 positionToUse = textureCoordinate;

    if (hasFace == 1) {
        positionToUse = thinFace(positionToUse);
        positionToUse = bigEye(positionToUse);
    }

    gl_FragColor = texture2D(inputImageTexture, positionToUse);
}

    );

@implementation GPUThinFaceAndBigEyeFilter
{
    GLint aspectRatioUniform;
    GLint facePointsUniform;
    GLint thinFaceValueUniform;
    GLint bigEyeValueUniform;
    GLint hasFaceUniform;
}

- (instancetype)init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageThinFaceAndBigEyeFragmentShaderString])) {
        return nil;
    }
    hasFaceUniform = [filterProgram uniformIndex:@"hasFace"];
    aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
    facePointsUniform = [filterProgram uniformIndex:@"facePoints"];
    thinFaceValueUniform = [filterProgram uniformIndex:@"thinFaceValue"];
    bigEyeValueUniform = [filterProgram uniformIndex:@"bigEyeValue"];

    self.thinFaceValue = 0;
    self.bigEyeValue = 0;
    return self;
}

- (void)setUniformWithPoints:(NSArray<NSValue *> *)points {
    if (!points.count) {
        [self setInteger:0 forUniform:hasFaceUniform program:filterProgram];
        return;
    }
    [self setInteger:1 forUniform:hasFaceUniform program:filterProgram];

    CGFloat aspect = inputTextureSize.width / inputTextureSize.height;
    [self setFloat:aspect forUniform:aspectRatioUniform program:filterProgram];
    [self setFloat:self.thinFaceValue forUniform:thinFaceValueUniform program:filterProgram];
    [self setFloat:self.bigEyeValue forUniform:bigEyeValueUniform program:filterProgram];

    GLsizei size = 106 * 2;
    GLfloat *facePoints = malloc(size * sizeof(GLfloat));

    int index = 0;
    for (NSValue *value in points) {
        CGPoint point = [value CGPointValue];
        *(facePoints + index) = point.x;
        *(facePoints + index + 1) = point.y;
        index += 2;

        if (index == size) {
            break;
        }
    }
    [self setFloatArray:facePoints length:size forUniform:facePointsUniform program:filterProgram];

    free(facePoints);
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    [self setUniformWithPoints:self.points];
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

@end
