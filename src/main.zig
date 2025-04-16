const std = @import("std");

pub const CaseErrors = error{
    IncorrectCase,
    OutputMemoryTooSmall,
    InputDoesNotMatchAnyCase,
};

pub fn whichCase(text: []const u8) CaseErrors!Case {
    for (comptime std.meta.fieldNames(Case)) |name| {
        const case = std.meta.stringToEnum(Case, name);
        if (isCase(text, case)) return case;
    } else return CaseErrors.InputDoesNotMatchAnyCase;
}

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
    if (!std.ascii.isUpper(text[0])) return false;
    var has_snake: bool = false;
    for (text) |ch| {
        switch (ch) {
            '_' => {
                has_snake = true;
                continue;
            },
            'A'...'Z', '0'...'9' => continue,
            else => return false,
        }
    }
    return has_snake and text[text.len -% 1] != '_';
}

fn isSnakeCase(text: []const u8) bool {
    if (text.len == 0) return false;
    if (!std.ascii.isLower(text[0])) return false;
    var has_snake: bool = false;
    for (text) |ch| {
        switch (ch) {
            '_' => {
                has_snake = true;
                continue;
            },
            'a'...'z', '0'...'9' => continue,
            else => return false,
        }
    }
    return has_snake and text[text.len -% 1] != '_';
}

fn isScreamingKebabCase(text: []const u8) bool {
    if (text.len == 0) return false;
    if (!std.ascii.isUpper(text[0])) return false;
    var has_kebabs: bool = false;
    for (text) |ch| {
        switch (ch) {
            '-' => {
                has_kebabs = true;
                continue;
            },
            'A'...'Z', '0'...'9' => continue,
            else => return false,
        }
    }
    return has_kebabs and text[text.len -% 1] != '-';
}

fn isKebabCase(text: []const u8) bool {
    if (text.len == 0) return false;
    if (!std.ascii.isLower(text[0])) return false;
    var has_kebabs: bool = false;
    for (text) |ch| {
        switch (ch) {
            '-' => {
                has_kebabs = true;
                continue;
            },
            'a'...'z', '0'...'9' => continue,
            else => return false,
        }
    }
    return has_kebabs and text[text.len -% 1] != '-';
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

fn split2Words(allo: std.mem.Allocator, input: []const u8) !std.ArrayList([]const u8) {
    const input_case = try whichCase(input);
    var words = std.ArrayList([]const u8).init(allo);
    switch (input_case) {
        .camel, .pascal => {
            var start: u32 = 0;
            var end: u32 = 0;
            for (input[0 .. input.len - 1], input[1..input.len], 0..) |ch1, ch2, i| {
                if ((std.ascii.isLower(ch1) or std.ascii.isDigit(ch1)) and std.ascii.isUpper(ch2)) {
                    end = @truncate(i +% 1);
                    const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                    try words.append(new_word);
                    start = end;
                }
            } else {
                end = input.len;
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
            }
        },
        .kebab, .screaming_kebab => {
            var start: u32 = 0;
            var end: u32 = 0;
            for (input, 0..) |ch, i| {
                if (ch != '-') continue;
                end = @truncate(i);
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
                start = end +% 1;
            } else {
                end = input.len;
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
            }
        },
        .snake, .screaming_snake => {},
        else => {
            var start: u32 = 0;
            var end: u32 = 0;
            for (input, 0..) |ch, i| {
                if (ch != '_') continue;
                end = @truncate(i);
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
                start = end +% 1;
            } else {
                end = input.len;
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
            }
        },
    }
    return words;
}

pub fn convert(allo: std.mem.Allocator, input: []const u8, to: Case) ![]u8 {
    if (input.len == 0) unreachable;
    const input_case = try whichCase(input);
    if (@intFromEnum(input_case) == @intFromEnum(to)) return try allo.dupe(u8, input);
    const words = try split2Words(allo, input);
    defer words.deinit();
    defer for (words.items) |word| allo.free(word);
    const new_word = try switch (input_case) {
        .snake => words2Snake(allo, words),
        .screaming_snake => words2ScreamingSnake(allo, words),
        .kebab => words2Kebab(allo, words),
        .screaming_kebab => words2ScreamingKebab(allo, words),
        .pascal => words2Pascal(allo, words),
        .camel => words2Camel(allo, words),
    };
    return new_word;
}

fn words2Snake(allo: std.mem.Allocator, words: std.ArrayList([]u8)) ![]u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items) |word| n_letters +%= word.len +% 1;
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items) |word| {
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx +% word.len +% 1] = '_';
        idx +%= word.len +% 1;
    }
    return new_word;
}

fn words2ScreamingSnake(allo: std.mem.Allocator, words: std.ArrayList([]u8)) ![]u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items) |word| n_letters +%= word.len +% 1;
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items) |word| {
        var i: usize = 0;
        while (i < word.len) : (i +%= 1) {
            word[i] = std.ascii.toUpper(word[i]);
        }
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx +% word.len +% 1] = '_';
        idx +%= word.len +% 1;
    }
    return new_word;
}

fn words2Kebab(allo: std.mem.Allocator, words: std.ArrayList([]u8)) ![]u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items) |word| n_letters +%= word.len +% 1;
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items) |word| {
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx +% word.len +% 1] = '-';
        idx +%= word.len +% 1;
    }
    return new_word;
}

fn words2ScreamingKebab(allo: std.mem.Allocator, words: std.ArrayList([]u8)) ![]u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items) |word| n_letters +%= word.len +% 1;
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items) |word| {
        var i: usize = 0;
        while (i < word.len) : (i +%= 1) {
            word[i] = std.ascii.toUpper(word[i]);
        }
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx +% word.len +% 1] = '-';
        idx +%= word.len +% 1;
    }
    return new_word;
}

fn words2Pascal(allo: std.mem.Allocator, words: std.ArrayList([]u8)) ![]u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items) |word| n_letters +%= word.len;
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items) |word| {
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx] = std.ascii.toUpper(new_word[idx]);
        idx +%= word.len;
    }
    return new_word;
}

fn words2Camel(allo: std.mem.Allocator, words: std.ArrayList([]u8)) ![]u8 {
    var n_letters: usize = 0;
    for (words.items) |word| n_letters +%= word.len;
    var new_word = try allo.alloc(u8, n_letters);
    @memcpy(new_word[0..words.items[0].len], words.items[0]);
    var idx: usize = words.items[0].len;
    for (words.items[1..words.items.len]) |word| {
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx] = std.ascii.toUpper(new_word[idx]);
        idx +%= word.len;
    }
    return new_word;
}

pub const Case = enum(u8) {
    snake,
    screaming_snake,
    kebab,
    screaming_kebab,
    pascal,
    camel,
};
