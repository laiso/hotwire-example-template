# Hotwire: Typeahead searching

Let's build a collapsible search-as-you-type text box that expands to
show its results in-line while searching, supports keyboard navigation
and selection, and only submits requests to our server when there is a
search term.

We’ll start with an out-of-the-box Rails installation that utilizes
Turbo Drive, Turbo Frames, and Stimulus to then progressively enhance
concepts and tools that are built directly into browsers. Plus, it’ll
degrade gracefully when JavaScript is unavailable!

The code samples contained within omit the majority of the application's
setup. While reading, know that the application's baseline code was
generated via `rails new`. The rest of the source code from this article
can be found [on GitHub][].

[on GitHub]: https://github.com/thoughtbot/hotwire-example-template/commits/hotwire-example-typeahead-search

Our haystack
---

We'll be searching through a collection of Active Record-backed
`Message` models, with each row containing a [TEXT][] column named
`body`. Let's use Rails' `scaffold` [generator][] to create application
scaffolding for the `Message` routes, controllers, and model:

```sh
bin/rails generate scaffold Message body:text
```

For simplicity's sake, our application will rely on SQL's [ILIKE][]-powered
pattern matching. Once implemented, the experience could be improved by more
powerful search tools (e.g. PostgresSQL's [full-text searching][] capabilities).

[TEXT]: https://www.postgresql.org/docs/12/datatype-character.html
[generator]: https://guides.rubyonrails.org/command_line.html#bin-rails-generate
[ILIKE]: https://www.postgresql.org/docs/12/functions-matching.html#FUNCTIONS-LIKE
[full-text searching]: https://www.postgresql.org/docs/12/textsearch.html

Searching for our needle
---

First, we'll declare the `searches#index` route to handle our search
query requests:

```diff
--- a/config/routes.rb
+++ b/config/routes.rb
 Rails.application.routes.draw do
   resources :messages
+  resources :searches, only: :index
   # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
 end
```

Next, add a `<header>` element to our layout. While we're at it, we'll
also wrap the `<%= yield %>` in a `<main>` element so that it's the
`<header>` element's sibling:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -15,6 +15,21 @@
   <body>
+    <header>
+    </header>
+
-    <%= yield %>
+    <main><%= yield %></main>
   </body>
 </html>
```

Within the `<header>`, we'll nest a `<form>` element that submits
requests to the `searches#index` route:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -15,6 +15,21 @@
   <body>
     <header>
+      <form action="<%= searches_path %>">
+      </form>
     </header>

     <main><%= yield %></main>
   </body>
 </html>
```

When declared without a `[method]` attribute, `<form>` elements default
to `[method="get"]`. Since querying is an [idempotent][] and [safe][]
action, the `<form>` element will make [GET][] HTTP requests when
submitted.

Within the `<form>`, we'll declare an `<input type="search">` to capture
the query and a `<button>` to submit the request:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
       <form action="<%= searches_path %>">
+        <label for="search_query">Query</label>
+        <input id="search_query" name="query" type="search">
+
+        <button>
+          Search
+        </button>
       </form>
```

[idempotent]: https://developer.mozilla.org/en-US/docs/Glossary/Idempotent
[safe]: https://developer.mozilla.org/en-US/docs/Glossary/Safe/HTTP
[GET]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/GET

Within the `searches#index` controller action, we'll transform the
`?query=` parameter into an argument for our `Message.containing` Active
Record [scope][].

```ruby
class SearchesController < ApplicationController
  def index
    @messages = Message.containing(params[:query])
  end
end
```

The `Message.containing` scope interpolates the `query` argument's text
into an [ILIKE][] statement with leading and trailing `%` wildcard
operators:

```diff
--- a/app/models/message.rb
+++ b/app/models/message.rb
 class Message < ApplicationRecord
+  scope :containing, -> (query) { where <<~SQL, "%" + query + "%" }
+    body ILIKE :query
+  SQL
 end
```

Within the corresponding `app/views/searches/index.html.erb` template,
we'll render an `<a>` element for each result. We'll pass each
`Message#body` to [highlight][] so that the portions of the text that
match the search term are wrapped with [`<mark>`][mark] elements.

```erb
<h1>Results</h1>

<ul>
  <% @messages.each do |message| %>
    <li>
      <%= link_to highlight(message.body, params[:query]), message_path(message) %>
    </li>
  <% end %>
</ul>
```

[scope]: https://edgeapi.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[Message.none]: https://edgeapi.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[set_page_and_extract_portion_from]: https://github.com/basecamp/geared_pagination/tree/v1.1.0#example
[highlight]: https://edgeapi.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-highlight
[mark]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/mark

## Enhancing our search

Currently, submitting our search `<form>` navigates our application,
resulting in a full-page transition. We can improve upon that experience
by navigating _part_ of our page instead.

[Turbo Frames][] are a predefined portion of a page that can be updated
upon request. Any requests from inside a frame from links or forms are
captured, and the frame's contents are automatically updated after
receiving a response. Frames are rendered as `<turbo-frame>` [Custom
Elements][], and have their own set of [attributes and properties][].
They can be navigated by descendant `<a>` and `<form>` elements _or_ by
`<a>` and `<form>` elements elsewhere in the document.

Let's render our search results _into_ a `<turbo-frame>` element. We'll
add the element as a sibling to our header's `<form>` element, making
sure to give it an `[id]` attribute:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
         <button type="submit">
           Search
         </button>
       </form>
+
+      <turbo-frame id="search_results"></turbo-frame>
     </header>
   </body>
```

To navigate it, we'll _target_ it with our search `<form>` by declaring
the [data-turbo-frame="search_results"][] attribute:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -17,7 +17,7 @@
-      <form action="<%= searches_path %>">
+      <form action="<%= searches_path %>" data-turbo-frame="search_results">
         <label for="search_query">Query</label>
         <input id="search_query" name="query" type="search">

         <button>
           Search
         </button>
       </form>

       <turbo-frame id="search_results"></turbo-frame>
```

Whenever our `<form>` element submits, Turbo will navigate the
`<turbo-frame id="search_results">` based on the `<form>` element's
[action][] attribute. For example, when a user fills in the `<input
type="search">` element with "needle" and submits the `<form>`, Turbo
will set the `<turbo-frame>` element's [src][] attribute and navigate to
`/searches?query=needle`. The request's [Accept][] HTTP Headers will be
similar to what the browser would submit had it navigated the entire
page.

In response, our server will handle the request like any other HTML
request, with one additional constraint: we'll need to make sure that
our response HTML [contains a `<turbo-frame>` element with an `[id]`
attribute that matches the frame in the requesting page][matching-id].

To meet that requirement, we'll wrap the contents of the
`searches#index` template in a matching `<turbo-frame
id="search_results">` element:

```diff
--- a/app/views/searches/index.html.erb
+++ b/app/views/searches/index.html.erb
+<turbo-frame id="search_results">
   <h1>Results</h1>

   <ul>
     <% @messages.each do |message| %>
       <li>
         <%= link_to highlight(message.body, params[:query]), message_path(message) %>
       </li>
     <% end %>
   </ul>
+</turbo-frame>
```

To ensure sure that the request's `<turbo-frame>` element `[id]` is
consistent with to the response's, we'll encode the identifier into the
`?turbo_frame=` query parameter as part of the `<form>` element's
`[action]` attribute:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -17,7 +17,7 @@
-      <form action="<%= searches_path %>" data-turbo-frame="search_results">
+      <form action="<%= searches_path(turbo_frame: "search_results") %>" data-turbo-frame="search_results">
         <label for="search_query">Query</label>
         <input id="search_query" name="query" type="search">

         <button>
           Search
         </button>
       </form>

       <turbo-frame id="search_results"></turbo-frame>
```

Then we'll encode the value into the rendered `<turbo-frame>` element's
`[id]` with a default value when the `param` is missing:

```diff
--- a/app/views/searches/index.html.erb
+++ b/app/views/searches/index.html.erb
-<turbo-frame id="search_results">
+<turbo-frame id="<%= params.fetch(:turbo_frame, "search_results") %>">
```

When an end-user clicks on a `<a>` element in the results, we'll want to
navigate the _page_, not the `<turbo-frame>` element that contains the
`<a>`. To ensure that, we have two options: annotate each `<a>` with the
[`data-turbo-frame="_top"`][] attribute, or annotate the `application`
layout template's `<turbo-frame>` element with the [`target="_top"`][]
attribute.

For the sake of simplicity, let's annotate the custom `<turbo-frame>`
element with the custom `[target]` attribute instead of annotating the
standards-based `<a>` element with a `data`-prefixed custom attribute:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
-      <turbo-frame id="search_results"></turbo-frame>
+      <turbo-frame id="search_results" target="_top"></turbo-frame>
```

[Turbo Frames]: https://turbo.hotwire.dev/handbook/frames
[Custom Elements]: https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_custom_elements
[attributes and properties]: https://turbo.hotwire.dev/reference/frames
[data-turbo-frame="search_results"]: https://turbo.hotwire.dev/handbook/frames#targeting-navigation-into-or-out-of-a-frame
[action]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form#attr-action
[src]: https://turbo.hotwire.dev/reference/frames#html-attributes
[Accept]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept
[matching-id]: https://turbo.hotwire.dev/reference/frames#basic-frame
[`data-turbo-frame="_top"`]: https://turbo.hotwired.dev/reference/frames#frame-with-overwritten-navigation-targets
[`target="_top"`]: https://turbo.hotwired.dev/reference/frames#frame-that-drives-navigation-to-replace-whole-page
