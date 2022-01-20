---
layout: page
title: Projects
permalink: /projects/
pagination:
  enabled: true
  collection: projects
  per_page: 10
---

<section class="section">
  <div class="container">
    <div class="content">
      {% assign projects = paginator.documents %} {% render "collection", collection: projects, metadata: site.metadata %}
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
