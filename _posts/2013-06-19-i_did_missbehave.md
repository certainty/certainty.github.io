---
layout: post
title: I did mis(s)behave
tagline: Lessons learned from a failed project
datestring: 2013-06-19
tags: [scheme,missbehave,chicken,tdd,bdd,testing]
---

It is really hard to admit that a project has failed. That's probably why many projects are taken
further and further even though they have failed a long time ago.

One of my failed projects is a little scheme library called [missbehave](http://wiki.call-cc.org/eggref/4/missbehave).

I intended to provide a testing framework that could be used in [TDD](http://en.wikipedia.org/wiki/Test-driven_development) and especially in [BDD](http://en.wikipedia.org/wiki/Behavior-driven_development). It was inspired and mostly designed after the really neat [rspec-library](http://rspec.info). If you're a ruby programmer
and you don't know it yet, go ahead and give it a try.


### How did it fail?

Well the most obvious thing I realized was that even I as the developer of the library didn't use it much.
I used it to some extend, but whenever I wanted to make sure things work and I had to get things done, I switched to the [defacto standard
testing library for chicken scheme](http://wiki.call-cc.org/eggref/4/test).
And so did others.

There weren't many who tried the library, and when they did they immediately recognized problems.
Fixing those problems became harder and harder, which is another indicator for a failed project.

While it did provide some new and useful features, it was just another testing library, and there
already have been very mature ones.


### Missbehave: the bad parts

Let me walk you through the parts of the library that are the reason for its failure. There are things that I really like about
the library which I will outline in [the good parts](#missbehave_the_good_parts).


#### 1) Behavior verification

That's one of the things the library aimed at. I intended to enable BDD in scheme.
The problem with that is that most of the testing techniques that currently exist
to support BDD are alien or at least unnatural for scheme. Let me describe shortly what that
normally looks like and you'll realize that this is not what scheme is about most of the time.

BDD is an outside-in or top-down or interface-first approach to testing.
This means that the programmer starts with the definition of the interface and works his/her way from the outermost layer inwards.
Interface in that context can indeed be the GUI, external APIs or just protocols describing the services a particular '''object''' provides.
It is common to test behavior with objects that have not been implemented at that point.
This is done by using test doubles which are used as replacement for the actual thing that will be implemented later.
Often these doubles represent [depended-on components (DOCs)](http://xunitpatterns.com/DOC.html) that the [system under test (SUT)](http://xunitpatterns.com/SUT.html) interacts with. So if we want not make sure that the SUT behaves as expected, we can not do that by just looking
at its direct outputs; instead we have to verify it through indirect output performed on the DOC. This is often done by placing
expectations on the DOC about which method will be invoked with what arguments. A method call does not just return
a value (if it does), but also invokes methods on DOCs, that have often been injected. See also [dependency injection DI](http://xunitpatterns.com/Dependency%20Injection.html).
This type of testing is called [behavior verification](http://xunitpatterns.com/Behavior%20Verification.html).

In functional programs or mostly functional programs, we don't have these
kinds of functions. We are in the fortunate position to be able to determine the correctness of a referentially transparent function just by looking
at the arguments and the return value of the function. Indirect outputs would normally be side-effects, which don't exist in pure functions.

That doesn't mean that scheme programs don't have side-effects, but they are rare and generally discouraged.
That again means, that I have provided a library that eases the testing/development of a small fraction of the code that you typically produce in scheme.
That's not very useful, is it? So the bad idea here was:

> I worked against the language, its characteristics and idioms

Functional programs aren't about behavior, but rather about values and computation. That doesn't mean that functional systems don't have behavior, but they don't interest us as much when we apply tests to the system.


#### 2) Procedure expectations

Since scheme programs are usually not build in a OO fashion with compound objects and complicated hierarchies based on types, I provided a way
to verify that a certain function has been called. Additionally you could verify that it has been called given times and with given arguments. This is an essential feature if you apply OOish behavior verification to scheme.

~~~ clojure
 (use missbehave missbehave-matchers srfi-1)

 (define (shuffle ls)
   (sort ls (lambda _ (zero? (random 2)))))

 (define (yodize str)
   (string-intersperse
	 (shuffle
	   (string-split str " "))))

 (context "procedure expectations"
   (it "calls shuffle once"
	 (expect (yodize "may the force be with you") (to (call shuffle once)))))
~~~

As I pointed out earlier, this can be useful in some situations, but those are rare.
There is an additional problem, which is not so important for the client programmer, but still a reason I don't like that feature; it's the implementation of that mechanism.

<strong>Admission:</strong> It is implemented using a lot of mutation.


#### 3) Stubs and mocks

As I explained it is common, in behavior verification, to introduce test doubles, so missbehave added a possibility to mock procedures.
Though the general idea might be pleasing, the particular implementation didn't feel right.
I essentially <strong>redefined</strong> the procedures to have the desired behavior. Also I made again heavy use of the [advice egg](http://wiki.call-cc.org/eggref/4/advice) to do this. The following example shows how to stub the result of (car).

~~~ clojure
 (use missbehave missbehave-matchers missbehave-stubs srfi-1)

 (stub! car (returns '()))
 (car (list 1 2 3))
 (car '())
~~~

Procedure stubs aren't that useful in scheme, since in functional languages we are more concerned about the result of a procedure, rather than if it has been
invoked. Most likely we will have an interface that accepts a procedure or uses a parameter. For both cases we can
provide implementations that fit in our tests, without resorting to replacing a function's implementation. That's a natural
property of higher order functions. In essence I tried to solve a problem, that isn't there.

#### 4) Hooks

A key part of the library are contexts. Contexts are a snapshot of the world in a given state. They supported hooks that could
be used to setup a certain state of the world at a given point in time.
In traditional test frameworks this is where your setup and tear-down code resides. The following example illustrates this:

~~~ clojure
 (use missbehave missbehave-matchers missbehave-stubs srfi-1)

 (context "context with hooks"
   (before :each (set! ($ 'answer) 42))
   (it "should have the answer"
	 (expect ($ 'answer) (to (be 42)))))
~~~

As it turns out, this feature is really bad since it embraces mutable state and even worse, it hides when the mutation happens.
It's way clearer to just use let-bindings to share values across examples and use an explicit set! if you must.

#### 5) The runner

This is something that turned out to complicate things. The library comes with an executable that is used to run missbehave tests. This means that
you can not just run the test file itself using csi. That also means that you can't compile your test file which also means you can not use FFI calls.
Also the chicken CI expects the tests to work in a certain way and without going through some hoops it was not possible to run missbehave in the
context of [salmonella](http://tests.call-cc.org/). I added a way to do that later, as the following example shows:

~~~ clojure
(use missbehave missbehave-matchers missbehave-stubs srfi-1)

(run-specification
  (call-with-specification
    (make-empty-specification
      (lambda ()
        (it "should work")))))
~~~

Not exactly short, but it did work to some degree. The more problematic part was, again, an implementation detail.
I had to use some hacks in conjunction with eval that I'm not very proud of. You can check the [sourcecode](https://bitbucket.org/certainty/missbehave/src/578b051764092dab0c5bd9c7d66640f44d281c25/behave.scm?at=default#cl-231) if you want to see it.

The last problem is that the way it was designed, it didn't work well (read: "didn't work at all") in the REPL and thus you could
not use it to throw in some quick verification right into the REPL to prove that you're on the right track.
That is really something that is bad for a lisp.


> I provided tools that didn't support the programming workflow

#### 6) Trust

This is a somewhat non-technical problem, but still I think it was a reason why the library failed.
Even I didn't have much trust in it. This may be partly
due to the messy implementation and partly because there really were things that just didn't work.
This lowered the overall trust in the library, and trust is an essential property of a tool that you use to make sure
that your code works. That means that the testing tool needs to work correct and work well.



### Missbehave: the good parts

Now that I've showed you some of the bad parts, it's time to look at the things that I didn't mess up totally. There are some things that are valuable.
Indeed some of these things will make it into a new library that intents to honor the language more. It's a work in progress, but
if you're curious you can take a peek at [veritas](https://bitbucket.org/certainty/veritas).

#### 1) The matcher abstraction

Missbehave introduced an abstraction called a matcher, that was used to verify expectations. A matcher, in missbehave, is
a higher order function that knows how to verify the behavior of the subject that is passed to it.
Also it knows how to generate messages for the failure and success case.
Matchers serve two goals.

1. They are a means to extend the test library. That's a very lispy approach as lisp itself is intended to be extended
  by custom functions that look as if they belong to the lisp/scheme core itself.

2. They shall improve the expressiveness of the test. By creating clever matchers the source code
  is able to express what happens more clearly, possibly using vocabulary from the problem domain.

The following code snippet shows the matcher abstraction to provide new matchers.

~~~ clojure
 (use missbehave missbehave-matchers srfi-1)

 (define (contain what)
   (matcher
	(check (subject)
	  (member what (force subject)))
	(message (form subject negate)
	  (if negate
		(sprintf "Expected ~a not to contain ~a" (force subject) what)
		(sprintf "Expected ~a to contain ~a" (force subject) what)))))

 (expect (iota 10) (to (contain 3)))
~~~

There are quite many matchers that are built into the library, but
you can also provide your own with ease. It provides nice messages and enables more expressive tests.
Note that you can achieve something like that using the [test egg](http://wiki.call-cc.org/eggref/4/advice) as well.

~~~ clojure
 (use test)

 (define contains (flip member)))

 (test (contains (iota 10) 5))
~~~

This exploits the fact that the test-library uses a pretty printed form of the expression as the title for the test if no title has
been given. For more complicated things, this doesn't work so well though. Also note that missbehave does a similar thing if
you use the simplest form:

~~~ clojure
 (use missbehave missbehave-matchers srfi-1)

 (expect (> 2 1))
~~~

This will automatically generate a message that uses the expression itself.


#### 2) Meta information and filters

The library provided a way to attach meta data to examples and contexts. The user could then use filters to run only examples that
have corresponding meta-data. This is a valuable feature as it gives you fine grained control over which tests are run.
For example you might have platform dependent tests, that you only want to run on the matching platform. You could tag your tests
with the OS they support and run them filtered. Another example would be fast and slow tests, where you generally want to run the slow tests
during CI but not during development. I think this is really useful, but it should be opt-in. And it should be orthogonal to the
other features. In missbehave the syntax for examples and contexts supported a variation that was used to declare meta-data.
In that regard this feature was bound to their syntax. What I want instead is to let this be composable and usable "a la carte".
That means I want you to be able to mix and match contexts and meta-data  without requiring them to know from each other.

In missbehave it looks something like this:

~~~ clojure
 (use missbehave)

 (context "Test"
   (it "has some meta-data" (meta ((issue-id . 1234)))
     (expect #t)))
~~~

As a sneak preview, this is what I currently have in mind for veritas:

~~~ clojure
 (use veritas)

 (meta (os: 'linux pace: 'slow)
   (verify #t))

 (meta (os: 'linux)
   (context "this is some context"
	 (verify #t)))
~~~

So that's completely orthogonal to the notion and syntax of contexts and examples. Also I want meta-data to compose in the way that
nested meta data "adds up", so that the inner most expression holds the union of all meta-data surrounding it.

#### 3) Pending tests

Pending tests are extremely valuable and I don't quite understand why they are not supported by the test egg, or at least not directly.
As the name suggests you can temporarily disable the execution of tests by marking them pending. The point is that these tests aren't run,
but they are reported as being pending, so that you know that they are actually there. This means, that you can't accidentally forget them.
In missbehave you can define a pending tests in two ways. The first way is to mark it explicitly as pending as the following example shows:

~~~ clojure
 (use missbehave missbehave-matchers missbehave-stubs )

 (describe "Pending"
  (it "is explicitly pending"
	(pending)
	(expect '() (be a number))))
~~~


As you see you could add a call to pending at any point in the expectation which would make the expectation exit early and skip the
verification machinery. The second way is to make an example implicitly pending by omitting the body.

~~~ clojure
 (use missbehave missbehave-matchers missbehave-stubs )

 (describe "Pending"
   (it "is implicitly pending"))
~~~

This is especially nice, if you start by outlining the things you intend to test and then you fill in the actual code.
This way it's hard to forget some of the tests.

So this is really something that is valuable and will be added to veritas as well, but in a slightly different way.
Again I want it to be usable a-la-carte and compose well. This is what it will probably look like in veritas:

~~~ clojure
 (use veritas)

 (pending "some reason"
  (verify #f))
~~~

### What now?

Another framework? Yes, that's what I'm working on. I believe that diversity is a good thing and having the choice
between different tools for the same task is good. What I aim at is a library that:

1. embraces the host language
2. focuses on value and state verification
3. works nicely in the REPL
4. is small, composable and works well
5. fits in the existing infrastructure
6. incorporates some ideas from missbehave
7. enables quick-check like tests

You can have a look here two projects in that direction:

* [veritas](https://bitbucket.org/certainty/veritas)
* [data-generators](https://bitbucket.org/certainty/data-generators)

I'll blog about them once there is something to say.

### Wrap up

I hope you enjoyed this little journey through all my failures. It has certainly been a pleasure for me and a healthy way to look at the "monster" I've made.
I'm sure there is still much to learn for me and I'm open to it. I want to thank all the helpful people that provided valuable feedback for this post
and for missbehave.

<strong>I for one will continue to improve, which means I will continue to fail. Promised! ;)</strong>
