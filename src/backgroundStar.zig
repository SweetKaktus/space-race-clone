const rl = @import("raylib");

pub const BackgroundStar = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    color: rl.Color,

    pub fn init(
        position_x: f32,
        position_y: f32,
    ) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = 2.0,
            .height = @as(f32, @floatFromInt(rl.getRandomValue(2, 4))),
            .speed = @as(f32, @floatFromInt(rl.getRandomValue(500, 1500))),
            .color = rl.Color.init(
                255,
                255,
                255,
                @as(u8, @intCast(rl.getRandomValue(150, 200))),
            ),
        };
    }

    pub fn update(self: *@This(), dt: f32, screenHeight: i32) void {
        self.position_y += self.speed * dt;
        if (self.position_y >= @as(f32, @floatFromInt(screenHeight))) {
            self.position_y = 0;
        }
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            self.color,
        );
    }
};
