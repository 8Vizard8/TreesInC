#include <stdio.h>
#include <stdlib.h>

typedef struct node node;

struct node // структура для представления узлов дерева
{
	int key;
	int data;
	unsigned char height;
	node* left;
	node* right;
};

unsigned char height(node* p)
{
	return p?p->height:0;
}

int bfactor(node* p)
{
	return height(p->right)-height(p->left);
}

void fixheight(node* p)
{
	unsigned char hl = height(p->left);
	unsigned char hr = height(p->right);
	p->height = (hl>hr?hl:hr)+1;
}

node* rotateright(node* p) // правый поворот вокруг p
{
	node* q = p->left;
	p->left = q->right;
	q->right = p;
	fixheight(p);
	fixheight(q);
	return q;
}

node* rotateleft(node* q) // левый поворот вокруг q
{
	node* p = q->right;
	q->right = p->left;
	p->left = q;
	fixheight(q);
	fixheight(p);
	return p;
}

node* balance(node* p) // балансировка узла p
{
	fixheight(p);
	if( bfactor(p)==2 )
	{
		if( bfactor(p->right) < 0 )
			p->right = rotateright(p->right);
		return rotateleft(p);
	}
	if( bfactor(p)==-2 )
	{
		if( bfactor(p->left) > 0  )
			p->left = rotateleft(p->left);
		return rotateright(p);
	}
	return p; // балансировка не нужна
}

node* insert(node* p, int k, int d) // вставка ключа k в дерево с корнем p
{
	if( !p ) {
    p = malloc (sizeof(struct node));
    p->key = k;
    p->data = d;
    p->height = 1;
    p->left = p->right = 0;
    return p;
	}
	if( k<p->key )
		p->left = insert(p->left,k,d);
	else if (k==p->key)
    p->data = d;
	else
		p->right = insert(p->right,k,d);
	return balance(p);
}

node* findmin(node* p) // поиск узла с минимальным ключом в дереве p
{
	return p->left?findmin(p->left):p;
}

node* removemin(node* p) // удаление узла с минимальным ключом из дерева p
{
	if( p->left==0 )
		return p->right;
	p->left = removemin(p->left);
	return balance(p);
}

node* removen(node* p, int k) // удаление ключа k из дерева p
{
	if( !p ) return 0;
	if( k < p->key )
		p->left = removen(p->left,k);
	else if( k > p->key )
		p->right = removen(p->right,k);
	else //  k == p->key
	{
		node* q = p->left;
		node* r = p->right;
		free(p);
		if( !r ) return q;
		node* min = findmin(r);
		min->right = removemin(r);
		min->left = q;
		return balance(min);
	}
	return balance(p);
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
main (void)
{
  char c;
  struct node *tree = 0;
  while ((c=getchar())!='F')
  {
    int a=0,b=0;
    switch(c)
    {
      case 'A':
        scanf("%d%d", &a, &b);
        tree = insert(tree,a,b);
        break;
      case 'S':
        scanf("%d",&a);
        struct node *temp = find_node(a,tree);
        if (temp)
          printf("%d %d\n", temp->key, temp->data);
        break;
      case 'D':
        scanf("%d", &a);
        tree = removen(tree,a);
        break;
      default:
        break;
    }
  }
  free_tree(tree);
  return 0;
}