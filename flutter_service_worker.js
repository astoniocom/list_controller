'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "a4d18f3219cd969554a86e5551ee7ed4",
"assets/AssetManifest.json": "f8023cb9a6a4338deaacc67303fcb727",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "5e4b5cac3f8eafa2c49af1c45247e378",
"assets/lib/examples/actualizing/actualizing_list_controller.dart": "a9541d07c26814b91e5845d6d04bf83f",
"assets/lib/examples/actualizing/actualizing_view.dart": "4cee04449fb20560608fdb8be319ead8",
"assets/lib/examples/animated_list/animated_list_controller.dart": "7d7717d7ec20d2360484614c7a3c2c10",
"assets/lib/examples/animated_list/animated_list_view.dart": "2c85ec6fca2b46fbe7a6f36696f74976",
"assets/lib/examples/async_records_loading/async_records_loading_list_controller.dart": "4a340b05caec74e7c05ff1d61bb05b21",
"assets/lib/examples/async_records_loading/async_records_loading_view.dart": "f702fc00bc20b43b81436307e53d746f",
"assets/lib/examples/basic/basic_list_controller.dart": "6b9dd60908213f034d21a46016e5c408",
"assets/lib/examples/basic/basic_view.dart": "98f8be3bd2c01da39ae0fa47080e0315",
"assets/lib/examples/carousel_slider/carousel_slider_controller.dart": "9de4c662a24ea9d868c0b9908999de72",
"assets/lib/examples/carousel_slider/carousel_slider_view.dart": "0ea142ae39f2dbc49454fa127f5a7504",
"assets/lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_bloc.dart": "0b94dadb93ee6adf3ae41d27f5dc76f9",
"assets/lib/examples/complex_bidirectional_bloc_list/bloc/bidirectional_list_state.dart": "949a2b28abe871becbdb09d5f064f452",
"assets/lib/examples/complex_bidirectional_bloc_list/complex_bidirectional_bloc_list_view.dart": "e877bf369ede6524ef96828eeccd9b3e",
"assets/lib/examples/complex_bloc_list/bloc/complex_list_bloc.dart": "f90cd867155b6647c517ebff93ad36bc",
"assets/lib/examples/complex_bloc_list/complex_bloc_list_view.dart": "be3dd399736596c710650ddfe8d25c13",
"assets/lib/examples/complex_value_notifier_list/complex_value_notifier_list_controller.dart": "ff76c1ee35784c38ed30e6360d07d34c",
"assets/lib/examples/complex_value_notifier_list/complex_value_notifier_list_view.dart": "d7f9230655178120206ef972e5e61e25",
"assets/lib/examples/filtering_keyset_pagination_value_notifier_list/filtering_keyset_pagination_value_notifier_list_controller.dart": "99bb6dea4278d7a6dc09badbca5a7b0f",
"assets/lib/examples/filtering_keyset_pagination_value_notifier_list/filtering_keyset_pagination_value_notifier_list_view.dart": "53194effca3c0e2a01d495be794c1b79",
"assets/lib/examples/filtering_sorting/filtering_sorting_list_controller.dart": "885ef4436a160636ed3342d68fcd46d4",
"assets/lib/examples/filtering_sorting/filtering_sorting_view.dart": "7d5448371ba64aaba078c5fb2afe021c",
"assets/lib/examples/hot_huge_list/hot_huge_list_controller.dart": "ff346427d0836dda5bca2ba64201211d",
"assets/lib/examples/hot_huge_list/hot_huge_list_view.dart": "9bbf67f601874026da23c998d98c69be",
"assets/lib/examples/huge_list/huge_list_controller.dart": "5643aaa7d03aa6640d8a5a640b303731",
"assets/lib/examples/huge_list/huge_list_view.dart": "f8980b66b9464d895a9c0ce16f53d294",
"assets/lib/examples/isolate_loading/isolate_loading_list_controller.dart": "5b6e89245543319404d04d4f7d5d6f5d",
"assets/lib/examples/isolate_loading/isolate_loading_view.dart": "90af4254f52241235936ee2b1d2f7647",
"assets/lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_bloc.dart": "22d3c541a7286d559e64c127d76f681b",
"assets/lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_events.dart": "e710f2f9153f4bf3e5d7659da28cd728",
"assets/lib/examples/keyset_pagination_bloc_list/bloc/keyset_pagination_list_query.dart": "9249cae8b2f40feee42b1ff3f64f6100",
"assets/lib/examples/keyset_pagination_bloc_list/keyset_pagination_bloc_list_view.dart": "515315db7e588574990484d66a1f0e05",
"assets/lib/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_controller.dart": "2db263d1bcb646dd2a65b487f1a92144",
"assets/lib/examples/keyset_pagination_mobx_list/keyset_pagination_mobx_list_view.dart": "194e4ca5b6d4353b18767410dc5adf93",
"assets/lib/examples/keyset_pagination_statefull_widget/keyset_pagination_statefull_widget.dart": "70340dd2eaa205e65a71f00ac3cf63f2",
"assets/lib/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_controller.dart": "1fae8f7dcb7cca845eafbe04cd31c1d6",
"assets/lib/examples/keyset_pagination_value_notifier_list/keyset_pagination_value_notifier_list_view.dart": "12852039dcbfe803c34e5a898a2a7944",
"assets/lib/examples/line_by_line_loading/line_by_line_loading_list_controller.dart": "dea229de793918390c3ad2585494ea88",
"assets/lib/examples/line_by_line_loading/line_by_line_loading_view.dart": "8f366b192c903393b197f0b0f117049b",
"assets/lib/examples/offset_pagination_list/offset_pagination_list_controller.dart": "99de9e3edf639754afad0f1ab3112515",
"assets/lib/examples/offset_pagination_list/offset_pagination_list_view.dart": "99d042d11829741ffc9467f34b0c392f",
"assets/lib/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_controller.dart": "70370ef0451e891733a9fec18824da8e",
"assets/lib/examples/offset_pagination_splitted_list/offset_pagination_splitted_list_view.dart": "e73c952bae3f8056468d5b0882f83209",
"assets/lib/examples/record_tracking/record_tracking_list_controller.dart": "07a3fd708ed62c5638920689faa6582b",
"assets/lib/examples/record_tracking/record_tracking_view.dart": "03f2f91708b511c8fc82d33dd1ae5423",
"assets/lib/examples/related_records_list/related_records_list_controller.dart": "a0c09bb181e0ff008b7d03797ef07ce9",
"assets/lib/examples/related_records_list/related_records_list_view.dart": "cb4aac736fefcbb4ab726da7067f3707",
"assets/lib/examples/repeating_queries/repeating_queries_list_controller.dart": "f449fbef2541e2b3874d25d0abfce616",
"assets/lib/examples/repeating_queries/repeating_queries_view.dart": "a0ee1df7b5f023f4ef3294d354305ef9",
"assets/NOTICES": "f3401b9ff8db8c6bce9bcd5dd5fff9a2",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "47fb35d54a7153a79c02128ce526b8fd",
"/": "47fb35d54a7153a79c02128ce526b8fd",
"main.dart.js": "c7700b438e0335f0eab97f260c84f68a",
"manifest.json": "8836bc035984c10a2b3625e8bfe2a287",
"version.json": "90d31a2aa594b8db9c159c727e579e48"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
