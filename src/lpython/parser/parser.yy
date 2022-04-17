%require "3.0"
%define api.pure
%define api.value.type {LFortran::YYSTYPE}
%param {LFortran::Parser &p}
%locations
%expect    0   // shift/reduce conflicts

// Uncomment this to get verbose error messages
//%define parse.error verbose

/*
// Uncomment this to enable parser tracing. Then in the main code, set
// extern int yydebug;
// yydebug=1;
%define parse.trace
%printer { fprintf(yyo, "%s", $$.str().c_str()); } <string>
%printer { fprintf(yyo, "%d", $$); } <n>
%printer { std::cerr << "AST TYPE: " << $$->type; } <ast>
*/


%code requires // *.h
{
#include <lpython/parser/parser.h>
}

%code // *.cpp
{

#include <lpython/parser/parser.h>
#include <lpython/parser/tokenizer.h>
#include <lpython/parser/semantics.h>

int yylex(LFortran::YYSTYPE *yylval, YYLTYPE *yyloc, LFortran::Parser &p)
{
    return p.m_tokenizer.lex(p.m_a, *yylval, *yyloc, p.diag);
} // ylex

void yyerror(YYLTYPE *yyloc, LFortran::Parser &p, const std::string &msg)
{
    p.handle_yyerror(*yyloc, msg);
}

#define YYLLOC_DEFAULT(Current, Rhs, N)                                 \
    do                                                                  \
      if (N)                                                            \
        {                                                               \
          (Current).first   = YYRHSLOC (Rhs, 1).first;                  \
          (Current).last    = YYRHSLOC (Rhs, N).last;                   \
        }                                                               \
      else                                                              \
        {                                                               \
          (Current).first   = (Current).last   =                        \
            YYRHSLOC (Rhs, 0).last;                                     \
        }                                                               \
    while (0)

} // code


// -----------------------------------------------------------------------------
// List of tokens
// All tokens that we use (including "+" and such) are declared here first
// using the %token line. Each token will end up a member of the "enum
// yytokentype" in parser.tab.hh. Tokens can have a string equivalent (such as
// "+" for TK_PLUS) that is used later in the file to simplify reading it, but
// it is equivalent to TK_PLUS. Bison also allows so called "character token
// type" which are specified using single quotes (and that bypass the %token
// definitions), and those are not used here, and we test that the whole file
// does not contain any single quotes to ensure that.
//
// If this list is updated, update also token2text() in parser.cpp.

// Terminal tokens
%token END_OF_FILE 0
%token TK_NEWLINE
%token TK_INDENT
%token TK_DEDENT
%token <string> TK_NAME
%token <int_suffix> TK_INTEGER
%token <string> TK_REAL
%token <int_suffix> TK_IMAG_NUM
%token TK_PLUS "+"
%token TK_MINUS "-"
%token TK_STAR "*"
%token TK_SLASH "/"
%token TK_COLON ":"
%token TK_SEMICOLON ";"
%token TK_COMMA ","
%token TK_EQUAL "="
%token TK_LPAREN "("
%token TK_RPAREN ")"
%token TK_LBRACKET "["
%token TK_RBRACKET "]"
%token TK_LBRACE "{"
%token TK_RBRACE "}"
%token TK_PERCENT "%"
%token TK_VBAR "|"
%token TK_AMPERSAND "&"
%token TK_DOT "."
%token TK_TILDE "~"
%token TK_CARET "^"
%token TK_AT "@"
%token <string> TK_STRING
%token <string> TK_COMMENT
%token <string> TK_EOLCOMMENT
%token TK_POW "**"
%token TK_FLOOR_DIV "//"
%token TK_RIGHTSHIFT ">>"
%token TK_LEFTSHIFT "<<"
%token TK_PLUS_EQUAL "+="
%token TK_MIN_EQUAL "-="
%token TK_STAR_EQUAL "*="
%token TK_SLASH_EQUAL "/="
%token TK_PERCENT_EQUAL "%="
%token TK_AMPER_EQUAL "&="
%token TK_VBAR_EQUAL "|="
%token TK_CARET_EQUAL "^="
%token TK_ATEQUAL "@="
%token TK_RARROW "->"
%token TK_COLONEQUAL ":="
%token TK_ELLIPSIS "..."
%token TK_LEFTSHIFT_EQUAL "<<="
%token TK_RIGHTSHIFT_EQUAL ">>="
%token TK_POW_EQUAL "**="
%token TK_DOUBLESLASH_EQUAL "//="
%token TK_EQ "=="
%token TK_NE "!="
%token TK_LT "<"
%token TK_LE "<="
%token TK_GT ">"
%token TK_GE ">="
%token TK_NOT "not"
%token TK_AND "and"
%token TK_OR "or"
%token TK_TRUE "True"
%token TK_FALSE "False"


// Terminal tokens: Keywords
%token KW_AS
%token KW_ASSERT
%token KW_ASYNC
%token KW_AWAIT
%token KW_BREAK
%token KW_CLASS
%token KW_CONTINUE
%token KW_DEF
%token KW_DEL
%token KW_ELIF
%token KW_ELSE
%token KW_EXCEPT
%token KW_FINALLY
%token KW_FOR
%token KW_FROM
%token KW_GLOBAL
%token KW_IF
%token KW_IMPORT
%token KW_IN
%token KW_IS
%token KW_LAMBDA
%token KW_NONE
%token KW_NONLOCAL
%token KW_PASS
%token KW_RAISE
%token KW_RETURN
%token KW_TRY
%token KW_WHILE
%token KW_WITH
%token KW_YIELD

// Nonterminal tokens

%type <ast> script_unit
%type <ast> id
%type <ast> expr
%type <vec_ast> expr_list
/* %type <vec_ast> expr_list_opt */
%type <ast> statement
%type <ast> single_line_statement
/* %type <ast> multi_line_statement */
%type <ast> augassign_statement
%type <operator_type> augassign_op
%type <ast> pass_statement
%type <ast> continue_statement
%type <ast> break_statement
%type <ast> raise_statement
%type <ast> assert_statement
%type <ast> import_statement
%type <ast> global_statement
%type <ast> nonlocal_statement
%type <ast> assignment_statement
%type <vec_ast> target_list
%type <vec_ast> target_item_list
%type <ast> target_item
%type <ast> target
%type <ast> ann_assignment_statement
%type <ast> delete_statement
%type <ast> del_target
%type <vec_ast> del_target_list
%type <ast> return_statement
/*
%type <ast> expression_statment
 */
%type <vec_ast> module
%type <alias> module_as_id
%type <vec_alias> module_item_list
%type <vec_ast> sep
%type <ast> sep_one

// Precedence

//%left "or"
//%left "and"
//%precedence "not"
%left "==" "!=" ">=" ">" "<=" "<" //"is not" "is" "not in" "in"
%left "|"
%left "^"
%left "&"
%left ">>" "<<"
%left "-" "+"
%left "%" "//" "/" "@" "*"
%precedence UNARY
%right "**"

%start units

%%

// The order of rules does not matter in Bison (unlike in ANTLR). The
// precedence is specified not by the order but by %left and %right directives
// as well as with %dprec.

// ----------------------------------------------------------------------------
// Top level rules to be used for parsing.

// Higher %dprec means higher precedence

units
    : units script_unit   { RESULT($2); }
    | script_unit         { RESULT($1); }
    | sep
    ;

script_unit
    : statement sep   { $$ = SCRIPT_UNIT_STMT($1); }
    | expr sep        { $$ = SCRIPT_UNIT_EXPR($1); }
    ;
/*
statements
    : single_stmt_list TK_NEWLINE { }
    | sep TK_INDENT statements1 TK_DEDENT { }
    ;

statements1
    : statements1 statement sep { }
    | statement sep { }
    ;

single_stmt_list
    : single_stmt_list ";" single_line_statement { }
    | single_line_statement { }
    ;
 */
statement
    : single_line_statement
    /* | multi_line_statement */
    ;

single_line_statement
    /* : expression_statment */
    : assert_statement
    | assignment_statement
    | augassign_statement
    | ann_assignment_statement
    | pass_statement
    | delete_statement
    | return_statement
    | raise_statement
    | break_statement
    | continue_statement
    | import_statement
    | global_statement
    | nonlocal_statement
    ;

pass_statement
    : KW_PASS { $$ = PASS(@$); }
    ;

break_statement
    : KW_BREAK { $$ = BREAK(@$); }
    ;

continue_statement
    : KW_CONTINUE { $$ = CONTINUE(@$); }
    ;

raise_statement
    : KW_RAISE { $$ = RAISE_01(@$); }
    | KW_RAISE expr { $$ = RAISE_02($2, @$); }
    | KW_RAISE expr KW_FROM expr { $$ = RAISE_03($2, $4, @$); }
    ;

assert_statement
    : KW_ASSERT expr { $$ = ASSERT_01($2, @$); }
    | KW_ASSERT expr "," expr { $$ = ASSERT_02($2, $4, @$); }
    ;

target
    : id { $$ = TARGET_ID($1, @$); }
    | expr "." id { }
    | expr "[" expr_list "]" { }
    ;

target_item_list
    : target_item_list "," target { $$ = $1; LIST_ADD($$, $3); }
    | target { LIST_NEW($$); LIST_ADD($$, $1); }
    ;

target_item
    : target_item_list { $$ = TUPLE_01($1, @$); }
    ;

target_list
    : target_list target_item "=" { $$ = $1; LIST_ADD($$, $2); }
    | target_item "=" { LIST_NEW($$); LIST_ADD($$, $1); }
    ;

assignment_statement
    : target_list expr { $$ = ASSIGNMENT($1, $2, @$); }
    ;

augassign_statement
    : target augassign_op expr { $$ = AUGASSIGN_01($1, $2, $3, @$); }
    ;

augassign_op
    : "+=" { $$ = OPERATOR(Add, @$); }
    | "-=" { $$ = OPERATOR(Sub, @$); }
    | "*=" { $$ = OPERATOR(Mult, @$); }
    | "/=" { $$ = OPERATOR(Div, @$); }
    | "%=" { $$ = OPERATOR(Mod, @$); }
    | "&=" { $$ = OPERATOR(BitAnd, @$); }
    | "|=" { $$ = OPERATOR(BitOr, @$); }
    | "^=" { $$ = OPERATOR(BitXor, @$); }
    | "<<=" { $$ = OPERATOR(LShift, @$); }
    | ">>=" { $$ = OPERATOR(RShift, @$); }
    | "**=" { $$ = OPERATOR(Pow, @$); }
    | "//=" { $$ = OPERATOR(FloorDiv, @$); }
    ;

ann_assignment_statement
    : target ":" expr { $$ = ANNASSIGN_01($1, $3, @$); }
    | target ":" expr "=" expr { $$ = ANNASSIGN_02($1, $3, $5, @$); }
    ;

del_target
    : id { $$ = DEL_TARGET_ID($1, @$); }
    ;

del_target_list
    : del_target_list "," del_target { $$ = $1; LIST_ADD($$, $3); }
    | del_target { LIST_NEW($$); LIST_ADD($$, $1); }
    ;

delete_statement
    : KW_DEL del_target_list { $$ = DELETE($2, @$); }
    ;

return_statement
    : KW_RETURN { $$ = RETURN_01(@$); }
    | KW_RETURN expr { $$ = RETURN_02($2, @$); }
    ;

module
    : module "." id { $$ = $1; LIST_ADD($$, $3); }
    | id { LIST_NEW($$); LIST_ADD($$, $1); }
    ;

module_as_id
    : module { $$ = MOD_ID_01($1, @$); }
    | module KW_AS id { $$ = MOD_ID_02($1, $3, @$); }
    | "*" { $$ = MOD_ID_03("*", @$); }
    ;

module_item_list
    : module_item_list "," module_as_id { $$ = $1; PLIST_ADD($$, $3); }
    | module_as_id { LIST_NEW($$); PLIST_ADD($$, $1); }
    ;

dot_list
    : dot_list "." { DOT_COUNT_01(); }
    | "." { DOT_COUNT_01(); }
    | dot_list "..." { DOT_COUNT_02(); }
    | "..." { DOT_COUNT_02(); }
    ;

import_statement
    : KW_IMPORT module_item_list { $$ = IMPORT_01($2, @$); }
    | KW_FROM module KW_IMPORT module_item_list {
        $$ = IMPORT_02($2, $4, @$); }
    | KW_FROM module KW_IMPORT "(" module_item_list ")" {
        $$ = IMPORT_02($2, $5, @$); }
    | KW_FROM dot_list KW_IMPORT module_item_list {
        $$ = IMPORT_03($4, @$); }
    | KW_FROM dot_list module KW_IMPORT module_item_list {
        $$ = IMPORT_04($3, $5, @$); }
    | KW_FROM dot_list KW_IMPORT "(" module_item_list ")" {
        $$ = IMPORT_03($5, @$); }
    | KW_FROM dot_list module KW_IMPORT "(" module_item_list ")" {
        $$ = IMPORT_04($3, $6, @$); }
    ;

global_statement
    : KW_GLOBAL expr_list { $$ = GLOBAL($2, @$); }
    ;

nonlocal_statement
    : KW_NONLOCAL expr_list { $$ = NON_LOCAL($2, @$); }
    ;

expr_list
    : expr_list "," expr { $$ = $1; LIST_ADD($$, $3); }
    | expr { LIST_NEW($$); LIST_ADD($$, $1); }
    ;

expr
    : id { $$ = $1; }
    | TK_INTEGER { $$ = INTEGER($1, @$); }
    | TK_STRING { $$ = STRING($1, @$); }
    | TK_REAL { $$ = FLOAT($1, @$); }
    | TK_IMAG_NUM { $$ = COMPLEX($1, @$); }
    | TK_TRUE { $$ = BOOL(true, @$); }
    | TK_FALSE { $$ = BOOL(false, @$); }
    | "(" expr ")" { $$ = $2; }
    | id "(" ")" { $$ = CALL_01($1, @$); }
    | id "(" expr_list ")" { $$ = CALL_02($1, $3, @$); }

    | expr "+" expr { $$ = BINOP($1, Add, $3, @$); }
    | expr "-" expr { $$ = BINOP($1, Sub, $3, @$); }
    | expr "*" expr { $$ = BINOP($1, Mult, $3, @$); }
    | expr "/" expr { $$ = BINOP($1, Div, $3, @$); }
    | expr "%" expr { $$ = BINOP($1, Mod, $3, @$); }
    | "-" expr %prec UNARY { $$ = UNARY($2, USub, @$); }
    | "+" expr %prec UNARY { $$ = UNARY($2, UAdd, @$); }
    | "~" expr %prec UNARY { $$ = UNARY($2, Invert, @$); }
    | expr "**" expr { $$ = BINOP($1, Pow, $3, @$); }
    | expr "//" expr { $$ = BINOP($1, FloorDiv, $3, @$); }
    | expr "@" expr { $$ = BINOP($1, MatMult, $3, @$); }

    | expr "&" expr { $$ = BINOP($1, BitAnd, $3, @$); }
    | expr "|" expr { $$ = BINOP($1, BitOr, $3, @$); }
    | expr "^" expr { $$ = BINOP($1, BitXor, $3, @$); }
    | expr "<<" expr { $$ = BINOP($1, LShift, $3, @$); }
    | expr ">>" expr { $$ = BINOP($1, RShift, $3, @$); }

    | expr "==" expr { $$ = COMPARE($1, Eq, $3, @$); }
    | expr "!=" expr { $$ = COMPARE($1, NotEq, $3, @$); }
    | expr "<" expr { $$ = COMPARE($1, Lt, $3, @$); }
    | expr "<=" expr { $$ = COMPARE($1, LtE, $3, @$); }
    | expr ">" expr { $$ = COMPARE($1, Gt, $3, @$); }
    | expr ">=" expr { $$ = COMPARE($1, GtE, $3, @$); }
    ;

id
    : TK_NAME { $$ = SYMBOL($1, @$); }
    ;

sep
    : sep sep_one { $$ = $1; LIST_ADD($$, $2); }
    | sep_one { LIST_NEW($$); LIST_ADD($$, $1); }
    ;

sep_one
    : TK_NEWLINE {}
    | TK_COMMENT {}
    | TK_EOLCOMMENT {}
    | ";" {}
    ;
