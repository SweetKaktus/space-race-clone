const rl = @import("raylib");

pub const GameConfig = struct {
	screenWidth: i32,
	screenHeight: i32,
	playerWidth: f32,
	playerHeight: f32,
	playerStartY: f32,
	playerBottomBoundPosition: f32,
	player1StartX: f32,
	player2StartX: f32,
	player1Texture: rl.Texture,
	player2Texture: rl.Texture,
	boundBottomStarStartY: i32,
	starWidth: f32,
	starHeight: f32,
	initTimer: f32,

	pub fn init(
		screenWidth: i32,
		screenHeight: i32,
		playerWidth: f32,
		playerHeight: f32,
		playerStartY: f32,
		playerBottomBoundPosition: f32,
		player1StartX: f32,
		player2StartX: f32,
		player1Texture: rl.Texture,
		player2Texture: rl.Texture,
		boundBottomStarStartY: i32,
		starWidth: f32,
		starHeight: f32,
		initTimer: f32
	) @This() {
		return .{
			.screenWidth = screenWidth,
			.screenHeight = screenHeight,
			.playerWidth = playerWidth,
			.playerHeight = playerHeight,
			.playerStartY = playerStartY,
			.playerBottomBoundPosition = playerBottomBoundPosition,
			.player1StartX = player1StartX,
			.player2StartX = player2StartX,
			.player1Texture = player1Texture,
			.player2Texture = player2Texture,
			.boundBottomStarStartY = boundBottomStarStartY,
			.starWidth = starWidth,
			.starHeight = starHeight,
			.initTimer = initTimer,
		}; 
	}
};
