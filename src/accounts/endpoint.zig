const std = @import("std");
const zap = @import("zap");
const HttpError = @import("../error/types.zig").HttpError;

pub const Self = @This();

// const _sub_routes = std.ComptimeStringMap([]const u8, .{
//     &.{ "/transacoes", "a" },
//     &.{ "/extrato", "b" },
// });

const AccountHandler = (*const fn (account_id: u64, req: zap.Request) void);

const _sub_routes = std.ComptimeStringMap(AccountHandler, .{
    &.{ "/transacoes", &_getTransactions },
    &.{ "/extrato", &_getSummary },
});

_alloc: std.mem.Allocator = undefined,
_endpoint: zap.Endpoint = undefined,

pub fn init(alloc: std.mem.Allocator, path: []const u8) Self {
    return .{
        ._alloc = alloc,
        ._endpoint = zap.Endpoint.init(.{ .path = path, .get = _getAccountsSafe }),
    };
}

pub fn endpoint(self: *Self) *zap.Endpoint {
    return &self._endpoint;
}

fn _getNextPathSegment(path: []const u8) []const u8 {
    var i: u64 = 1;
    while (i < path.len and path[i] != '/') {
        i += 1;
    }

    return path[0..i];
}

fn _accountIdFromPath(path: []const u8) ?u64 {
    if (path.len <= 1) {
        return null;
    }

    const id_str = path[1..];
    const parsed = std.fmt.parseUnsigned(u64, id_str, 10) catch return null;
    return @as(u64, parsed);
}

fn _getTransactions(account_id: u64, _: zap.Request) void {
    std.log.debug("transactions: {d}", .{account_id});
}

fn _getSummary(account_id: u64, _: zap.Request) void {
    std.log.debug("summary: {d}", .{account_id});
}

fn _getAccounts(ep: *zap.Endpoint, req: zap.Request) !void {
    // Obtém "self" com essa macro visto que a função getAccounts tem que ter assinatura sem Self
    // para ser aceita por zap.Endpoint.init
    // const self = @fieldParentPtr(Self, "_endpoint", ep);
    const path = req.path.?[ep.settings.path.len..];

    const id_subpath = _getNextPathSegment(path);
    const action_subpath = _getNextPathSegment(path[id_subpath.len..]);

    if (!_sub_routes.has(action_subpath)) {
        return HttpError.NotFound;
    }

    const id_unsafe = _accountIdFromPath(id_subpath);

    if (id_unsafe) |id| {
        const handler_func: AccountHandler = _sub_routes.get(action_subpath).?;
        handler_func(id, req);
    } else {
        return HttpError.NotFound;
    }
}

// TODO: middleware sem closure
fn _getAccountsSafe(ep: *zap.Endpoint, req: zap.Request) void {
    _getAccounts(ep, req) catch |err| {
        // std.log.err("{s}", .{err});

        if (err == HttpError.NotFound) {
            req.setStatus(zap.StatusCode.not_found);
            req.sendJson("{}") catch return;
        }
    };
}
