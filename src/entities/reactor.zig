const rl = @import("raylib");

pub const Reactor = struct {
    texture_atlas: rl.Texture,
    frame_size: f32,
    frame_rec: rl.Rectangle,
    current_frame: i32,
    frame_counter: f32,
    frame_speed: f32,

    pub fn init(
        texture_atlas: rl.Texture,
        frame_size: f32,
        frame_speed: f32,
    ) @This() {
        return .{
            .texture_atlas = texture_atlas,
            .frame_size = frame_size,
            .frame_speed = frame_speed,
            .frame_rec = rl.Rectangle.init(
                0.0,
                0.0,
                frame_size,
                frame_size,
            ),
            .current_frame = 0,
            .frame_counter = 0,
        };
    }

    pub fn get_max_frame(self: @This()) f32 {
        return @as(f32, @floatFromInt(self.texture_atlas.width)) / self.frame_size;
    }

    pub fn update(self: *@This(), dt: f32, min_frame: f32, max_frame: f32) void {
        if (self.frame_counter < min_frame) {
            self.frame_counter = min_frame;
        }

        self.frame_counter += self.frame_speed * dt;

        if (self.frame_counter >= max_frame) {
            self.frame_counter = min_frame;
        }
        self.current_frame = @as(i32, @floor(self.frame_counter));
        self.frame_rec.x = @as(f32, @floatFromInt(self.current_frame)) * self.frame_size;
    }

    pub fn draw(self: @This(), position: rl.Vector2) void {
        rl.drawTextureRec(self.texture_atlas, self.frame_rec, position, rl.Color.white);
    }
};
