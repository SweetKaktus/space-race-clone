const rl = @import("raylib");

pub const GameConfig = struct {
    screen_width: i32,
    screen_height: i32,
    sprite_size: f32,
    player_start_y: f32,
    player_bottom_bound_position: f32,
    player1_start_x: f32,
    player2_start_x: f32,
    player1_texture: rl.Texture,
    player2_texture: rl.Texture,
    reactor_texture_atlas: rl.Texture,
    bound_bottom_star_start_y: i32,
    star_width: f32,
    star_height: f32,
    init_timer: f32,

    pub fn init(
        screen_width: i32,
        screen_height: i32,
        sprite_size: f32,
        player_start_y: f32,
        player_bottom_bound_position: f32,
        player1_start_x: f32,
        player2_start_x: f32,
        player1_texture: rl.Texture,
        player2_texture: rl.Texture,
        reactor_texture_atlas: rl.Texture,
        bound_bottom_star_start_y: i32,
        star_width: f32,
        star_height: f32,
        init_timer: f32,
    ) @This() {
        return .{
            .screen_width = screen_width,
            .screen_height = screen_height,
            .sprite_size = sprite_size,
            .player_start_y = player_start_y,
            .player_bottom_bound_position = player_bottom_bound_position,
            .player1_start_x = player1_start_x,
            .player2_start_x = player2_start_x,
            .player1_texture = player1_texture,
            .player2_texture = player2_texture,
            .reactor_texture_atlas = reactor_texture_atlas,
            .bound_bottom_star_start_y = bound_bottom_star_start_y,
            .star_width = star_width,
            .star_height = star_height,
            .init_timer = init_timer,
        };
    }

    pub fn set_player_texture(self: *@This(), player1_texture: rl.Texture, player2_texture: rl.Texture) void {
        self.player1_texture = player1_texture;
        self.player2_texture = player2_texture;
    }
};
