/**
AVL-TREE:
A key data - add node
S key - search
D key - delete node
F - destroy tree
P.S.
NULL is determined as 0!
**/

#include <stdio.h>
#include <stdlib.h>

struct node
{
    int key;
    int data;
    int height;
    struct node *left;
    struct node *right;
};

struct node *find_node (int key, struct node *t); //returns node with key "key" from tree with root t or 0 if it such node doesn't exist
struct node *find_min (struct node *t); //returns node with minimum key from subtree with root t
struct node *remove_min (struct node *t); //removes node with minimum key from subtree with root tree (but doesn't delete removed node!)
struct node *insert_node (int key, int data, struct node *t); //inserts node with key "key" to tree with root t
struct node *delete_node (int key, struct node *t); //deletes node with key "key" form tree with root t
void free_tree (struct node *t); //free all memory reserved for tree with root t
        
        /*auxiliary functions*/
int height (struct node *t); //returns height of node t
int max (int a, int b); //returns max for a nd b integers
struct node* balance (struct node *t); //makes subtree with t as a root balanced and finds new t's height

struct node *RR (struct node *k2);
struct node *LL (struct node *k2);
struct node *LR (struct node *t);
struct node *RL (struct node *t);

int
main (void)
{
    char c;
    struct node *tree = 0;
    while ((c=getchar())!='F')
    {
        int a,b;
        switch(c)
        {
            case 'A':
                scanf("%d%d", &a, &b);
                tree = insert_node(a, b, tree);
                break;
            case 'S':
                scanf("%d",&a);
                struct node *temp = find_node(a,tree);
                if (temp)
                    printf("%d %d\n", temp->key, temp->data);
                break;
            case 'D':
                scanf("%d", &a);
                tree = delete_node(a,tree);
                break;
            default:
                break;
        }
    }
    free_tree(tree);
    return 0;
}

struct node*
find_node (int key, struct node *t)
{
    while (t && t->key != key)
    {
        if (key < t->key)
            t = t->left;
        else
            t = t->right;
    }
    return t;
};

struct node*
find_min (struct node *t)
{
    if (!t || !(t->left)) return t;
    while (t->left)
        t = t->left;
    return t;
}

struct node*
remove_min (struct node *t)
{
    if (!t->left)
        return t->right;
    t->left = remove_min(t->left);
    return balance (t);
}

struct node*
insert_node (int key, int data, struct node *t)
{
    if (!t)
    {
        t = malloc (sizeof(struct node));
        t->key = key;
        t->data = data;
        t->height = 1;
        t->left = t->right = 0;
    }
    else if (key == t->key) {
        t->data = data;
        return t;
    }
    else if (key < t->key)
        t->left = insert_node (key, data, t->left);
    else
        t->right = insert_node (key, data, t->right);
    return balance(t);
}

struct node*
delete_node (int key, struct node *t)
{
    if (!t) return 0;
    if (key < t->key)
        t->left = delete_node(key, t->left);
    else if (key > t->key)
        t->right = delete_node(key, t->right);
    else
    {
        struct node *l = t->left;
        struct node *r = t->right;
        if (!r) {
            free(t);
            return l;
        }
        struct node *min = find_min(r);
        min->right = remove_min(r);
        min->left=l;
        free(t);
        return balance(min);
    }
    return balance(t);
}

void
free_tree (struct node *t)
{
    if (t)
    {
        free_tree (t->left);
        free_tree (t->right);
        free (t);
    }
}

int
height (struct node *t)
{
    return (t) ? t->height:0;
}

int
max (int a, int b)
{
    return a > b ? a : b;
}

struct node*
balance (struct node *t)
{
    if(t)
    {
        if (height(t->left) - height(t->right) == 2)
        {
            if (height(t->left->left)-height(t->left->right) == 1)
                t = RR(t);
            else
                t = LR(t);
        }
        else if (height(t->right)-height(t->left) == 2)
        {
            if (height(t->right->right)-height(t->right->left) == 1)
                t = LL(t);
            else
                t = RL(t);
        }
        t->height = max (height(t->left), height(t->right)) + 1;
    }
    return t;
}

struct node*
RR (struct node *k2)
{
    struct node *k1;
    k1 = k2->left;
    k2->left = k1->right;
    k1->right = k2;
    k2->height = max (height(k2->left), height(k2->right))+1;
    k1->height = max (height(k1->left), k2->height)+1;
    return k1;
}

struct node*
LL (struct node *k2)
{
    struct node *k1;
    k1 = k2->right;
    k2->right = k1->left;
    k1->left = k2;
    k2->height = max (height(k2->left), height(k2->right))+1;
    k1->height = max (height(k1->right), k2->height)+1;
    return k1;
}

struct node*
LR (struct node *t)
{
    t->left = LL(t->left);
    return RR(t);
};

struct node*
RL (struct node *t)
{
    t->right = RR(t->right);
    return LL(t);
}