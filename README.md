# Hotwire: Mapping Locations with a Leaflet.js

[Leaflet.js][] is an open-source JavaScript library for mobile-friendly
interactive maps. In order to use it in our application, we'll need to
add it as an in-browser dependency, then configure it.

Creating our controller
---

First, let's declare a [Stimulus Controller][] to drive the map through
the Leaflet object instances. Let's use `leaflet` as the controller's
[identifier][] by declaring it in
`app/javascript/controllers/leaflet_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
}
```

Next, our controller will need an element in the [DOM][] to control.
We'll introduce the `locations/leaflet` partial, then render the
`locations/leaflet` it into the `locations/index` template:

By rendering a `<section data-controller="leaflet">` element, Stimulus
will connect the `Controller` descendant we've declared in
`app/javascript/controllers/leaflet_controller.js` whenever the
`<section data-controller="leaflet">` element is present in the
document.

Before we start making substantial changes to our new element, let's
extract a new `locations/leaflet` view partial:

```erb
<%# app/views/locations/_leaflet.html.erb %>

<%= tag.section data: {
  controller: "leaflet",
} do %>
  <h1>Map</h1>
<% end %>
```

```diff
--- a/app/views/locations/index.html.erb
+++ b/app/views/locations/index.html.erb
@@ -1,5 +1,10 @@
 <p id="notice"><%= notice %></p>

+<%= render partial: "locations/leaflet" %>

 <section id="locations">
   <h1>Locations</h1>
```

[Leaflet.js]: https://leafletjs.com
[Stimulus Controller]: https://stimulus.hotwire.dev/handbook/hello-stimulus#controllers-bring-html-to-life
[identifier]: https://stimulus.hotwire.dev/reference/controllers#identifiers
[DOM]: https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model

Utilizing Leaflet.js
---

Next, depend on Leaflet's JavaScript interface by importing the library
through [Skypack][]:

```diff
--- a/app/javascript/controllers/leaflet_controller.js
+++ b/app/javascript/controllers/leaflet_controller.js
+import L from "https://cdn.skypack.dev/leaflet@1.6.0"
 import { Controller } from "@hotwired/stimulus"

 export default class extends Controller {
 }
```

The Leaflet package also provides its own stylesheets, which we'll
consume through a [`<link>` element][link] referencing the assets via a
[Content Distribution Network][] (<abbr title="Content Distribution
Network">CDN</abbr>).

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
     <%= csp_meta_tag %>

     <link rel="stylesheet" href="https://unpkg.com/trix@1.3.1/dist/trix.css"></link>
+    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css"
+      integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
+      crossorigin="">

     <%= stylesheet_link_tag "inter-font", "data-turbo-track": "reload" %>
```

[Skypack]: https://docs.skypack.dev
[link]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link
[Content Distribution Network]: https://developer.mozilla.org/en-US/docs/Glossary/CDN

Creating the map
---

Each Stimulus Controller instance retains a reference to its
corresponding element, which it can access through its [element][]
property. In addition, a controller can access descendant elements
through [Stimulus-powered Targets][]. Since our map will rely on
the controller to manage additional context and state, let's declare a
descendant target element (marked by the `[data-leaflet-target="map"]`
attribute), and use that as our map element:

```diff
--- a/app/views/locations/_leaflet.html.erb
+++ b/app/views/locations/_leaflet.html.erb
@@ -0,0 +1,8 @@
 <%= tag.section data: {
   controller: "leaflet",
+  leaflet_geo_json_layer_value: geo_json_layer,
+  leaflet_tile_layer_value: tile_layer,
 } do %>
   <h1>Map</h1>
+  <article class="w-full h-96" data-leaflet-target="map"></article>
 <% end %>
```

After declaring the element's HTML, we'll define a matching [target][]
within our `leaflet` controller. Using the resulting `mapTarget`
property, we'll create an instance of [L.Map][] from within the
controller's [initialize()] callback:

```diff
--- a/app/javascript/controllers/leaflet_controller.js
+++ b/app/javascript/controllers/leaflet_controller.js
 import L from "https://cdn.skypack.dev/leaflet@1.6.0"
 import { Controller } from "@hotwired/stimulus"

 export default class extends Controller {
+  static get targets() { return [ "map" ] }
+
+  initialize() {
+    this.leaflet = L.map(this.mapTarget)
+  }
 }
```

Once the Leaflet map instance is initialized, we'll add an
[OpenStreetMap][]-powered [L.TileLayer][]. Our Leaflet instance will
need several configuration values and credentials to properly consume
the <abbr title="Open Street Map">OSM</abbr> tiles.

Out-of-the-box, Rails provides a robust configuration system through a
combination of the `config/` directory and
[Rails.application.config_for][]. We can leverage those utilities to
store and read our OSM configuration values. We'll declare them in a
`config/leaflet.yml` file:

```yml
shared:
  accessToken: your-access-token
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  id: mapbox/streets-v11
  maxZoom: 18
  templateUrl: https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}
  tileSize: 512
  zoomOffset: -1
```

Next, we'll read those values in a [custom configuration][] from within
our `config/application.rb`:

```diff
--- a/config/application.rb
+++ b/config/application.rb
@@ -18,5 +18,6 @@ module HotwireExampleTemplate
     #
     # config.time_zone = "Central Time (US & Canada)"
     # config.eager_load_paths << Rails.root.join("extras")
+    config.x.leaflet = config_for(:leaflet)
   end
 end
```

From our `locations/idnex` template, we'll read those values and pass it
into our `locations/leaflet` view partial as `tile_layer`:

```diff
--- a/app/views/locations/index.html.erb
+++ b/app/views/locations/index.html.erb
 <p id="notice"><%= notice %></p>

-<%= render partial: "locations/leaflet" %>
+<%= render partial: "locations/leaflet", locals: {
+  tile_layer: Rails.configuration.x.leaflet,
+} %>

 <section id="locations">
   <h1>Locations</h1>
```

From our view partial, we'll encode them into JSON then embed them
directly into HTML in a way that our `leaflet` controller instance can
access directly through [Stimulus-powered Values][]:

```diff
--- a/app/views/locations/_leaflet.html.erb
+++ b/app/views/locations/_leaflet.html.erb
 <%= tag.section data: {
   controller: "leaflet",
+  leaflet_tile_layer_value: tile_layer,
 } do %>
   <h1>Map</h1>
   <article class="w-full h-96" data-leaflet-target="map"></article>
 <% end %>
```

With the values present in the HTML, we'll need to extend our `leaflet`
controller to access the configuration JSON embedded into the
`[data-leaflet-tile-layer-value]` attribute. We'll first declare a
static `values` accessor to return a mapping the `tileLayer` key to
`Object` to direct to Stimulus on how to encode and decode the value:

```diff
--- a/app/javascript/controllers/leaflet_controller.js
+++ b/app/javascript/controllers/leaflet_controller.js
 import L from "https://cdn.skypack.dev/leaflet@1.6.0"
 import { Controller } from "@hotwired/stimulus"

 export default class extends Controller {
   static get targets() { return [ "map" ] }
+  static get values() { return { tileLayer: Object } }

   initialize() {
     this.leaflet = L.map(this.mapTarget)
   }
 }
```

There are a few overlapping mechanisms in-play here that make this all
possible, and are worth emphasizing:

1.  Our YAML file read into the `Rails.configuration.x.leaflet` value is
    represented by a Ruby `Hash` instance

2.  Action View helpers transform `Hash` instances nested within `data:
    { }` options into HTML-escaped `JSON`

3.  The escaped JSON string is encoded into the
    `[data-leaflet-tile-layer-value]` HTML attribute

4.  Once connected, our `leaflet` Stimulus Controller reads the
    `[data-leaflet-tile-layer-value]` attribute as a `String`, then
    transforms that `String` into an `Object` by passing it to
    [JSON.parse][]

With that declaration in place, our controller gains access to a
`tileLayerValueChanged(value, oldValue)` callback that will fire
whenever the controlled element's `[data-leaflet-tile-layer-value]`
attribute changes. From within that callback, we'll construct an
[L.tileLayer] instance, add it to our map, then make sure it's rendered
at the bottom of map's stack of layers:

```diff
--- a/app/javascript/controllers/leaflet_controller.js
+++ b/app/javascript/controllers/leaflet_controller.js
 import L from "https://cdn.skypack.dev/leaflet@1.6.0"
 import { Controller } from "@hotwired/stimulus"

 export default class extends Controller {
   static get targets() { return [ "map" ] }
   static get values() { return { tileLayer: Object } }

   initialize() {
     this.leaflet = L.map(this.mapTarget)
   }
+
+  tileLayerValueChanged({ templateUrl, ...options }) {
+    const layer = L.tileLayer(templateUrl, options)
+
+    layer.addTo(this.leaflet).bringToBack()
+  }
 }
```

A note about operational security
---

It's worth highlighting the fact that by embedding our configuration
values _directly_ into our HTML and JavaScript code, we're transmitting
them to each client in plain text. That is acceptable in this case,
since the Leaflet configuration doesn't contain any credentials or
secrets.

The `L.TileLayer` initialization process requires a [MapBox token][] as
an argument, which would be transmitted in plain text even if we
declared it elsewhere in our client-side code. Keep this in mind when
considering encoding configuration values with
[Rails.application.config_for][].

[element]: https://stimulus.hotwire.dev/reference/controllers#properties
[Stimulus-powered Targets]: https://stimulus.hotwire.dev/handbook/hello-stimulus#targets-map-important-elements-to-controller-properties
[target]: https://stimulus.hotwire.dev/reference/targets#definitions
[L.Map]: https://leafletjs.com/reference-1.6.0.html#map-example
[initialize]: https://stimulus.hotwired.dev/reference/lifecycle-callbacks#methods
[L.TileLayer]: https://leafletjs.com/reference-1.6.0.html#tilelayer
[OpenStreetMap]: https://www.openstreetmap.org/about
[Rails.application.config_for]: https://edgeapi.rubyonrails.org/classes/Rails/Application.html#method-i-config_for
[custom configuration]: https://edgeguides.rubyonrails.org/configuring.html#custom-configuration
[Stimulus-powered Values]: https://stimulus.hotwire.dev/reference/values
[JSON.parse]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse

Translating `Location` records to map markers
---

Leaflet provides built-in support for translating [GeoJSON][] into a
[GeoJSON Layer][] of map markers through calls to [L.geoJSON][].

We can use the same [Stimulus-powered Values][] plumbing to encode
server-rendered JSON into our `leaflet` controller's HTML element.

First, we'll need to render the JSON. We'll, declare a pair of
[jbuilder][] view files. First, a template file for the
`locations#index` action to represent the set of `Location` records as a
GeoJSON "FeatureCollection":

```ruby
 # app/views/locations/index.json.jbuilder
 json.type "FeatureCollection"
 json.features @locations, partial: "locations/location", as: :location
```

Next, the `locations/location` view partial to transform an individual
`Location` record into GeoJSON:

```ruby
 # app/views/locations/index.json.jbuilder
 json.type "Feature"
 json.geometry do
   json.type "Point"
   json.coordinates location.values_at(:longitude, :latitude)
 end
```

Next, we'll pass the rendered template into our `locations/leaflet`
partial:

```diff
--- a/app/views/locations/index.html.erb
+++ b/app/views/locations/index.html.erb
 <p id="notice"><%= notice %></p>

 <%= render partial: "locations/leaflet", locals: {
+  geo_json_layer: render(template: "locations/index", formats: :json),
   tile_layer: Rails.configuration.x.leaflet,
 } %>

 <section id="locations">
   <h1>Locations</h1>
```

From there, we'll encode it to the element as the
`[data-leaflet-geo-json-layer-value]` attribute:

```diff
--- a/app/views/locations/_leaflet.html.erb
+++ b/app/views/locations/_leaflet.html.erb
 <%= tag.section data: {
   controller: "leaflet",
+  leaflet_geo_json_layer_value: geo_json_layer,
   leaflet_tile_layer_value: tile_layer,
 } do %>
   <h1>Map</h1>

   <article class="w-full h-96" data-leaflet-target="map"></article>
 <% end %>
```

Finally, pass the GeoJSON along to [L.geoJSON][] whenever the `leaflet`
element is [connected][] to the DOM:

```diff
 export default class extends Controller {
   static get targets() { return [ "map" ] }
-  static get values() { return { tileLayer: Object } }
+  static get values() { return { tileLayer: Object, geoJsonLayer: Object } }

   initialize() {
```

With that declaration, the controller gains access to a
`geoJsonLayerValueChanged(value, oldValue)` callback. From within that
callback, we'll create an [L.geoJSON][] instance, add it to the map, and
make sure it's rendered at the top of the map's stack of layers. We'll
also use it to determine the map's initial bounds, zoom, and center
location:

```diff
+++ a/app/javascript/controllers/leaflet_controller.js
+++ b/app/javascript/controllers/leaflet_controller.js
   tileLayerValueChanged({ templateUrl, ...options }) {
     const layer = L.tileLayer(templateUrl, options)

     layer.addTo(this.leaflet).bringToBack()
   }
+
+  geoJsonLayerValueChanged(value) {
+    const layer = L.geoJSON(value)
+
+    layer.addTo(this.leaflet).bringToFront()
+
+    this.leaflet.fitBounds(layer.getBounds())
+  }
 }
```

[MapBox token]: https://leafletjs.com/examples/quick-start/#setting-up-the-map
[GeoJSON]: https://tools.ietf.org/html/rfc7946
[GeoJSON layer]: https://leafletjs.com/reference-1.6.0.html#geojson
[L.tileLayer]: https://leafletjs.com/reference-1.6.0.html#tilelayer
[L.geoJSON]: https://leafletjs.com/reference-1.6.0.html#geojson
[jbuilder]: https://github.com/rails/jbuilder/tree/v2.11.2#jbuilder
[connected]: https://stimulus.hotwire.dev/reference/lifecycle-callbacks#connection
