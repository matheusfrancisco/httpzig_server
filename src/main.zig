// create a tcp socket object
// bind a name (or more specifically, an address) to this socket object.
// make this socket object to start listening and waiting for incoming connections
// when a connection arrive we accept this connection, and we exchange the http messages(http request and http response)
// then we simplly close the connection
//
const std = @import("std");
const SocketConfg = @import("config.zig");
const Request = @import("request.zig");
const Response = @import("responses.zig");
const stdout = std.io.getStdOut().writer();

//parsing the http request
//the top-level header indicating of the http request, the uri and the http version used in the message
// a list of http headers.
// the body of the http request.

pub fn main() !void {
    const socket = try SocketConfg.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});
    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| buffer[i] = 0;
    try Request.read_request(connection, buffer[0..buffer.len]);
    const r = Request.parse_request(buffer[0..buffer.len]);

    if (r.method == Request.Method.GET) {
        if (std.mem.eql(u8, r.uri, "/")) {
            try stdout.print("Sending 200 OK response\n", .{});
            try Response.send_200(connection);
        } else {
            try stdout.print("Sending 404 Not Found response for URI: {s}\n", .{r.uri});
            try Response.send_404(connection);
        }
    }
    try stdout.print("Received request: {any}\n", .{r});
}
