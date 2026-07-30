const rl = @import("raylib");
const StarDirection = @import("../enums/star_direction.zig").StarDirection;
const Rectangle = @import("../components/rectangle.zig").Rectangle;

pub const Star = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    direction: StarDirection,
    color: rl.Color,

    pub fn init(
        position_x: f32,
        position_y: f32,
        width: f32,
        height: f32,
        direction: StarDirection,
    ) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .direction = direction,
            .speed = @as(f32, @floatFromInt(rl.getRandomValue(100, 250))),
            .color = rl.Color.gold,
        };
    }

    pub fn get_rect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn update(self: *@This(), dt: f32, screen_width: i32) void {
        const int_direction = @intFromEnum(self.direction);
        const float_direction = @as(f32, @floatFromInt(int_direction));

        self.position_x += self.speed * dt * float_direction;

        if (self.direction == StarDirection.right) {
            if (self.position_x >= @as(f32, @floatFromInt(screen_width))) {
                self.position_x = 0;
            }
        } else {
            if (self.position_x < 0 - self.width) {
                self.position_x = @as(f32, @floatFromInt(screen_width));
            }
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
