parser grammar PebbleParser;

@header {
package com.github.bjansen.pebble.parser;
}

@members {

private void ideRecover(int ttype, String message) {
    CommonToken t = new CommonToken(ttype, message);
    _ctx.addErrorNode(t);
}

}

// Use this when working with the IntelliJ plugin
//options { tokenVocab=PebbleLexer; }

// Use this when working with Gradle
options { tokenVocab='com/github/bjansen/pebble/parser/PebbleLexer'; }

pebbleTemplate
    : (
        CONTENT
        | printDirective
        | commentDirective
        | tagDirective
    )*
    ;

printDirective
    : PRINT_OPEN expression filters? PRINT_CLOSE
    ;

commentDirective
    : COMMENT
    ;

tagDirective
    : verbatimTag
    | genericTag
    ;

verbatimTag
    : VERBATIM_TAG_OPEN CONTENT? VERBATIM_TAG_END
    ;

genericTag
    : TAG_OPEN tagName expression? filters? TAG_CLOSE
    ;

tagName
    : ID_NAME
    ;

expression
    : assignment_expression
    | unary_op expression
    | parenthesized_expression
    | expression list_expression
    | expression WITH map_expression
    | expression OR expression
    | expression AND expression
    | expression ((IS test)|(CONTAINS expression))
    | expression comparison_op expression
    | expression OP_TERNARY expression OP_COLON expression
    | expression additive_op expression
    | expression multiplicative_op expression
    | expression OP_CONCAT expression
    | expression OP_RANGE expression
    | list_expression
    | map_expression
    | in_expression
    | function_call_expression
    | qualified_expression
    | term
    ;

assignment_expression
    : identifier OP_ASSIGN expression
    ;

in_expression
    : identifier IN expression
    ;

parenthesized_expression
    : LPAREN expression RPAREN
    ;

list_expression
    : LBRACKET (expression (COMMA expression)*)? RBRACKET
    ;

map_expression
    : LBRACE (map_element (COMMA map_element)*)? RBRACE
    ;

map_element
    : string_literal OP_COLON (map_expression | expression)
    ;

qualified_expression
    : (function_call_expression | identifier) (OP_MEMBER (function_call_expression | identifier))+
    ;

function_call_expression
    : identifier argument_list
    ;

argument_list
    : LPAREN
        (
            expression (COMMA expression)*
            (COMMA { ideRecover(ID_NAME, "expected expression"); })?
        )?
      RPAREN
    ;

term
    : boolean_literal
    | NULL
    | NONE
    | string_literal
    | numeric_literal
    | identifier
    ;

test
    : NOT? (NULL | identifier)
    ;

unary_op
    : OP_PLUS
    | OP_MINUS
    | NOT
    ;

multiplicative_op
    : OP_DIV
    | OP_MULT
    | OP_MOD
    ;

additive_op
    : OP_PLUS
    | OP_MINUS
    ;

comparison_op
    : OP_EQ
    | EQUALS
    | OP_NEQ
    | OP_LE
    | OP_LT
    | OP_GE
    | OP_GT
    ;

boolean_literal
    : TRUE
    | FALSE
    ;

string_literal
    : STRING_START (TEXT | (INTERPOLATED_STRING_START expression? INTERPOLATED_STRING_STOP))* STRING_END?
    | SINGLE_QUOTED_STRING
    ;

numeric_literal
    : NUMERIC
    | LONG
    ;

identifier
    : ID_NAME | WITH | IN | NONE // TODO NONE is a keyword
    ;

filters
    : OP_PIPE filter (OP_PIPE filter)*
    ;

filter
    : identifier argument_list?
    ;
