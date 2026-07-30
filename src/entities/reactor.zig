const rl = @import("raylib");

pub const Reactor = struct {
    textureAtlas: rl.Texture,
    frameSize: f32,
    frameRec: rl.Rectangle,
    currentFrame: i32,
    frameCounter: f32,
    frameSpeed: f32,

    pub fn init(
        textureAtlas: rl.Texture,
        frameSize: f32,
        frameSpeed: f32,
    ) @This() {
        return .{
            .textureAtlas = textureAtlas,
            .frameSize = frameSize,
            .frameSpeed = frameSpeed,
            .frameRec = rl.Rectangle.init(
                0.0,
                0.0,
                frameSize,
                frameSize,
            ),
            .currentFrame = 0,
            .frameCounter = 0,
        };
    }

    pub fn getMaxFrame(self: @This()) f32 {
        return @as(f32, @floatFromInt(self.textureAtlas.width)) / self.frameSize;
    }

    pub fn update(self: *@This(), dt: f32, minFrame: f32, maxFrame: f32) void {
        if (self.frameCounter < minFrame) {
            self.frameCounter = minFrame;
        }

        self.frameCounter += self.frameSpeed * dt;

        if (self.frameCounter >= maxFrame) {
            self.frameCounter = minFrame;
        }
        self.currentFrame = @as(i32, @floor(self.frameCounter));
        self.frameRec.x = @as(f32, @floatFromInt(self.currentFrame)) * self.frameSize;
    }
    pub fn draw(self: @This(), position: rl.Vector2) void {
        rl.drawTextureRec(self.textureAtlas, self.frameRec, position, rl.Color.white);
    }
};
