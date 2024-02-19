const std = @import("std");
const zap = @import("zap");

const AccountsEndpoint = @import("accounts/endpoint.zig");

fn onRequest(r: zap.Request) void {
    if (r.path) |path| {
        std.debug.print("Req path not found: {s}\n", .{path});
    }

    r.setStatus(zap.StatusCode.not_found);
    r.sendJson("{}") catch return;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    var allocator = gpa.allocator();

    // we scope everything that can allocate within this block for leak detection
    {
        var listener = zap.Endpoint.Listener.init(
            allocator,
            .{
                .on_request = onRequest,
                .port = 8080,
                .log = true,
                .max_clients = 100000,
            },
        );
        defer listener.deinit();

        // /accounts endpoint
        var accounts = AccountsEndpoint.init(allocator, "/accounts");

        try listener.register(accounts.endpoint());

        // listen
        try listener.listen();
        std.debug.print("Listening on 0.0.0.0:8080\n", .{});
        zap.start(.{
            .threads = 8,
            .workers = 8,
        });
    }

    const has_leaked = gpa.detectLeaks();
    std.log.debug("Has leaked: {}\n", .{has_leaked});
}
