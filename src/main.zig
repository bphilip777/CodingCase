const std = @import("std");

pub const CaseErrors = error{
    IncorrectCase,
    OutputMemoryTooSmall,
    InputDoesNotMatchAnyCase,
};

pub fn whichCase(text: []const u8) CaseErrors!Case {
    for (comptime std.meta.fieldNames(Case)) |name| {
        const case = std.meta.stringToEnum(Case, name).?;
        if (isCase(text, case)) return case;
    } else return CaseErrors.InputDoesNotMatchAnyCase;
}

pub fn isCase(text: []const u8, case: Case) bool {
    return switch (case) {
        .snake => isSnake(text),
        .screaming_snake => isScreamingSnake(text),
        .kebab => isKebab(text),
        .screaming_kebab => isScreamingKebab(text),
        .pascal => isPascal(text),
        .camel => isCamel(text),
    };
}

fn isScreamingSnake(text: []const u8) bool {
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

fn isSnake(text: []const u8) bool {
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

fn isScreamingKebab(text: []const u8) bool {
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

fn isKebab(text: []const u8) bool {
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

pub fn isPascal(text: []const u8) bool {
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

fn isCamel(text: []const u8) bool {
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

pub fn split2Words(allo: std.mem.Allocator, input: []const u8) !std.ArrayList([]const u8) {
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
                end = @truncate(input.len);
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
                end = @truncate(input.len);
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
            }
        },
        .snake, .screaming_snake => {
            var start: u32 = 0;
            var end: u32 = 0;
            for (input, 0..) |ch, i| {
                if (ch != '_') continue;
                end = @truncate(i);
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
                start = end +% 1;
            } else {
                end = @truncate(input.len);
                const new_word = try std.ascii.allocLowerString(allo, input[start..end]);
                try words.append(new_word);
            }
        },
    }
    return words;
}

pub fn convert(allo: std.mem.Allocator, input: []const u8, to: Case) ![]const u8 {
    if (input.len == 0) unreachable;
    const input_case = try whichCase(input);
    if (@intFromEnum(input_case) == @intFromEnum(to)) return try allo.dupe(u8, input);
    const words = try split2Words(allo, input);
    defer words.deinit();
    defer for (words.items) |word| allo.free(word);
    const new_word = try switch (to) {
        .snake => words2Snake(allo, words),
        .screaming_snake => words2ScreamingSnake(allo, words),
        .kebab => words2Kebab(allo, words),
        .screaming_kebab => words2ScreamingKebab(allo, words),
        .pascal => words2Pascal(allo, words),
        .camel => words2Camel(allo, words),
    };
    return new_word;
}

pub fn words2Snake(allo: std.mem.Allocator, words: std.ArrayList([]const u8)) ![]const u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        n_letters +%= word.len +% 1;
    } else {
        n_letters +%= words.items[words.items.len -% 1].len;
    }
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx +% word.len] = '_';
        idx +%= word.len +% 1;
    } else {
        const word = words.items[words.items.len -% 1];
        @memcpy(new_word[idx .. idx +% word.len], word);
    }
    return new_word;
}

pub fn words2ScreamingSnake(allo: std.mem.Allocator, words: std.ArrayList([]const u8)) ![]const u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        n_letters +%= word.len +% 1;
    } else {
        n_letters +%= words.items[words.items.len -% 1].len;
    }
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        for (word, 0..) |ch, i| {
            new_word[idx +% i] = std.ascii.toUpper(ch);
        }
        new_word[idx +% word.len] = '_';
        idx +%= word.len +% 1;
    } else {
        const word = words.items[words.items.len - 1];
        for (word, 0..) |ch, i| {
            new_word[idx +% i] = std.ascii.toUpper(ch);
        }
    }
    return new_word;
}

pub fn words2Kebab(allo: std.mem.Allocator, words: std.ArrayList([]const u8)) ![]const u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        n_letters +%= word.len +% 1;
    } else {
        n_letters +%= words.items[words.items.len -% 1].len;
    }
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        @memcpy(new_word[idx .. idx +% word.len], word);
        new_word[idx +% word.len] = '-';
        idx +%= word.len +% 1;
    } else {
        const word = words.items[words.items.len -% 1];
        @memcpy(new_word[idx .. idx +% word.len], word);
    }
    return new_word;
}

pub fn words2ScreamingKebab(allo: std.mem.Allocator, words: std.ArrayList([]const u8)) ![]const u8 {
    if (words.items.len == 0) unreachable;
    var n_letters: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        n_letters +%= word.len +% 1;
    } else {
        n_letters +%= words.items[words.items.len -% 1].len;
    }
    var new_word = try allo.alloc(u8, n_letters);
    var idx: usize = 0;
    for (words.items[0 .. words.items.len -% 1]) |word| {
        for (word, 0..) |ch, i| {
            new_word[idx +% i] = std.ascii.toUpper(ch);
        }
        new_word[idx +% word.len] = '-';
        idx +%= word.len +% 1;
    } else {
        const word = words.items[words.items.len -% 1];
        for (word, 0..) |ch, i| {
            new_word[idx +% i] = std.ascii.toUpper(ch);
        }
    }
    return new_word;
}

pub fn words2Pascal(allo: std.mem.Allocator, words: std.ArrayList([]const u8)) ![]const u8 {
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

pub fn words2Camel(allo: std.mem.Allocator, words: std.ArrayList([]const u8)) ![]const u8 {
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

test "Which Case" {
    const base_inputs = [_][]const u8{ "helloWorld", "HelloWorld", "hello-world", "HELLO-WORLD", "hello_world", "HELLO_WORLD" };
    const expected_cases = [_]Case{ .camel, .pascal, .kebab, .screaming_kebab, .snake, .screaming_snake };
    for (base_inputs, expected_cases) |base_input, expected_case| {
        const actual_case = try whichCase(base_input);
        try std.testing.expectEqual(actual_case, expected_case);
    }
}

test "Is Case" {
    const base_inputs = [_][]const u8{ "helloWorld", "HelloWorld", "hello-world", "HELLO-WORLD", "hello_world", "HELLO_WORLD" };
    const base_inputs2 = [_][]const u8{ "hello2World", "Hello2World", "hello-2-world", "HELLO-2-WORLD", "hello_2_world", "HELLO_2_WORLD" };
    const expected_comparisons = [_]Case{ .camel, .pascal, .kebab, .screaming_kebab, .snake, .screaming_snake };
    for (base_inputs, base_inputs2, expected_comparisons) |bi, bi2, expected_case| {
        try std.testing.expect(isCase(bi, expected_case));
        try std.testing.expect(isCase(bi2, expected_case));
    }
}

test "Split 2 Words" {
    const expected_words = [_][]const u8{ "hello", "world" };

    const allo = std.testing.allocator;
    const base_inputs = [_][]const u8{ "helloWorld", "HelloWorld", "hello-world", "HELLO-WORLD", "hello_world", "HELLO_WORLD" };
    for (base_inputs) |base_input| {
        const words = try split2Words(allo, base_input);
        defer words.deinit();
        defer for (words.items) |word| allo.free(word);

        for (words.items, expected_words) |word, expected_word| {
            try std.testing.expectEqualStrings(word, expected_word);
        }
    }
}

test "Convert" {
    const allo = std.testing.allocator;
    const base_input = "HelloWorld";
    const expected_cases = [_]Case{ .camel, .pascal, .screaming_kebab, .kebab, .screaming_snake, .snake };
    const expected_outputs = [_][]const u8{ "helloWorld", "HelloWorld", "HELLO-WORLD", "hello-world", "HELLO_WORLD", "hello_world" };

    for (expected_cases, expected_outputs) |expected_case, expected_output| {
        const new_input = try convert(allo, base_input, expected_case);
        defer allo.free(new_input);
        try std.testing.expectEqualStrings(new_input, expected_output);
    }
}
