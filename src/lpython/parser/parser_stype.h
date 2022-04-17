#ifndef LPYTHON_PARSER_STYPE_H
#define LPYTHON_PARSER_STYPE_H

#include <cstring>
#include <lpython/python_ast.h>
#include <libasr/location.h>
#include <libasr/containers.h>
#include <libasr/bigint.h>

namespace LFortran
{

struct IntSuffix {
    BigInt::BigInt int_n;
    Str int_kind;
};

union YYSTYPE {
    int64_t n;
    Str string;
    IntSuffix int_suffix;

    LPython::AST::ast_t* ast;
    Vec<LPython::AST::ast_t*> vec_ast;

    LPython::AST::alias_t* alias;
    Vec<LPython::AST::alias_t> vec_alias;

    LPython::AST::operatorType operator_type;
};

static_assert(std::is_standard_layout<YYSTYPE>::value);
static_assert(std::is_trivial<YYSTYPE>::value);
// Ensure the YYSTYPE size is equal to Vec<AST::ast_t*>, which is a required member, so
// YYSTYPE has to be at least as big, but it should not be bigger, otherwise it
// would reduce performance.
static_assert(sizeof(YYSTYPE) == sizeof(Vec<LPython::AST::ast_t*>));

} // namespace LFortran


typedef struct LFortran::Location YYLTYPE;
#define YYLTYPE_IS_DECLARED 1
#define YYLTYPE_IS_TRIVIAL 0


#endif // LPYTHON_PARSER_STYPE_H
