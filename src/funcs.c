#include <stdio.h>
#include "parser.h"


struct symbol* symbolTable = (symbol*)NULL;

struct parseTree* root = (parseTree*)NULL;

void yyerror(const char* const s) {
    fprintf(stderr, "%s\n", s);
}

struct symbol* lookUp(char* s) {
    struct symbol* sym;
    if (symbolTable == NULL) {
        printf("Error: Symbol table is empty\n");
        return NULL;
    }
    HASH_FIND_STR(symbolTable, s, sym);
    return sym;
}

struct symbol* insert(char* st) {
    struct symbol* sym;
    sym = lookUp(st);
    if (sym == NULL) {
        sym = (struct symbol*)malloc(sizeof(symbol));
        sym->name = strdup(st);
        HASH_ADD_KEYPTR(hh, symbolTable, st, strlen(sym->name), sym);
        return sym;
    }
    else {
        return NULL;
    }
}

void handleDeclarations(declarationsNode* node) {
    printf("Handling declarations\n");
    while (node != NULL) {
        switch (node->type) {
        case factorTypeInt:
            printf("Int:  %d ", node->type);
            break;
        case factorTypeBool:
            printf("Bool: %d ", node->type);
            break;
        default:
            printf("Error: Invalid type");
        }
        node = node->next;
    }
}

void handleStatement(stmtNode* node) {
    printf("Handling statement\n");
    switch (node->type) {
    case stmtTypeAssignment:
        handleAssignment(node->stmtPtr);
        break;
    case stmtTypeIf:
        handleIf(node->stmtPtr);
        break;
    case stmtTypeWhile:
        handleWhile(node->stmtPtr);
        break;
    case stmtTypeWriteInt:
        handleWriteInt(node->stmtPtr);
        break;
    }
}

void handleStatementSeq(stmtSeqNode* node) {
    while (node != NULL) {
        handleStatement(node->stmt);
        node = node->next;
    }
}

void handleAssignment(assignmentNode* node) {
    printf("Handling assignment\n");
    struct symbol* symbol = lookUp(node->name);
    if (symbol == NULL) {
        printf("Error: Symbol not found");
    }
    else if (node->expr != NULL) {
        handleExpression(node->expr);
    }
    else {
        printf("read int");
    }
}

void handleIf(ifNode* node) {
    printf("Handling if\n");
    handleExpression(node->expr);
    handleStatementSeq(node->stmtSeq);
}

void handleElse(elseNode* node) {
    printf("Handling else\n");
    handleStatementSeq(node->stmtSeq);
}

void handleWhile(whileNode* node) {
    printf("Handling while\n");
    handleExpression(node->expr);
    handleStatementSeq(node->stmtSeq);
}

void handleWriteInt(writeIntNode* node) {
    printf("Handling writeInt\n");
    handleExpression(node->expr);
}

void handleExpression(exprNode* node) {
    if (node->simpExpr2 == NULL) {
        handleSimpExpr(node->simpExpr1);
    }
    else {
        handleSimpExpr(node->simpExpr1);
        printf(" %s ", node->op);
        handleSimpExpr(node->simpExpr2);
        // TODO: If expression evals to false in code, compiler could drop some statements?
        /* if (strcmp(node->op, "<") == 0) {
            return left < right;
        }
        else if (strcmp(node->op, ">") == 0) {
            return left > right;
        }
        else if (strcmp(node->op, "<=") == 0) {
            return left <= right;
        }
        else if (strcmp(node->op, ">=") == 0) {
            return left >= right;
        }
        else if (strcmp(node->op, "==") == 0) {
            return left == right;
        }
        else if (strcmp(node->op, "!=") == 0) {
            return left != right;
        } */
    }
}

void handleSimpExpr(simpExprNode* node) {
    if (node->term2 == NULL) {
        handleTerm(node->term1);
    }
    else {
        handleTerm(node->term1);
        printf(" %s ", node->op);
        handleTerm(node->term2);
    }
}

void handleTerm(termNode* node) {
    if (node->factor2 == NULL) {
        handleFactor(node->factor1);
    }
    else {
        handleFactor(node->factor1);
        printf(" %s ", node->op);
        handleFactor(node->factor2);
    }
}

void handleFactor(factorNode* node) {
    printf("Handling factor\n");
    printf(" %d ", node->type);
    switch (node->type) {
    case factorTypeIdent:
        printf("Identifier: %s ", node->value);
        break;
    case factorTypeInt:
        printf("Int:  %d ", node->value);
        break;
    case factorTypeBool:
        printf("Bool: %d ", node->value);
        break;
    }
}

ParseTreeNode createParseTree(NodeType nodeType, ParseTreeNode* node, ParseTreeNode* left, ParseTreeNode* right) {
    if ()
        struct parseTree* tree = (struct parseTree*)malloc(sizeof(parseTree));
    tree->nodeType = nodeType;
    tree->node = node;
    tree->left = left;
    tree->right = createParseTree(NodeType)
        return tree;
}

void compileParseTree(ParseTreeNode* node) {
    if (node == NULL) {
        /* Null Root */
        return;
    }
    switch (node->nodeType) {
    case programNodeType:
        compileParseTree(node->programNode);
        break;
    case declarationsNodeType:
        compileParseTree(node->declarationsNode);
        break;
    case stmtSeqNodeType:
        compileParseTree(node->declarationsNode);
        compileParseTree(node->declarationsNode2);
        break;
    case stmtNodeType:
        compileParseTree(node->declarationNode);
        break;
    case assignmentNodeType:
        compileParseTree(node->declarationNode);
        compileParseTree(node->declarationNode2);
        break;
    case ifNodeType:
        compileParseTree(node->typeNode);
        break;
    case elseNodeType:
        compileParseTree(node->statementsNode);
        break;
    case whileNodeType:
        compileParseTree(node->statementsNode);
        compileParseTree(node->statementsNode2);
        break;
    case writeIntNodeType:
        compileParseTree(node->statementNode);
        break;
    case exprNodeType:
        compileParseTree(node->statementNode);
        compileParseTree(node->statementNode2);
        break;
    case simpExprNodeType:
        compileParseTree(node->assignmentNode);
        break;
    case termNodeType:
        compileParseTree(node->ifNode);
        break;
    case factorNodeType:
        compileParseTree(node->elseNode);
        break;
    }
}