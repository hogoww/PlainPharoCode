# PlainCode

Able to generate methods using the pharo syntax in a block rather than strings, or complex node writting.  The variables used in the environment will be replaced by their values if they are set. You can also pass a dictionary to rename the arguments of the nodes.

/!\ Uses the context the block has been defined in, meaning that you cannot create the target block in another block that will be valued in another context. Use #ifTrue:ifFalse and variants if you need control flow (they are inlined at compilation time, so no context change).  
We also (sadly) have to stringify the AST rather than giving it directly to the compiler, because the replacement are pretty rudimentary, and don't analyze a lot of things (such as replaced values that are instance variables of the targeted class).

![Simple Example](./images/ex1.png)

![Example #2](./images/ex2.png)

![Example #3](./images/ex2.png)
