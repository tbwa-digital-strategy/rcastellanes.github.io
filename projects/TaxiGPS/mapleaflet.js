var map = L.map( 'map', {
    center: [40.7260493,-73.9917831],
    zoom: 13
});

L.tileLayer( 'http://{s}.tiles.mapbox.com/v4/rcastellanes.d1bd2cf7/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoicmNhc3RlbGxhbmVzIiwiYSI6IkVRd0dDaVEifQ.EsWXaa4BxE2qtGQ658rXqQ', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">MapBox</a>'
}).addTo( map );

$.get('http://rcastellanes.github.io/data/centroidnewfile.csv', function(data) {
    mapData(data);
});

function mapData(data) {
    var dataset = $.csv.toObjects(data);
    var datasetLength = dataset.length;
    var marker;
    for (var i = 0; i < datasetLength; i++) {
	var currentDataPoint = dataset[i];

	if (!currentDataPoint.BlockHeight || !currentDataPoint.RoadbedDist ||
	    !currentDataPoint.XCoord || !currentDataPoint.YCoord) {
	    continue;
	}

	var maxVal = Math.max(currentDataPoint.BlockHeight, currentDataPoint.RoadbedDist);
	
	var options = {
	    data: {
		'blockHeight': currentDataPoint.BlockHeight,
		'roadbedDist': currentDataPoint.RoadbedDist
	    },
	    chartOptions: {
		'blockHeight': {
		    fillColor: '#9e66ab',
		    minValue: 0,
		    maxValue: maxVal,
		    maxHeight: 20,
		    displayText: function (value) {
			return value.toFixed(2);
		    }
		},
		'roadbedDist': {
		    fillColor: '#79c36a',
		    minValue: 0,
		    maxValue: maxVal,
		    maxHeight: 20,
		    displayText: function (value) {
			return value.toFixed(2);
		    }
		}
	    },
	    weight: 1,
	    color: '#000000'
	}
	
	marker = new L.BarChartMarker(new L.LatLng(currentDataPoint.YCoord,currentDataPoint.XCoord), options);
	map.addLayer(marker);
    }

//    map.on('zoomend', function () {
//	if (map.getZoom() < 15 && map.hasLayer(marker)) {
//	    map.removeLayer(marker);
//	}
//	if (map.getZoom() > 15 && map.hasLayer(marker) == false)
//	{
//	    map.addLayer(marker);
//	}   
//    });
}


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
