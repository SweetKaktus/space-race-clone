// std imports
const std = @import("std");
const print = @import("std").debug.print;

// lib imports
const rl = @import("raylib");

// custom imports
const Player = @import("entities/player.zig").Player;
const PlayerNumber = @import("enums/playerNumber.zig").PlayerNumber;
const PlayerState = @import("enums/playerState.zig").PlayerState;
const GameConfig = @import("config/gameConfig.zig").GameConfig;
const Star = @import("entities/star.zig").Star;
const StarDirection = @import("enums/starDirection.zig").StarDirection;
const BackgroundStar = @import("entities/backgroundStar.zig").BackgroundStar;
const AudioManager = @import("systems/audioManager.zig").AudioManager;

const GameState = enum {
    MENU,
    RUNNING,
    TIMES_UP,
};

const debug: bool = false;

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

    const spriteSize = 32.0;

    // load ship sprites into images
    const minShip: usize = 0;
    const maxShip: usize = 4;
    var shipSpritesImg: [maxShip + 1]rl.Image = undefined;
    for (&shipSpritesImg, 0..) |*sprite, i| {
        sprite.* = try rl.loadImage(rl.textFormat("assets/graphics/ships/space_ship_%d.png", .{i + 1}));
        sprite.resizeNN(@as(i32, @intFromFloat(spriteSize)), @as(i32, @intFromFloat(spriteSize)));
    }

    // load reactor spritesheet into image
    var reactorImageAtlas = try rl.loadImage("assets/graphics/reactor_fire_spritesheet.png");
    reactorImageAtlas.resizeNN(spriteSize * 12, spriteSize);

    // Config Player
    const playerStartY = @as(f32, @floatFromInt(screenHeight)) - 90.0;
    const playerBottomBoundPosition = @as(f32, @floatFromInt(screenHeight)) - spriteSize / 2;
    const player1StartX = @as(f32, @floatFromInt(screenWidth)) / 4 - spriteSize / 2;
    const player2StartX = @as(f32, @floatFromInt(screenWidth)) / 4 * 3 - spriteSize / 2;

    // Config Stars
    const starCount = 24;
    const boundBottomStarStartY = @as(i32, @intFromFloat(playerStartY - 20.0));
    const starWidth = 8.0;
    const starHeight = 8.0;

    // Config Background Stars
    const bgStarCount = 8;
    var bgStars: [bgStarCount]BackgroundStar = undefined;
    for (&bgStars, 0..) |*star, i| {
        var starStartX: f32 = @as(f32, @floatFromInt(rl.getRandomValue(10, screenWidth / 2)));
        if (i >= bgStars.len / 2) {
            starStartX = @as(f32, @floatFromInt(rl.getRandomValue(screenWidth / 2, screenWidth - 10)));
        }

        const starStartY = @as(f32, @floatFromInt(rl.getRandomValue(0, screenHeight)));
        star.* = BackgroundStar.init(starStartX, starStartY);
    }

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

    var audioManager: AudioManager = try AudioManager.init(screenHeight, playerStartY);
    defer audioManager.unloadAll();

    rl.initWindow(screenWidth, screenHeight, gameTitle);
    defer rl.closeWindow();

    var shipSpritesTextures: [maxShip + 1]rl.Texture = undefined;
    for (&shipSpritesTextures, 0..) |*sprite, i| {
        sprite.* = try rl.loadTextureFromImage(shipSpritesImg[i]);
    }
    defer {
        for (&shipSpritesTextures) |*sprite| {
            if (debug) print("SPRITE TEXTURE UNLOADED\n", .{});
            sprite.unload();
        }
    }

    for (&shipSpritesImg) |*sprite| {
        if (debug) print("SPRITE IMAGE UNLOADED\n", .{});
        sprite.unload();
    }

    const reactorTextureAtlas = try rl.loadTextureFromImage(reactorImageAtlas);
    defer reactorTextureAtlas.unload();
    reactorImageAtlas.unload();

    var player1SelectedShip: usize = 0;
    var player2SelectedShip: usize = 1;

    const player1Texture = shipSpritesTextures[player1SelectedShip];
    const player2Texture = shipSpritesTextures[player2SelectedShip];

    var player1 = Player.init(
        PlayerNumber.firstPlayer,
        player1StartX,
        playerStartY,
        playerBottomBoundPosition,
        spriteSize,
        spriteSize,
        player1Texture,
        reactorTextureAtlas,
    );
    var player2 = Player.init(
        PlayerNumber.secondPlayer,
        player2StartX,
        playerStartY,
        playerBottomBoundPosition,
        spriteSize,
        spriteSize,
        player2Texture,
        reactorTextureAtlas,
    );

    var config: GameConfig = GameConfig.init(
        screenWidth,
        screenHeight,
        spriteSize,
        playerStartY,
        playerBottomBoundPosition,
        player1StartX,
        player2StartX,
        player1Texture,
        player2Texture,
        reactorTextureAtlas,
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
                audioManager.menuUpdate(debug);

                // Core
                // UPDATE

                if (rl.isKeyPressed(rl.KeyboardKey.a)) {
                    if (player1SelectedShip <= minShip) {
                        player1SelectedShip = maxShip;
                    } else {
                        player1SelectedShip -= 1;
                    }
                }

                if (rl.isKeyPressed(rl.KeyboardKey.d)) {
                    player1SelectedShip += 1;
                    if (player1SelectedShip > maxShip) {
                        player1SelectedShip = minShip;
                    }
                }

                if (rl.isKeyPressed(rl.KeyboardKey.left)) {
                    if (player2SelectedShip <= minShip) {
                        player2SelectedShip = maxShip;
                    } else {
                        player2SelectedShip -= 1;
                    }
                }

                if (rl.isKeyPressed(rl.KeyboardKey.right)) {
                    player2SelectedShip += 1;
                    if (player2SelectedShip > maxShip) {
                        player2SelectedShip = minShip;
                    }
                }

                config.setPlayerTexture(
                    shipSpritesTextures[player1SelectedShip],
                    shipSpritesTextures[player2SelectedShip],
                );

                // DRAW
                rl.drawText("Press SPACE to Start, Press ESC to Quit", 75, @as(f32, @floatFromInt(screenHeight)) / 2 - 40, 30, rl.Color.green);
                if (!firstGame) {
                    const player1ScoreText = rl.textFormat("Score player 1 = %d", .{player1.score});
                    const player2ScoreText = rl.textFormat("Score player 2 = %d", .{player2.score});
                    rl.drawText(player1ScoreText, 50, screenHeight - 200, 20, rl.Color.yellow);
                    rl.drawText(player2ScoreText, screenWidth - 250, screenHeight - 200, 20, rl.Color.yellow);
                }

                rl.drawTexture(
                    config.player1Texture,
                    @as(i32, @intFromFloat(config.player1StartX)),
                    @as(i32, @intFromFloat(config.playerStartY)),
                    rl.Color.white,
                );
                rl.drawTexture(
                    config.player2Texture,
                    @as(i32, @intFromFloat(config.player2StartX)),
                    @as(i32, @intFromFloat(config.playerStartY)),
                    rl.Color.white,
                );

                if (rl.isKeyDown(rl.KeyboardKey.space)) {
                    resetGame(
                        &player1,
                        &player2,
                        &stars,
                        &bgStars,
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

                audioManager.runningUpdate(screenHeight, player1, player2);

                // ====== CONFIG ======

                firstGame = false;
                const dt = rl.getFrameTime();

                // ====== END ======

                // ====== UPDATE ======

                player1.update(dt);
                player2.update(dt);

                if (player1.position_y < 0.0 - player1.width) {
                    audioManager.playCrossLineSound();
                    player1.state = PlayerState.CROSS_FINISH_LINE;
                }

                if (player2.position_y < 0.0 - player2.width) {
                    audioManager.playCrossLineSound();
                    player2.state = PlayerState.CROSS_FINISH_LINE;
                }

                for (&stars) |*star| {
                    star.update(dt, screenWidth);
                    if (star.getRect().isColliding(player1.getRect())) {
                        audioManager.playStarShootSound();
                        player1.state = PlayerState.DEAD;
                    }
                    if (star.getRect().isColliding(player2.getRect())) {
                        audioManager.playStarShootSound();
                        player2.state = PlayerState.DEAD;
                    }
                }

                for (&bgStars) |*star| {
                    star.update(dt, screenHeight);
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

                for (&bgStars) |*star| {
                    star.draw();
                }

                // Draw Score
                const scorePlayer1_text = rl.textFormat("%d", .{player1.score});
                const scorePlayer2_text = rl.textFormat("%d", .{player2.score});
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
    bgStars: []BackgroundStar,
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
    player1.* = Player.init(
        PlayerNumber.firstPlayer,
        config.player1StartX,
        config.playerStartY,
        config.playerBottomBoundPosition,
        config.spriteSize,
        config.spriteSize,
        config.player1Texture,
        config.reactorTextureAtlas,
    );
    player2.* = Player.init(
        PlayerNumber.secondPlayer,
        config.player2StartX,
        config.playerStartY,
        config.playerBottomBoundPosition,
        config.spriteSize,
        config.spriteSize,
        config.player2Texture,
        config.reactorTextureAtlas,
    );

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

    for (bgStars) |*star| {
        const starStartX = @as(f32, @floatFromInt(rl.getRandomValue(0, config.screenWidth)));
        const starStartY = @as(f32, @floatFromInt(rl.getRandomValue(0, config.screenHeight)));
        star.* = BackgroundStar.init(starStartX, starStartY);
    }

    // Reset Timer
    floatTimer.* = config.initTimer;
    intTimer.* = @intFromFloat(floatTimer.*);
}
