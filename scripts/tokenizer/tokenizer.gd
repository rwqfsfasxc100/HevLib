# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends Reference
#class_name TOKENIZER

# THIS IS UNFINISHED AND CURRENTLY UNDOCUMENTED

# Translation layer to permit proper autocompletion of the tokenizer implementation
# SCRIPT USAGE: var tokenizer:TOKENIZER = load("res://HevLib/scripts/tokenizer/tokenizer.gd").new()
# See res://HevLib/scripts/tokenizer/README.md for complete usage instructions


# Token types
# Values used by the `type` property from a get_token() entry
enum Token{
	TK_EMPTY = 0, # "Empty"
	TK_IDENTIFIER = 1, # "Identifier"
	TK_CONSTANT = 2, # "Constant"
	TK_SELF = 3, # "self"
	TK_BUILT_IN_TYPE = 4, # "Built-In Type"
	TK_BUILT_IN_FUNC = 5, # "Built-In Func"
	TK_OP_IN = 6, # "in"
	TK_OP_EQUAL = 7, # "=="
	TK_OP_NOT_EQUAL = 8, # "!="
	TK_OP_LESS = 9, # "<"
	TK_OP_LESS_EQUAL = 10, # "<="
	TK_OP_GREATER = 11, # ">"
	TK_OP_GREATER_EQUAL = 12, # ">="
	TK_OP_AND = 13, # "and"
	TK_OP_OR = 14, # "or"
	TK_OP_NOT = 15, # "not"
	TK_OP_ADD = 16, # "+"
	TK_OP_SUB = 17, # "-"
	TK_OP_MUL = 18, # "*"
	TK_OP_DIV = 19, # "/"
	TK_OP_MOD = 20, # "%"
	TK_OP_SHIFT_LEFT = 21, # "<<"
	TK_OP_SHIFT_RIGHT = 22, # ">>"
	TK_OP_ASSIGN = 23, # "="
	TK_OP_ASSIGN_ADD = 24, # "+="
	TK_OP_ASSIGN_SUB = 25, # "-="
	TK_OP_ASSIGN_MUL = 26, # "*="
	TK_OP_ASSIGN_DIV = 27, # "/="
	TK_OP_ASSIGN_MOD = 28, # "%="
	TK_OP_ASSIGN_SHIFT_LEFT = 29, # "<<="
	TK_OP_ASSIGN_SHIFT_RIGHT = 30, # ">>="
	TK_OP_ASSIGN_BIT_AND = 31, # "&="
	TK_OP_ASSIGN_BIT_OR = 32, # "|="
	TK_OP_ASSIGN_BIT_XOR = 33, # "^="
	TK_OP_BIT_AND = 34, # "&"
	TK_OP_BIT_OR = 35, # "|"
	TK_OP_BIT_XOR = 36, # "^"
	TK_OP_BIT_INVERT = 37, # "~"
	TK_CF_IF = 38, # "if"
	TK_CF_ELIF = 39, # "elif"
	TK_CF_ELSE = 40, # "else"
	TK_CF_FOR = 41, # "for"
	TK_CF_WHILE = 42, # "while"
	TK_CF_BREAK = 43, # "break"
	TK_CF_CONTINUE = 44, # "continue"
	TK_CF_PASS = 45, # "pass"
	TK_CF_RETURN = 46, # "return"
	TK_CF_MATCH = 47, # "match"
	TK_PR_FUNCTION = 48, # "func"
	TK_PR_CLASS = 49, # "class"
	TK_PR_CLASS_NAME = 50, # "class_name"
	TK_PR_EXTENDS = 51, # "extends"
	TK_PR_IS = 52, # "is"
	TK_PR_ONREADY = 53, # "onready"
	TK_PR_TOOL = 54, # "tool"
	TK_PR_STATIC = 55, # "static"
	TK_PR_EXPORT = 56, # "export"
	TK_PR_SETGET = 57, # "setget"
	TK_PR_= 58, # "const"
	TK_PR_VAR = 59, # "var"
	TK_PR_AS = 60, # "as"
	TK_PR_VOID = 61, # "void"
	TK_PR_ENUM = 62, # "enum"
	TK_PR_PRELOAD = 63, # "preload"
	TK_PR_ASSERT = 64, # "assert"
	TK_PR_YIELD = 65, # "yield"
	TK_PR_SIGNAL = 66, # "signal"
	TK_PR_BREAKPOINT = 67, # "breakpoint"
	TK_PR_REMOTE = 68, # "remote"
	TK_PR_SYNC = 69, # "sync"
	TK_PR_MASTER = 70, # "master"
	TK_PR_SLAVE = 71, # "slave"
	TK_PR_PUPPET = 72, # "puppet"
	TK_PR_REMOTESYNC = 73, # "remotesync"
	TK_PR_MASTERSYNC = 74, # "mastersync"
	TK_PR_PUPPETSYNC = 75, # "puppetsync"
	TK_BRACKET_OPEN = 76, # "["
	TK_BRACKET_CLOSE = 77, # "]"
	TK_CURLY_BRACKET_OPEN = 78, # "{"
	TK_CURLY_BRACKET_CLOSE = 79, # "}"
	TK_PARENTHESIS_OPEN = 80, # "("
	TK_PARENTHESIS_CLOSE = 81, # ")"
	TK_COMMA = 82, # ","
	TK_SEMICOLON = 83, # ";"
	TK_PERIOD = 84, # "."
	TK_QUESTION_MARK = 85, # "?"
	TK_COLON = 86, # ":"
	TK_DOLLAR = 87, # "$"
	TK_FORWARD_ARROW = 88, # "->"
	TK_NEWLINE = 89, # "New Line"
	TK_CONST_PI = 90, # "PI"
	TK_CONST_TAU = 91, # "TAU"
	TK_WILDCARD = 92, # "_"
	TK_CONST_INF = 93, # "INF"
	TK_CONST_NAN = 94, # "NAN"
	TK_ERROR = 95, # "Error"
	TK_EOF = 96, # "EOF"
	TK_CURSOR = 97, # "Cursor"
	TK_MAX = 98, # number of token types
}






func set_source(new_source: String) -> void:
	tokenizer.set_source(new_source)


func get_source() -> String:
	return tokenizer.get_source()


func clear() -> void:
	tokenizer.clear()


func has_source() -> bool:
	return tokenizer.has_source()


func set_tab_size(columns: int) -> void:
	tokenizer.set_tab_size(columns)


func get_tab_size() -> int:
	return tokenizer.get_tab_size()


func set_tools_build(on: bool) -> void:
	tokenizer.set_tools_build(on)


func get_tools_build() -> bool:
	return tokenizer.get_tools_build()


func get_token_count() -> int:
	return tokenizer.get_token_count()


func get_token(index: int) -> Dictionary:
	return tokenizer.get_token(index)


func get_tokens(from: int, count: int) -> Array:
	return tokenizer.get_tokens(from, count)


func tokenize() -> Array:
	return tokenizer.tokenize()


func get_token_text(index: int) -> String:
	return tokenizer.get_token_text(index)


func split() -> PoolStringArray:
	return tokenizer.split()


func split_ex(include_newlines: bool = false) -> PoolStringArray:
	return tokenizer.split_ex(include_newlines)


func normalize() -> String:
	return tokenizer.normalize()


func validate() -> Dictionary:
	return tokenizer.validate()


func validate_lexical() -> Dictionary:
	return tokenizer.validate_lexical()


func parse() -> Dictionary:
	return tokenizer.parse()


func is_valid() -> bool:
	return tokenizer.is_valid()


func get_errors() -> Array:
	return tokenizer.get_errors()


func get_errors_text() -> PoolStringArray:
	var lines:PoolStringArray = PoolStringArray()
	for error in tokenizer.get_errors():
		lines.append(format_error(error))
	return lines


static func format_error(error: Dictionary) -> String:
	return "%d:%d %s" % [error.get("line", 0), error.get("column", 0), error.get("message", "")]


func find_members(kind: String = "", name: String = "") -> Array:
	return tokenizer.find_members(kind, name)


func find_member(name: String) -> Dictionary:
	return tokenizer.find_member(name)


func find_token(type: int, from: int = 0) -> int:
	return tokenizer.find_token(type, from)


func find_tokens(type: int) -> PoolIntArray:
	return tokenizer.find_tokens(type)


func count_tokens(type: int) -> int:
	return tokenizer.count_tokens(type)


func find_token_sequence(types: PoolIntArray, from: int = 0) -> int:
	return tokenizer.find_token_sequence(types, from)


func find_token_sequences(types: PoolIntArray) -> PoolIntArray:
	return tokenizer.find_token_sequences(types)


func find_identifier(name: String, from: int = 0) -> int:
	return tokenizer.find_identifier(name, from)


func find_identifiers(name: String) -> PoolIntArray:
	return tokenizer.find_identifiers(name)


func find_identifiers_with_prefix(prefix: String) -> PoolIntArray:
	return tokenizer.find_identifiers_with_prefix(prefix)


func find_identifiers_containing(part: String) -> PoolIntArray:
	return tokenizer.find_identifiers_containing(part)


func get_identifier_names() -> Dictionary:
	return tokenizer.get_identifier_names()


func find_text(text: String, from: int = 0) -> int:
	return tokenizer.find_text(text, from)


func find_texts(text: String) -> PoolIntArray:
	return tokenizer.find_texts(text)


func find_constant(value, from: int = 0) -> int:
	return tokenizer.find_constant(value, from)


func find_constants(value) -> PoolIntArray:
	return tokenizer.find_constants(value)


func find_builtin(name: String, from: int = 0) -> int:
	return tokenizer.find_builtin(name, from)


func find_builtins(name: String) -> PoolIntArray:
	return tokenizer.find_builtins(name)


func get_token_dicts(indexes: PoolIntArray) -> Array:
	var result:Array = []
	for index in indexes:
		result.append(tokenizer.get_token(index))
	return result


func get_line_count() -> int:
	return tokenizer.get_line_count()


func get_line(line: int) -> String:
	return tokenizer.get_line(line)


func get_tokens_on_line(line: int) -> PoolIntArray:
	return tokenizer.get_tokens_on_line(line)


func get_token_at_offset(offset: int) -> int:
	return tokenizer.get_token_at_offset(offset)


func get_token_at(line: int, column: int) -> int:
	return tokenizer.get_token_at(line, column)


func get_matching_bracket(index: int) -> int:
	return tokenizer.get_matching_bracket(index)


func rebuild(tokens: Array) -> String:
	return tokenizer.rebuild(tokens)


func rebuild_ex(tokens: Array, ignore_trivia: bool) -> String:
	return tokenizer.rebuild_ex(tokens, ignore_trivia)


func get_token_types() -> Dictionary:
	return tokenizer.get_token_types()


func get_token_type_name(type: int) -> String:
	return tokenizer.get_token_type_name(type)





var tokenizer

func _init(initialize_source : String = ""):
	tokenizer = load("res://HevLib/scripts/tokenizer/tokenizer.gdns").new()
	tokenizer.set_tools_build(false)
	if initialize_source:
		tokenizer.set_source(initialize_source)
