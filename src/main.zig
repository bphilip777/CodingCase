const std = @import("std");

// Very poorly coded
// other way to solve this problem is too split words based on the case, recombine words based on case,
// no need to actually split word but just record start/end or just ends of splits
// then call split case, form case = less combinations -> 6^2 + 6 fns becomes 3*6 fns, still x2 for allo, buf
pub const CaseErrors = error{
    IncorrectCase,
    OutputMemoryTooSmall,
};

pub fn isCase(text: []const u8, case: Case) bool {
    return switch (case) {
        .snake => isSnakeCase(text),
        .screaming_snake => isScreamingSnakeCase(text),
        .kebab => isKebabCase(text),
        .screaming_kebab => isScreamingKebabCase(text),
        .pascal => isPascalCase(text),
        .camel => isCamelCase(text),
    };
}

fn isScreamingSnakeCase(text: []const u8) bool {
    if (text.len == 0) return false;
    for (text) |ch| {
        switch (ch) {
            '_', 'A'...'Z', '0'...'9' => continue,
            else => return false,
        }
    } else return true;
}

fn isSnakeCase(text: []const u8) bool {
    if (text.len == 0) return false;
    for (text) |ch| {
        switch (ch) {
            '_', 'a'...'z', '0'...'9' => continue,
            else => return false,
        }
    } else return true;
}

fn isScreamingKebabCase(text: []const u8) bool {
    if (text.len == 0) return false;
    for (text) |ch| {
        switch (ch) {
            '-', 'A'...'Z', '0'...'9' => continue,
            else => return false,
        }
    } else return true;
}

fn isKebabCase(text: []const u8) bool {
    if (text.len == 0) return false;
    for (text) |ch| {
        switch (ch) {
            '-', 'a'...'z', '0'...'9' => continue,
            else => return false,
        }
    } else return true;
}

pub fn isPascalCase(text: []const u8) bool {
    if (text.len == 0) return false;
    if (!std.ascii.isUpper(text[0])) return false;
    if (text.len == 1) return true;
    for (text[1..text.len]) |ch| {
        switch (ch) {
            'a'...'z', 'A'...'Z', '0'...'9' => continue,
            else => return false,
        }
    } else return true;
}

fn isCamelCase(text: []const u8) bool {
    if (text.len == 0) return false;
    if (!std.ascii.isLower(text[0])) return false;
    if (text.len == 1) return true;
    for (text[1..text.len]) |ch| {
        switch (ch) {
            'a'...'z', 'A'...'Z', '0'...'9' => continue,
            else => return false,
        }
    } else return true;
}

fn screamingSnakeCaseFromSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isSnakeCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '_') '_' else std.ascii.toUpper(ch);
        i += 1;
    }
    return output[0..i];
}

fn kebabCaseFromSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isSnakeCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '_') '-' else ch;
        i += 1;
    }
    return output[0..i];
}

fn screamingKebabCaseFromSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isSnakeCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '_') '-' else std.ascii.toUpper(ch);
        i += 1;
    }
    return output[0..i];
}

fn pascalCaseFromSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isSnakeCase(text)) return CaseErrors.IncorrectCase;
    const n: u16 = @truncate(std.mem.count(u8, text, "_"));
    if (output.len < text.len - n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '_') continue;
        output[i] = if (ch1 == '_') std.ascii.toUpper(ch2) else ch2;
        i += 1;
    }
    return output[0..i];
}

fn camelCaseFromSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isSnakeCase(text)) return CaseErrors.IncorrectCase;
    const n: u16 = @truncate(std.mem.count(u8, text, "_"));
    if (output.len < text.len - n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = text[0];
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '_') continue;
        output[i] = if (ch1 == '_') std.ascii.toUpper(ch2) else ch2;
        i += 1;
    }
    return output[0..i];
}

fn snakeCaseFromScreamingSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingSnakeCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '_') '_' else std.ascii.toLower(ch);
        i += 1;
    }
    return output[0..i];
}

fn screamingKebabCaseFromScreamingSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingSnakeCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '_') '-' else ch;
        i += 1;
    }
    return output[0..i];
}

fn kebabCaseFromScreamingSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingSnakeCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '_') '-' else std.ascii.toLower(ch);
        i += 1;
    }
    return output[0..i];
}

fn pascalCaseFromScreamingSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingSnakeCase(text)) return CaseErrors.IncorrectCase;
    const n: u16 = @truncate(std.mem.count(u8, text, "_"));
    if (output.len < text.len - n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = text[0];
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '_') continue;
        output[i] = if (ch1 == '_') ch2 else std.ascii.toLower(ch2);
        i += 1;
    }
    return output[0..i];
}

fn camelCaseFromScreamingSnakeCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingSnakeCase(text)) return CaseErrors.IncorrectCase;
    const n: u16 = @truncate(std.mem.count(u8, text, "_"));
    if (output.len < text.len - n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toLower(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '_') continue;
        output[i] = if (ch1 == '_') ch2 else std.ascii.toLower(ch2);
        i += 1;
    }
    return output[0..i];
}

fn snakeCaseFromKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '-') '_' else ch;
        i += 1;
    }
    return output[0..i];
}

fn screamingSnakeCaseFromKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '-') '_' else std.ascii.toUpper(ch);
        i += 1;
    }
    return output[0..i];
}

fn screamingKebabCaseFromKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = if (ch == '-') '-' else std.ascii.toUpper(ch);
        i += 1;
    }
    return output[0..i];
}

fn pascalCaseFromKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '-') continue;
        output[i] = if (ch1 == '-') std.ascii.toUpper(ch2) else ch2;
        i += 1;
    }
    return output[0..i];
}

fn camelCaseFromKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '-') continue;
        output[i] = if (ch1 == '-') std.ascii.toUpper(ch2) else ch2;
        i += 1;
    }
    return output[0..i];
}

fn snakeCaseFromScreamingKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toLower(text[0]);
    var i: u16 = 1;
    for (text[1..text.len]) |ch| {
        output[i] = if (ch == '-') '_' else std.ascii.toLower(ch);
        i += 1;
    }

    return output[0..i];
}

fn screamingSnakeCaseFromScreamingKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    for (text, 0..) |ch, i| {
        output[i] = if (ch == '-') '_' else ch;
    }
    return output[0..text.len];
}

fn kebabCaseFromScreamingKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingKebabCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    var i: u16 = 0;
    for (text) |ch| {
        output[i] = std.ascii.toLower(ch);
        i += 1;
    }
    return output[0..i];
}

fn pascalCaseFromScreamingKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingKebabCase(text)) return CaseErrors.IncorrectCase;
    const n: usize = std.mem.count(u8, text, "-");
    if (output.len < text.len - n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = text[0];
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        output[i] = if (ch1 == '-') std.ascii.toUpper(ch2) else std.ascii.toLower(ch2);
        i += 1;
    }
    return output[0..i];
}

fn camelCaseFromScreamingKebabCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isScreamingKebabCase(text)) return CaseErrors.IncorrectCase;
    const n: usize = std.mem.count(u8, text, "-");
    if (output.len < text.len - n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toLower(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        output[i] = if (ch1 == '-') std.ascii.toUpper(ch2) else std.ascii.toLower(ch2);
        i += 1;
    }
    return output[0..i];
}

fn snakeCaseFromPascalCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isPascalCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = @truncate(text.len);
    for (text[1..text.len], text[0 .. text.len - 1]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isUpper(ch1) and std.ascii.isLower(ch2));
    }
    if (n > output.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toLower(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (std.ascii.isUpper(ch2) and std.ascii.isLower(ch1)) {
            output[i] = '_';
            i += 1;
        }
        output[i] = std.ascii.toLower(ch2);
        i += 1;
    }
    return output[0..i];
}

fn screamingSnakeCaseFromPascalCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isPascalCase(text)) return CaseErrors.IncorrectCase;
    // inefficient = todo: use simd
    var n: u16 = @truncate(text.len);
    for (text[1..text.len], text[0 .. text.len - 1]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isUpper(ch1) and std.ascii.isLower(ch2));
    }
    if (n < output.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (std.ascii.isUpper(ch2) and std.ascii.isLower(ch1)) {
            output[i] = '_';
            i += 1;
        }
        output[i] = std.ascii.toUpper(ch2);
        i += 1;
    }
    return output[0..i];
}

fn kebabCaseFromPascalCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isPascalCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = 0;
    for (text[1 .. text.len - 1], text[2..text.len]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isLower(ch1) and std.ascii.isUpper(ch2));
    }
    if (output.len < text.len + n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '-') continue;
        output[i] = if (ch1 == '-') std.ascii.toUpper(ch2) else ch2;
        i += 1;
    }
    return output[0..i];
}

fn screamingKebabCaseFromPascalCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isPascalCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = 0;
    for (text[1 .. text.len - 1], text[2..text.len]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isLower(ch1) and std.ascii.isUpper(ch2));
    }
    if (output.len < text.len + n) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (ch2 == '-') continue;
        output[i] = if (ch1 == '-') std.ascii.toUpper(ch2) else ch2;
        i += 1;
    }
    return output[0..i];
}

fn camelCaseFromPascalCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isPascalCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toLower(text[0]);
    if (text.len == 1) return output[0..1];
    @memcpy(output[1..text.len], text[1..text.len]);
    return output[0..text.len];
}

fn snakeCaseFromCamelCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    // if (!isCamelCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isLower(ch1) and std.ascii.isUpper(ch2));
    }
    if (n + text.len > output.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = text[0];
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (std.ascii.isLower(ch1) and std.ascii.isUpper(ch2)) {
            output[i] = '_';
            i += 1;
        }
        output[i] = std.ascii.toLower(ch2);
        i += 1;
    }
    return output[0..i];
}

fn screamingSnakeCaseFromCamelCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isCamelCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isLower(ch1) and std.ascii.isUpper(ch2));
    }
    if (n + text.len > output.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toUpper(text[0]);
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (std.ascii.isLower(ch1) and std.ascii.isUpper(ch2)) {
            output[i] = '_';
            i += 1;
        }
        output[i] = std.ascii.toUpper(ch2);
        i += 1;
    }
    return output[0..i];
}

fn kebabCaseFromCamelCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isCamelCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isLower(ch1) and std.ascii.isUpper(ch2));
    }
    if (n + text.len > output.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = text[0];
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (std.ascii.isLower(ch1) and std.ascii.isUpper(ch2)) {
            output[i] = '-';
            i += 1;
        }
        output[i] = ch2;
        i += 1;
    }
    return output[0..i];
}

fn screamingKebabCaseFromCamelCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isCamelCase(text)) return CaseErrors.IncorrectCase;
    var n: u16 = 0;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        n += @intFromBool(std.ascii.isLower(ch1) and std.ascii.isUpper(ch2));
    }
    if (n + text.len > output.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = text[0];
    if (text.len == 1) return output[0..1];
    var i: u16 = 1;
    for (text[0 .. text.len - 1], text[1..text.len]) |ch1, ch2| {
        if (std.ascii.isLower(ch1) and std.ascii.isUpper(ch2)) {
            output[i] = '-';
            i += 1;
        }
        output[i] = std.ascii.toUpper(ch2);
        i += 1;
    }
    return output[0..i];
}

fn pascalCaseFromCamelCase(output: []u8, text: []const u8) CaseErrors![]const u8 {
    if (!isCamelCase(text)) return CaseErrors.IncorrectCase;
    if (output.len < text.len) return CaseErrors.OutputMemoryTooSmall;
    output[0] = std.ascii.toLower(text[0]);
    if (text.len == 1) return output[0..1];
    @memcpy(output[1..text.len], text[1..text.len]);
    return output[0..text.len];
}

pub fn convert(output: []u8, input: []const u8, to: Case, from: Case) CaseErrors![]const u8 {
    // output and input length will never be 0, output will never be smaller than input,
    if (output.len == 0 or input.len == 0) unreachable;
    if (output.len < input.len) unreachable;
    // if same just copy``
    if (@intFromEnum(to) == @intFromEnum(from)) {
        @memcpy(output[0..input.len], input);
        return output[0..input.len];
    }

    switch (from) {
        .snake => {
            return switch (to) {
                .screaming_snake => try screamingSnakeCaseFromSnakeCase(output, input),
                .kebab => try kebabCaseFromSnakeCase(output, input),
                .screaming_kebab => try screamingKebabCaseFromSnakeCase(output, input),
                .pascal => try pascalCaseFromSnakeCase(output, input),
                .camel => try camelCaseFromSnakeCase(output, input),
                else => unreachable,
            };
        },
        .screaming_snake => {
            return switch (to) {
                .snake => try snakeCaseFromScreamingSnakeCase(output, input),
                .kebab => try kebabCaseFromScreamingSnakeCase(output, input),
                .screaming_kebab => try screamingKebabCaseFromScreamingSnakeCase(output, input),
                .pascal => try pascalCaseFromScreamingSnakeCase(output, input),
                .camel => try camelCaseFromScreamingSnakeCase(output, input),
                else => unreachable,
            };
        },
        .kebab => {
            return switch (to) {
                .snake => try snakeCaseFromKebabCase(output, input),
                .screaming_snake => try screamingSnakeCaseFromKebabCase(output, input),
                .screaming_kebab => try screamingKebabCaseFromKebabCase(output, input),
                .pascal => try pascalCaseFromKebabCase(output, input),
                .camel => try camelCaseFromKebabCase(output, input),
                else => unreachable,
            };
        },
        .screaming_kebab => {
            return switch (to) {
                .snake => try snakeCaseFromScreamingKebabCase(output, input),
                .screaming_snake => try screamingSnakeCaseFromScreamingKebabCase(output, input),
                .kebab => try kebabCaseFromScreamingKebabCase(output, input),
                .pascal => try pascalCaseFromScreamingKebabCase(output, input),
                .camel => try camelCaseFromScreamingKebabCase(output, input),
                else => unreachable,
            };
        },
        .pascal => {
            return switch (to) {
                .snake => try snakeCaseFromPascalCase(output, input),
                .screaming_snake => try screamingSnakeCaseFromPascalCase(output, input),
                .kebab => try kebabCaseFromPascalCase(output, input),
                .screaming_kebab => try screamingKebabCaseFromPascalCase(output, input),
                .camel => try camelCaseFromPascalCase(output, input),
                else => unreachable,
            };
        },
        .camel => {
            return switch (to) {
                .snake => try snakeCaseFromCamelCase(output, input),
                .screaming_snake => try screamingSnakeCaseFromCamelCase(output, input),
                .kebab => try kebabCaseFromCamelCase(output, input),
                .screaming_kebab => try screamingKebabCaseFromCamelCase(output, input),
                .pascal => try pascalCaseFromCamelCase(output, input),
                else => unreachable,
            };
        },
    }
}

pub const Case = enum(u8) {
    snake,
    screaming_snake,
    kebab,
    screaming_kebab,
    pascal,
    camel,
};

pub fn convertSubtextCase(
    input: []const u8,
    output: []u8,
    start: u16,
    end: u16,
    from: Case,
    to: Case,
) ![]const u8 {
    // unreachables
    if (input.len == 0 or output.len == 0) unreachable;
    if (output.len < input.len) unreachable;
    if (start >= end) unreachable;
    // match
    var conv: []const u8 = undefined;
    if (from == to) {
        @memcpy(output[0 .. end - start], input[start..end]);
        conv = output[0 .. end - start];
    } else {
        conv = try convert(output, input[start..end], to, from);
    }
    return conv;
}

pub fn splitCase2Words(
    allo: std.mem.Allocator,
    sentence: []const u8,
    case: Case,
) !std.ArrayList([]const u8) {
    // check sentence
    switch (case) {
        .snake => if (!isSnakeCase(sentence)) return error.IncorrectCase,
        .screaming_snake => if (!isScreamingSnakeCase(sentence)) return error.IncorrectCase,
        .kebab => if (!isKebabCase(sentence)) return error.IncorrectCase,
        .screaming_kebab => if (!isScreamingKebabCase(sentence)) return error.IncorrectCase,
        .camel => if (!isCamelCase(sentence)) return error.IncorrectCase,
        .pascal => if (!isPascalCase(sentence)) return error.IncorrectCase,
    }
    // split into words
    const words = switch (case) {
        .snake, .screaming_snake => try splitWordsByDelimiter(allo, sentence, '_'),
        .kebab, .screaming_kebab => try splitWordsByDelimiter(allo, sentence, '-'),
        .camel, .pascal => try splitWordsByUpperCase(allo, sentence),
    };
    // return words
    return words;
}

fn splitWordsByDelimiter(
    allo: std.mem.Allocator,
    sentence: []const u8,
    delimiter: u8,
) !std.ArrayList([]const u8) {
    // check sentence
    if (!isCase(sentence, .snake)) return error.IncorrectCase;
    // mem
    var words = try std.ArrayList([]const u8).initCapacity(allo, 128);
    // split sentence
    var start: usize = 0;
    var end: usize = 0;
    while (true) {
        // update end
        end = std.mem.indexOfScalar(u8, sentence[start..sentence.len], delimiter) orelse break;
        end += start;
        // get + append word
        const word = sentence[start..end];
        try words.append(word);
        // update start
        start = end + 1;
    }
    // get last word
    if (start != sentence.len) {
        const word = sentence[start..sentence.len];
        try words.append(word);
    }
    // return words
    return words;
}

fn splitWordsByUpperCase(
    allo: std.mem.Allocator,
    sentence: []const u8,
) !std.ArrayList([]const u8) {
    // check sentence
    if (!isCase(sentence, .snake)) return error.IncorrectCase;
    // mem
    var words = try std.ArrayList([]const u8).initCapacity(allo, 128);
    // split sentence
    var start: usize = 0;
    var end: usize = 0;
    while (true) {
        // update end
        for (
            sentence[start .. sentence.len - 1],
            sentence[start + 1 .. sentence.len],
            0..sentence.len - 1,
        ) |ch1, ch2, i| {
            if (std.ascii.isLower(ch1) and std.ascii.isUpper(ch2)) {
                end = i + start;
                break;
            }
        }
        // get + append word
        const word = sentence[start..end];
        try words.append(word);
        // update start
        start = end + 1;
    }
    // get last word
    if (start != sentence.len) {
        const word = sentence[start..sentence.len];
        try words.append(word);
    }
    // return words
    return words;
}
