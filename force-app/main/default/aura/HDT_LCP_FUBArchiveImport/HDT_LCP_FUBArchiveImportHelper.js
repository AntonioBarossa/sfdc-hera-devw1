({
    CSV2JSON: function (component,csv) {
        var arr = [];
        arr =  csv.split('\n');
        var jsonObj = [];
        for(var i = 0; i < arr.length; i++) {
            var data = arr[i].trim();
            if(data != ''){
                jsonObj.push(data);
            }
        }
        var json = JSON.stringify(jsonObj);
        return json;
    },
})