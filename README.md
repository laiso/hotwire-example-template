# Hotwire Example Template

We'll cover:

1. `<input type="radio">` change hides/shows management phone number
2. `<select>` change hides/shows management phone number and explanation
3. `<select>` change to fetch contents within a `<turbo-frame>`

## Our starting point

Collect a Building's address, along with whether or not it's owned or leased.
When it's leased, the form also requires that the management phone number is
provided.

## Radio buttons + Rendered + Disabled + Hidden

Introduce `fields` controller, route `input` events to `fields#expand`, render
`<fieldset disabled>` and use `disabled:hidden`

## "Other" Radio button option + Rendered + Disabled + Hidden

* Add third "other" value for `building_type`
* Add the `buildings.building_type_description` column and mark it required for
  "other" records

## Select + Rendered + Disabled + Hidden

* Replace `<input type"radio">` elements with a `<select>`

## Select + Fetched data

Rendering all possible combinations of Country and State would be far too
expensive:

```ruby
irb(main):001:0> country_codes = CS.countries.keys
=>
[:AD,
...
irb(main):002:0> country_codes.flat_map { |code| CS.states(code).keys }.count
=> 3391
```

When it suits your use-case, treat a change to a `<select>` as a `GET
/buildings/new` submission, encoding all current values into the URL, forwarding
those query parameter encoded values to the `Building` instance, then
re-rendering the page

## Select + Fetched data + Turbo Frame

* Preserve state (like focus and scroll depth) by scoping the submission to a
  `<turbo-frame>` element that wraps the State `<select>`

There are several ways to navigate the frame, including retrieving the
`<turbo-frame>` instance and updating the `[src]` attribute from JavaScript.

In this example's case, we'll programmatically click a visually hidden `<input
type="submit">` element to navigate the `<select>` element's ancestor `<form>`.
We get to render all the concrete details like the path and the frame ID, while
still relying on the browser's built-in form field encoding mechanisms to
transform the currently selected `<option>` value to a query parameter.

## Select + Fetched data + Turbo Frame + Turbo Stream

Imagine the form included a preview of some server-side calculation. For
example, calculating the arrival date whenever the Country and State pairing
changes. We'll introduce a `buildings/building` view partial to serve as the
server-side rendered data:

```erb
<%# app/views/buildings/_building.html.erb %>

<div id="<%= dom_id building %>">
  <p>Estimated arrival: <%= distance_of_time_in_words_to_now building.estimated_arrival_on %> from now.</p>
</div>
```

Our current solution that navigates a `<turbo-frame>` element could render that
server-generated preview, but what if the preview is elsewhere in the page?

We'll render the partial at the bottom of the form, as a sibling to the
`<turbo-frame>`:

```diff
--- a/app/views/buildings/new.html.erb
+++ b/app/views/buildings/new.html.erb
       </turbo-frame>

       <%= form.label :postal_code %>
       <%= form.text_field :postal_code %>
+
+      <%= render partial: "buildings/building", object: @building %>
     <% end %>

     <%= form.button %>
```

While it might be tempting to reach for [XMLHttpRequest][] or [fetch][] to
refresh the data whenever our Country `<select>` changes, using a
`<turbo-stream>` element might suit our use-case (and not in the way you might
be thinking!).

Most of the fanfare for Turbo Streams is in relation to Web Socket broadcasts or
Form Submissions, the `<turbo-stream>` element is an HTML like any other [Custom
Element][], and can be rendered directly into the `<html>` element.


[XMLHttpRequest]: https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
[fetch]: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
[Custom Element]: https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_custom_elements
