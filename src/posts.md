---
layout: page
title: Posts
permalink: /posts/
pagination:
  enabled: true
  collection: posts
  per_page: 10
---

<section class="section">
  <div class="container">
    <div class="content">
      {% assign posts = paginator.documents %} {% render "collection", collection: posts, metadata: site.metadata %}
      {% if paginator.total_pages > 1 %}
        <ul class="pagination">
          {% if paginator.previous_page %}
            <li>
              <a href="{{ paginator.previous_page_path }}">Previous Page</a>
            </li>
          {% endif %}
          {% if paginator.next_page %}
            <li>
              <a href="{{ paginator.next_page_path }}">Next Page</a>
            </li>
          {% endif %}
        </ul>
      {% endif %}
    </div>
  </div>
</section>
