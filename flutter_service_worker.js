'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "d34ff9a29ffee566100aa8dd9bfa4968",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/lib/examples/actualizing/actualizing_list_controller.dart": "949a2c385ab77c8ea3b92b24a0b821fe",
"assets/lib/examples/actualizing/actualizing_view.dart": "6cfb67b7d36750aedf98583b3fb6a3cb",
"assets/lib/examples/async_records_loading/async_records_loading_list_controller.dart": "4a340b05caec74e7c05ff1d61bb05b21",
"assets/lib/examples/async_records_loading/async_records_loading_view.dart": "f702fc00bc20b43b81436307e53d746f",
"assets/lib/examples/basic/basic_list_controller.dart": "6b9dd60908213f034d21a46016e5c408",
"assets/lib/examples/basic/basic_view.dart": "98f8be3bd2c01da39ae0fa47080e0315",
"assets/lib/examples/carousel_slider/carousel_slider_controller.dart": "9de4c662a24ea9d868c0b9908999de72",
"assets/lib/examples/carousel_slider/carousel_slider_view.dart": "0ea142ae39f2dbc49454fa127f5a7504",
"assets/lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_bloc.dart": "a2d0a4503fef50f216350ad5fb189222",
"assets/lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_state.dart": "a02305cfdb4b8e24101a49876bf3f0a2",
"assets/lib/examples/complex_bidirectional_bloc_list/complex_bidirectional_bloc_list_view.dart": "0c40765aa5c184f5d70a42560cff2c15",
"assets/lib/examples/complex_bloc_list/bloc/complex_list_bloc.dart": "8de0f49c6ae8d4691700af9b00bca5bd",
"assets/lib/examples/complex_bloc_list/complex_bloc_list_view.dart": "da13ac092a3547a2f97506e2a9eca45d",
"assets/lib/examples/complex_value_notifier_list/complex_value_notifier_list_controller.dart": "9414854705a51e246d5a4f72b6d70a58",
"assets/lib/examples/complex_value_notifier_list/complex_value_notifier_list_view.dart": "dc51f760ce6ba2cadee0bef86b038a27",
"assets/lib/examples/filtering_sorting/filtering_sorting_list_controller.dart": "885ef4436a160636ed3342d68fcd46d4",
"assets/lib/examples/filtering_sorting/filtering_sorting_view.dart": "7d5448371ba64aaba078c5fb2afe021c",
"assets/lib/examples/hot_huge_list/hot_huge_list_controller.dart": "ff346427d0836dda5bca2ba64201211d",
"assets/lib/examples/hot_huge_list/hot_huge_list_view.dart": "ef7d7e441b5dde8f57e19dfff1cae0a5",
"assets/lib/examples/huge_list/huge_list_controller.dart": "696fc13a61a6eaf02a87ea65ba0671a7",
"assets/lib/examples/huge_list/huge_list_view.dart": "6555e7ff093bc9bb477e9916a18b2db6",
"assets/lib/examples/isolate_loading/isolate_loading_list_controller.dart": "4c2befc25b3a3bf142bea84a1b6e88d7",
"assets/lib/examples/isolate_loading/isolate_loading_view.dart": "90af4254f52241235936ee2b1d2f7647",
"assets/lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_bloc.dart": "48c9ec0816acd9d579c0ceacccd67006",
"assets/lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_events.dart": "e710f2f9153f4bf3e5d7659da28cd728",
"assets/lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_query.dart": "9249cae8b2f40feee42b1ff3f64f6100",
"assets/lib/examples/keyset_pagination_bloc_list/keyset_pagination_bloc_list_view.dart": "515315db7e588574990484d66a1f0e05",
"assets/lib/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_controller.dart": "535597bb41ff23f0495dc708f8da67ce",
"assets/lib/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_view.dart": "194e4ca5b6d4353b18767410dc5adf93",
"assets/lib/examples/keyset_pagination_statefull_widget/keyset_pagination_statefull_widget.dart": "84bac78c9587939469aa6f79f2504d87",
"assets/lib/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_controller.dart": "5c2c078c3b49f462ea5f6380b56d2985",
"assets/lib/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_view.dart": "12852039dcbfe803c34e5a898a2a7944",
"assets/lib/examples/line_by_line_loading/line_by_line_loading_list_controller.dart": "dea229de793918390c3ad2585494ea88",
"assets/lib/examples/line_by_line_loading/line_by_line_loading_view.dart": "8f366b192c903393b197f0b0f117049b",
"assets/lib/examples/offset_pagination_list/offset_pagination_list_controller.dart": "42147f848efe029d9d1837821968aeae",
"assets/lib/examples/offset_pagination_list/offset_pagination_list_view.dart": "99d042d11829741ffc9467f34b0c392f",
"assets/lib/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_controller.dart": "ca8be308ed7b6a96d5d311b6f8bb5e7b",
"assets/lib/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_view.dart": "e73c952bae3f8056468d5b0882f83209",
"assets/lib/examples/record_tracking/record_tracking_list_controller.dart": "07a3fd708ed62c5638920689faa6582b",
"assets/lib/examples/record_tracking/record_tracking_view.dart": "03f2f91708b511c8fc82d33dd1ae5423",
"assets/lib/examples/related_records_list/related_records_list_controller.dart": "20c9ef5fc80e43ffd5d1703a12ff4f2e",
"assets/lib/examples/related_records_list/related_records_list_view.dart": "7d9795fb3f4fececa1014a7f6bb6af39",
"assets/lib/examples/repeating_queries/repeating_queries_list_controller.dart": "e6f02d8d281740746c60d27fbd3c019c",
"assets/lib/examples/repeating_queries/repeating_queries_view.dart": "a0ee1df7b5f023f4ef3294d354305ef9",
"assets/NOTICES": "73190efa2e43b30d09512dbb11428480",
"assets/shaders/ink_sparkle.frag": "c2ec18b2d47b1b20d5bf340603cf91d7",
"canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "123332750080de31e822ace362c2d18b",
"/": "123332750080de31e822ace362c2d18b",
"main.dart.js": "cb6d5489edfcddc9b2e77825ca5b95b8",
"manifest.json": "8836bc035984c10a2b3625e8bfe2a287",
"version.json": "1e98a4f7390d2e9d9ad60c99fb0aff05"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
