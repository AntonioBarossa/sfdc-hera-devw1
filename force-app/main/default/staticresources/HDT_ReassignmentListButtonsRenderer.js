function renderComponent(idList, componentName, containerId) {
    var jsonString = idList.replaceAll("[","[\"").replaceAll("]","\"]").replaceAll(", ","\",\"");
    var list = JSON.parse(jsonString);
    console.log("### SELECTED IDs:");
    console.log(list);

    $Lightning.use(
        "c:HDT_LAP_ActivityReassignmentMassive",
        function() {
            $Lightning.createComponent(
                componentName,
                {
                    idList: list
                },
                containerId,
                function(cmp) {
                    console.log("### COMPONENT CREATED");
                }
            );
        }
    );
}