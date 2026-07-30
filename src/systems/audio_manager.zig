const rl = @import("raylib");
const print = @import("std").debug.print;
const Player = @import("../entities/player.zig").Player;

pub const AudioManager = struct {
    menu_music: rl.Music,
    game_music: rl.Music,
    player1_engine_sound: rl.Music,
    player1_engine_pan: f32,
    player1_engine_volume: f32,
    player1_engine_pitch: f32,
    player2_engine_sound: rl.Music,
    player2_engine_pan: f32,
    player2_engine_volume: f32,
    player2_engine_pitch: f32,
    star_shoot_sound: rl.Sound,
    cross_line_sound: rl.Sound,

    pub fn init(
        screen_height: i32,
        player_start_y: f32,
    ) !@This() {
        const menu_music = try rl.loadMusicStream("assets/music/menu.wav");
        rl.setMusicVolume(menu_music, 0.8);
        const game_music = try rl.loadMusicStream("assets/music/game.wav");
        rl.setMusicVolume(game_music, 0.6);

        const player1_engine_sound = try rl.loadMusicStream("assets/sfx/engine-looping_1.wav");

        const player1_engine_pan: f32 = -1.0;
        rl.setMusicPan(player1_engine_sound, player1_engine_pan);

        // Formule : ((screen_height - position_y) * 100) / screen_height
        const player1_engine_volume: f32 = (@as(f32, @floatFromInt(screen_height)) - player_start_y) / (@as(f32, @floatFromInt(screen_height)) * 0.5);
        rl.setMusicVolume(player1_engine_sound, player1_engine_volume);

        const player1_engine_pitch: f32 = (@as(f32, @floatFromInt(screen_height)) - player_start_y) / (@as(f32, @floatFromInt(screen_height))) + 0.5;
        rl.setMusicPitch(player1_engine_sound, player1_engine_pitch);

        const player2_engine_sound = try rl.loadMusicStream("assets/sfx/engine-looping_1.wav");
        const player2_engine_pan: f32 = 1.0;
        rl.setMusicPan(player2_engine_sound, player2_engine_pan);
        const player2_engine_volume: f32 = (@as(f32, @floatFromInt(screen_height)) - player_start_y) / (@as(f32, @floatFromInt(screen_height)) * 0.5);
        rl.setMusicVolume(player2_engine_sound, player2_engine_volume);
        const player2_engine_pitch: f32 = (@as(f32, @floatFromInt(screen_height)) - player_start_y) / (@as(f32, @floatFromInt(screen_height))) + 0.5;
        rl.setMusicPitch(player2_engine_sound, player2_engine_pitch);

        const star_shoot_sound = try rl.loadSound("assets/sfx/shoot-small_6.wav");
        rl.setSoundVolume(star_shoot_sound, 0.8);

        const cross_line_sound = try rl.loadSound("assets/sfx/misc_3.wav");
        rl.setSoundVolume(cross_line_sound, 0.8);

        return .{
            .menu_music = menu_music,
            .game_music = game_music,
            .player1_engine_sound = player1_engine_sound,
            .player1_engine_pan = player1_engine_pan,
            .player1_engine_volume = player1_engine_volume,
            .player1_engine_pitch = player1_engine_pitch,
            .player2_engine_sound = player2_engine_sound,
            .player2_engine_pan = player2_engine_pan,
            .player2_engine_volume = player2_engine_volume,
            .player2_engine_pitch = player2_engine_pitch,
            .star_shoot_sound = star_shoot_sound,
            .cross_line_sound = cross_line_sound,
        };
    }

    pub fn unload_all(self: *@This()) void {
        self.menu_music.unload();
        self.game_music.unload();
        self.player1_engine_sound.unload();
        self.player2_engine_sound.unload();
        self.star_shoot_sound.unload();
        self.cross_line_sound.unload();
    }

    pub fn menu_update(self: *@This(), debug: bool) void {
        if (rl.isMusicStreamPlaying(self.game_music)) rl.stopMusicStream(self.game_music);
        if (rl.isMusicStreamPlaying(self.player1_engine_sound)) rl.stopMusicStream(self.player1_engine_sound);
        if (rl.isMusicStreamPlaying(self.player2_engine_sound)) rl.stopMusicStream(self.player2_engine_sound);

        if (!rl.isMusicStreamPlaying(self.menu_music)) {
            rl.playMusicStream(self.menu_music);
        }

        rl.updateMusicStream(self.menu_music);

        if (debug) {
            if (rl.isMusicStreamPlaying(self.menu_music)) print("MENU MUSIC PLAYING\n", .{});
        }
    }

    pub fn running_update(self: *@This(), screen_height: i32, player1: Player, player2: Player) void {
        // Stop Menu Music
        if (rl.isMusicStreamPlaying(self.menu_music)) rl.stopMusicStream(self.menu_music);

        // Start Game Music
        if (!rl.isMusicStreamPlaying(self.game_music)) {
            rl.playMusicStream(self.game_music);
        }

        // Manage engine sounds
        if (!rl.isMusicStreamPlaying(self.player1_engine_sound)) {
            rl.playMusicStream(self.player1_engine_sound);
        }

        if (!rl.isMusicStreamPlaying(self.player2_engine_sound)) {
            rl.playMusicStream(self.player2_engine_sound);
        }

        self.player1_engine_volume = (@as(f32, @floatFromInt(screen_height)) - player1.position_y) / (@as(f32, @floatFromInt(screen_height)) * 0.5);
        self.player2_engine_volume = (@as(f32, @floatFromInt(screen_height)) - player2.position_y) / (@as(f32, @floatFromInt(screen_height)) * 0.5);

        self.player1_engine_pitch = (@as(f32, @floatFromInt(screen_height)) - player1.position_y) / (@as(f32, @floatFromInt(screen_height))) + 0.7;
        self.player2_engine_pitch = (@as(f32, @floatFromInt(screen_height)) - player2.position_y) / (@as(f32, @floatFromInt(screen_height))) + 0.7;

        if (self.player1_engine_volume > 0.5) {
            self.player1_engine_volume = 0.5;
        }

        if (self.player2_engine_volume > 0.5) {
            self.player2_engine_volume = 0.5;
        }

        rl.setMusicVolume(self.player1_engine_sound, self.player1_engine_volume);
        rl.setMusicVolume(self.player2_engine_sound, self.player2_engine_volume);

        rl.setMusicPitch(self.player1_engine_sound, self.player1_engine_pitch);
        rl.setMusicPitch(self.player2_engine_sound, self.player2_engine_pitch);

        rl.updateMusicStream(self.game_music);
        rl.updateMusicStream(self.player1_engine_sound);
        rl.updateMusicStream(self.player2_engine_sound);
    }

    pub fn play_cross_line_sound(self: *@This()) void {
        rl.playSound(self.cross_line_sound);
    }

    pub fn play_star_shoot_sound(self: *@This()) void {
        rl.playSound(self.star_shoot_sound);
    }
};
