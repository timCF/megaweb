
Act
===

This small lib provides almost pure erlang-style actors in js.

Install
-------

```
bower install act --save
```

Usage
-----

```
worker = new Act(init_state, mode, timeout)
worker.cast((state) -> do_work(state))
worker.zcast(() -> do_other_work())
worker.get()
```
Where:

- init_state : any js term
- mode : "pure" | "global_state" : If pure, we clone state every time get/change it. If global_state, we get/change state by reference
- timeout : timeout of processing queue in ms
- "cast" function gets one arg : function of prev state that must return new state. "cast" will return queue length
- "zcast" function's arity is 0 : it only execute something, not change inner state. "zcast" will return queue length
- "get" function returns current state

WARNING
-------

```
Avoid cyclic references in pure mode!!!
```