// std imports
const std = @import("std");
const print = @import("std").debug.print;

// lib imports
const rl = @import("raylib");

// custom imports
// import entities
const Player = @import("entities/player.zig").Player;
const Star = @import("entities/star.zig").Star;
const BackgroundStar = @import("entities/background_star.zig").BackgroundStar;

// import enums
const PlayerNumber = @import("enums/player_number.zig").PlayerNumber;
const PlayerState = @import("enums/player_state.zig").PlayerState;
const StarDirection = @import("enums/star_direction.zig").StarDirection;
const GameState = @import("enums/game_state.zig").GameState;

// import configs
const GameConfig = @import("config/game_config.zig").GameConfig;

// import systems
const AudioManager = @import("systems/audio_manager.zig").AudioManager;

// import utils
const utils = @import("utils/utils.zig");

const debug: bool = false;

pub fn main(init: std.process.Init) !void {

    // Set Timestamp to get random seed for PRNG
    const io = init.io;
    utils.rng_init_new_seed(io);

    const screen_width = 800;
    const screen_height = 600;
    const game_title = "Space Race";

    var game_state: GameState = GameState.menu;
    var first_game: bool = true;

    const sprite_size = 32.0;

    // load ship sprites into images
    const min_ship: usize = 0;
    const max_ship: usize = 4;
    var ship_sprites_img: [max_ship + 1]rl.Image = undefined;
    for (&ship_sprites_img, 0..) |*sprite, i| {
        sprite.* = try rl.loadImage(rl.textFormat("assets/graphics/ships/space_ship_%d.png", .{i + 1}));
        sprite.resizeNN(@as(i32, @intFromFloat(sprite_size)), @as(i32, @intFromFloat(sprite_size)));
    }

    // load reactor spritesheet into image
    var reactor_image_atlas = try rl.loadImage("assets/graphics/reactor_fire_spritesheet.png");
    reactor_image_atlas.resizeNN(sprite_size * 12, sprite_size);

    // Config Player
    const player_start_y = @as(f32, @floatFromInt(screen_height)) - 90.0;
    const player_bottom_bound_position = @as(f32, @floatFromInt(screen_height)) - sprite_size / 2;
    const player1_start_x = @as(f32, @floatFromInt(screen_width)) / 4 - sprite_size / 2;
    const player2_start_x = @as(f32, @floatFromInt(screen_width)) / 4 * 3 - sprite_size / 2;

    // Config Stars
    const star_count = 24;
    const bound_bottom_star_start_y = @as(i32, @intFromFloat(player_start_y - 20.0));
    const star_width = 8.0;
    const star_height = 8.0;

    // Config Background Stars
    const bg_star_count = 8;
    var bg_stars: [bg_star_count]BackgroundStar = undefined;
    for (&bg_stars, 0..) |*star, i| {
        var star_start_x: f32 = @as(f32, @floatFromInt(rl.getRandomValue(10, screen_width / 2)));
        if (i >= bg_stars.len / 2) {
            star_start_x = @as(f32, @floatFromInt(rl.getRandomValue(screen_width / 2, screen_width - 10)));
        }

        const star_start_y = @as(f32, @floatFromInt(rl.getRandomValue(0, screen_height)));
        star.* = BackgroundStar.init(star_start_x, star_start_y);
    }

    var stars: [star_count]Star = undefined;
    for (&stars, 0..) |*star, i| {
        const star_start_x = @as(f32, @floatFromInt(rl.getRandomValue(0, screen_width)));
        const star_start_y = @as(f32, @floatFromInt(rl.getRandomValue(0, bound_bottom_star_start_y)));
        var star_direction = StarDirection.right;
        if (i % 2 == 0) {
            star_direction = StarDirection.left;
        }

        star.* = Star.init(star_start_x, star_start_y, star_width, star_height, star_direction);
    }

    // Timer
    const init_timer: f32 = 61.0;
    var float_timer: f32 = init_timer;
    var int_timer: i32 = @as(i32, @intFromFloat(float_timer));

    // Config Audio
    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    var audio_manager: AudioManager = try AudioManager.init(screen_height, player_start_y);
    defer audio_manager.unload_all();

    rl.initWindow(screen_width, screen_height, game_title);
    defer rl.closeWindow();

    var ship_sprites_textures: [max_ship + 1]rl.Texture = undefined;
    for (&ship_sprites_textures, 0..) |*sprite, i| {
        sprite.* = try rl.loadTextureFromImage(ship_sprites_img[i]);
    }
    defer {
        for (&ship_sprites_textures) |*sprite| {
            if (debug) print("SPRITE TEXTURE UNLOADED\n", .{});
            sprite.unload();
        }
    }

    for (&ship_sprites_img) |*sprite| {
        if (debug) print("SPRITE IMAGE UNLOADED\n", .{});
        sprite.unload();
    }

    const reactor_texture_atlas = try rl.loadTextureFromImage(reactor_image_atlas);
    defer reactor_texture_atlas.unload();
    reactor_image_atlas.unload();

    var player1_selected_ship: usize = 0;
    var player2_selected_ship: usize = 1;

    const player1_texture = ship_sprites_textures[player1_selected_ship];
    const player2_texture = ship_sprites_textures[player2_selected_ship];

    var player1 = Player.init(
        PlayerNumber.first_player,
        player1_start_x,
        player_start_y,
        player_bottom_bound_position,
        sprite_size,
        sprite_size,
        player1_texture,
        reactor_texture_atlas,
    );
    var player2 = Player.init(
        PlayerNumber.second_player,
        player2_start_x,
        player_start_y,
        player_bottom_bound_position,
        sprite_size,
        sprite_size,
        player2_texture,
        reactor_texture_atlas,
    );

    var config: GameConfig = GameConfig.init(
        screen_width,
        screen_height,
        sprite_size,
        player_start_y,
        player_bottom_bound_position,
        player1_start_x,
        player2_start_x,
        player1_texture,
        player2_texture,
        reactor_texture_atlas,
        bound_bottom_star_start_y,
        star_width,
        star_height,
        init_timer,
    );

    while (!rl.windowShouldClose()) {
        // ========= GAME LOOP ==========

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        switch (game_state) {
            GameState.menu => {
                if (debug) print("MENU\n", .{});

                // Play Music
                audio_manager.menu_update(debug);

                // Core
                // UPDATE

                if (rl.isKeyPressed(rl.KeyboardKey.a)) {
                    if (player1_selected_ship <= min_ship) {
                        player1_selected_ship = max_ship;
                    } else {
                        player1_selected_ship -= 1;
                    }
                }

                if (rl.isKeyPressed(rl.KeyboardKey.d)) {
                    player1_selected_ship += 1;
                    if (player1_selected_ship > max_ship) {
                        player1_selected_ship = min_ship;
                    }
                }

                if (rl.isKeyPressed(rl.KeyboardKey.left)) {
                    if (player2_selected_ship <= min_ship) {
                        player2_selected_ship = max_ship;
                    } else {
                        player2_selected_ship -= 1;
                    }
                }

                if (rl.isKeyPressed(rl.KeyboardKey.right)) {
                    player2_selected_ship += 1;
                    if (player2_selected_ship > max_ship) {
                        player2_selected_ship = min_ship;
                    }
                }

                config.set_player_texture(
                    ship_sprites_textures[player1_selected_ship],
                    ship_sprites_textures[player2_selected_ship],
                );

                // DRAW
                rl.drawText("Press SPACE to Start, Press ESC to Quit", 75, @as(f32, @floatFromInt(screen_height)) / 2 - 40, 30, rl.Color.green);
                if (!first_game) {
                    const player1_score_text = rl.textFormat("Score player 1 = %d", .{player1.score});
                    const player2_score_text = rl.textFormat("Score player 2 = %d", .{player2.score});
                    rl.drawText(player1_score_text, 50, screen_height - 200, 20, rl.Color.yellow);
                    rl.drawText(player2_score_text, screen_width - 250, screen_height - 200, 20, rl.Color.yellow);
                }

                rl.drawTexture(
                    config.player1_texture,
                    @as(i32, @intFromFloat(config.player1_start_x)),
                    @as(i32, @intFromFloat(config.player_start_y)),
                    rl.Color.white,
                );
                rl.drawTexture(
                    config.player2_texture,
                    @as(i32, @intFromFloat(config.player2_start_x)),
                    @as(i32, @intFromFloat(config.player_start_y)),
                    rl.Color.white,
                );

                if (rl.isKeyDown(rl.KeyboardKey.space)) {
                    utils.reset_game(
                        &player1,
                        &player2,
                        &stars,
                        &bg_stars,
                        &float_timer,
                        &int_timer,
                        io,
                        config,
                    );

                    game_state = GameState.running;
                }
            },
            GameState.running => {
                if (debug) print("RUNNING\n", .{});

                audio_manager.running_update(screen_height, player1, player2);

                // ====== CONFIG ======

                first_game = false;
                const dt = rl.getFrameTime();

                // ====== END ======

                // ====== UPDATE ======

                player1.update(dt);
                player2.update(dt);

                if (player1.position_y < 0.0 - player1.height) {
                    audio_manager.play_cross_line_sound();
                    player1.state = PlayerState.cross_finish_line;
                }

                if (player2.position_y < 0.0 - player2.height) {
                    audio_manager.play_cross_line_sound();
                    player2.state = PlayerState.cross_finish_line;
                }

                for (&stars) |*star| {
                    star.update(dt, screen_width);
                    if (star.get_rect().is_colliding(player1.get_rect())) {
                        audio_manager.play_star_shoot_sound();
                        player1.state = PlayerState.dead;
                    }
                    if (star.get_rect().is_colliding(player2.get_rect())) {
                        audio_manager.play_star_shoot_sound();
                        player2.state = PlayerState.dead;
                    }
                }

                for (&bg_stars) |*star| {
                    star.update(dt, screen_height);
                }

                float_timer -= 1.0 * dt;
                int_timer = @as(i32, @intFromFloat(float_timer));

                if (int_timer <= 0) {
                    game_state = GameState.times_up;
                }

                // ====== END ======

                // ====== DRAW ======

                player1.draw();
                player2.draw();

                for (&stars) |*star| {
                    star.draw();
                }

                for (&bg_stars) |*star| {
                    star.draw();
                }

                // Draw Score
                const score_player1_text = rl.textFormat("%d", .{player1.score});
                const score_player2_text = rl.textFormat("%d", .{player2.score});
                rl.drawText(score_player1_text, 20, screen_height - 60, 40, rl.Color.yellow);
                rl.drawText(score_player2_text, screen_width - 40, screen_height - 60, 40, rl.Color.yellow);

                // Draw Timer

                const timer_text = rl.textFormat("%d\n", .{int_timer});
                rl.drawText(timer_text, @as(f32, @floatFromInt(screen_width)) / 2 - 30, screen_height - 80, 60, rl.Color.white);

                // ====== END ======
            },
            GameState.times_up => {
                if (debug) print("TIMES_UP\n", .{});
                // Play Animation ?
                // Play Sound ?
                // Create Particles ?

                game_state = GameState.menu;
            },
        }

        // ========= END ==========
    }
}
