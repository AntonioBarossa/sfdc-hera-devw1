function ErrorObject(fieldName, errorMessage){//With this object you can set error message on lightning input fields
    this.body = {'output':{'fieldErrors':{}}};
    this.body.output.fieldErrors[fieldName] = [{'message':errorMessage}];
}


const performErrorActions = function(wrp){
    console.log("Test ValidateActions")
    blankFields.call(this, wrp.fieldsToBlank);
    mandateFields.call(this, wrp.mandatoryFields);
}


const blankFields = function(fields){
    fields?.forEach(field=>{
        this.selector(field)?.setErrors(new ErrorObject(field, 'Non puoi valorizzare questo campo'));
    });
}

const mandateFields = function(fields){
    fields?.forEach(field=>{
        const inpField = this.selector(field);
        if(inpField)    inpField.required=true;
    })
}

export {performErrorActions};