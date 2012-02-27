---
layout: post
title: "hello octopress"
date: 2012-02-26 13:58
comments: true
categories: [blogging, study, markdown] 
tags: [octopress, minutes, languages, programming]
---

# Mark down syntax study

Here comes some execrcises to learn mark down.

## Programming language zoo

I used to dive into below programming languages in my 6-year's career as a programmer:

- Awk
- C
- C++
- Erlang
- Go
- Haskell
- Java
- Javascript
- Lisp
- Python
- Ruby
- Sed

<!--more-->

### Recent interest

- Ruby
- Haskell
- Python
- C
- C++

**Haskell kills your brain cells** The good thing is, you also get refreshed if you revert your mind to understand functional programming and familiar yourself with some background knowledges and be customed to thinking in recurisve style than loop/iterating style.

**Ruby and python share a lot** Both support functional programming, lambda, hash, array and OO as well. Closure in Ruby are more powerful than in python, and the implementation differs a lot with ruby respect to Lisp's real closure such that everything in the context is captured as reference in a closure.

**C is old yet powerful** An old language like C still gains broad acceptance around the world and has been on top of the TIOBE index for a long time. You can do everything including OO using C, but it's hard to follow DRY(*DONOT REPEAT YOURSELF*) strictly - projects written in C tends to be more fragile and contain smelly duplications and traps.

**C++ is really complicated** It's a powerful language and has a lot of features that take perfomance into consideration, which is one of the roots of its inherent complexity. Many programmers are familiar with this language or at least spend some time on it if they have some C background. C++ has 4 kinds of programming styles and any team can take some parts of them - it's silly to try to master every corner of the language. 

### Other general-purpose languages

- Java
- Javascript
- Go
- Erlange

**Java is used widely in enterprise environment** I don't spend much time on Java but can read most of the Java code since Java's readability tends to be good and lots of smelly code was written because this language is friendly to newbie programmers.

**Javascript is the king of web** More and more client side technologies are based on javascript, and its support for functional style programming, closure are seen in other languages.The most important thing about this language is its prototype based object model, which even allow object creation/clone/inheritance without ordinary OO constructors.

**Go/Erlang takes concurrency as a goal** Both are designed to use CSP model to simplify programming in the concurrency era - programs are expected to be scalable and adaptive to multi-core environment. Erlange has nodes to communicate with each other, while go uses channel and go routine.

### Small languages (domain specific languages)

- Sed
- Awk
- D script

Those are just small languages probably designed for certain special purpose. They all show their power in certain special scenario, for example on production environment UNIX server, it's not feasible to install or upgrade some modern scripting languages like Python/Ruby and you may need to filer some information from application logs or generate reports/statistics.

**AWK is awesome regarding performance** It's even faster than similar codes written in C while keeping small to extract some records based on a certain pattern.The pattern/action structure makes me think of Haskell's processing of switches. Sometimes the order of patter/action groups are important.

** D scripts are powerful when using mdb ** Pattern/action based structure is very similar to AWK. MDB providers and some C-style statistic functions are widely used to generate distribution diagrams to reveal the attached program's internal behavior. When you need to profile/optimize/troubleshoot triky issues on Solaris, don't miss MDB/D.

**Sed is widely used in shell scripts** I only used some basic commands like replace/delete/print. It's quite neat if you want to search for a configuration, extract it's value and cut part of the string with regular expression - using python/ruby seems overkill as you can finish such task by a pipeline.

