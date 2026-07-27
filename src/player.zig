const print = @import("std").debug.print;

const rl = @import("raylib");

const PlayerNumber = @import("playerNumber.zig").PlayerNumber;
const Rectangle = @import("rectangle.zig").Rectangle;
const PlayerState = @import("playerState.zig").PlayerState;

var debug: bool = false;


pub const Player = struct {
	player_number: PlayerNumber,
	startY: f32,
	bottomBoundPosition: f32,
	position_x: f32,
	position_y: f32,
	width: f32,
	height: f32,
	speed: f32,
	score: i32,
	texture: rl.Texture,
	state: PlayerState,

	pub fn init(
		player_number: PlayerNumber,
		position_x: f32,
		startY: f32,
		bottomBoundPosition: f32,
		width: f32,
		height: f32,
		texture: rl.Texture,
	) @This() {
		return .{
			.player_number = player_number,
			.startY = startY,
			.bottomBoundPosition = bottomBoundPosition,
			.position_x = position_x,
			.position_y = startY,
			.width = width,
			.height = height,
			.speed = 100.0,
			.score = 0,
			.texture = texture,
			.state = PlayerState.IDLE,
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

	pub fn update(self: *@This(), dt: f32) void {
		var up: rl.KeyboardKey = rl.KeyboardKey.w;
		var down: rl.KeyboardKey = rl.KeyboardKey.s;


		switch (self.state) {
			PlayerState.IDLE => {
				if (debug) print("IDLE\n", .{});
				// Play animation ?
				// Play Sound ?
				// Create Particles ?
			},
			PlayerState.DEAD => {
				if (debug) print("DEAD\n", .{});
				// Play Animation ?
				// Play Sound ?
				// Create Particles ?
				self.position_y = self.startY;
				self.state = PlayerState.IDLE;
			},
			PlayerState.MOVING_UP => {
				if (debug) print("MOVING_UP\n", .{});
				// Play animation
				// Play Sound ?
				// Create Particles ?
				self.position_y -= self.speed * dt;
			},
			PlayerState.MOVING_DOWN => {
				if (debug) print("MOVING_DOWN\n", .{});
				// Play animation ?
				// Play Sound ?
				// Create Particles ?
				self.position_y += self.speed * dt;
			},
			PlayerState.CROSS_FINISH_LINE => {
				if (debug) print("CROSS_FINISH_LINE\n", .{});
				// Play animation ?
				// Play Sound ?
				// Create Particles ?
				self.score += 1;
				self.position_y = self.bottomBoundPosition;
				self.state = PlayerState.IDLE;
			},
		}

		if (self.player_number == PlayerNumber.secondPlayer) {
			up = rl.KeyboardKey.up;
			down = rl.KeyboardKey.down;
		}
		if (rl.isKeyDown(up)) {
			self.state = PlayerState.MOVING_UP;
		}
		
		if (rl.isKeyDown(down)) {
			self.state = PlayerState.MOVING_DOWN;
		}

		if ((rl.isKeyReleased(up) and !rl.isKeyDown(down)) or (rl.isKeyReleased(down) and !rl.isKeyDown(up))) {
			self.state = PlayerState.IDLE;
		}
		
		if (self.position_y > self.bottomBoundPosition) {
			self.position_y = self.bottomBoundPosition;
		}
	}

	pub fn draw(self: @This()) void {
		rl.drawTexture(
			self.texture,
			@intFromFloat(self.position_x),
			@intFromFloat(self.position_y),
			rl.Color.white,
		);
	}
};
