---
layout: post
title: "YAML-YAML Ain't Markup Language"
date: 2012-02-26 17:13
comments: true
categories: [study]
tags: [yaml, programming, markdown]
---

## YAML - The language
* YAML is a markup language that dates back to 2001 by Clark Evants.

    Originally it's named as **Yet Another Markup Language**.

* It's human-readable data serialization format. 

    The purpose is to focus on data, than on doucmentation markup.

------------------------
## Features
* Provides structures that can be easily mapped to common data types in most high-level languages including:
    - list
    - associative array
    - scalar

* Indented outline and lean apperance
    - suited for configuration files
    - documentation headers like Markdown file header
    - well-suited for hierarchical data representation

* Line and whitespace delimiters are friendly to grep/perl/python/ruby operations

* Very easy for human read/write

<!--more-->
----------------------------
## Basic elements
* Lists
1. Conventional block format use hyphen+space to begin a new item - just like markdown syntax, exmple:

        ---#Favoriate movies
        - Casablanca
        - Roman Holiday
        - Kill Bill

2. Optional inline format use JSON similar syntax, like 

        [milk, pie, eggs, juice]


* Associate array
    
1. Keys are seperated from values by colon+space, like 

           name: John Smith
           age: 33

2. Inline blocks, like python dict
        
           {name: John Smith, age: 33}

* Block literal - strings don't require quotation.

----------------------------
## Basic elements
* Lists of associative arrays - can be composed by any of the format
    
        - {name:John, age:22}
        - name: Jason
          age: 27

* Associative array of lists - can be composed by any of the format

        men: [John, Bill]
        women: 
            - Mary
            - Susan

----------------------------
## Reference

The wiki page can be found [Here](http://en.wikipedia.org/wiki/YAML#Lists).

