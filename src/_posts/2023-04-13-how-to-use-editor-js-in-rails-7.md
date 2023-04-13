---
layout: post
title: How to use Editor.js in Rails 7
date: 2023-04-13T20:05:48.175Z
categories: Rails
---
![editor JS hero](/images/editorjs-hero.png)

In this article I will step through adding [Editor.Js](https://editorjs.io/) to a Rails 7 app. Lets start with creating the Rails app.

```ruby
rails new editor-js-app --javascript=esbuild
```

So we have a resource to work with let's scaffold Articles.

```ruby
rails generate scaffold article title body:json
```

Now open the migration `<timestamp>_create_articles.rb`, and update the body to have a default value of "{}".

```ruby

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.json :body, default: {} # <= update this line

      t.timestamps
    end
  end
end

```

Save and then run `rails db:migrate` to create the table.

Next we will add the Editor.js and some Block tools. If you only add the Editor.js it will come with a default Text (a.k.a. paragraph) tool. With the extra ones you will have the option for a Header and Text tool with alignment options. In the terminal run:

```
yarn add @editorjs/editorjs @editorjs/header editorjs-paragraph-with-alignment@3.x
```

To connect the editor to our articles we will use a Stimulus controller. Lets create the controller. In the terminal run:

```
rails generate stimulus editor
```

This create the `editor_controller.js` in the `app/javascript/controllers` folder and update the `index.js` in the same folder to register the controller. Open the `editor_controller.js` and overwrite the code with the following:

```javascript
import { Controller } from "@hotwired/stimulus"
import EditorJS from '@editorjs/editorjs';
import Paragraph from 'editorjs-paragraph-with-alignment';
import Header from '@editorjs/header';

export default class extends Controller {
  static targets = [ "body" ]
  static values = { 
    readonly: Boolean,
    editordata: String 
  }

  connect() {
    let body = this.editordataValue ? JSON.parse(this.editordataValue) : {}
    this.editor = new EditorJS({
      holder: 'editorjs',
      tools: {
        paragraph: { 
          class: Paragraph,
          config: {
            placeholder: 'Enter text'
          }
        },
        header: {
          class: Header,
          shortcut: 'CMD+SHIFT+H',
          config: {
            placeholder: 'Enter a header',
            levels: [1,2,3,4],
            default: 3
          }
        },
      },
      readOnly: this.readonlyValue,
      data: body,
      onChange: async () => {
        let content = await this.editor.saver.save();
        this.bodyTarget.value = JSON.stringify(content)
      },
    });
  }

  disconnect() {
    if (this.editor) {
      this.editor = null
    }
  }
}

```

The following will import the packages we added through yarn

```javascript
import EditorJS from '@editorjs/editorjs';
import Paragraph from 'editorjs-paragraph-with-alignment';
import Header from '@editorjs/header';
```

The following will are Stimulus data attributes that you can reference. In are case we will be targeting a data attribute called "body" to put information and getting values from data attributes called "readonly" and "editordata". We will be using these in the views and the Connect function in this same controller.

```javascript
  static targets = [ "body" ]
  static values = { 
    readonly: Boolean,
    editordata: String 
  }
```

The connect function is main part. Here we instantiate and configure the editor.js. First we are setting variable body to the value of `editordata` or and empty object `{}` this is based on the condition if this is a new article or an existing article. With a new article the `editordata` will not have any value. This body variable will set the `data` attribute in the editor configuration. 

The next item is the configuration of the editor. Holder is the id of the HTML attributes where the editorjs will be added. Tools are were we configure the Text, Header or whatever Block tool you bring in. In this case it is just those two. 

With the latest version of editor.js you can set the editor to be ReadOnly. I am using this in the show.html.erb page, which we will see later.

Lastly we see the onChange function this is called everytime a value is update in the editor. What is happening is here is that the save function is called on the values of the editor on each change. This will this insert the content into a hidden field in the form that will later be submitted and saved to the database. I could have made the submit to do a fetch POST call, but there was some unexpected behavior when I attempted this, which was basically it would cause an error of too many redirects. So came up with this implementation and stayed closer to what is already built into the rails forms. Also, if I recall correctly other WYSYWIG editors do the same with a hidden field.

```javascript
  connect() {
    let body = this.editordataValue ? JSON.parse(this.editordataValue) : {}
    this.editor = new EditorJS({
      holder: 'editorjs',
      tools: {
        paragraph: { 
          class: Paragraph,
          config: {
            placeholder: 'Enter text'
          }
        },
        header: {
          class: Header,
          shortcut: 'CMD+SHIFT+H',
          config: {
            placeholder: 'Enter a header',
            levels: [1,2,3,4],
            default: 3
          }
        },
      },
      readOnly: this.readonlyValue,
      data: body,
      onChange: async () => {
        let content = await this.editor.saver.save();
        this.bodyTarget.value = JSON.stringify(content)
      },
    });
  }
```

The disconnect function is just to do some memory clean up of the editor.

```javascript
  disconnect() {
    if (this.editor) {
      this.editor = null
    }
  }
```










