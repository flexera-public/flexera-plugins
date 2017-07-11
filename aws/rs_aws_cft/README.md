


Note: Create & Update do not return the Stack Name in the result, so it is recommended to do a `@stack.get(name: $stack_name)` after a manual `@stack.create()` or a `@stack.update()`