pub const Rectangle = struct {
	x: f32,
	y: f32,
	width: f32,
	height: f32,

	pub fn init(
		x: f32,
		y: f32,
		width: f32,
		height: f32,
	) @This() {
		return .{
			.x = x,
			.y = y,
			.width = width,
			.height = height,
		};
	}

	pub fn is_colliding(self: @This(), other: Rectangle) bool {
		return self.x < other.x + other.width and
			self.x + self.width > other.x and
			self.y < other.y + other.height and
			self.y + self.height > other.y;
	}
};
