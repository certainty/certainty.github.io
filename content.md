---
layout: page
title: Content Index 
---

I’ve just started my journey to become a (better) writer. The following index is for your convenience, in case you’re interested in any of my ramblings. 

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
