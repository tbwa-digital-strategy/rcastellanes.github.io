var map = L.map( 'map', {
    center: [40.7260493,-73.9917831],
    zoom: 13
});

L.tileLayer( 'http://{s}.tiles.mapbox.com/v4/rcastellanes.d1bd2cf7/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoicmNhc3RlbGxhbmVzIiwiYSI6IkVRd0dDaVEifQ.EsWXaa4BxE2qtGQ658rXqQ', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">MapBox</a>'
}).addTo( map );

var options = {
    data: {
        'dataPoint1': Math.random() * 20,
        'dataPoint2': Math.random() * 20
    },
    chartOptions: {
        'dataPoint1': {
            fillColor: '#727272',
            minValue: 0,
            maxValue: 20,
            maxHeight: 20,
            displayText: function (value) {
                return value.toFixed(2);
            }
        },
        'dataPoint2': {
            fillColor: '#79c36a',
            minValue: 0,
            maxValue: 20,
            maxHeight: 20,
            displayText: function (value) {
                return value.toFixed(2);
            }
        }
    },
    weight: 1,
    color: '#000000'
}

var marker = new L.BarChartMarker(new L.LatLng(40.7260493,-73.9917831), options);

map.on('zoomend', function () {
if (map.getZoom() < 15 && map.hasLayer(marker)) {
    map.removeLayer(marker);
}
if (map.getZoom() > 15 && map.hasLayer(marker) == false)
{
    map.addLayer(marker);
}   
});

//var myIcon = L.icon({
//    iconUrl: myURL + 'images/pin24.png',
//   iconRetinaUrl: myURL + 'images/pin48.png',
//    iconSize: [29, 24],
//    iconAnchor: [9, 21],
//    popupAnchor: [0, -14]
//});

//for ( var i=0; i < markers.length; ++i ) 
//{
//   L.marker( [markers[i].lat, markers[i].lng], {icon: myIcon} )
//      .bindPopup( '<a href="' + markers[i].url + '" target="_blank">' + markers[i].name + '</a>' )
//      .addTo( map );
//}
