var map = L.map( 'map', {
    center: [40.7260493,-73.9917831],
    minZoom: 7,
    zoom: 13
});

L.tileLayer('http://{s}.tiles.mapbox.com/v4/rcastellanes.d1bd2cf7/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">MapBox</a>'
    subdomains: ['otile1','otile2','otile3','otile4']
}).addTo( map );

var myURL = jQuery( 'script[src$="leaf-demo.js"]' ).attr( 'src' ).replace( 'leaf-demo.js', '' );
