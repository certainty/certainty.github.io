---
layout: post
title: Testing your CHICKEN code
tagline: using the test egg in anger
datestring: 2014-04-11
tags: [scheme,test,chicken,testing]
---

Hello everybody and welcome back. In this article I'll attempt to introduce you to the very excellent [test egg](http://wiki.call-cc.org/eggref/4/test), which is a great way to do your unit-testing in CHICKEN.

It will start with a gentle introduction to unit testing in general, before we dive into the **test egg** itself. I'll present you a few **best practices**, that will help you to benefit most from your test code. After I've outlined the bells and whistles that come with **test**, I'm going to introduce you to **random testing** on top of **test**. Finally you'll be given some hints on how a useful Emacs setup to do testing in CHICKEN may look like.

You can either read this article as a whole, which is what I recommend, or cherry-pick the parts that you're interested in. Both will hopefully work out.

For those of you, who are fluent with **test**, there is probably not much new here. Still I'd love you to be my guest and read on. Don't hesitate to come back to me and tell me about things I've missed or things that you do differently. I'm eager to learn about your setup.

Now without further ado, let's go down this rabbit hole.

### A gentle introduction to testing

You probably heard, that testing your code is good practice and that every *serious* software engineer is obliged to do it. I do agree with this in general and the software engineers I know, do as well. While there seems to be a general agreement that tests are good, there are also different schools of testing. Some do the tests after their code, some do them before and yet others do them while they flesh out their functions in the REPL. I don't want to tell you, that there is only one true way to do it, but there are a few arguments that I'd like to make, that suggest that a particular school may have advantages. At first though, I want to give you a very brief overview of what testing gains you.

#### What does testing give you?

If done right, it gives you a reasonable amount of confidence, that the code you're testing works correctly. Your tests act like a specification for the code under test.
Secondly they give you a safety net that enables you to change your code and still make sure, that the code works as expected. This means that you're free to refactor without having to worry, that you broke some, probably distant, part of the code. That is not only true for yourself but also for another person, who wants to contribute to your code.

Closely related to this are regression tests, which are used to detect bugs, that have been fixed sometime in the past, but pop up again, after you have changed some portion of your code. Regression tests are an important part of a test suite. Once you discover a bug, you generally write a test that reproduces it. This test will be naturally be failing as the system/code under test doesn't behave as expected. The next step is to fix the bug and make the test pass. This must be contrasted with the sort of tests that are used to test your features. While those are
estimates for the correctness of your code, testing for bugs and fixing them can act as a proof. Of course there is no rule without an exception. [Bugs tend to come in clusters](http://testingreflections.com/node/7584) and can be grouped into categories or families. This means in practice that you may have fixed this particular bug but you're advised to look
for a generalization of that bug, that might occur elsewhere. Also you likely want to check the code, that surrounds the section that constitutes the bug. It has been shown empirically that it is likely to contain bugs as well. For a critical view on this theory, you might want to have a look at [this](http://www.developsense.com/blog/2009/01/ideas-around-bug-clusters).

Also tests often are a form of documentation. They describe the expected behavior of your code and thus give strong hints about how it shall be used. You may find that the documentation
of a project isn't very well. If it at least has a thorough test-suite, you can quickly learn the most important aspects of the library.

There are many more testing categories that all have their particular value. The literature is
full of those and I very much recommend reading some of it. The [reference section](#references) has a few links, that you may find useful.

#### What does testing not give you?

You write as much tests as needed to reach a level of confidence that you find sufficient.
This level may be either perceived intuitively or measured. A common way to measure it is the, so called, code coverage analysis. An analyzer runs your tests and checks which code paths they exercise. The result may be used to derive a metric for the developer on when he/she has good enough tests. This approach has some obvious flaws and a 100% coverage says nothing about
the quality of your tests. You can easily see that you can have tests that execute all of your code paths but simply do not verify their outputs. In this case you have 100% coverage, but actually
zero confidence that the code is correct.

While code coverage gives you a qualitative measure of your test code there is also a quantitative measure. That is the code to test ratio. It's as simple as it can be; it just tells you the proportion of your code and tests. Most people tend to agree that a ratio of 1:2 is about good. That means you have twice as much tests as you've got actual code. In my opinion that very much depends on the kind of project. If you happen to have many internal helper procedures and very few procedures that belong to the public API, then you most likely won't reach that ratio. If your code is mostly public API though then it may be actually close to the truth as each procedure is likely to have at least two tests. Again my advice is not to use that as an absolute measure but only as a guideline to verify that you're on the right track.

Another aspect that must be emphasized is that tests can never prove the absence of bugs, possibly with the exception of regression tests. If tests have been written **after** a certain bug occurred you have a high probability that this specific bug has been fixed. Apart from these though, tests are by no means a proof for the absence of bugs.

Tests are not a silver bullet and are not a replacement for good design and solid software engineering skills. Having great many tests that verify features of your application is comforting and all, but be assured that there will be a time when a bug pops up in your application. All your tests didn't do anything to prevent it. You're on your own.
Now you actually have to understand your system, reason about it and figure out what went wrong. This is another crucial part of developing
an application. You must make sure that you have a system that you can actually understand. Tests can help to develop such a system, as it has been shown that software that is easy to test is often also [simpler](http://www.infoq.com/presentations/Simple-Made-Easy), more focused and easier to comprehend.

#### If testing is that great, why do some people still don't do it?

I can't give you a universal answer to this, as there is probably a great variety of reasons, which might or might not be sensible. I've heard some reasons repeatedly though.

* **It is more work than just writing your application code**

  This one is true. Writing tests is an investment. It does cost more time, more money and more energy. But as with all good investments, they probably pay off in the end. It turns out that
  most of the time this is indeed the case. The longer a project exists, the more often you or someone else comes back to your code and changes it. This involves fixing bugs, adding new features, improving performance, you name it. For all those cases, you will spend significantly less time
  if you have a test-suite that helps you to ensure that all those changes didn't break anything.

* **It's hard to break the thing that you just carefully built**

  It's just not fun to try to destroy what you just built. Suppose you finished a procedure that has
  been really hard to accomplish. Now you're supposed to find a possible invocation in which it
  misbehaves. If you succeed you will have to get back at it and fix it, which will again be very hard eventually. There is an inner barrier, that subconsciously holds you back. I think we all agree that having found this misbehavior is better than keeping it buried, but the back of our
  mind might disagree, especially when it's Friday afternoon at 6pm.

* **It's not fun**

  I don't agree with that one, but I have heard that many times. I think that is possibly the
  consequence of the points above. If you create a mindset where tests are actually part of your
  code and are first class citizens of your project, then I think tests are at least as fun as the
  application code itself.

Of course there may be many more reasons. Just take these as an excerpt.

#### OK, I want to test. How do I do it?

While there is value in doing manual testing in the REPL or by executing your application by hand, you really also want a suite of **automated tests**. Automated means in practice, that you have written code that tests your application. You can run these tests and the result will tell you if and which tests have failed or passed. This makes your tests reproducible with minimum effort. You want to develop this test suite as you develop your application. If you test before your actual code or after is really up to you. There is one thing though that I want to point out. There is a general problem with tests, well a few of those but one is particularly important now: **How do you make sure, that your test code is correct?** It doesn't make much sense to put trust in your code because
of your shiny test-suite, when the test-suite itself is incorrect. Possibly all tests pass where they shouldn't or they don't pass but really should. While you could write tests for your tests, you may immediately see that this is a recursive problem and might lead to endless tests testing tests testing tests ....

This is one reason why doing tests **before** code might be helpful. This discipline is called [TDD](https://en.wikipedia.org/wiki/Test-driven_development). It suggests a work-flow, that we refer to as **"Red-Green-Refactor"**. **Red** means that we start with a failing test. **Green** means that we implement as much of the application code, that is needed to make this test pass. **Refactor** is changing details of your code without effecting the overall functionality. I don't want to go into details, but there is one aspect that is particularly useful.
If we start with a **red test**, we at least have some good evidence that our tests exercises portions of our code that don't yet work as expected, because otherwise the test would succeed. Also
if there are no errors, we have some confidence that the test code is correct. Also we have trust that we're testing the right thing before we make the test pass.
Contrast this with tests that you do after your code. You don't ever know if the tests would be failing in case the code didn't work correctly. You could update parts of your application code to emulate this, but that's often more work. This is what the TDD-folks consider good enough to make sure that the tests work correctly, so that they don't need a test-suite for a test-suite for a test-suite ....
There are other aspects of TDD that I don't cover here, like responding to difficult tests by changing your application code instead of
the tests. There is many more and I invite you to have a look at this methodology even if you don't apply it.
Personally I do test before and I do test after and also while I develop application code. I try though to test first, if it's feasible.

There are many best practices when it comes to testing. I can not name and explain all of them here. One reason is that I certainly don't know them all and the other is that there are too many.
A few of them are very essential though and I have often seen people violating them which made their tests brittle.

**&laquo;Always think about the value of the tests&raquo;**

Don't write tests just because someone said you must. Don't write tests, that don't improve the trust in your system. This can be a difficult decision. Test code is code just like your application code. It has to be written and maintained.

**&laquo;Think about interfaces not implementation&raquo;**

This means that your tests should not need to know about the internals of the procedures. You should just run them against your interface
boundaries. Doing so enables you to change your implementation and yet have your test-suite telling the truth about your system.

**&laquo;Keep your tests focused&raquo;**

Write enough test code to *"verify"* one aspect of your function but not more. For example if
you have three invariants that you can test for a given function, then you likely want three tests for them. The reason may not be
obvious but it should become clear in a moment. **There should be only one reason for a test to fail**. This is because the step after you noticed a failing test is to find out
what went wrong. If there are multiple possibilities why the test has failed, you have to investigate all paths.
Having one test for each of the invariants makes this task trivial as you immediately see what the culprit is.
The other aspect is, that it tends to keep your test code small, which means that you have fewer code to maintain and
fewer places that can be wrong. The attentive reader might have noticed that a consequence from this guideline is, that you
have more tests. This is totally true. You want to make sure that they execute fast then. A typical test-suite of unit-tests often contains
a rather large amount of small tests.

**&laquo;Keep your tests independent&raquo;**

This just means that tests should be implemented in such a way that, only the code inside the test you're looking at can make
the test fail or pass. In particular it must not depend on other tests. This is likely to occur when your code involves mutation of shared state.
Suddenly you may find that your test only passes, if you run the entire suite but fails if you run one test in isolation. This is obviously a
bad thing, as it makes your tests unpredictable. One way to automatically detect these kinds of dependencies is to randomize the
order in which tests are executed. This is useful as sometimes you're simply not aware of one test depending on another.

**&laquo;Keep your tests simple&raquo;**

Naturally tests are a critical part of your system. They are the safety net. You don't want them to contain bugs. Keeping them simple also means that it is easier to make them correct. Secondly they are easier to comprehend. Test-code should state as clearly as possible what it is supposed to do.


**&laquo;Keep your tests fast&raquo;**

This turns out to be a crucial feature of your test suite as well. If your tests are slow they will disrupt your work-flow. Ideally testing and writing code is smoothly intertwined. You test a little, then you code a little, then you repeat. If you have to wait for a long time for your tests to finish, there will be some point where you don't run them regularly anymore. Of course you can trim down your test-suite to just the tests that are currently important, but after you've finished the implementation of a particular procedure you will likely want to run the entire suite.

These guidelines apply to unit-tests in general. There are specific Do and Don'ts that apply to other kinds
of tests that I don't want to cover here. I hope this little introduction gave you enough information to go on with the rest of the article and you now have a firm grip of what I'm going to be talking about.

### Putting the test egg to work

You're still here and not bored away by the little introduction. Very good, since this is finally where the fun starts and we will be seeing actual code. CHICKEN is actually a good environment to do testing. Almost every egg is covered by unit-tests and within the community there seems to be a general agreement, that tests are useful. Additionally tests for CHICKEN extensions are encouraged particularly. We have a great continuous integration (CI) setup, that will automatically run the unit-tests of your eggs, even on different platforms and CHICKENS. You can find more information on [tests.call-cc.org](http://tests.call-cc.org/). I'll tell you a little more about this later. For now just be assured that you're in good company.

Let's continue our little journey now by implementing the well known [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) and building a suite of unit-tests for it. This is a fairly simple task and allows us to concentrate on the tests.

#### Prerequisites

You obviously need [CHICKEN](https://code.call-cc.org/) and you need the [test egg](https://wiki.call-cc.or/eggref/4/test).
You can obtain it with the lovely **chicken-install**. I assume you're familiar with it, but I'll give you the command line anyway.

```bash
 $ chicken-install test
```

#### The project layout

Once we've installed the test egg, we can have a closer look at the directory layout of our example project.
There is the top-level directory **stack**, which holds one scheme source file named **stack.scm**. This is where our application code resides. Furthermore there is a directory called **tests** which holds a single file named **run.scm**. The entire layout looks like this:

<pre>
 stack
 | - stack.scm
 | - tests
     | - run.scm
</pre>

This is the standard layout of a scheme project for CHICKEN. There are projects that have additional folders
and structure their files differently but the majority of projects look like this, so it is a good practice
to follow. You may have noticed, that this is also the standard layout of CHICKEN EGGS. They contain egg specific files like *.release-info, *.meta and *.setup, but apart from that, they look very much like this. Another reason to arrange your tests the way I showed you is that CHICKEN's CI at [salmonella](https://tests.call-cc.org) expects this layout. You can benefit from this service once you follow this convention. It's time to give **Mario** and **Peter** a big **"thank you!"**, as they made it possible.

#### Basic layout of the test file

Let's dive in now and start writing our first tests. For this purpose we're going to add a little skeleton to tests/run.scm, that looks like this.

~~~ clojure
 (use test)

 (test-begin "stack")
 (test-end "stack")

 (test-exit)
~~~

This little snippet is a useful template for the tests you write. It loads and imports the test egg. It encloses your
tests with a **(test-begin)** and **(test-end)** form. You will want to do this as **test** will print a summary for every
test within these boundaries. It contains information about how many tests have passed and how many tests have failed. It prints that summary at the very bottom,
so that you can't miss a failing test that has flitted across the screen. I've been bit by that many times.
Finally the last line in our test file should be **(test-exit)**. This will make the test process exit
with a status code that indicates the status of tests. If there have been any tests failing it will return with a non-zero
status code, which can be passed as an argument to the procedure and defaults to 1. Zero will be the status code if all tests have passed.

We'll start by adding the procedure that we obviously need at the beginning. We want a way to create an empty stack. I'll start with a test for it.

~~~ clojure
(use test)
(load "../stack.scm")

(test-begin "stack")
(test "make-stack creates an empty stack"
   #t
   (stack-empty? (make-stack)))
(test-end "stack")

(test-exit)
~~~

Let's have a closer look at this now. You see a new form there:

 **(test description expected expression)**

It takes multiple arguments. The first argument is a description string that gives a hint about
what this particular test attempts to verify. The next argument is the **expected value**. It can be any scheme value. The last argument is the scheme expression, that shall be tested. It will be evaluated and compared with the **expected value**.
This is actually the long form of the test macro. You can get by with the shorter form that omits the description string like so:

~~~ clojure
 (test 3 (+ 1 2))
~~~

That is very handy for multiple reasons. The most obvious reason is that you don't have to think of a fitting description.
The test egg is smart enough to use a pretty-printed form of the expression, which is (+ 1 2) in our little example, as the
description. Secondly you can use this feature to generate descriptions out of your expression that are still meaningful.
You just have to create a form that reads nicely. Let me clarify this:

~~~ clojure
 (test #t (member 3 (list 1 2 3)))
~~~

This will generate a description like this, which makes the purpose of the tests pretty clear.

<pre>
(member 3 (list 1 2 3)) .............................................. [<span style="color:green"> PASS</span>]
</pre>


OK, going back to the example above. I've added a little test that attempts to verify
that a stack created with make-stack is initially empty.
Let's run the tests now. You can do this by changing into the tests directory and running
the file with csi.

<pre>
  cd tests
  csi -s run.scm
</pre>

The output looks like this:

<pre>
-- testing stack -------------------------------------------------------------
make-stack creates an empty stack .................................... [<span style="color:red">ERROR</span>]

Error: unbound variable: stack-empty?
    (stack-empty? (make-stack))
1 test completed in 0.001 seconds.
<span style="color:red">1 error (100%).</span>
0 out of 1 (0%) tests passed.
-- done testing stack --------------------------------------------------------
</pre>

As you can see the test output indicates that something went wrong. The red **ERROR** clearly indicates this. This is test's way to tell us that a condition has been signaled.
The text following it shows the details, that make things clearer. It tells us that
we attempted to use a procedure that doesn't actually exist. This makes perfect sense since we didn't write any code yet. That's easy enough to mitigate.

~~~ clojure
 (define-record-type stack (create-stack elements) stack? (elements stack-elements stack-elements-set!))
 (define (stack-empty? stack) #t)
 (define (make-stack . elements) (create-stack (reverse elements))
~~~

I've added the minimal amount of procedures, that are needed to remove the error eventually.
Please note that I've chosen to represent the stack as a list internally.

<pre>
-- testing stack -------------------------------------------------------------
make-stack creates an empty stack .................................... [ <span style="color:green">PASS</span>]
1 test completed in 0.0 seconds.
<span style="color:green">1 out of 1 (100%) test passed.</span>
-- done testing stack --------------------------------------------------------
</pre>

This looks better. You can see that all tests we've written are now passing, as indicated by the green PASS on the right side. We've written enough code to make the tests pass, but it's easy to
see, that these tests are lying. The procedure (stack-empty?) always returns #t regardless of the argument. Let's add a test that verifies that a non-empty stack is indeed not empty. Our make-stack procedure allows us to specify initial elements of the stack so we have all we need to create our tests.

~~~ clojure
 (use test)
 (load "../stack.scm")

 (test-begin "stack")
 (test "make-stack creates an empty stack"
    #t
    (stack-empty? (make-stack)))

 (test "make-stack with arguments creates a non-empty stack"
    #f
    (stack-empty? (make-stack 'one 'two)))

 (test-end "stack")

 (test-exit)
~~~

Running these tests reveals the following:

<pre>
-- testing stack -------------------------------------------------------------
make-stack creates an empty stack .................................... [ <span style="color:green">PASS</span>]
make-stack with arguments creates a non-empty stack .................. [ <span style="color:red">FAIL</span>]
    expected #f but got #t
    (stack-empty? (make-stack 'one 'two))
2 tests completed in 0.002 seconds.
<span style="color:red">1 failure (50.0%).</span>
1 out of 2 (50.0%) test passed.
-- done testing stack --------------------------------------------------------
</pre>

This time the output tells us that one of our tests has passed and one has failed. The red **FAIL** indicates that an assertion didn't hold. I this case (stack-empty?) returned #t for the non-empty stack. This is expected as (stack-empty?) doesn't do anything useful yet. That shows the last possible result-type of a test. Please take a second and contrast a FAIL with an ERROR. ERROR indicates that a condition has been signaled whereas FAIL indicates that an assertion did not hold.
Let's quickly fix this and make all tests pass. stack.scm now looks like this:

~~~clojure
 (define-record-type stack (create-stack elements) stack? (elements stack-elements stack-elements-set!))
 (define (stack-empty? stack) (null? (stack-elements stack)))
 (define (make-stack . elements) (create-stack (reverse elements)))
~~~

Running the tests for these definitions results in the following output:

<pre>
-- testing stack -------------------------------------------------------------
make-stack creates an empty stack .................................... [ <span style="color:green">PASS</span>]
make-stack with arguments creates a non-empty stack .................. [ <span style="color:green">PASS</span>]
2 tests completed in 0.002 seconds.
<span style="color:green">2 out of 2 (100%) tests passed.</span>
-- done testing stack --------------------------------------------------------
</pre>

Very good! All tests are passing. We're in the green. Let's take the opportunity and refactor the test-code a bit. The first test asserts that the outcome of the procedure invocation is the boolean #t. Whenever you find yourself writing tests that look like **(test description #t code)**, then you might want to take the shorter **(test-assert)** form. It allows you to declare invariants of your procedures. Let's quickly do this in the test file.

~~~clojure
 (use test)
 (load "../stack.scm")

 (test-begin "stack")

 (test-assert "make-stack creates an empty stack"
    (stack-empty? (make-stack)))

 (test "make-stack with arguments creates a non-empty stack"
    #f
    (stack-empty? (make-stack 'one 'two)))

 (test-end "stack")

 (test-exit)
~~~

That reads a bit nicer. As every good refactoring, this one didn't change the semantic of our tests and consequently it didn't change the output that is generated, so I leave that out right now.
There are some more procedures, that are needed to make the stack actually useful. Let's continue by implementing **stack-push!**, which will allow us to add a single value to the stack.

~~~clojure
 (use test)
 (load "../stack.scm")

 (test-begin "stack")

 (test-assert "make-stack creates an empty stack"
    (stack-empty? (make-stack)))

 (test "make-stack with arguments creates a non-empty stack"
    #f
    (stack-empty? (make-stack '(one two))))

 (test-group "stack-push!"
   (test #f (stack-empty? (stack-push! (make-stack) 'item))))

 (test-end "stack")

 (test-exit)
~~~

You'll notice that I not only added a new test for **stack-push!** but also introduced the a new form: **(test-group)**. This form allows you to group related tests into a named context. Every group runs the tests it contains and finishes them with a status report, that tells you how many of the tests have failed and haw many have passed. I've added the group "stack-push!" that will hold all tests that are needed to cover the stack-push! procedure. While we're at it let's also create a group for make-stack. The test file now looks like this:

~~~clojure
 (use test)
 (load "../stack.scm")

 (test-begin "stack")

 (test-group "make-stack"
   (test-assert "without arguments creates an empty stack"
      (stack-empty? (make-stack)))

   (test "with arguments creates a non-empty stack"
      #f
      (stack-empty? (make-stack '(one two)))))

 (test-group "stack-push!"
   (test #f (stack-empty? (stack-push! (make-stack) 'item))))

 (test-end "stack")

 (test-exit)
~~~

The output that is generated reads like this:

<pre>
-- testing stack -------------------------------------------------------------

    -- testing make-stack ----------------------------------------------------
    without arguments creates an empty stack ......................... [ <span style="color:green">PASS</span>]
    with arguments creates a non-empty stack ......................... [ <span style="color:green">PASS</span>]
    2 tests completed in 0.0 seconds.
    <span style="color:green">2 out of 2 (100%) tests passed.</span>
    -- done testing make-stack -----------------------------------------------


    -- testing stack-push! ----------------------------------------------------------
    (stack-empty? (stack-push! (make-stack) 'item)) ................... [<span style="color:red">ERROR</span>]

Error: unbound variable: stack-push!
    1 test completed in 0.0 seconds.
    <span style="color:red">1 error (100%).</span>
    0 out of 1 (0%) tests passed.
    -- done testing stack-push! -----------------------------------------------------

2 subgroups completed in 0.007 seconds.
1 out of 2 (50.0%) subgroup passed.
-- done testing stack --------------------------------------------------------
</pre>

Look how groups are nicely formatted and separate your test output into focused chunks that
deal with one aspect of your API. Of course we see an ERROR indicating a condition as we didn't
yet implement the **stack-push!** procedure. Let's fix this now.

~~~clojure
 (define-record-type stack (create-stack elements) stack? (elements stack-elements stack-elements-set!))
 (define (stack-empty? stack) (null? (stack-elements stack)))
 (define (make-stack . elements) (create-stack (reverse elements)))

 (define (stack-push! stack item)
   (stack-elements-set! stack (cons item (stack-elements stack)))
   stack)
~~~

With these definitions all of our tests pass and we're back in the green. I'll fast forward now and show you the code and the tests that cover a little bit more of the API.

~~~clojure
 (use test)
 (load "../stack.scm")

 (test-begin "stack")

 (test-group "make-stack"
   (test-assert "without arguments creates an empty stack"
      (stack-empty? (make-stack)))

   (test "with arguments creates a non-empty stack"
      #f
      (stack-empty? (make-stack '(one two)))))

 (test-group "stack-push!"
   (test #f (stack-empty? (stack-push! (make-stack) 'item)))
   (test "pushing an item makes it the new top item"
       'two
        (let ((stack (make-stack 'one)))
          (stack-top (stack-push! stack 'two)))))

 (test-group "stack-top"
   (test "returns the only element for a stack with one element"
      'one
      (let ((stack (make-stack 'one)))
        (stack-top stack)))
   (test "returns the top-most element"
      'two
      (let ((stack (make-stack 'one 'two)))
        (stack-top stack))))

 (test-end "stack")

 (test-exit)
~~~

The code look like this:

~~~clojure
 (define-record-type stack (create-stack elements) stack? (elements stack-elements stack-elements-set!))
 (define (stack-empty? stack) (null? (stack-elements stack)))
 (define (make-stack . elements) (create-stack (reverse elements)))

 (define (stack-push! stack item)
  (stack-elements-set! stack (cons item (stack-elements stack)))
  stack)

 (define (stack-top stack)
   (car (stack-elements stack)))
~~~

We've added a few more tests for the **stack-top** API. Let's take a closer look at that procedure. It behaves well when the stack is non-empty, but what should happen if the stack is empty? Let's just signal a condition, that indicates that taking the top item of an empty stack is an error. The test egg gives us another form that allows
us to assert that we expect some piece of code to signal a condition. This form is **(test-error)**. Let's see what this looks like.

~~~clojure
 (use test)
 (load "../stack.scm")

 (test-begin "stack")

 (test-group "make-stack"
   (test-assert "without arguments creates an empty stack"
      (stack-empty? (make-stack)))

   (test "with arguments creates a non-empty stack"
      #f
      (stack-empty? (make-stack '(one two)))))

 (test-group "stack-push!"
   (test #f (stack-empty? (stack-push! (make-stack) 'item)))
   (test "pushing an item makes it the new top item"
       'two
        (let ((stack (make-stack 'one)))
          (stack-top (stack-push! stack 'two)))))

 (test-group "stack-top"
   (test "returns the only element for a stack with one element"
      'one
      (let ((stack (make-stack 'one)))
        (stack-top stack)))
   (test "returns the top-most element"
      'two
      (let ((stack (make-stack 'one 'two)))
        (stack-top stack)))
   (test-error "taking the top item from an empty stack is an error"
      (stack-top (make-stack))))

 (test-end "stack")

 (test-exit)
~~~

The last test in the test-group "stack-top" attempts to codify our assertion. Let's have a look at the output.
Instead of just invoking the tests normally, like we did before, I want to show you another feature of **test** that comes in handy. As we're currently
working on the implementation of **stack-top** we're not interested in the result of the other tests and would like to leave them out.
We can do so by applying a test filter. Take a look:

<pre>
TEST_FILTER="empty stack is an error" csi -s run.scm
</pre>

This will only run the tests which include the given text in their description. The filter can actually be a regular expression, so it is much more versatile than it appears at first. There is also the variable TEST_GROUP_FILTER which allows you to run test-groups that match the filter. However in the current implementation of test, it is not possible to filter groups within other groups. So setting TEST_GROUP_FILTER="stack-top" doesn't currently work. It will not run any tests since the filter doesn't match the surrounding group "stack". It would be a nice addition though.

The output with the filter expression looks like this:

<pre>
-- testing stack -------------------------------------------------------------
    -- done testing make-stack -----------------------------------------------

    -- done testing stack-push! ----------------------------------------------


    -- testing stack-top -----------------------------------------------------
    taking the top item from an empty stack is an error .............. [ <span style="color:green">PASS</span>]
    1 test completed in 0.0 seconds (2 tests skipped).
    1 out of 1 (100%) test passed.
    -- done testing stack-top ------------------------------------------------

3 subgroups completed in 0.007 seconds.
<span style="color:green">3 out of 3 (100%) subgroups passed.</span>
-- done testing stack --------------------------------------------------------
</pre>

**Please pay close attention to the output.** The test passes!
How can that be? We didn't even implement the part of the code which signals an error in the case of an empty stack.
This is a good example of why it is good practice to write your tests **before** your code. If we had written the tests after the code, we would've never noticed that the tests succeed even without the proper implementation, which pretty much renders these tests useless. The test passes already because it is an error to take the **car** of the empty list. Obviously just checking, that an error occurred is not enough. We should verify, that a particular error has been raised. The test library doesn't provide a procedure or macro that does this, which means we have to come up with our own. We need a way to tell if and which condition has been signaled in a given expression. For this purpose we'll add a little helper to the very top
of the test file and update the tests to use it.

~~~ clojure
 (use test)
 (load "../stack.scm")

 (define-syntax condition-of
   (syntax-rules ()
     ((_ code)
      (begin
        (or (handle-exceptions exn (map car (condition->list exn)) code #f)
            '())))))

 (test-begin "stack")

 ; ... other tests

 (test-group "stack-top"
   (test "returns the only element for a stack with one element"
      'one
      (let ((stack (make-stack 'one)))
        (stack-top stack)))
   (test "returns thet top-most element"
      'two
      (let ((stack (make-stack 'one 'two)))
        (stack-top stack)))
   (test "taking the top item from an empty stack is an error"
      '(exn stack empty)
       (condition-of (stack-top (make-stack)))))

 (test-end "stack")

 (test-exit)
~~~

With these definitions, let's see now if our tests fail. Running them reveals:

<pre>
-- testing stack -------------------------------------------------------------
    -- done testing make-stack -----------------------------------------------

    -- done testing stack-push! ----------------------------------------------


    -- testing stack-top -----------------------------------------------------
    taking the top item from an empty stack is an error .............. [ <span style="color:red">FAIL</span>]
        expected (exn stack empty) but got (exn type)
    (condition-of (stack-top (make-stack)))
    1 test completed in 0.0 seconds (2 tests skipped).
    <span style="color:red">1 failure (100%).</span>
    0 out of 1 (0%) tests passed.
    -- done testing stack-top ------------------------------------------------

3 subgroups completed in 0.007 seconds.
2 out of 3 (66.7%) subgroups passed.
-- done testing stack --------------------------------------------------------
</pre>

Aha! We have a failing test saying that we were expecting a condition of type **(exn stack empty)** but we actually got a condition of type **(exn type)**. Now we can go on and add the code that signals the correct condition.

~~~clojure
 (define-record-type stack (create-stack elements) stack? (elements stack-elements stack-elements-set!))
 (define (stack-empty? stack) (null? (stack-elements stack)))
 (define (make-stack . elements) (create-stack (reverse elements)))

 (define (stack-push! stack item)
  (stack-elements-set! stack (cons item (stack-elements stack)))
  stack)

 (define (assert-not-empty stack message)
   (if (null? (stack-elements stack))
     (signal
      (make-composite-condition
       (make-property-condition
        'exn
        'message message)
       (make-property-condition 'stack)
       (make-property-condition 'empty)))))

 (define (stack-top stack)
   (assert-not-empty stack "can't take top of empty stack")
   (car (stack-elements stack)))
~~~

This little helper signals an error if someone tries to retrieve the top item of an empty stack.
The test output look like this:

<pre>
-- testing stack -------------------------------------------------------------
    -- done testing make-stack -----------------------------------------------

    -- done testing stack-push! ----------------------------------------------


    -- testing stack-top -----------------------------------------------------
    taking the top item from an empty stack is an error .............. [ <span style="color:green">PASS</span>]
    1 test completed in 0.0 seconds (2 tests skipped).
    <span style="color:green">1 out of 1 (100%) test passed.</span>
    -- done testing stack-top ------------------------------------------------

3 subgroups completed in 0.007 seconds.
<span style="color:green">3 out of 3 (100%) subgroups passed.</span>
-- done testing stack --------------------------------------------------------
</pre>


This looks very good. We have added tests for this case and while doing so we introduced a nice little helper to handle
specific kinds of conditions. That's the usual way to do it. The test egg provides us with all the primitives that are needed
to build on. It does not attempt to solve every possible problem. This is very much in the spirit of scheme and the [prime clingerism](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.154.5197) (Greetings to Peter).
The next step is to run the entire test suite and check if still all other tests pass. I'll leave that out now but be assured that they all pass.
You have learned now most of the things that are needed to use the test egg for your own code. I want to finish this part and tell you something about the bells and whistles that test offers you.

### Bells and whistles of the test egg

The test egg is very configurable. It gives you a knob for almost every aspect of it. I often found myself wanting features from
test when I realized that they are already there. Test's author **Alex Shinn** did a very good job.

There are a few parameters that you want to be aware of.

#### current-test-epsilon

This is used for comparison of flonums. As you may know, it's not a good idea to use exact comparison on inexact numbers. The test egg uses a sensible default for this parameter, but you may want to set your own if you really need it.

#### current-test-comparator
This allows you to specify the procedure, that is used to compare the expected value to the actual value. It defaults to ***equal?**.


#### current-test-applier

This is a parameter, that allows you to hook into the testing machinery. The test applier is a procedure that receives the expected value and the code that produces the actual value as arguments (along with some other data) and is expected to run the verification and return a result that is understood by the **current-test-handler**. The cases in which you need to use this parameter are possibly rare but be assured that they exist. For the details of that API please have a look at test's code.

#### current-test-handler

This procedure receives the result of the application of **current-test-applier** to its arguments. It is responsible for the reporting in the default implementation of test. This is the place where the test results are written to the standard output. It's actually quite a useful thing.
You might consider a hypothetical case where you want to inform some GUI, about the results of your tests.
You can easily do this with this hook, just add a custom handler that does this.
One thing that I was thinking about to add, was a little extension that would allow you to plug in multiple listeners. It would still call the original test-handler but also notify listeners when tests PASS,FAIL or have an ERROR. You could have many listeners and all of them would be invoked in order.

#### current-test-filter
We've seen a version of this already. It's a list of predicates that are invoked with each test
and only the tests that produce #t will be run. This defaults to an implementation that retrieves filters from the **TEST_FILTER** environment variable.

#### current-test-group-filter
This is the same as above but does the filtering on test-groups. The environment variable that
is used in the default implementation is **TEST_GROUP_FILTER**.

#### current-test-skipper
This is related to filtering. It specifies a list of predicates that determine which tests
should **not** be run. The default implementation of it takes the **TEST_REMOVE** environment variable into account.

#### current-test-verbosity
This controls the verbosity of the tests. If it is set to #t it prints full diagnostic output.
If it is set to #f, however, it will only print a "." for passed and an "x" for failed tests.
This is useful when you have many tests and are only interested in the overall outcome and not the details. This parameter can also be controlled with the **TEST_QUIET** environment variable.

#### colorful output
By default the test egg will try to determine if your terminal supports colors and will use them in case it does. You can however explicitly turn colors on and off with the **TEST_USE_ANSI** environment variable. Set it to 0 to disable colors and use 1 in order to enable colors.

### Best practices when using the test egg

#### put your tests into tests/run.scm

It is common practice to put the tests into "tests/run.scm" relative to your project's root. Especially for eggs this is a good convention to follow since CHICKEN's CI will expect your tests to be exactly there. It will run your tests automatically and report the status of your egg back at [tests.call-cc.org](https://tests.call-cc.org).

#### enclose your tests in test-begin and test-end

This is especially useful for bigger test-suites, that easily fill more than one page of your screen. If you don't enclose your tests this way, you risk to miss failing tests as they flit across the screen unnoticed. You could also use TEST_QUIET=1 as you know by now, but that won't give you nice statistics.

#### use test-exit

Salmonella (CHICKEN's CI worker bee) will run your tests and check the exit code to determine whether they passed or failed. If you don't add this line you will leave no clue and the poor salmonella may report passing tests when there really something is badly broken. Also some other tools like the chicken-test-mode, which I will introduce later, determines the status of your tests this way. Apart from that, it's good practice in a UNIXy environment.

#### use (use) to load code of your egg

If you're testing an egg you should use **(use)** to load your code. Again this is due to the way salmonella works. It will install your egg before it executes your test code, so you're safe to just **(use)** it. As an aside: Salmonella will also change into your tests directory before it runs your tests.


#### use test filters and skippers to focus

This one thing I do regularly. If you don't want to follow it it's perfectly fine.
In order to run the tests that I'm currently working on and nothing else I put the string WIP into their description.

~~~clojure
 (test "WIP: this is the test I'm working on" #t #t)
~~~

Then I run the tests like so:

<pre>
TEST_FILTER="WIP" csi -s run.scm
</pre>

This is a pretty easy way to do it and it worked out pretty well.
You could use other indicators that allow filtering. For example you could mark slow tests with SLOW or tests that use an external API with NEEDS_API_FOO.


### Random testing with test-generative

What we have done so far was thinking about which properties of our code we want to test and then
creating inputs and validations which encode these properties. This is the somewhat classic approach that works really well and should be the foundation of your test suite. However there is another way to do your testing. It involves thinking about invariants of your procedures. Invariants are properties of your code that are always true. For example we can assert that for every non-empty list, taking the cdr of that list produces a list that is smaller than the original list.

~~~clojure
 (let ((ls (list 1 2 3)))
   (test-assert "taking the cdr produces a smaller list"
     (< (length (cdr ls)) ls)))
~~~

The **(test-assert)** form makes invariants explicit. Once you have your invariants you can feed
data to your procedures and run them to see if they hold. Thinking of data that can be fed
into procedures can be a tedious task. Wouldn't it be nice to have a way to generate the data
and just concentrate on your invariants? There is a little library [test-generative](https://wiki.call-cc.org/eggref/4/test-generative) that allows you to do this. It extends the test egg, so that you can use generated data in order to find an application that violates some invariant. This style of testing is quite common in the haskell world. The most famous implementation of this approach is the [quick-check library](http://hackage.haskell.org/package/QuickCheck).

#### Eliminating the programmer

It is sometimes good to let computers generate the data for our tests. This is simply because we as the designer of our API are much more likely to think within the constraints of the library. It's harder for us to come up with cases where it would break. I can imagine, you have experienced that many times with your own code. You seem to have thought of every possible input that would break your code, but as soon as someone else uses your procedure he/she finds a way to pass data that reveals a misbehavior of it.


#### Random testing in practice
Let me show you how testing with test-generative looks like. Suppose you have the following test file.

~~~clojure
 (use test test-generative)

 (test-begin "random-testing")

 (test-generative ((number (lambda () (random 10000))))
   (test-assert (negative? (* -1 number))))

 (test-end "random-testing")

 (test-exit)
~~~

You know the basic skeleton of a test file and the test-assert form by now, so let's concentrate on the new part. There is a **(test-generative)** form, that binds a random number between 0 and 10000 to the variable number and runs one assertion with it.

The general definition of test-generative is:

**(test-generative (bindings ...) test-code ...)**

It looks very much like a let and in fact that's on purpose. Bindings declare variable names that should be bound to the generated values. The right hand side of a binding expression must be a thunk. The value of this thunk is bound to the variable for exactly one iteration. What is an iteration? Well, test-generative will run the tests it encloses not only once but many times. Each run is called an iteration. The actual amount of iterations can be configured using the **current-test-generative-iterations** parameter. It defaults to 100, which means that your test-code will be exercised 100 times with 100 possibly different values for the given variables.

That particular test verifies one invariant. It states that for every number in the given range the result of multiplying that number with -1 results in a negative number. Let's see what happens:

<pre>
-- testing random-testing ----------------------------------------------------
(negative? (* -1 number)) ............................................ [ <span style="color:red">FAIL</span>]
    assertion failed
    iteration: 43
    seeds: ((number 0))
1 test completed in 0.002 seconds.
<span style="color:red">1 failure (100%).</span>
0 out of 1 (0%) tests passed.
-- done testing random-testing -----------------------------------------------
</pre>

It seems as if test-generative has proven us wrong. Indeed not every number multiplied by -1 results in a negative number. The additional data that is printed for every failing test now contains two more keys.

* **iteration:**
This is the iteration in which the test failed. In the example above it took 43 tries to find
a falsification

* **seeds:**
These are the variables and the values they were bound to when the test has failed. In our example
this is the variable **number** and it was bound to **0**.

Zero is a number, that is not negative when it is multiplied by -1. Let's fix that assertion to match the reality.

~~~clojure
 (use test test-generative)

 (test-begin "random testing")

 (test-generative ((number (lambda () (random 10000))))
   (let ((number* (* -1 number)))
     (test-assert (or (zero? number*) (negative? number*)))))

 (test-end "random-testing")

 (test-exit)
~~~

Now we're asserting that every number within the range multiplied by -1 is either 0 or negative. Let's see the output:

<pre>
-- testing random-testing ----------------------------------------------------
(or (zero? new-number) (negative? new-number)) ....................... [ <span style="color:green">PASS</span>]
1 test completed in 0.004 seconds.
<span style="color:green">1 out of 1 (100%) test passed.</span>
-- done testing random-testing -----------------------------------------------
</pre>

That looks very good. All tests are green. You may notice that you only get one output per test and not 100. The tests are invoked multiple times but you will only ever see a report once.

You may notice that having to come up with generator procedures for every kind of data you need, can quickly become messy and you probably repeat yourself alot across your test files.
As it turns out there already is a library, that gives you generators for various scheme types.
It's called [data-generators](https://wiki.call-cc.org/eggref/4/data-generators) and the generators it provides are compatible with the test-generative interface. The tests above could be rewritten using data-generators as follows:

~~~clojure
 (use test test-generative data-generators)

 (test-begin "random-testing")

 (test-generative ((number (gen-uint32)))
   (let ((new-number (* -1 number)))
     (test-assert (or (zero? new-number) (negative? new-number)))))

 (test-end "random-testing")

 (test-exit)
~~~

This simply generates a positive 32bit fixnum in each iteration using the (gen-uint32) generator.

#### Purity

You may notice, that this kind of testing imposes some restrictions on your code. As the tests are executed multiple times, you want to avoid to test procedures with side-effects. As a rule of thumb you should only ever test pure code with test-generative.

#### Model based testing

Model based testing is a very nice approach to testing. The idea is very simple. A procedure is validated against a model. That means that for every input the results of the procedure under test and the model are expected to be equal. Often you have a procedure that is correct but slow. Then you can use the slow model to verify the behavior of your faster versions. Let's take the following example:

~~~clojure
 (use srfi-13)

 (define (palindrome? input)
  (string=? input (string-reverse input)))
~~~

This is the definition of a procedure, that checks if a given string is a palindrome. It just verifies if the reverse of the string equals the string itself. That is an almost literal translation of the definition of a palindrome. It's easy to see that it is "obviously" correct, so it's a good candidate to be a model procedure. Let's first test it against some palindromes. Data-generators doesn't give us a palindrome generator but all the primitives needed to build one.

~~~clojure
 (use test test-generative data-generators srfi-13)

 (define (palindrome? input)
   (string=? input (string-reverse input)))


 (define (gen-palindrome)
  (gen-transform (lambda (str) (string-append str (string-reverse str))) (gen-string-of (gen-char (range #\a #\z)))))

 (test-begin "palindrome")

  (test-generative ((str (gen-palindrome)))
   (test-assert (palindrome? str)))

 (test-end "palindrome")

 (test-exit)
~~~

This shows how to build a custom generator that builds palindromes for us. It does this by simply generating a string and then appending the reverse of that string to it.
With these definitions we can codify the invariant that our faster algorithm should behave like our model.

~~~clojure
 (define (fast-palindrome? input)
   (cond
    ((string-null? input) #t)
    (else
     (do ((i 0 (add1 i))
          (j   (sub1 (string-length input)) (sub1 j)))
         ((or (not (char=? (string-ref input i) (string-ref input j)))
              (>= i j))
          (<= j i))))))

 (test-generative ((str (gen-sample-of (gen-string-of (gen-char)) (gen-palindrome))))
   (test-assert (eq? (palindrome? str) (fast-palindrome? str))))
~~~

We've added a faster version of palindrome? and added the tests that are needed to signify the invariant. Mind the generator that now not only generates palindromes but also
strings that are likely to not be a palindrome. For all these inputs we want fast-palindrome? to deliver the same result as palindrome? The output indeed shows that they do. I'll leave it
out though as it is nothing new.

Often times you will test against some procedure, that has already been defined by someone else and that you put great trust into. For example let's suppose we want to write a faster multiplication procedure that attempts to optimize by adding a fast path in case one of the arguments is 0.

~~~clojure
(define (fast-* x y)
  (cond
   ((zero? x) x)
   ((zero? y) y)
   (else (* x y))))
~~~

This looks like a reasonable optimization. Let's see what our model based testing reveals:

~~~clojure
 (use test test-generative data-generators)

 (define (fast-* x y)
   (cond
    ((zero? x) x)
    ((zero? y) y)
    (else (* x y))))

 (test-begin "fast-mul")

 (test-generative ((x (gen-sample-of (gen-fixnum) (gen-flonum)))
                   (y (gen-sample-of (gen-fixnum) (gen-flonum))))
   (test-assert (= (* x y) (fast-* x y))))

 (test-end "fast-mul")

 (test-exit)
~~~

Running these tests might show the following output:

<pre>
-- testing fast-mul ----------------------------------------------------------
(= (* x y) (fast-* x y)) ............................................. [ <span style="color:red">FAIL</span>]
    assertion failed
    iteration: 6
    seeds: ((x 0.821921655141171) (y +nan.0))
1 test completed in 0.002 seconds.
<span style="color:red">1 failure (100%).</span>
0 out of 1 (0%) tests passed.
-- done testing fast-mul -----------------------------------------------------
</pre>

Oh oh, as you can see our optimization isn't actually valid for flonums. The flonum generator also generated +nan.0 which is a special flonum that doesn't produce 0 when it is multiplied with 0. IEEE requires NaN to be propagated. In fact this optimization is only valid for fixnums. Thanks to our automated tests we found out about that case and will refuse to try to be smarter than core.

There are more applications for these kinds of tests and they often serve as a good basis for a thorough test-suite.

### Integrating tests into your Emacs work-flow

You're still here? That's good. We're half way through already! I'm just kidding. This is the last section, in which I want to tell you about some ideas, that allow you to integrate testing into your development work-flow using our great Emacs editor.
If you don't use Emacs, you won't gain much from this paragraph. In that case I'd like you
to go on with the [Wrap up](#wrap-up).

Having all the great tools to do your testing is valuable but you also want to have a way
to integrate testing into your development work-flow. In particular you might want to be able to run
your test-suite from within Emacs and work on the test results. I created a little extension
for Emacs that aims to provide such an integration. It is currently work in progress but I use
it regularly already. You can find **chicken-test-mode** [here](https://bitbucket.org/certainty/chicken-test-mode/overview).

#### What does it give you?

This mode is roughly divided into two parts. One part gives you functions that allow you to run your test-suite. The other part deals with the navigation within your test-output. Let us dive in and put the mode to practice. Suppose you have installed the mode according to the little help text, that is in the header of the mode's source file.
I further assume that we're working on the stack example from the beginning of this article. I have opened up a buffer that holds the scheme implementation file of the stack. We need to adjust the test file to load the implementation differently.

~~~clojure
 (use test)
 (load-relative "../stack.scm")

 ; .... tests follow
~~~

This enables us to run the tests from within Emacs without problems.

#### Running tests within Emacs

With these definitions in place I can now issue the command **C-c t t** which will run the tests, open up the CHICKEN-test buffer and put the output of your tests there. In my setup it looks like this:

<a href="/images/posts/testing_chicken/run-tests.png">
  <img src="/images/posts/testing_chicken/run-tests_thumb.png">
</a>

You can click on the image to load it full-size. You see two buffers opened now. The buffer
on the left side holds the application code and the buffer on the right side holds the output
of the tests. What you can not see here is that there will be a mini-buffer message telling you
whether the tests have all passed or if there were failures.

#### Navigating the test output

You can now switch to the test buffer (C-x o). Inside that buffer you have various possibilities to navigate. Just hitting **P** will allow you to step through each test backwards.
Hitting **N** will do the same thing but forward. Things get more interesting when there are failures. So let's quickly introduce some failures and see what we can do.

~~~clojure
 (use test)
 (load-relative "../stack.scm")

 (test-begin "stack")

 (test-group "make-stack"
  ; ... tests
  )

 (test-group "stack-push!"
  ; ... tests
  )

 (test "this test shall fail" #t #f)

 (test-group "stack-top"
  ; ... tests
  )

 (test "this test shall fail too" #t #f)

 (test-end "stack")

 (test-exit)
~~~

As you can see, I added two failing tests. When I run the tests again, the buffer opens up and shows me the output which contains failures now.
I can change to the buffer **(C-x o)** and hit **f** which will bring me to the **f**irst failing test. In my case it looks like this:

<a href="/images/posts/testing_chicken/run-tests-w-failures.png">
  <img src="/images/posts/testing_chicken/run-tests-w-failures_thumb.png">
</a>

The first failing test has been selected and the line it occurs in has been highlighted.
You can jump straight to the **n**ext failing test by hitting **n**.
Likewise you can hit **p** to jump to the **p**revious failing test. Lastly you can hit
**l** to jump to the last failing test.
If you're done you can just hit **q** to close the buffer.

#### More possibilities to run tests

Beside running the full test-suite, you can also apply a filter and run only those tests that
match it. Let's suppose that we only want to run the tests that contain the text "top-most". In reality you might want to mark your tests specially, as I have already described in the best practices section. To run tests filtered you can type **C-t f** which will ask you for the filter to apply. It looks like this:

<a href="/images/posts/testing_chicken/run-tests-w-filter.png">
  <img src="/images/posts/testing_chicken/run-tests-w-filter_thumb.png">
</a>

Mind the mini-buffer. It asks for the filter to use. Now once you hit enter you get the filtered results that look like this:


<a href="/images/posts/testing_chicken/run-tests-w-filter-apply.png">
  <img src="/images/posts/testing_chicken/run-tests-w-filter-apply_thumb.png">
</a>

There is a little bit more like removing tests and running filters on test-groups. Check out the project to learn about all its features. I'm currently thinking on how to implement a function that allows you to test the procedure under point. That would be relatively easy for tests, that don't use description strings but use the short test form which will pretty print the expression. With that in place you could run a filtered tests, that only includes tests, that have the name of the procedure in their description. It's not exactly elegant but it may work. In the mean time the things that are already are hopefully helpful.

### Wrap up

Wow, you've made it through the article. It has been a long one, I know. I have hope that I did not bore you to death. You've learned alot about CHICKEN's test culture and the tools you have
at your disposal to address your very own testing needs. I hope that the information provided here serves as a good introduction. Please feel free to contact me if that's not the case or if things are just plain wrong.

# References

* [xunit test patterns](http://xunitpatterns.com/)
* [regression testing](https://en.wikipedia.org/wiki/Regression_testing)
* [black swans](http://testingreflections.com/node/7584)
* [ideas around bug clusters](http://www.developsense.com/blog/2009/01/ideas-around-bug-clusters)
* [test](https://wiki.call-cc.org/eggref/4/test)
* [test-generative](https://wiki.call-cc.org/eggref/4/test-generative)
* [data-generators](https://wiki.call-cc.org/eggref/4/data-generators)
* [chicken-test-mode](https://bitbucket.org/certainty/chicken-test-mode/overview)
