const std = @import("std");
const rl = @import("raylib");

const Player = @import("../entities/player.zig").Player;
const Star = @import("../entities/star.zig").Star;
const BackgroundStar = @import("../entities/backgroundStar.zig").BackgroundStar;

const PlayerNumber = @import("../enums/playerNumber.zig").PlayerNumber;
const StarDirection = @import("../enums/starDirection.zig").StarDirection;

const GameConfig = @import("../config/gameConfig.zig").GameConfig;

pub fn resetGame(
    player1: *Player,
    player2: *Player,
    stars: []Star,
    bgStars: []BackgroundStar,
    floatTimer: *f32,
    intTimer: *i32,
    io: std.Io,
    config: GameConfig,
) void {
    // Reset Random Seed
    rngInitNewSeed(io);

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

pub fn rngInitNewSeed(io: std.Io) void {
    const timestamp: i64 = std.Io.Clock.now(.real, io).toSeconds();
    rl.setRandomSeed(@as(u32, @intCast(timestamp)));
}
