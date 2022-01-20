---
layout: home
---

<section class="hero is-white is-medium">
  <div class="hero-body">
    <div class="container has-text-centered">
      <div class="is-flex is-justify-content-center"	>
        <figure class="image is-128x128">
          <img class="is-rounded" src="/images/photo_at_beach_profile.jpg">
        </figure>
      </div>
      <p class="mt-2 is-size-4">
        Hi! I am James Garcia. I am a Ruby on Rails developer, and JavaScript is cool also. 😃
      </p>
    </div>
  </div>
</section>
<section class="section has-background-info-light">
  <div class="container">
    <div class="content">
      <h1 class="my-5 title has-text-centered">Latest Articles</h1>

      {% assign posts = collections.posts.resources | slice: 0, 6 %} {% render "collection", collection: posts, metadata: site.metadata %}

      {% if collections.posts.resources.size > 6 %}
      <div class="has-text-right">
        <a href="/posts/" class="button is-outlined">
          <span>Previous Articles</span>
          <span class="icon"><ion-icon name="chevron-forward-outline"></ion-icon></span>
        </a>
      </div>
      {% endif %}
    </div>
  </div>
</section>
<section class="section">
  <div class="container">
    <div class="content">
      <h1 class="my-5 title has-text-centered">Projects</h1>

      {% assign projects = collections.projects.resources | slice: 0, 6 %} {% render "collection", collection: projects, metadata: site.metadata %}

      {% if collections.projects.resources.size > 6 %}
      <div class="has-text-right">
        <a href="/posts/" class="button is-outlined">
          <span>Previous Projects</span>
          <span class="icon"><ion-icon name="chevron-forward-outline"></ion-icon></span>
        </a>
      </div>
      {% endif %}
    </div>
  </div>
</section>
