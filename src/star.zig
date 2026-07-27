const rl = @import("raylib");
const StarDirection = @import("starDirection.zig").StarDirection;
const Rectangle = @import("rectangle.zig").Rectangle;

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
	pub fn getRect(self: @This()) Rectangle {
		return .{
			.x = self.position_x,
			.y = self.position_y,
			.width = self.width,
			.height = self.height,
		};
	}
	pub fn update(self: *@This(), dt: f32, screenWidth: i32) void {
		const intDirection = @intFromEnum(self.direction);
		const floatDirection = @as(f32, @floatFromInt(intDirection));
		
		self.position_x += self.speed * dt * floatDirection;

		if (self.direction == StarDirection.right) {
			if (self.position_x >= @as(f32, @floatFromInt(screenWidth))) {
				self.position_x = 0;
			}
		} else {
			if (self.position_x < 0 - self.width) {
				self.position_x = @as(f32, @floatFromInt(screenWidth));
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
