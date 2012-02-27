---
layout: post
title: "markdown format for blogging"
date: 2012-02-26 15:01
comments: true
categories: [study, markdown]
tags: [minutes, markdown]
---

## Markdown format 

### Blockquotes

Email-style ">" is used for blockquoting, example:

> Quoted content
> More contents follows with another leading >

> Lazy blocks
New lines can ommit the leading ">" while Markdown is smart enough to be aware of this.

> Nested quotes
> > Nested contents
>
> This is the outer quoted text.

Block quotes can contain other mark down syntax

> ## This is a header
> 1. First column
> 2. Second column
>
> Here is some example code:
> 
>         return shell_exec("echo $input| $markdown_script")

<!--more-->
### Lists (ordered and unordered)
Both bullet lists and numbered lists are supported.

Colors:

* Red
* Green
* Blue

The same as

+ Red
+ Green
+ Blue 

or

- Red
- Green
- Blue 

Numbered list
1. Bird
2. McHale
3. Parish


Lists can be intended:
1.   Number 1
1.   Number 2
1.   Number 3


Lists may contain multiple paragraphs

1.    The first paragraph in this list
      Contents continue

      Another paragraph

1.    Second one, par1

      Par2.
      > Qutoes inside the list sub-paragraph

----------------------------------------------------
## Special blocks

### code blocks

Code blocks can be formatted with a new line and an extra 8 spaces or 2 TABs. Exmple:

        #Some shell scripts
        cat log.txt | awk -F":" '{print $2}' | sort -n | wc -l


Span of code like the following function call as `sprintf()`

This is a line of code contains literal backtick ``There is a literal backtick (`) here ``

### Special link example

1. local link
    This is an example to refer to a local page, see [studyMaterials](/blog/categories/study/index.html).

1. implicit link
    Links to [Google][]

    Links to official guide, visit [Daring Fireball][] for more information.

1. link shortcuts
    
    This is a link to [sina][1].
    Another link to [163][2].

### Emphasis

1. Single asterisks *example*
2. Single underscore _example_
3. Double asterisks **double asterisks**
4. Double underscore __double underscore__
5. Emphasis in the middle of a word - T__his__ is an ex_am_ple
6. Literal asterisk \*literal asterisk\*

----------------------------------------------------
## Images/others

Image syntax has 2 styles:

* Inline syntax, like
    
        ![Alt text](/path/to/img.jpg)
        ![Alt text](/path/to/img.jpg "Optional title") 

    This is an image for my workspace ![Octopress workspace](/images/octopress-ws.png)
  

* Preference style, using
    
        ![Alt text][id]
    
    Here id is the name of a defined image index, the same example: ![my ws][4]


----------------------------------------------------
## Reference:
- Markdown syntax [link](http://daringfireball.net/projects/markdown/syntax)
- YAML Front matter [link](https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter)

[Google]: http://google.com/   "Google"
[Daring Fireball]: http://daringfireball.net/
[1]: http://google.com/   "Google"
[2]: http://www.sina.com.cn/ "Sina"
[3]: http://www.163.com/ "NetEase"   
[4]: /images/octopress-ws.png "my terminator workspace"
