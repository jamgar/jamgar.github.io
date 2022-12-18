---
layout: home
---

<section class="h-full py-20">
  <div class="flex flex-col px-4 py-8 justify-center items-center sm:flex-row">
    <div class="w-48 mr-8">
      <img class="rounded-full" src="/images/photo_at_beach_profile.jpg">
    </div>
    <div class="text-center sm:text-left">
        <h1 class="mb-4 text-4xl font-bold text-gray-800 tracking-tight leading-none md:text-5xl xl:text-6xl">
          Hi! I am James Garcia.
        </h1>
        <p class="font-light text-gray-500 md:text-lg lg:text-xl">
          I am a <span class="text-red-500 font-semibold">Ruby on Rails 💎</span> developer, and JavaScript is cool too. 😃
        </p>
    </div>
  </div>
</section>
<section class="bg-gray-100 py-10 px-4">
  <h2 class="mb-10 text-4xl tracking-tight font-bold text-gray-800 text-center">Latest Articles</h2>

  {% assign posts = collections.posts.resources | slice: 0, 6 %} {% render "collection", collection: posts, metadata: site.metadata %}

  {% if collections.posts.resources.size > 6 %}
  <div class="">
    <a href="/posts/" class="btn bg-gray-700">
      <span>Previous Articles</span>
      <span class="text-gray-300" aria-hidden="true">&rarr;</span>
    </a>
  </div>
  {% endif %}
</section>
<section class="py-10 px-4">
  <h2 class="mb-10 text-4xl tracking-tight font-bold text-gray-800 text-center">Projects</h2>

  {% assign projects = collections.projects.resources | slice: 0, 6 %} {% render "collection", collection: projects, metadata: site.metadata %}

  {% if collections.projects.resources.size > 6 %}
  <div class="">
<a href="/projects/" class="btn bg-gray-700">
  <span>Previous Articles</span>
  <span class="text-gray-300" aria-hidden="true">&rarr;</span>
</a>
  </div>
  {% endif %}
</section>
