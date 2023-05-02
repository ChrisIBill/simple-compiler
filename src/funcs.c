#include "parser.h"

struct symbol* symbolTable = (symbol*)NULL;

struct symbol* lookUp(char* s) {
    struct symbol* sym;
    if (symbolTable == NULL) {
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

int handleDeclaration(declarationNode* node, FILE* out) {
    switch (node->type) {
    case factorTypeInt:
        fprintf(out, "int %s", node->name);
        break;
    case factorTypeBool:
        fprintf(out, "bool %s", node->name);
        break;
    default:
        printd(LOG_ERROR, "Error: Invalid type\n");
        return -1;
    }
    fprintf(out, ";\n");
    return 0;
}

void handleStatement(stmtNode* node, FILE* out) {
    switch (node->type) {
    case stmtTypeAssignment:
        handleAssignment(node->stmtPtr, out);
        break;
    case stmtTypeIf:
        handleIf(node->stmtPtr, out);
        break;
    case stmtTypeWhile:
        handleWhile(node->stmtPtr, out);
        break;
    case stmtTypeWriteInt:
        handleWriteInt(node->stmtPtr, out);
        break;
    }
}

void handleAssignment(assignmentNode* node, FILE* out) {
    printd(LOG_INFO, "INFO: Handling assignment\n");
    struct symbol* symbol = lookUp(node->name);
    if (symbol == NULL) {
        printd(LOG_ERROR, "ERROR: Symbol not found");
    }
    else if (node->expr == NULL) {
        fprintf(out, "scanf(\"%%i\", &%s)", node->name);
    }
    else {
        fprintf(out, "%s = ", node->name);
    }
}

void handleIf(ifNode* node, FILE* out) {
    printd(LOG_INFO, "INFO: Handling if\n");
    fprintf(out, "if (");
    //handleExpression(node->expr, out);
    //handleStatementSeq(node->stmtSeq, out);
}

void handleElse(elseNode* node, FILE* out) {
    printd(LOG_INFO, "Handling else\n");
    fprintf(out, "else {");
    //handleStatementSeq(node->stmtSeq, out);
}

void handleWhile(whileNode* node, FILE* out) {
    printd(LOG_INFO, "Handling while\n");
    fprintf(out, "while (");
}

void handleWriteInt(writeIntNode* node, FILE* out) {
    printd(LOG_INFO, "Handling writeInt\n");
    fprintf(out, "printf(\"%%i\\n\", ");
}

void handleExpression(exprNode* node, FILE* out) {
    printd(LOG_INFO, "Handling expression\n");
    if (node->simpExpr2 == NULL) {
        if (node->op != NULL) {
            printd(LOG_ERROR, "ERROR: Invalid expression\n");
            fprintf(out, " %s ", node->op);
        }
    }
    else {
        //handleSimpExpr(node->simpExpr1, out);
        fprintf(out, " %s ", node->op);
        //handleSimpExpr(node->simpExpr2, out);
        /* @TODO: If expression evals to false in code, compiler could drop some statements? */
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

void handleSimpExpr(simpExprNode* node, FILE* out) {
    printd(LOG_INFO, "Handling simpExpr\n");
    if (node->term2 == NULL) {
        // handleTerm(node->term1, out);
        if (node->op != NULL) {
            printd(LOG_ERROR, "ERROR: Invalid expression\n");
            fprintf(out, " %s ", node->op);
        }
    }
    else {
        // handleTerm(node->term1, out);
        fprintf(out, " %s ", node->op);
        // handleTerm(node->term2, out);
    }
}

void handleTerm(termNode* node, FILE* out) {
    printd(LOG_INFO, "Handling term\n");
    if (node->factor2 == NULL) {
        // handleFactor(node->factor1, out);
        if (node->op != NULL) {
            printd(LOG_ERROR, "ERROR: Invalid expression\n");
            fprintf(out, " %s ", node->op);
        }
    }
    else {
        // handleFactor(node->factor1, out);
        fprintf(out, " %s ", node->op);
        // handleFactor(node->factor2, out);
    }
}

void handleFactor(factorNode* node, FILE* out) {
    printd(LOG_INFO, "INFO: Handling factor\n");
    //printf(" %d ", node->type);
    switch (node->type) {
    case factorTypeIdent:
        printd(LOG_INFO, "INFO: Identifier \n");
        fprintf(out, " %s ", node->value->name);
        break;
    case factorTypeInt:
        printd(LOG_INFO, "INFO: Int \n");
        fprintf(out, " %d ", node->value->iValue);
        break;
    case factorTypeBool:
        printd(LOG_INFO, "INFO: Bool \n");
        fprintf(out, " %d ", node->value->iValue);
        break;
    }
}

struct ParseTreeNode* createParseTreeNode(
    NodeType nodeType,
    ParseTreeNodeTypes* node,
    ParseTreeNode* left,
    ParseTreeNode* right
) {
    struct ParseTreeNode* tree = (struct ParseTreeNode*)malloc(sizeof(ParseTreeNode));
    tree->nodeType = nodeType;
    tree->data = node;
    tree->left = left;
    tree->right = right;
    return tree;
}
int compileParseTree(ParseTreeNode* node, FILE* output) {
    if (node == NULL) {
        /* Null Leaf */
        return;
    }
    switch (node->nodeType) {
    case programNodeType:
        fprintf(output, "#include <stdbool.h>\n");
        fprintf(output, "#include <stdio.h>\n");
        fprintf(output, "int main() {\n");
        compileParseTree(node->left, output);
        compileParseTree(node->right, output);
        fprintf(output, "return 0;\n");
        fprintf(output, "}\n");
        break;
    case declarationNodeType:
        handleDeclaration(node->data, output);
        /* Declarations are placed in parse tree only on */
        compileParseTree(node->left, output);
        break;
    case stmtSeqNodeType:
        printf("Handling statement sequence\n");
        compileParseTree(node->left, output);
        compileParseTree(node->right, output);
        break;
    case stmtNodeType:
        compileParseTree(node->left, output);
        compileParseTree(node->right, output);
        //fprintf(output, ";\n");
        break;
    case assignmentNodeType:
        handleAssignment(node->data, output);
        compileParseTree(node->left, output);
        fprintf(output, ";\n");
        break;
    case ifNodeType:
        handleIf(node->data, output);
        compileParseTree(node->left, output);
        fprintf(output, ") {\n");
        compileParseTree(node->right, output);
        fprintf(output, "}\n");
        break;
    case elseNodeType:
        handleElse(node->data, output);
        compileParseTree(node->left, output);
        fprintf(output, "}\n");
        break;
    case whileNodeType:
        fprintf(output, "while (");
        compileParseTree(node->left, output);
        fprintf(output, ") {\n");
        compileParseTree(node->right, output);
        fprintf(output, "}\n");
        break;
    case writeIntNodeType:
        /* Need to declare a temp integer to eval expression to, then print that */
        handleWriteInt(node->data, output);
        compileParseTree(node->left, output);
        fprintf(output, ");\n");
        break;
    case exprNodeType:
        compileParseTree(node->left, output);
        handleExpression(node->data, output);
        compileParseTree(node->right, output);
        break;
    case simpExprNodeType:
        compileParseTree(node->left, output);
        handleSimpExpr(node->data, output);
        compileParseTree(node->right, output);
        break;
    case termNodeType:
        compileParseTree(node->left, output);
        handleTerm(node->data, output);
        compileParseTree(node->right, output);
        break;
    case factorNodeType:
        handleFactor(node->data, output);
        break;
    }
}