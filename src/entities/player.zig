const print = @import("std").debug.print;

const rl = @import("raylib");

const PlayerNumber = @import("../enums/player_number.zig").PlayerNumber;
const Rectangle = @import("../components/rectangle.zig").Rectangle;
const PlayerState = @import("../enums/player_state.zig").PlayerState;
const Reactor = @import("reactor.zig").Reactor;

var debug: bool = false;

pub const Player = struct {
    player_number: PlayerNumber,
    start_y: f32,
    bottom_bound_position: f32,
    position_x: f32,
    position_y: f32,
    reactor_position: rl.Vector2,
    width: f32,
    height: f32,
    speed: f32,
    score: i32,
    texture: rl.Texture,
    reactor_anim: Reactor,
    state: PlayerState,

    pub fn init(
        player_number: PlayerNumber,
        position_x: f32,
        start_y: f32,
        bottom_bound_position: f32,
        width: f32,
        height: f32,
        texture: rl.Texture,
        reactor_texture_atlas: rl.Texture,
    ) @This() {
        return .{
            .player_number = player_number,
            .start_y = start_y,
            .bottom_bound_position = bottom_bound_position,
            .position_x = position_x,
            .position_y = start_y,
            .reactor_position = rl.Vector2.init(position_x - width / 2 + width / 2, start_y),
            .width = width,
            .height = height,
            .speed = 100.0,
            .score = 0,
            .texture = texture,
            .reactor_anim = Reactor.init(reactor_texture_atlas, width, 9),
            .state = PlayerState.idle,
        };
    }

    pub fn get_rect(self: @This()) Rectangle {
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
            PlayerState.idle => {
                if (debug) print("IDLE\n", .{});
                // Play animation ?
                self.reactor_anim.update(dt, 0.0, 4.0);
                // Play Sound ?
                // Create Particles ?
            },
            PlayerState.dead => {
                if (debug) print("DEAD\n", .{});
                // Play Animation ?
                // Play Sound ?
                // Create Particles ?
                self.position_y = self.start_y;
                self.state = PlayerState.idle;
            },
            PlayerState.moving_up => {
                if (debug) print("MOVING_UP\n", .{});
                // Play animation
                self.reactor_anim.update(dt, 8.0, self.reactor_anim.get_max_frame());
                // Play Sound ?
                // Create Particles ?
                self.position_y -= self.speed * dt;
            },
            PlayerState.moving_down => {
                if (debug) print("MOVING_DOWN\n", .{});
                // Play animation ?
                self.reactor_anim.update(dt, 8.0, self.reactor_anim.get_max_frame());
                // Play Sound ?
                // Create Particles ?
                self.position_y += self.speed * dt;
            },
            PlayerState.cross_finish_line => {
                if (debug) print("CROSS_FINISH_LINE\n", .{});
                // Play animation ?
                // Play Sound ?
                // Create Particles ?
                self.score += 1;
                self.position_y = self.bottom_bound_position;
                self.state = PlayerState.idle;
            },
        }

        if (self.player_number == PlayerNumber.second_player) {
            up = rl.KeyboardKey.up;
            down = rl.KeyboardKey.down;
        }
        if (rl.isKeyDown(up)) {
            self.state = PlayerState.moving_up;
        }

        if (rl.isKeyDown(down)) {
            self.state = PlayerState.moving_down;
        }

        if ((rl.isKeyReleased(up) and !rl.isKeyDown(down)) or (rl.isKeyReleased(down) and !rl.isKeyDown(up))) {
            self.state = PlayerState.idle;
        }

        if (self.position_y > self.bottom_bound_position) {
            self.position_y = self.bottom_bound_position;
        }

        self.reactor_position.y = self.position_y + self.height - 4;
    }

    pub fn draw(self: @This()) void {
        self.reactor_anim.draw(self.reactor_position);
        rl.drawTexture(
            self.texture,
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            rl.Color.white,
        );
    }
};
