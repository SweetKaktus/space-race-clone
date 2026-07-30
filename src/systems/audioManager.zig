const rl = @import("raylib");
const print = @import("std").debug.print;
const Player = @import("../entities/player.zig").Player;

pub const AudioManager = struct {
    menuMusic: rl.Music,
    gameMusic: rl.Music,
    player1EngineSound: rl.Music,
    player1EnginePan: f32,
    player1EngineVolume: f32,
    player1EnginePitch: f32,
    player2EngineSound: rl.Music,
    player2EnginePan: f32,
    player2EngineVolume: f32,
    player2EnginePitch: f32,
    starShootSound: rl.Sound,
    crossLineSound: rl.Sound,

    pub fn init(
        screenHeight: i32,
        playerStartY: f32,
    ) !@This() {
        const menuMusic = try rl.loadMusicStream("assets/music/menu.wav");
        rl.setMusicVolume(menuMusic, 0.8);
        const gameMusic = try rl.loadMusicStream("assets/music/game.wav");
        rl.setMusicVolume(gameMusic, 0.6);

        const player1EngineSound = try rl.loadMusicStream("assets/sfx/engine-looping_1.wav");

        const player1EnginePan: f32 = -1.0;
        rl.setMusicPan(player1EngineSound, player1EnginePan);

        // Formule : ((screenHeigh - position_y) * 100) / screenHeight
        const player1EngineVolume: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);
        rl.setMusicVolume(player1EngineSound, player1EngineVolume);

        const player1EnginePitch: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight))) + 0.5;
        rl.setMusicPitch(player1EngineSound, player1EnginePitch);

        const player2EngineSound = try rl.loadMusicStream("assets/sfx/engine-looping_1.wav");
        const player2EnginePan: f32 = 1.0;
        rl.setMusicPan(player2EngineSound, player2EnginePan);
        const player2EngineVolume: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);
        rl.setMusicVolume(player2EngineSound, player2EngineVolume);
        const player2EnginePitch: f32 = (@as(f32, @floatFromInt(screenHeight)) - playerStartY) / (@as(f32, @floatFromInt(screenHeight))) + 0.5;
        rl.setMusicPitch(player2EngineSound, player2EnginePitch);

        const starShootSound = try rl.loadSound("assets/sfx/shoot-small_6.wav");
        rl.setSoundVolume(starShootSound, 0.8);

        const crossLineSound = try rl.loadSound("assets/sfx/misc_3.wav");
        rl.setSoundVolume(crossLineSound, 0.8);

        return .{
            .menuMusic = menuMusic,
            .gameMusic = gameMusic,
            .player1EngineSound = player1EngineSound,
            .player1EnginePan = player1EnginePan,
            .player1EngineVolume = player1EngineVolume,
            .player1EnginePitch = player1EnginePitch,
            .player2EngineSound = player2EngineSound,
            .player2EnginePan = player2EnginePan,
            .player2EngineVolume = player2EngineVolume,
            .player2EnginePitch = player2EnginePitch,
            .starShootSound = starShootSound,
            .crossLineSound = crossLineSound,
        };
    }

    pub fn unloadAll(self: *@This()) void {
        self.menuMusic.unload();
        self.gameMusic.unload();
        self.player1EngineSound.unload();
        self.player2EngineSound.unload();
        self.starShootSound.unload();
        self.crossLineSound.unload();
    }

    pub fn menuUpdate(self: *@This(), debug: bool) void {
        if (rl.isMusicStreamPlaying(self.gameMusic)) rl.stopMusicStream(self.gameMusic);
        if (rl.isMusicStreamPlaying(self.player1EngineSound)) rl.stopMusicStream(self.player1EngineSound);
        if (rl.isMusicStreamPlaying(self.player2EngineSound)) rl.stopMusicStream(self.player2EngineSound);

        if (!rl.isMusicStreamPlaying(self.menuMusic)) {
            rl.playMusicStream(self.menuMusic);
        }

        rl.updateMusicStream(self.menuMusic);

        if (debug) {
            if (rl.isMusicStreamPlaying(self.menuMusic)) print("MENU MUSIC PLAYING\n", .{});
        }
    }

    pub fn runningUpdate(self: *@This(), screenHeight: i32, player1: Player, player2: Player) void {
        // Stop Menu Music
        if (rl.isMusicStreamPlaying(self.menuMusic)) rl.stopMusicStream(self.menuMusic);

        // Start Game Music
        if (!rl.isMusicStreamPlaying(self.gameMusic)) {
            rl.playMusicStream(self.gameMusic);
        }

        // Manage engine sounds
        if (!rl.isMusicStreamPlaying(self.player1EngineSound)) {
            rl.playMusicStream(self.player1EngineSound);
        }

        if (!rl.isMusicStreamPlaying(self.player2EngineSound)) {
            rl.playMusicStream(self.player2EngineSound);
        }

        self.player1EngineVolume = (@as(f32, @floatFromInt(screenHeight)) - player1.position_y) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);
        self.player2EngineVolume = (@as(f32, @floatFromInt(screenHeight)) - player2.position_y) / (@as(f32, @floatFromInt(screenHeight)) * 0.5);

        self.player1EnginePitch = (@as(f32, @floatFromInt(screenHeight)) - player1.position_y) / (@as(f32, @floatFromInt(screenHeight))) + 0.7;
        self.player2EnginePitch = (@as(f32, @floatFromInt(screenHeight)) - player2.position_y) / (@as(f32, @floatFromInt(screenHeight))) + 0.7;

        if (self.player1EngineVolume > 0.5) {
            self.player1EngineVolume = 0.5;
        }

        if (self.player2EngineVolume > 0.5) {
            self.player2EngineVolume = 0.5;
        }

        rl.setMusicVolume(self.player1EngineSound, self.player1EngineVolume);
        rl.setMusicVolume(self.player2EngineSound, self.player2EngineVolume);

        rl.setMusicPitch(self.player1EngineSound, self.player1EnginePitch);
        rl.setMusicPitch(self.player2EngineSound, self.player2EnginePitch);

        rl.updateMusicStream(self.gameMusic);
        rl.updateMusicStream(self.player1EngineSound);
        rl.updateMusicStream(self.player2EngineSound);
    }

    pub fn playCrossLineSound(self: *@This()) void {
        rl.playSound(self.crossLineSound);
    }

    pub fn playStarShootSound(self: *@This()) void {
        rl.playSound(self.starShootSound);
    }
};
