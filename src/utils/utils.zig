const std = @import("std");
const rl = @import("raylib");

const Player = @import("../entities/player.zig").Player;
const Star = @import("../entities/star.zig").Star;
const BackgroundStar = @import("../entities/background_star.zig").BackgroundStar;

const PlayerNumber = @import("../enums/player_number.zig").PlayerNumber;
const StarDirection = @import("../enums/star_direction.zig").StarDirection;

const GameConfig = @import("../config/game_config.zig").GameConfig;

pub fn reset_game(
    player1: *Player,
    player2: *Player,
    stars: []Star,
    bg_stars: []BackgroundStar,
    float_timer: *f32,
    int_timer: *i32,
    io: std.Io,
    config: GameConfig,
) void {
    // Reset Random Seed
    rng_init_new_seed(io);

    // Reset Players
    player1.* = Player.init(
        PlayerNumber.first_player,
        config.player1_start_x,
        config.player_start_y,
        config.player_bottom_bound_position,
        config.sprite_size,
        config.sprite_size,
        config.player1_texture,
        config.reactor_texture_atlas,
    );
    player2.* = Player.init(
        PlayerNumber.second_player,
        config.player2_start_x,
        config.player_start_y,
        config.player_bottom_bound_position,
        config.sprite_size,
        config.sprite_size,
        config.player2_texture,
        config.reactor_texture_atlas,
    );

    // Reset Stars
    for (stars, 0..) |*star, i| {
        const star_start_x = @as(f32, @floatFromInt(rl.getRandomValue(0, config.screen_width)));
        const star_start_y = @as(f32, @floatFromInt(rl.getRandomValue(0, config.bound_bottom_star_start_y)));
        var star_direction = StarDirection.right;
        if (i % 2 == 0) {
            star_direction = StarDirection.left;
        }

        star.* = Star.init(star_start_x, star_start_y, config.star_width, config.star_height, star_direction);
    }

    for (bg_stars) |*star| {
        const star_start_x = @as(f32, @floatFromInt(rl.getRandomValue(0, config.screen_width)));
        const star_start_y = @as(f32, @floatFromInt(rl.getRandomValue(0, config.screen_height)));
        star.* = BackgroundStar.init(star_start_x, star_start_y);
    }

    // Reset Timer
    float_timer.* = config.init_timer;
    int_timer.* = @intFromFloat(float_timer.*);
}

pub fn rng_init_new_seed(io: std.Io) void {
    const timestamp: i64 = std.Io.Clock.now(.real, io).toSeconds();
    rl.setRandomSeed(@as(u32, @intCast(timestamp)));
}
