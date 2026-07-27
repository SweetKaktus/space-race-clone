// std imports
const std = @import("std");
const print = @import("std").debug.print;

// lib imports
const rl = @import("raylib");

// custom imports
const Player = @import("player.zig").Player;
const PlayerNumber = @import("playerNumber.zig").PlayerNumber;
const PlayerState = @import("playerState.zig").PlayerState;
const GameConfig = @import("gameConfig.zig").GameConfig;
const Star = @import("star.zig").Star;
const StarDirection = @import("starDirection.zig").StarDirection;

const GameState = enum {
	MENU,
	RUNNING,
	TIMES_UP,
};

var debug: bool = false;

pub fn main(init: std.process.Init) !void {

	// Set Timestamp to get random seed for PRNG
	const io = init.io;
	var timestamp: i64 = std.Io.Clock.now(.real, io).toSeconds();
	rl.setRandomSeed(@as(u32, @intCast(timestamp)));
	
	const screenWidth = 800;
	const screenHeight = 600;
	const gameTitle = "Space Race";

	var gameState: GameState = GameState.MENU;
	var firstGame = true;

	// Config Player
	const playerWidth = 32.0;
	const playerHeight = 32.0;
	const playerStartY = @as(f32, @floatFromInt(screenHeight)) - 90.0;
	const playerBottomBoundPosition = @as(f32, @floatFromInt(screenHeight)) - playerWidth / 2;
	const player1StartX = @as(f32, @floatFromInt(screenWidth)) / 4 - playerWidth / 2;
	const player2StartX = @as(f32, @floatFromInt(screenWidth)) / 4 * 3 - playerWidth / 2;
	var player1Image = try rl.loadImage("assets/graphics/ships/space_ship_1.png");
	var player2Image = try rl.loadImage("assets/graphics/ships/space_ship_3.png");
	player1Image.resizeNN(playerWidth, playerHeight);
	player2Image.resizeNN(playerWidth, playerHeight);

	// Config Stars
	const starCount = 24;
	const boundBottomStarStartY = @as(i32, @intFromFloat(playerStartY - 20.0));
	const starWidth = 8.0;
	const starHeight = 8.0;
			
	var stars: [starCount]Star = undefined;
	for (&stars, 0..) |*star, i| {
		const starStartX = @as(f32, @floatFromInt(rl.getRandomValue(0, screenWidth)));
		const starStartY = @as(f32, @floatFromInt(rl.getRandomValue(0, boundBottomStarStartY)));
		var starDirection = StarDirection.right;
		if (i % 2 == 0) {
			starDirection = StarDirection.left;
		}

		star.* = Star.init(starStartX, starStartY, starWidth, starHeight, starDirection);
	}

	// Timer
	const initTimer: f32 = 61.0;
	var floatTimer: f32 = initTimer;
	var intTimer: i32 = @as(i32, @intFromFloat(floatTimer));
	
	// Config Audio
	rl.initAudioDevice();
	defer rl.closeAudioDevice();
	rl.setMasterVolume(1.0);

	const menuMusic = try rl.loadMusicStream("assets/music/menu.wav");
	defer menuMusic.unload();
	rl.setMusicVolume(menuMusic, 0.8);
	const gameMusic = try rl.loadMusicStream("assets/music/game.wav");
	defer gameMusic.unload();
	rl.setMusicVolume(gameMusic, 0.6);

	const player1EngineSound = try rl.loadMusicStream("assets/sfx/engine-looping_1.wav");
	defer player1EngineSound.unload();

	const player1EnginePan: f32 = -1.0;
	rl.setMusicPan(player1EngineSound, player1EnginePan);

	// Formule : ((screenHeigh - position_y) * 100) / screenHeight 
	var player1EngineVolume: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);
	rl.setMusicVolume(player1EngineSound, player1EngineVolume);
	
	var player1EnginePitch: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight))) + 0.5;
	rl.setMusicPitch(player1EngineSound, player1EnginePitch);

	const player2EngineSound = try rl.loadMusicStream("assets/sfx/engine-looping_1.wav");
	defer player2EngineSound.unload();
	
	const player2EnginePan: f32 = 1.0;
	rl.setMusicPan(player2EngineSound, player2EnginePan);
	
	var player2EngineVolume: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);
	rl.setMusicVolume(player2EngineSound, player2EngineVolume);

	var player2EnginePitch: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight))) + 0.5;
	rl.setMusicPitch(player2EngineSound, player2EnginePitch);


	const starShootSound = try rl.loadSound("assets/sfx/shoot-small_6.wav");
	defer starShootSound.unload();
	rl.setSoundVolume(starShootSound, 0.8);

	const crossLineSound = try rl.loadSound("assets/sfx/misc_3.wav");
	defer crossLineSound.unload();
	rl.setSoundVolume(crossLineSound, 0.8);


	rl.initWindow(screenWidth, screenHeight, gameTitle);
	defer rl.closeWindow();

	const player1Texture = try rl.loadTextureFromImage(player1Image);
	defer player1Texture.unload();
	const player2Texture = try rl.loadTextureFromImage(player2Image);
	defer player2Texture.unload();

	rl.unloadImage(player1Image);
	rl.unloadImage(player2Image);

	var player1 = Player.init(PlayerNumber.firstPlayer, player1StartX, playerStartY, playerBottomBoundPosition, playerWidth, playerHeight, player1Texture);
	var player2 = Player.init(PlayerNumber.secondPlayer, player2StartX, playerStartY, playerBottomBoundPosition, playerWidth, playerHeight, player2Texture);

	

	const config = GameConfig.init(
		screenWidth,
		screenHeight,
		playerWidth,
		playerHeight,
		playerStartY,
		playerBottomBoundPosition,
		player1StartX,
		player2StartX,
		player1Texture,
		player2Texture,
		boundBottomStarStartY,
		starWidth,
		starHeight,
		initTimer,
	);



	while (!rl.windowShouldClose()) {
		// ========= GAME LOOP =========

		rl.beginDrawing();
		defer rl.endDrawing();

		rl.clearBackground(rl.Color.black);


		switch (gameState) {
			GameState.MENU => {
				if (debug) print("MENU\n", .{});
				
				// Play Music
				if (rl.isMusicStreamPlaying(gameMusic)) rl.stopMusicStream(gameMusic);
				if (rl.isMusicStreamPlaying(player1EngineSound)) rl.stopMusicStream(player1EngineSound);
				if (rl.isMusicStreamPlaying(player2EngineSound)) rl.stopMusicStream(player2EngineSound);

				if (!rl.isMusicStreamPlaying(menuMusic)) {
					rl.playMusicStream(menuMusic);
				}
				
				rl.updateMusicStream(menuMusic);

				if (debug) {
					if (rl.isMusicStreamPlaying(menuMusic)) print("MENU MUSIC PLAYING\n", .{});
				}

				// Core
				rl.drawText("Press SPACE to Start, Press ESC to Quit", 75, @as(f32, @floatFromInt(screenHeight)) / 2 - 40, 30, rl.Color.green);
				if (!firstGame) {
					const player1ScoreText = rl.textFormat("Score player 1 = %d", .{player1.score}); 
					const player2ScoreText = rl.textFormat("Score player 2 = %d", .{player2.score}); 
					rl.drawText(player1ScoreText, 50, screenHeight - 200, 20, rl.Color.yellow);
					rl.drawText(player2ScoreText, screenWidth - 250, screenHeight - 200, 20, rl.Color.yellow);
				}
				if (rl.isKeyDown(rl.KeyboardKey.space)) {
					resetGame(
						&player1,
						&player2,
						&stars,
						&floatTimer,
						&intTimer,
						&timestamp,
						io,
						config,
					);
					
					gameState = GameState.RUNNING;
				}
			},
			GameState.RUNNING => {
				if (debug) print("RUNNING\n", .{});

				// Stop Menu Music
				if (rl.isMusicStreamPlaying(menuMusic)) rl.stopMusicStream(menuMusic);
				
				// Start Game Music
				if (!rl.isMusicStreamPlaying(gameMusic)) {
					rl.playMusicStream(gameMusic);
				}	

				// Manage engine sounds
				if (!rl.isMusicStreamPlaying(player1EngineSound)) {
					rl.playMusicStream(player1EngineSound);
				}

				if (!rl.isMusicStreamPlaying(player2EngineSound)) {
					rl.playMusicStream(player2EngineSound);
				}

				player1EngineVolume = (@as(f32, @floatFromInt(screenHeight)) - player1.position_y) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);
				player2EngineVolume = (@as(f32, @floatFromInt(screenHeight)) - player2.position_y) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);

				player1EnginePitch = (@as(f32, @floatFromInt(screenHeight)) - player1.position_y) / (@as(f32, @floatFromInt(screenHeight))) + 1.0;
				player2EnginePitch = (@as(f32, @floatFromInt(screenHeight)) - player2.position_y) / (@as(f32, @floatFromInt(screenHeight))) + 1.0;

				if (player1EngineVolume > 0.7) {
					player1EngineVolume = 0.7;
				}

				if (player2EngineVolume > 0.7) {
 					player2EngineVolume = 0.7;
 				} 

 				
				rl.setMusicVolume(player1EngineSound, player1EngineVolume);
				rl.setMusicVolume(player2EngineSound, player2EngineVolume);

				rl.updateMusicStream(gameMusic);
				rl.updateMusicStream(player1EngineSound);
				rl.updateMusicStream(player2EngineSound);

				// ====== CONFIG ======

				firstGame = false;
				const dt = rl.getFrameTime();

				// ====== END ======
			
				// ====== UPDATE ======
				
				player1.update(dt);
				player2.update(dt);
		
				if (player1.position_y < 0.0 - player1.width) {
					rl.playSound(crossLineSound);
					player1.state = PlayerState.CROSS_FINISH_LINE;
				}
		
				if (player2.position_y < 0.0 - player2.width) {
					rl.playSound(crossLineSound);
					player2.state = PlayerState.CROSS_FINISH_LINE;
				}
		
				for (&stars) |*star| {
					star.update(dt, screenWidth);
					if (star.getRect().isColliding(player1.getRect())) {
						rl.playSound(starShootSound);
						player1.state = PlayerState.DEAD;
					}
					if (star.getRect().isColliding(player2.getRect())) {
						rl.playSound(starShootSound);
						player2.state = PlayerState.DEAD;
					}
				}
		
				floatTimer -= 1.0 * dt;
				intTimer = @as(i32, @intFromFloat(floatTimer));

		
				if (intTimer <= 0) {
					gameState = GameState.TIMES_UP;
				}
				
				
				// ====== END ======

				// ====== DRAW ======
				
				player1.draw();
				player2.draw();
		
				for (&stars) |*star| {
					star.draw();
				}
		
				// Draw Score
				const scorePlayer1_text = rl.textFormat("%d", .{ player1.score });
				const scorePlayer2_text = rl.textFormat("%d", .{ player2.score });
				rl.drawText(scorePlayer1_text, 20, screenHeight - 60, 40, rl.Color.yellow);
				rl.drawText(scorePlayer2_text, screenWidth - 40, screenHeight - 60, 40, rl.Color.yellow);

				// Draw Timer

				const timer_text = rl.textFormat("%d\n", .{intTimer});
				rl.drawText(timer_text, @as(f32, @floatFromInt(screenWidth)) / 2 - 30, screenHeight - 80, 60, rl.Color.white);

				
				// ====== END ======
			},
			GameState.TIMES_UP => {
				if (debug) print("TIMES_UP\n", .{});
				// Play Animation ?
				// Play Sound ? 
				// Create Particles ?

				
				gameState = GameState.MENU;
			},
		}
		
		// ========= END =========
	}
}

pub fn resetGame(
	player1: *Player,
	player2: *Player,
	stars: []Star,
	floatTimer: *f32,
	intTimer: *i32,
	timestamp: *i64,
	io: std.Io,
	config: GameConfig,
) void {
	// Reset Random Seed
	timestamp.* = std.Io.Clock.now(.real, io).toSeconds();
	rl.setRandomSeed(@as(u32, @intCast(timestamp.*)));

	// Reset Players
	player1.* = Player.init(PlayerNumber.firstPlayer, config.player1StartX, config.playerStartY, config.playerBottomBoundPosition, config.playerWidth, config.playerHeight, config.player1Texture);
	player2.* = Player.init(PlayerNumber.secondPlayer, config.player2StartX, config.playerStartY, config.playerBottomBoundPosition, config.playerWidth, config.playerHeight, config.player2Texture);

	// Reset Stars
	for (stars, 0..) |*star, i| {
		const starStartX = @as(f32, @floatFromInt(rl.getRandomValue(0, config.screenWidth)));
		const starStartY = @as(f32, @floatFromInt(rl.getRandomValue(0, config.boundBottomStarStartY)));
		var starDirection = StarDirection.right;
		if (i % 2 == 0) {
			starDirection = StarDirection.left;
		}

		star.* = Star.init(starStartX, starStartY, config.starWidth, config.starHeight, starDirection);
	}

	// Reset Timer
	floatTimer.* = config.initTimer;
	intTimer.* = @intFromFloat(floatTimer.*);

}
